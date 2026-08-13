"""
Generates two matching 48-card QR decks - Kartu Statement and Kartu Respons -
both keyed S01..S48, encoding just the bare Card ID:

    final cardId = raw.trim().toUpperCase();
    final card = repo?.findById(cardId);

The app only ever looks up by that bare ID against assets/cards.json, so a
scan of S01 behaves identically whether it came off a Statement card or a
Respons card - the two decks share one ID namespace on purpose. What makes
them "Statement" vs "Respons" is which physical card you print each sheet
onto and how you use it at the table (e.g. one shown/uploaded during a turn,
the other scanned to reveal the verdict), not anything encoded differently
in the QR itself.

Usage:
    python print/generate_qr.py

Output (in print/qr-codes/):
    - statement/S01.png ... S48.png   pure QR per card, Kartu Statement deck
    - respons/S01.png ... S48.png     pure QR per card, Kartu Respons deck
                                       (identical payloads to statement/,
                                       just a second printed deck)
    - contact_sheet_statement.png/.pdf   QA-only proof sheet, never printed
                                          onto a card
    - contact_sheet_respons.png/.pdf     same, for the respons deck

The per-card PNGs are pure QR, nothing else. No ID text, and definitely no
FACT/HOAX - the verdict must stay hidden on the physical card and only be
revealed by the app after scanning, or the scan-to-verify mechanic is
pointless (players could just flip the card). If you need the ID readable
on a card for the manual-entry fallback, add it yourself in your card-back
design tool - see _answer_key_DO_NOT_PRINT_ON_CARDS.csv for the ID list.
"""

import json
import math
from pathlib import Path

import qrcode
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
CARDS_JSON = ROOT / "assets" / "cards.json"
OUT_DIR = Path(__file__).resolve().parent / "qr-codes"

QR_BOX_SIZE = 14          # pixels per QR module -> ~530px QR for a typical ID
QR_BORDER = 4              # quiet zone, in modules (keep this - aids scan reliability)
CAPTION_HEIGHT = 60        # only used in the contact sheet, never in the per-card PNGs
FONT_SIZE = 40


def load_font(bold: bool, size: int) -> ImageFont.ImageFont:
    candidates = (
        ["arialbd.ttf", "seguisb.ttf"] if bold else ["arial.ttf", "segoeui.ttf"]
    )
    for name in candidates:
        path = Path("C:/Windows/Fonts") / name
        if path.exists():
            return ImageFont.truetype(str(path), size)
    return ImageFont.load_default()


def make_card_qr(card_id: str) -> Image.Image:
    """Pure QR code, nothing else - no ID text, no FACT/HOAX. This is the
    file meant to go straight onto the printed card back."""
    qr = qrcode.QRCode(
        error_correction=qrcode.constants.ERROR_CORRECT_H,
        box_size=QR_BOX_SIZE,
        border=QR_BORDER,
    )
    qr.add_data(card_id)
    qr.make(fit=True)
    return qr.make_image(fill_color="black", back_color="white").convert("RGB")


def build_contact_sheet(images: list[tuple[str, Image.Image]]) -> Image.Image:
    """QA-only proof sheet with ID captions - never printed onto a card."""
    cols = 8
    rows = math.ceil(len(images) / cols)
    cell_w, cell_h = images[0][1].width, images[0][1].height + CAPTION_HEIGHT
    pad = 20
    sheet_w = cols * cell_w + (cols + 1) * pad
    sheet_h = rows * cell_h + (rows + 1) * pad
    sheet = Image.new("RGB", (sheet_w, sheet_h), "white")
    draw = ImageDraw.Draw(sheet)
    font = load_font(bold=True, size=FONT_SIZE)

    for i, (card_id, img) in enumerate(images):
        col, row = i % cols, i // cols
        x = pad + col * (cell_w + pad)
        y = pad + row * (cell_h + pad)
        sheet.paste(img, (x, y))
        text_w = draw.textlength(card_id, font=font)
        draw.text(
            (x + (img.width - text_w) / 2, y + img.height + (CAPTION_HEIGHT - FONT_SIZE) / 2 - 4),
            card_id,
            fill="black",
            font=font,
        )

    return sheet


def generate_deck(ids: list[str], deck_name: str) -> None:
    deck_dir = OUT_DIR / deck_name
    deck_dir.mkdir(parents=True, exist_ok=True)

    generated: list[tuple[str, Image.Image]] = []
    for card_id in ids:
        img = make_card_qr(card_id)
        img.save(deck_dir / f"{card_id}.png")
        generated.append((card_id, img))

    print(f"Wrote {len(generated)} QR PNGs to {deck_dir}")

    sheet = build_contact_sheet(generated)
    sheet.save(OUT_DIR / f"contact_sheet_{deck_name}.png")
    sheet.save(OUT_DIR / f"contact_sheet_{deck_name}.pdf", "PDF", resolution=150.0)
    print(f"Wrote contact_sheet_{deck_name}.png/.pdf ({sheet.width}x{sheet.height})")


def main() -> None:
    cards = json.loads(CARDS_JSON.read_text(encoding="utf-8"))
    ids = [card["id"] for card in cards]
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    generate_deck(ids, "statement")
    generate_deck(ids, "respons")

    # Internal production reference ONLY - never print this on a card, it's
    # just so whoever assembles the physical decks can double check each QR
    # ended up glued/printed onto the correct card in both decks.
    answer_key = OUT_DIR / "_answer_key_DO_NOT_PRINT_ON_CARDS.csv"
    with answer_key.open("w", encoding="utf-8") as f:
        f.write("id,status,headline\n")
        for card in cards:
            headline = card["headline"].replace(",", ";").replace("\n", " ")
            f.write(f"{card['id']},{card['status']},{headline}\n")
    print(f"Wrote internal QA reference (NOT for printing) to {answer_key}")


if __name__ == "__main__":
    main()
