#!/usr/bin/env python3
"""Generates the procedural placeholder SFX/music WAV files used by
AudioService. Re-run this script (`python3 tools/generate_audio.py`) to
regenerate assets/audio/**/*.wav from scratch.
"""

import math
import struct
import wave
from pathlib import Path

SAMPLE_RATE = 44100
ROOT = Path(__file__).resolve().parent.parent
SFX_DIR = ROOT / "assets" / "audio" / "sfx"
MUSIC_DIR = ROOT / "assets" / "audio" / "music"


def write_wav(path: Path, samples: list[float]) -> None:
    frames = bytearray()
    for s in samples:
        clamped = max(-1.0, min(1.0, s))
        frames += struct.pack("<h", int(clamped * 32767))
    with wave.open(str(path), "wb") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(SAMPLE_RATE)
        f.writeframes(bytes(frames))


def tone(freq_start: float, freq_end: float, duration: float, amp_env) -> list[float]:
    n = int(SAMPLE_RATE * duration)
    out = []
    phase = 0.0
    for i in range(n):
        t = i / SAMPLE_RATE
        progress = i / n
        freq = freq_start + (freq_end - freq_start) * progress
        phase += 2 * math.pi * freq / SAMPLE_RATE
        out.append(math.sin(phase) * amp_env(progress))
    return out


def noise(duration: float, amp_env) -> list[float]:
    import random
    n = int(SAMPLE_RATE * duration)
    return [(random.random() * 2 - 1) * amp_env(i / n) for i in range(n)]


def linear_decay(start: float = 1.0):
    return lambda p: start * (1 - p)


def attack_decay(attack: float, peak: float = 1.0):
    def env(p):
        if p < attack:
            return peak * (p / attack)
        return peak * (1 - (p - attack) / (1 - attack))
    return env


def mix(*tracks: list[float]) -> list[float]:
    length = max(len(t) for t in tracks)
    out = [0.0] * length
    for track in tracks:
        for i, v in enumerate(track):
            out[i] += v
    return out


def concat(*tracks: list[float]) -> list[float]:
    out: list[float] = []
    for t in tracks:
        out.extend(t)
    return out


