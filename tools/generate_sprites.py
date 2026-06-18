"""Generates the experimental pixel-art sprite pack with no third-party deps.

Outputs to assets/images/:
  player.png, enemy_<id>.png (one per enemy archetype), biome_<id>.png (x3).

These are deliberately low-resolution so they read as crisp pixel art when the
game scales them up with FilterQuality.none. They are original "programmer
pixel-art" - recognizable, category-colored shapes - and can be replaced by a
nicer hand-drawn pack later (same filenames). Pure stdlib PNG writer.
"""

import math
import os
import struct
import zlib


def hx(s):
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16))


def ci(v):
    return 0 if v < 0 else 255 if v > 255 else int(v)


def shade(c, f):
    return (ci(c[0] * f), ci(c[1] * f), ci(c[2] * f))


def mix(a, b, t):
    return (ci(a[0] + (b[0] - a[0]) * t),
            ci(a[1] + (b[1] - a[1]) * t),
            ci(a[2] + (b[2] - a[2]) * t))


DARK = (10, 14, 20)
def outline(c): return mix(c, DARK, 0.55)
def hi(c): return mix(c, (255, 255, 255), 0.5)
def sh(c): return shade(c, 0.68)

INNATE = hx('5DE0FF')
ANTIBODY = hx('B388FF')
CYTOTOXIC = hx('FF6E6E')

# Realistic organism body colors. Immune category is conveyed by a ring drawn
# around the sprite at render time (see MobComponent._drawCategoryRing), so the
# bodies themselves can use lifelike colors.
C_VIRUS = hx('9156D6')     # purple, classic virus illustration
C_BACTERIA = hx('5FB85A')  # green rod
C_FUNGUS = hx('D9663B')    # red-orange mushroom cap
C_PARASITE = hx('CF8FAE')  # mauve protozoan
C_CANCER = hx('D86B6B')    # fleshy red dysplastic cell
C_VESICLE = hx('D8C87A')   # pale gold vesicle
C_STROMAL = hx('C99878')   # tan spindle cell
C_MUCIN = hx('9DB8C9')     # blue-grey mucus
C_DECOY = hx('B8C0C8')     # faint grey decoy


class Img:
    def __init__(self, w, h):
        self.w = w
        self.h = h
        self.px = [[(0, 0, 0, 0) for _ in range(w)] for _ in range(h)]

    def set(self, x, y, c, a=255):
        x = int(round(x))
        y = int(round(y))
        if not (0 <= x < self.w and 0 <= y < self.h):
            return
        if a >= 255:
            self.px[y][x] = (c[0], c[1], c[2], 255)
        else:
            bg = self.px[y][x]
            t = a / 255.0
            self.px[y][x] = (ci(bg[0] + (c[0] - bg[0]) * t),
                             ci(bg[1] + (c[1] - bg[1]) * t),
                             ci(bg[2] + (c[2] - bg[2]) * t),
                             max(bg[3], a))

    def disc(self, cx, cy, r, c, a=255):
        for y in range(int(cy - r - 1), int(cy + r + 2)):
            for x in range(int(cx - r - 1), int(cx + r + 2)):
                if (x - cx) ** 2 + (y - cy) ** 2 <= r * r:
                    self.set(x, y, c, a)

    def ring(self, cx, cy, r, w, c, a=255):
        for y in range(int(cy - r - 1), int(cy + r + 2)):
            for x in range(int(cx - r - 1), int(cx + r + 2)):
                d = math.hypot(x - cx, y - cy)
                if r - w <= d <= r:
                    self.set(x, y, c, a)


def body(img, cx, cy, R, base, specular=True, alpha=255):
    for y in range(int(cy - R - 2), int(cy + R + 2)):
        for x in range(int(cx - R - 2), int(cx + R + 2)):
            dx = x - cx
            dy = y - cy
            d = math.hypot(dx, dy)
            if d <= R:
                if d > R - 1.3:
                    col = outline(base)
                else:
                    t = (dx + dy) / (R * 2)
                    col = hi(base) if t < -0.22 else (sh(base) if t > 0.3 else base)
                img.set(x, y, col, alpha)
    if specular:
        img.disc(cx - R * 0.34, cy - R * 0.34, max(1, R * 0.16), (255, 255, 255),
                 200 if alpha >= 255 else 130)


# --- enemy archetypes (operate on a SIZE x SIZE grid) ---

