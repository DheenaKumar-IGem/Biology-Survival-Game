"""Generates original, copyright-free, seamlessly-looping ambient music tracks
for the in-game jukebox.

Everything here is synthesized from scratch (Python stdlib only), so the output
is original work with no third-party copyright. Each track is a calm ambient
pad (drone + soft harmonics with a slow tremolo) plus a sparse, gently-decaying
pluck melody.

Seamless looping trick: every oscillator frequency is quantized so it completes
a WHOLE number of cycles over the loop length, so the waveform phase is
continuous at the wrap point (no click). Melody notes are only placed where
their short decay finishes before the loop boundary, so they're silent there.

Run:  python tools/generate_music.py
Output: assets/audio/music/*.wav
"""

import array
import math
import os
import wave

SR = 22050  # sample rate (ambient pads don't need 44.1k; keeps the web build lean)
OUT_DIR = os.path.join("assets", "audio", "music")

TWO_PI = 2 * math.pi


def quantized(freq, length):
    """Frequency nudged so it completes an integer number of cycles over
    `length` seconds -> phase is continuous at the loop point."""
    cycles = max(1, round(freq * length))
    return cycles / length


def render(length, root, harmonics, lfo_hz, melody, bpm,
           drone_amp=0.20, mel_amp=0.16, decay=1.0):
    n = int(SR * length)
    out = [0.0] * n

    # --- Pad: drone + harmonics, all loop-quantized ------------------------
    voices = [(quantized(root, length), drone_amp, False)]
    for mult, amp in harmonics:
        voices.append((quantized(root * mult, length), amp, True))
    qlfo = quantized(lfo_hz, length)

    for i in range(n):
        t = i / SR
        trem = 0.5 + 0.5 * math.sin(TWO_PI * qlfo * t)
        s = 0.0
        for f, amp, use_trem in voices:
            a = amp * (0.55 + 0.45 * trem) if use_trem else amp
            s += a * math.sin(TWO_PI * f * t)
        out[i] = s

    # --- Melody: sparse decaying plucks ------------------------------------
    if melody:
        step = 60.0 / bpm  # one note slot per beat
        t0 = 0.0
        idx = 0
        while t0 + decay <= length:
            note = melody[idx % len(melody)]
            if note is not None:
                f = quantized(note, length)
                start = int(t0 * SR)
                for j in range(int(decay * SR)):
                    if start + j >= n:
                        break
                    tt = j / SR
                    env = math.exp(-tt * 4.0)
                    # absolute-time phase keeps it continuous at the loop wrap
                    out[start + j] += mel_amp * env * math.sin(
                        TWO_PI * f * (t0 + tt))
            idx += 1
            t0 += step

    # --- Normalize + soft clip ---------------------------------------------
    peak = max(1e-6, max(abs(x) for x in out))
    gain = 0.92 / peak if peak > 0.92 else 1.0
    return [math.tanh(x * gain) for x in out]


def write_wav(name, samples):
    path = os.path.join(OUT_DIR, name)
    data = array.array("h", (int(max(-1.0, min(1.0, s)) * 32767) for s in samples))
    with wave.open(path, "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data.tobytes())
    print(f"  wrote {path}  ({len(samples) / SR:.0f}s, {len(data) * 2 // 1024} KB)")


# Note frequencies
A2, C3, E3, A3, C4, D4, E4, G4, A4 = 110.0, 130.81, 164.81, 220.0, 261.63, 293.66, 329.63, 392.0, 440.0
C2_, G2_, C3b, G3_, C4b, D4b, E4b, G4b = 65.41, 98.0, 130.81, 196.0, 261.63, 293.66, 329.63, 392.0
E2_, B2_, E3b, B3_, E4c, Gs4 = 82.41, 123.47, 164.81, 246.94, 329.63, 415.30

TRACKS = {
    # Calm default: warm A-minor pad, soft pentatonic plucks.
    "bloodstream_drift.wav": dict(
        length=28, root=A2, harmonics=[(1.5, 0.12), (2.0, 0.09), (1.2, 0.06)],
        lfo_hz=0.07, bpm=58, decay=1.2,
        melody=[A3, None, C4, None, E4, None, D4, None, None, None, A3, None],
    ),
    # Gentle, slightly brighter C-major drift.
    "immune_calm.wav": dict(
        length=26, root=C3b, harmonics=[(1.5, 0.11), (2.0, 0.08), (1.25, 0.06)],
        lfo_hz=0.05, bpm=64, decay=1.1,
        melody=[C4b, None, E4b, None, G4b, None, None, D4b, None, None],
    ),
    # Minimal, darker ambient drone with rare bell tones.
    "deep_current.wav": dict(
        length=30, root=E2_, harmonics=[(1.5, 0.12), (2.0, 0.08)],
        lfo_hz=0.04, bpm=50, decay=1.6, mel_amp=0.12,
        melody=[E4c, None, None, None, B3_, None, None, None, Gs4, None, None, None, None, None],
    ),
}


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    print(f"Synthesizing {len(TRACKS)} tracks into {OUT_DIR} ...")
    for name, cfg in TRACKS.items():
        write_wav(name, render(**cfg))
    print("done.")


if __name__ == "__main__":
    main()