def main() -> None:
    SFX_DIR.mkdir(parents=True, exist_ok=True)
    MUSIC_DIR.mkdir(parents=True, exist_ok=True)

    # shoot.wav - quick descending laser blip.
    write_wav(SFX_DIR / "shoot.wav", tone(1200, 600, 0.08, linear_decay(0.5)))

    # hit.wav - short noise impact.
    write_wav(SFX_DIR / "hit.wav", noise(0.07, linear_decay(0.6)))

    # death.wav - sine pop sliding down.
    write_wav(SFX_DIR / "death.wav", tone(500, 80, 0.35, linear_decay(0.6)))

    # coin.wav - two-note ascending ding.
    write_wav(
        SFX_DIR / "coin.wav",
        concat(
            tone(880, 880, 0.06, attack_decay(0.1, 0.5)),
            tone(1320, 1320, 0.12, attack_decay(0.05, 0.5)),
        ),
    )

    # mutation.wav - eerie rising wobble.
    n = int(SAMPLE_RATE * 0.5)
    mutation = []
    phase = 0.0
    for i in range(n):
        p = i / n
        base_freq = 280 + 220 * p
        wobble = 1 + 0.04 * math.sin(2 * math.pi * 8 * (i / SAMPLE_RATE))
        phase += 2 * math.pi * base_freq * wobble / SAMPLE_RATE
        env = attack_decay(0.1, 0.45)(p)
        mutation.append(math.sin(phase) * env)
    write_wav(SFX_DIR / "mutation.wav", mutation)

    # round_clear.wav - ascending major arpeggio (C5 E5 G5 C6).
    notes = [523.25, 659.25, 783.99, 1046.50]
    arpeggio = concat(*[tone(f, f, 0.14, attack_decay(0.08, 0.45)) for f in notes])
    write_wav(SFX_DIR / "round_clear.wav", arpeggio)

    # boss_charge.wav - low rumbling growl with amplitude tremor.
    n = int(SAMPLE_RATE * 0.6)
    rumble = []
    phase = 0.0
    for i in range(n):
        p = i / n
        freq = 110 - 60 * p
        phase += 2 * math.pi * freq / SAMPLE_RATE
        tremor = 0.7 + 0.3 * math.sin(2 * math.pi * 18 * (i / SAMPLE_RATE))
        # Square-ish wave for a growl timbre.
        wave_val = 1.0 if math.sin(phase) >= 0 else -1.0
        env = attack_decay(0.05, 0.5)(p)
        rumble.append(wave_val * tremor * env)
    write_wav(SFX_DIR / "boss_charge.wav", rumble)

    # swap.wav - crisp two-note "locked in" confirm for the core weapon swap.
    # Ascending so it reads as positive/ready and is distinct from the
    # descending shoot blip and the coin ding.
    write_wav(
        SFX_DIR / "swap.wav",
        concat(
            tone(600, 600, 0.03, linear_decay(0.5)),
            tone(980, 980, 0.05, attack_decay(0.02, 0.5)),
        ),
    )

    # dash.wav - short airy whoosh: filtered noise over a fast downward sweep.
    write_wav(
        SFX_DIR / "dash.wav",
        mix(
            noise(0.14, linear_decay(0.5)),
            tone(520, 160, 0.14, linear_decay(0.5)),
        ),
    )

    # theme.wav - soft looping ambient track (~8s). A warm sustained pad sits
    # under a gentle arpeggiated melody and a soft rhythmic pulse, so it reads
    # as music rather than a static drone. Everything uses integer numbers of
    # cycles over the loop (or aligns to the loop length) so the end matches the
    # start with no click.
    loop_seconds = 8.0
    n = int(SAMPLE_RATE * loop_seconds)

    def loop_freq(freq: float) -> float:
        # Snap a frequency to the nearest integer number of cycles over the
        # loop so its waveform is seamless across the loop boundary.
        cycles = max(1, round(freq * loop_seconds))
        return cycles / loop_seconds

    # Sustained pad chord (C3 E3 G3 C4) - the existing ambient bed.
    pad_freqs = [loop_freq(f) for f in (130.81, 164.81, 196.00, 261.63)]

    # Arpeggio: one note per beat, cycling a C-major pentatonic figure
    # (C5 E5 G5 E5 A4 G5 E5 C5). 8 steps over the 8s loop = one full bar that
    # repeats cleanly. Each step's pitch is loop-snapped and its soft pluck
    # envelope is fully contained within the step, so steps never click.
    arp_midi = [523.25, 659.25, 783.99, 659.25, 440.00, 783.99, 659.25, 523.25]
    arp_freqs = [loop_freq(f) for f in arp_midi]
    steps = len(arp_midi)
    step_len = loop_seconds / steps  # 1.0s per step

    # Soft rhythmic pulse: a gentle amplitude duck at the start of every step,
    # giving a subtle heartbeat-like groove without being percussive.
    pulses = steps

    theme = []
    for i in range(n):
        t = i / SAMPLE_RATE

        # --- Pad layer ---
        pad = 0.0
        for freq in pad_freqs:
            pad += math.sin(2 * math.pi * freq * t)
        pad /= len(pad_freqs)
        # Slow volume swell over the whole loop for ambience.
        swell = 0.5 + 0.5 * math.sin(2 * math.pi * t / loop_seconds)
        pad *= 0.6 + 0.4 * swell

        # --- Arpeggio layer ---
        step = int(t / step_len) % steps
        step_p = (t - step * step_len) / step_len  # 0..1 within this step
        # Soft pluck: quick attack, gentle decay, silent before the next step.
        pluck = math.sin(math.pi * min(step_p, 1.0)) ** 2
        arp = math.sin(2 * math.pi * arp_freqs[step] * t) * pluck

        # --- Rhythmic pulse (amplitude groove) ---
        pulse_phase = (t * pulses / loop_seconds) % 1.0
        pulse = 0.85 + 0.15 * math.cos(2 * math.pi * pulse_phase)

        sample = (pad * 0.7 + arp * 0.35) * pulse
        theme.append(sample * 0.16)
    write_wav(MUSIC_DIR / "theme.wav", theme)

    print("Generated audio assets in", SFX_DIR, "and", MUSIC_DIR)


if __name__ == "__main__":
    main()
