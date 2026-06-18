"""Generates original, copyright-free, looping stereo music for the jukebox.

Everything is synthesized from scratch with Python stdlib only. The three
tracks intentionally keep the existing filenames so saved settings and the
asset manifest stay compatible, but the compositions are new:

- bloodstream_drift.wav -> "Serum Skyline"
- immune_calm.wav       -> "Antibody Aurora"
- deep_current.wav      -> "Abyssal Current"

Run:  python tools/generate_music.py
Output: assets/audio/music/*.wav
"""

import array
import math
import os
import wave

SR = 44100
OUT_DIR = os.path.join("assets", "audio", "music")
TWO_PI = 2 * math.pi

NOTE_TO_SEMITONE = {
    "C": 0,
    "C#": 1,
    "Db": 1,
    "D": 2,
    "D#": 3,
    "Eb": 3,
    "E": 4,
    "F": 5,
    "F#": 6,
    "Gb": 6,
    "G": 7,
    "G#": 8,
    "Ab": 8,
    "A": 9,
    "A#": 10,
    "Bb": 10,
    "B": 11,
}


def note(name):
    if name is None:
        return None
    if len(name) == 2:
        pitch, octave = name[0], int(name[1])
    else:
        pitch, octave = name[:2], int(name[2:])
    midi = (octave + 1) * 12 + NOTE_TO_SEMITONE[pitch]
    return 440.0 * (2 ** ((midi - 69) / 12))


def smoothstep(x):
    x = max(0.0, min(1.0, x))
    return x * x * (3.0 - 2.0 * x)


def envelope(t, duration, attack, release, decay=0.0):
    if t < 0.0 or t >= duration:
        return 0.0
    attack_env = smoothstep(t / max(attack, 1e-6))
    release_env = smoothstep((duration - t) / max(release, 1e-6))
    decay_env = math.exp(-t * decay) if decay > 0 else 1.0
    return attack_env * release_env * decay_env


def quantized(freq, length):
    cycles = max(1, round(freq * length))
    return cycles / length


def pan_gains(pan):
    pan = max(-1.0, min(1.0, pan))
    angle = (pan + 1.0) * math.pi / 4.0
    return math.cos(angle), math.sin(angle)


def add_tone(
    left,
    right,
    start,
    duration,
    freq,
    amp,
    pan=0.0,
    attack=0.05,
    release=0.2,
    decay=0.0,
    harmonics=((1.0, 1.0),),
    phase=0.0,
    vibrato_hz=0.0,
    vibrato_depth=0.0,
):
    start_i = max(0, int(start * SR))
    end_i = min(len(left), int((start + duration) * SR))
    lg, rg = pan_gains(pan)
    for i in range(start_i, end_i):
        t = i / SR
        tt = t - start
        env = envelope(tt, duration, attack, release, decay)
        vib = 1.0
        if vibrato_hz > 0 and vibrato_depth > 0:
            vib += vibrato_depth * math.sin(TWO_PI * vibrato_hz * tt)
        sample = 0.0
        for mult, level in harmonics:
            sample += level * math.sin(TWO_PI * freq * mult * vib * tt + phase)
        sample *= amp * env
        left[i] += sample * lg
        right[i] += sample * rg


def add_pad_chord(left, right, start, duration, notes, amp, pan=0.0):
    count = max(1, len(notes))
    for idx, name in enumerate(notes):
        local_pan = pan + (idx - (count - 1) / 2) * 0.18
        add_tone(
            left,
            right,
            start,
            duration,
            note(name),
            amp / count,
            pan=local_pan,
            attack=2.4,
            release=2.7,
            harmonics=((1.0, 1.0), (2.0, 0.20), (3.0, 0.08)),
            phase=idx * 0.73,
            vibrato_hz=0.08 + idx * 0.015,
            vibrato_depth=0.0015,
        )


def add_bell(left, right, start, name, amp, pan, length=2.8):
    add_tone(
        left,
        right,
        start,
        length,
        note(name),
        amp,
        pan=pan,
        attack=0.025,
        release=0.8,
        decay=1.1,
        harmonics=((1.0, 1.0), (2.0, 0.34), (3.0, 0.09)),
    )


