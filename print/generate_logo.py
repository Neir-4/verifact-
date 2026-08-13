"""
Renders the VERIFACT brand mark (three signal bars) as a transparent PNG,
pixel-matched to lib/theme/brand_mark.dart's _BrandMarkPainter so the native
boot splash and the in-app widget are the same shape.

Usage:
    python print/generate_logo.py

Output:
    assets/branding/verifact_logo.png  (1024x1024, transparent background,
    used as the flutter_native_splash `image`)
"""

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
OUT_PATH = ROOT / "assets" / "branding" / "verifact_logo.png"

CANVAS = 1024
# The mark sits in a 24x24 viewBox in brand_mark.dart; give it generous
# padding so it stays inside Android 12's adaptive-icon safe zone.
MARK_SIZE = 620
ACCENT = (171, 210, 251)  # #ABD2FB


def main() -> None:
    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)

    img = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    unit = MARK_SIZE / 24
    offset = (CANVAS - MARK_SIZE) / 2

    def bar(y: float, w: float, opacity: float) -> None:
        x0 = offset + 2 * unit
        y0 = offset + y * unit
        x1 = x0 + w * unit
        y1 = y0 + 4.4 * unit
        alpha = round(255 * opacity)
        draw.rectangle([x0, y0, x1, y1], fill=(*ACCENT, alpha))

    bar(4, 20, 1.0)
    bar(10.2, 13, 0.45)
    bar(16.4, 17, 0.75)

    img.save(OUT_PATH)
    print(f"Wrote {OUT_PATH} ({img.width}x{img.height})")


if __name__ == "__main__":
    main()
