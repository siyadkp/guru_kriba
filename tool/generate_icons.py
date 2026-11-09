"""Draws the Guru Kripa emblem (same design as BrandMark in the header) as
the website's favicon and app icons.

Usage:  python3 tool/generate_icons.py      (needs Pillow)

Writes into web/:
  favicon.png               32x32  browser tab
  favicon-192.png           high-resolution tab / shortcut icon
  apple-touch-icon.png      180x180 iPhone/iPad home screen
  icons/Icon-192.png, Icon-512.png                 installed web app
  icons/Icon-maskable-192.png, Icon-maskable-512.png  Android adaptive
"""

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

CHARCOAL = (26, 29, 32, 255)  # AppColors.charcoal  #1A1D20
GOLD = (201, 164, 106, 255)   # AppColors.warmAccent #C9A46A
WHITE = (255, 255, 255, 255)
SUPERSAMPLE = 8

WEB = Path(__file__).resolve().parent.parent / "web"


def emblem(size: int, *, background: str, mark_scale: float) -> Image.Image:
    """background: 'rounded' (app icon), 'square' (full bleed) or 'none'."""
    s = size * SUPERSAMPLE
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    if background == "rounded":
        d.rounded_rectangle([0, 0, s - 1, s - 1], radius=s * 0.22, fill=CHARCOAL)
    elif background == "square":
        d.rectangle([0, 0, s - 1, s - 1], fill=CHARCOAL)

    c = s / 2
    r = s / 2 * mark_scale  # emblem radius

    # Soft warm glow behind the star.
    glow = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse(
        [c - r * 0.55, c - r * 0.55, c + r * 0.55, c + r * 0.55],
        fill=(201, 164, 106, 70),
    )
    img.alpha_composite(glow.filter(ImageFilter.GaussianBlur(r * 0.22)))
    d = ImageDraw.Draw(img)

    # Outer ring.
    ring_r = r * 0.94
    d.ellipse(
        [c - ring_r, c - ring_r, c + ring_r, c + ring_r],
        outline=WHITE,
        width=max(1, round(r * 0.07)),
    )

    # Twelve house dots.
    dot_r = r * 0.05
    for i in range(12):
        a = i * math.pi / 6
        x, y = c + math.cos(a) * r * 0.74, c + math.sin(a) * r * 0.74
        d.ellipse([x - dot_r, y - dot_r, x + dot_r, y + dot_r],
                  fill=(255, 255, 255, 165))

    # Gold four-point star.
    pts = []
    for i in range(8):
        a = -math.pi / 2 + i * math.pi / 4
        rr = r * 0.5 if i % 2 == 0 else r * 0.14
        pts.append((c + math.cos(a) * rr, c + math.sin(a) * rr))
    d.polygon(pts, fill=GOLD)

    return img.resize((size, size), Image.LANCZOS)


def main() -> None:
    (WEB / "icons").mkdir(exist_ok=True)
    outputs = {
        # Small sizes: emblem fills more of the tile so it stays legible.
        "favicon.png": emblem(32, background="rounded", mark_scale=0.9),
        "favicon-192.png": emblem(192, background="rounded", mark_scale=0.82),
        # iOS rounds the corners itself, so give it a full square.
        "apple-touch-icon.png": emblem(180, background="square", mark_scale=0.72),
        "icons/Icon-192.png": emblem(192, background="rounded", mark_scale=0.8),
        "icons/Icon-512.png": emblem(512, background="rounded", mark_scale=0.8),
        # Maskable: Android may crop to a circle — keep the emblem inside
        # the central safe zone (radius 40% of the icon).
        "icons/Icon-maskable-192.png": emblem(192, background="square", mark_scale=0.62),
        "icons/Icon-maskable-512.png": emblem(512, background="square", mark_scale=0.62),
    }
    for name, image in outputs.items():
        image.save(WEB / name, optimize=True)
        print(f"wrote web/{name}")


if __name__ == "__main__":
    main()