def a_spiky(img, cx, cy, R, base):
    # Knobbed surface spikes -> the iconic "virus" corona.
    spike_len = max(2, int(R * 0.5))
    for k in range(12):
        ang = 2 * math.pi * k / 12
        for t in range(0, spike_len):
            r = R - 1 + t
            img.set(cx + math.cos(ang) * r, cy + math.sin(ang) * r, outline(base))
        kr = R - 1 + spike_len
        img.disc(cx + math.cos(ang) * kr, cy + math.sin(ang) * kr,
                 max(1.5, R * 0.13), hi(base))
    body(img, cx, cy, R * 0.82, base)
    img.ring(cx, cy, R * 0.82, 1, outline(base))
    img.disc(cx, cy, R * 0.3, sh(base))


def a_rod(img, cx, cy, R, base):
    # Rod (bacillus) with whip-like flagella tails.
    L = R * 0.5
    rr = R * 0.72
    for fi, off in enumerate((-rr * 0.5, 0.0, rr * 0.5)):
        for t in range(0, int(R * 1.3)):
            fx = cx + L + rr + t
            fy = cy + off + math.sin(t * 0.5 + fi) * (R * 0.18)
            img.set(fx, fy, sh(base))
    for y in range(int(cy - rr - 2), int(cy + rr + 2)):
        for x in range(int(cx - L - rr - 2), int(cx + L + rr + 2)):
            px = min(max(x, cx - L), cx + L)
            d = math.hypot(x - px, y - cy)
            if d <= rr:
                img.set(x, y, outline(base) if d > rr - 1.2 else base)
    img.disc(cx - L * 0.5, cy - rr * 0.35, rr * 0.24, hi(base))
    img.disc(cx + L * 0.35, cy, rr * 0.18, sh(base))
    img.disc(cx - L * 0.1, cy + rr * 0.2, rr * 0.15, sh(base))


def a_mushroom(img, cx, cy, R, base):
    stem = (236, 223, 196)
    for y in range(int(cy), int(cy + R + 2)):
        ty = (y - cy) / (R + 2)
        hw = R * 0.28 * (1 + ty * 0.35)
        for x in range(int(cx - hw), int(cx + hw) + 1):
            img.set(x, y, mix(stem, DARK, 0.4) if abs(x - cx) > hw - 1 else stem)
    for y in range(int(cy - R - 2), int(cy) + 2):
        for x in range(int(cx - R - 2), int(cx + R + 2)):
            dx = (x - cx) / R
            dy = (y - cy) / (R * 0.82)
            d = math.hypot(dx, dy)
            if d <= 1.0 and y <= cy + 1:
                col = outline(base) if d > 0.9 else (hi(base) if dy < -0.45 else base)
                img.set(x, y, col)
    for (sx, sy, sr) in ((-0.42, -0.42, 0.13), (0.32, -0.5, 0.1),
                         (0.02, -0.2, 0.09), (0.52, -0.18, 0.08)):
        img.disc(cx + sx * R, cy + sy * R, sr * R + 1, (246, 234, 210))


def a_protozoan(img, cx, cy, R, base):
    for t in range(0, int(R * 1.0)):
        fx = cx + math.sin(t * 0.4) * (R * 0.22)
        fy = cy + R * 0.7 + t
        img.set(fx, fy, sh(base))
    for y in range(int(cy - R - 2), int(cy + R + 2)):
        for x in range(int(cx - R - 2), int(cx + R + 2)):
            dx = (x - cx) / (R * 0.72)
            ny = (y - cy) / R
            w = 1.0 - max(0.0, ny) * 0.5
            d = math.hypot(dx / max(0.3, w), ny)
            if d <= 1.0:
                img.set(x, y, outline(base) if d > 0.88 else base)
    for nx in (-0.3, 0.3):
        img.disc(cx + nx * R, cy - R * 0.15, R * 0.22, sh(base))
        img.disc(cx + nx * R, cy - R * 0.15, R * 0.1, mix(base, DARK, 0.6))


def a_bumpy(img, cx, cy, R, base):
    body(img, cx, cy, R * 0.82, base)
    for k in range(5):
        ang = 2 * math.pi * k / 5 + 0.4
        img.disc(cx + math.cos(ang) * R * 0.8, cy + math.sin(ang) * R * 0.8,
                 R * 0.26, base)
        img.ring(cx + math.cos(ang) * R * 0.8, cy + math.sin(ang) * R * 0.8,
                 R * 0.26, 1, outline(base))
    img.disc(cx - R * 0.2, cy + R * 0.1, R * 0.13, sh(base))
    img.disc(cx + R * 0.25, cy - R * 0.15, R * 0.1, sh(base))