def add_soft_bass(left, right, start, name, amp, duration=1.8):
    add_tone(
        left,
        right,
        start,
        duration,
        note(name),
        amp,
        attack=0.045,
        release=0.45,
        decay=0.55,
        harmonics=((1.0, 1.0), (2.0, 0.16)),
    )


def add_breath(left, right, rng_seed, amp=0.012):
    # Deterministic filtered noise for a soft "air" bed, far below the music.
    state = rng_seed
    l_prev = r_prev = 0.0
    for i in range(len(left)):
        state = (1664525 * state + 1013904223) & 0xFFFFFFFF
        noise = ((state / 0xFFFFFFFF) * 2.0 - 1.0) * amp
        l_prev = l_prev * 0.994 + noise * 0.006
        r_prev = r_prev * 0.993 + noise * 0.007
        left[i] += l_prev
        right[i] += r_prev


def add_loop_drone(left, right, length, notes, amp):
    for idx, name in enumerate(notes):
        freq = quantized(note(name), length)
        pan = -0.28 if idx % 2 == 0 else 0.28
        add_tone(
            left,
            right,
            0.0,
            length,
            freq,
            amp / len(notes),
            pan=pan,
            attack=0.01,
            release=0.01,
            harmonics=((1.0, 1.0), (2.0, 0.12)),
            phase=idx * 0.51,
            vibrato_hz=0.04,
            vibrato_depth=0.0008,
        )


def lowpass_pair(left, right, cutoff_hz=5200.0):
    rc = 1.0 / (TWO_PI * cutoff_hz)
    dt = 1.0 / SR
    alpha = dt / (rc + dt)
    out_l, out_r = [], []
    yl = yr = 0.0
    for l, r in zip(left, right):
        yl += alpha * (l - yl)
        yr += alpha * (r - yr)
        out_l.append(yl)
        out_r.append(yr)
    return out_l, out_r


def echo_pair(left, right, delay_s, feedback, mix, cross=0.12):
    delay = int(delay_s * SR)
    out_l = left[:]
    out_r = right[:]
    for i in range(delay, len(left)):
        wet_l = out_l[i - delay] * feedback
        wet_r = out_r[i - delay] * feedback
        out_l[i] += mix * ((1 - cross) * wet_l + cross * wet_r)
        out_r[i] += mix * ((1 - cross) * wet_r + cross * wet_l)
    return out_l, out_r


def apply_effects(left, right, track_length):
    # Render effects over two repeated loops, then keep the second loop so delay
    # and reverb tails are already in steady state at the wrap point.
    l2 = left + left
    r2 = right + right
    l2, r2 = lowpass_pair(l2, r2)
    for delay, feedback, mix, cross in [
        (0.23, 0.34, 0.16, 0.20),
        (0.37, 0.28, 0.12, 0.35),
        (0.61, 0.20, 0.08, 0.50),
    ]:
        l2, r2 = echo_pair(l2, r2, delay, feedback, mix, cross)
    start = int(track_length * SR)
    end = start + len(left)
    return l2[start:end], r2[start:end]


def master(left, right, target_peak=0.68):
    peak = max(1e-6, max(max(abs(x) for x in left), max(abs(x) for x in right)))
    gain = min(5.0, target_peak / peak)
    out_l, out_r = [], []
    for l, r in zip(left, right):
        out_l.append(math.tanh(l * gain) * 0.92)
        out_r.append(math.tanh(r * gain) * 0.92)
    return out_l, out_r


