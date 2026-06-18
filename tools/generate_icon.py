"""Generates the app launcher icon source art with no third-party deps.

Produces two 1024x1024 PNGs under assets/branding/:
  - app_icon.png             opaque, full background + cell (iOS/web/windows/legacy)
  - app_icon_foreground.png  transparent background, padded cell (Android adaptive)

Art: a glowing white/platinum immune cell (matching the in-game avatar) with a
gold detection rim on a deep tissue-blue radial field, echoing the saliva-scanner
loading screen. Pure stdlib (math/zlib/struct) PNG writer.
"""

import math
import os
import struct
import zlib

S = 1024
CX = CY = S / 2.0
MAXR = S * 0.70  # background gradient extent

EDGE = (8, 16, 26)        # deep navy
CENTER = (22, 48, 70)     # tissue blue
CORE = (246, 250, 255)    # avatar white
CELL_EDGE = (198, 223, 245)
GOLD = (255, 209, 102)    # #FFD166
GLOW = (150, 210, 255)
NUC = (150, 178, 205)     # nucleus blue-gray
TICKS = (0.0, math.pi / 2, math.pi, -math.pi / 2)  # reticle tick angles


def clamp(v, lo=0.0, hi=1.0):
    return lo if v < lo else hi if v > hi else v


def smooth(e0, e1, x):
    if e0 == e1:
        return 0.0 if x < e0 else 1.0
    t = clamp((x - e0) / (e1 - e0))
    return t * t * (3 - 2 * t)


def lerp(a, b, t):
    return (a[0] + (b[0] - a[0]) * t,
            a[1] + (b[1] - a[1]) * t,
            a[2] + (b[2] - a[2]) * t)


def render(radius, foreground):
    r_cell = radius
    hx = CX - r_cell * 0.34
    hy = CY - r_cell * 0.34
    nx = CX + r_cell * 0.15  # nucleus center (offset from the highlight)
    ny = CY + r_cell * 0.10
    nuc_r = r_cell * 0.5
    raw = bytearray()
    for y in range(S):
        raw.append(0)  # PNG filter type 0 (None) per scanline
        dyc = y - CY
        dyc2 = dyc * dyc
        for x in range(S):
            dxc = x - CX
            d = math.sqrt(dxc * dxc + dyc2)

            if foreground:
                r = g = b = 0.0
                a = 0.0
            else:
                bt = smooth(0, MAXR, d)
                r, g, b = lerp(CENTER, EDGE, bt)
                a = 255.0

            # Soft glow halo around the cell.
            gw = clamp(1.0 - d / (r_cell * 2.05))
            gw = gw * gw * 0.55
            if gw > 0:
                r += (GLOW[0] - r) * gw
                g += (GLOW[1] - g) * gw
                b += (GLOW[2] - b) * gw
                if foreground:
                    a = max(a, gw * 255.0)

            if d < r_cell + 2:
                # Cell body + upper-left highlight.
                ct = smooth(0, r_cell, d)
                cc = lerp(CORE, CELL_EDGE, ct)
                dxh = x - hx
                dyh = y - hy
                hd = math.sqrt(dxh * dxh + dyh * dyh)
                hl = clamp(1.0 - hd / (r_cell * 0.95))
                hl = hl * hl * 0.6
                cc = lerp(cc, (255, 255, 255), hl)
                cov = smooth(r_cell + 1.2, r_cell - 1.2, d)
                r += (cc[0] - r) * cov
                g += (cc[1] - g) * cov
                b += (cc[2] - b) * cov
                if foreground:
                    a = max(a, cov * 255.0)

                # Faint nucleus so it reads as a cell, not a pearl/moon.
                ndx = x - nx
                ndy = y - ny
                nd = math.sqrt(ndx * ndx + ndy * ndy)
                if nd < nuc_r:
                    namt = smooth(nuc_r, nuc_r * 0.18, nd) * 0.4 * cov
                    r += (NUC[0] - r) * namt
                    g += (NUC[1] - g) * namt
                    b += (NUC[2] - b) * namt

                # Gold detection rim.
                rim = smooth(r_cell * 0.88, r_cell * 0.95, d) * \
                    smooth(r_cell + 1.0, r_cell * 0.965, d)
                if rim > 0:
                    k = rim * 0.9
                    r += (GOLD[0] - r) * k
                    g += (GOLD[1] - g) * k
                    b += (GOLD[2] - b) * k
                    if foreground:
                        a = max(a, rim * 255.0)
            elif d < r_cell * 1.36:
                # Gold scanner-reticle ticks around the cell (detection motif).
                rad = smooth(r_cell * 1.12, r_cell * 1.17, d) * \
                    smooth(r_cell * 1.36, r_cell * 1.30, d)
                if rad > 0:
                    ang = math.atan2(dyc, dxc)
                    halfw = (r_cell * 0.05) / d
                    best = 0.0
                    for tk in TICKS:
                        da = abs(((ang - tk + math.pi) % (2 * math.pi)) - math.pi)
                        ti = smooth(halfw, halfw * 0.3, da)
                        if ti > best:
                            best = ti
                    amt = best * rad * 0.92
                    if amt > 0:
                        r += (GOLD[0] - r) * amt
                        g += (GOLD[1] - g) * amt
                        b += (GOLD[2] - b) * amt
                        if foreground:
                            a = max(a, amt * 255.0)

            raw.append(int(clamp(r, 0, 255)))
            raw.append(int(clamp(g, 0, 255)))
            raw.append(int(clamp(b, 0, 255)))
            raw.append(int(clamp(a, 0, 255)))
    return bytes(raw)


def write_png(path, raw):
    def chunk(typ, data):
        return (struct.pack(">I", len(data)) + typ + data +
                struct.pack(">I", zlib.crc32(typ + data) & 0xFFFFFFFF))

    ihdr = struct.pack(">IIBBBBB", S, S, 8, 6, 0, 0, 0)  # 8-bit RGBA
    idat = zlib.compress(raw, 9)
    with open(path, "wb") as f:
        f.write(b"\x89PNG\r\n\x1a\n")
        f.write(chunk(b"IHDR", ihdr))
        f.write(chunk(b"IDAT", idat))
        f.write(chunk(b"IEND", b""))


def main():
    os.makedirs("assets/branding", exist_ok=True)
    write_png("assets/branding/app_icon.png", render(S * 0.285, False))
    # Smaller cell so it survives Android adaptive-icon masking (safe zone).
    write_png("assets/branding/app_icon_foreground.png", render(S * 0.235, True))
    print("Generated assets/branding/app_icon.png + app_icon_foreground.png")


if __name__ == "__main__":
    main()