def a_worm(img, cx, cy, R, base):
    for y in range(int(cy - R - 2), int(cy + R + 2)):
        for x in range(int(cx - R - 2), int(cx + R + 2)):
            dx = (x - cx) / (R * 0.62)
            dy = (y - cy) / (R * 1.05)
            d = math.hypot(dx, dy)
            if d <= 1.0:
                img.set(x, y, outline(base) if d > 0.86 else base)
    img.disc(cx, cy - R * 0.55, R * 0.34, sh(base))  # head
    img.disc(cx - R * 0.12, cy - R * 0.62, R * 0.1, (240, 240, 250))  # eye glint
    img.disc(cx, cy + R * 0.2, R * 0.18, hi(base))


def a_irregular(img, cx, cy, R, base):
    body(img, cx, cy, R * 0.9, base)
    for k, (ox, oy, rr) in enumerate([(0.7, -0.5, 0.34), (-0.6, 0.6, 0.3),
                                      (0.5, 0.65, 0.26)]):
        img.disc(cx + ox * R, cy + oy * R, rr * R, base)
        img.ring(cx + ox * R, cy + oy * R, rr * R, 1, outline(base))
    img.disc(cx + R * 0.15, cy + R * 0.1, R * 0.36, mix(base, DARK, 0.5))  # nucleus
    img.disc(cx - R * 0.25, cy - R * 0.25, R * 0.12, hi(base))


def a_vesicle(img, cx, cy, R, base):
    img.ring(cx, cy, R * 0.82, max(2, R * 0.28), base)
    img.ring(cx, cy, R * 0.82, 1, outline(base))
    img.ring(cx, cy, R * 0.54, 1, outline(base))
    img.disc(cx, cy, R * 0.18, hi(base))


def a_star(img, cx, cy, R, base):
    for k in range(6):
        ang = 2 * math.pi * k / 6
        for t in range(0, int(R)):
            r = R * 0.5 + t
            w = max(1, int((R - t * 0.8) * 0.18))
            for o in range(-w, w + 1):
                px = cx + math.cos(ang) * r - math.sin(ang) * o
                py = cy + math.sin(ang) * r + math.cos(ang) * o
                img.set(px, py, base if t < R * 0.7 else outline(base))
    body(img, cx, cy, R * 0.5, base)
    img.disc(cx, cy, R * 0.18, hi(base))


def a_droplet(img, cx, cy, R, base):
    body(img, cx, cy + R * 0.15, R * 0.85, base, specular=False)
    for y in range(int(cy - R - 2), int(cy)):
        ty = max(0.0, min(1.0, (cy - y) / R))
        halfw = R * 0.7 * (1 - ty) ** 1.4
        if halfw < 0.5:
            continue
        for x in range(int(cx - halfw), int(cx + halfw) + 1):
            edge = abs(x - cx) > halfw - 1.1
            img.set(x, y, outline(base) if edge else base)
    img.disc(cx - R * 0.28, cy - R * 0.1, R * 0.14, (255, 255, 255), 220)  # sheen


def a_ghost(img, cx, cy, R, base):
    body(img, cx, cy, R * 0.78, base, specular=False, alpha=150)
    n = 16
    for k in range(n):
        if k % 2 == 0:
            ang = 2 * math.pi * k / n
            img.set(cx + math.cos(ang) * R * 0.78, cy + math.sin(ang) * R * 0.78,
                    hi(base), 230)
    img.disc(cx, cy, R * 0.16, (255, 255, 255), 150)


def make_enemy(name, archetype, base, size=32):
    img = Img(size, size)
    archetype(img, size / 2.0, size / 2.0, size * 0.40, base)
    save(img, os.path.join('assets', 'images', 'enemy_%s.png' % name))


def make_boss(size=48):
    img = Img(size, size)
    base = hx('C0455A')  # dark, menacing red-magenta
    cx = cy = size / 2.0
    R = size * 0.40
    for k in range(14):
        ang = 2 * math.pi * k / 14
        for t in range(0, max(2, int(R * 0.4))):
            r = R - 1 + t
            img.set(cx + math.cos(ang) * r, cy + math.sin(ang) * r, outline(base))
    a_irregular(img, cx, cy, R * 0.9, base)
    img.ring(cx, cy, R * 1.02, 2, hx('FFD166'), 210)  # gold mutation ring
    img.ring(cx, cy, R * 0.66, 1, hx('FFE08A'), 150)
    save(img, os.path.join('assets', 'images', 'boss.png'))


