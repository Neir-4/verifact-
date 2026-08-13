"""
Renders the VERIFACT app launcher icon (three signal bars on a solid navy
field) plus a transparent-background foreground layer for Android adaptive
icons. Same bar geometry as brand_mark.dart / generate_logo.py.

Usage:
    python print/generate_app_icon.py

Output:
    assets/branding/app_icon.png             1024x1024, opaque navy bg -
                                               legacy/iOS icon source
    assets/branding/app_icon_foreground.png   1024x1024, transparent bg,
                                               mark sized to stay inside the
                                               adaptive-icon safe zone
"""

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / "assets" / "branding"

CANVAS = 1024
NAVY = (8, 5, 22)         # #080516
ACCENT = (171, 210, 251)  # #ABD2FB


def draw_mark(draw: ImageDraw.ImageDraw, mark_size: float, color) -> None:
    unit = mark_size / 24
    offset = (CANVAS - mark_size) / 2

    def bar(y: float, w: float, opacity: float) -> None:
        x0 = offset + 2 * unit
        y0 = offset + y * unit
        x1 = x0 + w * unit
        y1 = y0 + 4.4 * unit
        alpha = round(255 * opacity)
        draw.rectangle([x0, y0, x1, y1], fill=(*color, alpha))

    bar(4, 20, 1.0)
    bar(10.2, 13, 0.45)
    bar(16.4, 17, 0.75)


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    # Legacy / iOS icon: solid navy field, mark fills most of the canvas.
    icon = Image.new("RGBA", (CANVAS, CANVAS), (*NAVY, 255))
    draw_mark(ImageDraw.Draw(icon), mark_size=680, color=ACCENT)
    icon_path = OUT_DIR / "app_icon.png"
    icon.save(icon_path)
    print(f"Wrote {icon_path} ({icon.width}x{icon.height})")

    # Adaptive icon foreground: transparent bg, mark kept inside the ~66%
    # safe zone so circular/squircle/rounded-square masks don't clip it.
    fg = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    draw_mark(ImageDraw.Draw(fg), mark_size=460, color=ACCENT)
    fg_path = OUT_DIR / "app_icon_foreground.png"
    fg.save(fg_path)
    print(f"Wrote {fg_path} ({fg.width}x{fg.height})")


if __name__ == "__main__":
    main()