def render_track(cfg):
    length = cfg["length"]
    n = int(length * SR)
    left = [0.0] * n
    right = [0.0] * n
    bar = 60.0 / cfg["bpm"] * 4.0

    add_loop_drone(left, right, length, cfg["drone"], cfg.get("drone_amp", 0.055))
    add_breath(left, right, cfg["seed"], cfg.get("air_amp", 0.008))

    for idx, chord in enumerate(cfg["chords"]):
        start = idx * bar * cfg.get("bars_per_chord", 2)
        duration = bar * cfg.get("bars_per_chord", 2)
        add_pad_chord(
            left,
            right,
            start,
            duration,
            chord,
            cfg.get("pad_amp", 0.16),
            pan=-0.1 if idx % 2 == 0 else 0.1,
        )

    bass_pattern = cfg.get("bass_pattern", [0, 2, 4, 6])
    for idx, root in enumerate(cfg["bass_roots"]):
        chord_start = idx * bar * cfg.get("bars_per_chord", 2)
        for beat in bass_pattern:
            add_soft_bass(
                left,
                right,
                chord_start + beat * (bar / 4.0),
                root,
                cfg.get("bass_amp", 0.05),
            )

    motif = cfg["motif"]
    beat = 60.0 / cfg["bpm"]
    for idx, name in enumerate(motif):
        if name is None:
            continue
        start = idx * beat
        while start < length - 2.8:
            pan = -0.42 + (idx % 5) * 0.21
            add_bell(left, right, start, name, cfg.get("bell_amp", 0.036), pan)
            start += len(motif) * beat

    left, right = apply_effects(left, right, length)
    return master(left, right, cfg.get("target_peak", 0.66))


def write_wav(name, left, right):
    path = os.path.join(OUT_DIR, name)
    frames = array.array("h")
    for l, r in zip(left, right):
        frames.append(int(max(-1.0, min(1.0, l)) * 32767))
        frames.append(int(max(-1.0, min(1.0, r)) * 32767))
    with wave.open(path, "w") as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(frames.tobytes())
    kb = len(frames) * 2 // 1024
    seconds = len(left) / SR
    print(f"  wrote {path} ({seconds:.0f}s stereo, {kb} KB)")


TRACKS = {
    "bloodstream_drift.wav": {
        "title": "Serum Skyline",
        "length": 32,
        "bpm": 60,
        "bars_per_chord": 2,
        "seed": 1297,
        "drone": ["C3", "G3"],
        "chords": [
            ["C4", "E4", "G4", "B4", "D5"],
            ["G3", "B3", "D4", "A4"],
            ["A3", "C4", "E4", "G4"],
            ["F3", "A3", "C4", "E4", "G4"],
        ],
        "bass_roots": ["C2", "G2", "A2", "F2"],
        "motif": ["E5", None, "G5", "D5", None, "B4", "C5", None],
        "pad_amp": 0.15,
        "bass_amp": 0.044,
        "bell_amp": 0.030,
    },
    "immune_calm.wav": {
        "title": "Antibody Aurora",
        "length": 32,
        "bpm": 60,
        "bars_per_chord": 2,
        "seed": 2843,
        "drone": ["E3", "B3"],
        "chords": [
            ["E4", "G#4", "B4", "F#5"],
            ["B3", "E4", "F#4", "A4"],
            ["C#4", "E4", "G#4", "B4"],
            ["A3", "C#4", "E4", "B4"],
        ],
        "bass_roots": ["E2", "B1", "C#2", "A1"],
        "motif": ["B4", "E5", None, "F#5", "G#5", None, "E5", None],
        "pad_amp": 0.135,
        "bass_amp": 0.040,
        "bell_amp": 0.027,
        "air_amp": 0.006,
    },
    "deep_current.wav": {
        "title": "Abyssal Current",
        "length": 32,
        "bpm": 60,
        "bars_per_chord": 2,
        "seed": 3901,
        "drone": ["D2", "A2"],
        "chords": [
            ["D3", "F3", "A3", "C4", "E4"],
            ["Bb2", "D3", "F3", "A3"],
            ["F3", "A3", "C4", "G4"],
            ["C3", "F3", "G3", "Bb3"],
        ],
        "bass_roots": ["D1", "Bb1", "F1", "C2"],
        "motif": ["A4", None, None, "C5", None, "F4", None, None, "E4", None, None, None],
        "pad_amp": 0.14,
        "bass_amp": 0.046,
        "bell_amp": 0.022,
        "air_amp": 0.010,
        "target_peak": 0.62,
    },
}


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    print(f"Synthesizing {len(TRACKS)} new tracks into {OUT_DIR} ...")
    for filename, cfg in TRACKS.items():
        print(f"  rendering {cfg['title']} -> {filename}")
        left, right = render_track(cfg)
        write_wav(filename, left, right)
    print("done.")


if __name__ == "__main__":
    main()