def make_player(size=28):
    img = Img(size, size)
    core = hx('EDF4FB')
    steel = hx('9DB8D4')
    cx = cy = size / 2.0
    R = size * 0.4
    # two small pseudopods
    img.disc(cx - R * 0.95, cy + R * 0.4, R * 0.28, steel)
    img.disc(cx + R * 0.9, cy - R * 0.5, R * 0.24, steel)
    body(img, cx, cy, R, core)
    img.ring(cx, cy, R, 1.4, steel)
    img.disc(cx + R * 0.18, cy + R * 0.12, R * 0.34, mix(steel, core, 0.3))  # nucleus
    img.ring(cx + R * 0.18, cy + R * 0.12, R * 0.34, 1, steel)
    img.disc(cx - R * 0.3, cy - R * 0.3, R * 0.16, (255, 255, 255))  # specular
    img.disc(cx - R * 0.05, cy + R * 0.05, R * 0.08, hx('FFD166'))  # gold core dot
    save(img, os.path.join('assets', 'images', 'player.png'))


SCATTER = [
    (0.12, 0.18, 9), (0.34, 0.62, 13), (0.6, 0.28, 10), (0.82, 0.7, 14),
    (0.48, 0.18, 7), (0.2, 0.78, 11), (0.7, 0.86, 8), (0.9, 0.22, 9),
    (0.05, 0.5, 7), (0.55, 0.78, 9), (0.78, 0.46, 7), (0.4, 0.4, 6),
]


def make_biome(name, top, mid, bot, cell, accent):
    W, H = 220, 130
    img = Img(W, H)
    for y in range(H):
        ty = y / (H - 1)
        col = mix(top, mid, ty * 2) if ty < 0.5 else mix(mid, bot, (ty - 0.5) * 2)
        for x in range(W):
            img.px[y][x] = (col[0], col[1], col[2], 255)
    for (cxf, cyf, r) in SCATTER:
        img.disc(cxf * W, cyf * H, r, cell, 55)
        img.ring(cxf * W, cyf * H, r, 1, accent, 45)
    # vignette
    for y in range(H):
        for x in range(W):
            dx = (x - W / 2) / (W / 2)
            dy = (y - H / 2) / (H / 2)
            v = (dx * dx + dy * dy)
            if v > 1.0:
                p = img.px[y][x]
                img.px[y][x] = (shade(p, 0.7) + (255,))
    save(img, os.path.join('assets', 'images', 'biome_%s.png' % name))


def encode_png(img):
    raw = bytearray()
    for y in range(img.h):
        raw.append(0)
        for x in range(img.w):
            p = img.px[y][x]
            raw += bytes((p[0], p[1], p[2], p[3]))

    def chunk(t, d):
        return (struct.pack('>I', len(d)) + t + d +
                struct.pack('>I', zlib.crc32(t + d) & 0xFFFFFFFF))

    ihdr = struct.pack('>IIBBBBB', img.w, img.h, 8, 6, 0, 0, 0)
    return (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', ihdr) +
            chunk(b'IDAT', zlib.compress(bytes(raw), 9)) + chunk(b'IEND', b''))


def save(img, path):
    with open(path, 'wb') as f:
        f.write(encode_png(img))


def main():
    os.makedirs(os.path.join('assets', 'images'), exist_ok=True)
    make_player()
    make_boss()
    make_enemy('virus', a_spiky, C_VIRUS)
    make_enemy('bacteria', a_rod, C_BACTERIA)
    make_enemy('fungal_spore', a_mushroom, C_FUNGUS)
    make_enemy('parasite', a_protozoan, C_PARASITE)
    make_enemy('dysplastic_cell', a_irregular, C_CANCER)
    make_enemy('biomarker_vesicle', a_vesicle, C_VESICLE)
    make_enemy('stromal_fibroblast', a_star, C_STROMAL)
    make_enemy('mucin_blob', a_droplet, C_MUCIN)
    make_enemy('decoy_signal', a_ghost, C_DECOY)
    make_biome('bloodstream', hx('03101C'), hx('06243A'), hx('0A3A55'),
               hx('1F5F82'), hx('4FB6E0'))
    make_biome('pancreas', hx('141118'), hx('221C26'), hx('2E2630'),
               hx('3A3340'), hx('6E6478'))
    make_biome('salivary_gland', hx('04140F'), hx('0A2C22'), hx('114133'),
               hx('1F7A5E'), hx('5CD6A8'))
    print('Generated player, 9 enemies, 3 biomes into assets/images/')


if __name__ == '__main__':
    main()
