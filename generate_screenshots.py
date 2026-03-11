#!/usr/bin/env python3
"""Generate placeholder App Store screenshots for Yapper.
These are design mockups showing intended screen layouts.
Replace with real device screenshots before App Store submission.
"""
import os
from PIL import Image, ImageDraw

# iPhone 6.7" (required for App Store)
W, H = 1290, 2796
OUT = "fastlane/screenshots/en-US"
os.makedirs(OUT, exist_ok=True)

BG_DARK = (13, 17, 23)       # #0D1117
ACCENT_GREEN = (34, 197, 94)  # #22C55E
ACCENT_ORANGE = (251, 146, 60) # #FB923C
WHITE = (255, 255, 255)
GRAY = (156, 163, 175)
CARD_BG = (22, 27, 34)       # slightly lighter dark

def make_base(title_line1, title_line2, subtitle):
    """Create a base screenshot frame."""
    img = Image.new("RGB", (W, H), BG_DARK)
    draw = ImageDraw.Draw(img)

    # Status bar area
    draw.rectangle([0, 0, W, 120], fill=(10, 14, 20))

    # Top label strip (gradient-ish)
    for y in range(120, 300):
        t = (y - 120) / 180
        r = int(13 + (22 - 13) * t)
        g = int(17 + (27 - 17) * t)
        b = int(23 + (34 - 23) * t)
        draw.line([(0, y), (W, y)], fill=(r, g, b))

    # Bottom tab bar
    draw.rectangle([0, H - 200, W, H], fill=(10, 14, 20))
    # Tab indicators
    tab_positions = [W // 5, W * 2 // 5, W * 3 // 5, W * 4 // 5]
    tab_labels = ["Home", "Scan", "Log", "Profile"]
    for i, (x, label) in enumerate(zip(tab_positions, tab_labels)):
        color = ACCENT_GREEN if i == 0 else GRAY
        dot_r = 6
        draw.ellipse([x - dot_r, H - 160 - dot_r, x + dot_r, H - 160 + dot_r], fill=color)
        draw.rectangle([x - 60, H - 140, x + 60, H - 128], fill=color if i == 0 else (50, 60, 70))

    return img, draw

def draw_pill(draw, x, y, w, h, color, alpha=None):
    r = h // 2
    draw.rounded_rectangle([x, y, x + w, y + h], radius=r, fill=color)

def screenshot_home():
    img, draw = make_base("Daily Summary", "", "")

    # App name / date header
    draw.rectangle([60, 140, 400, 180], fill=ACCENT_GREEN)  # placeholder text
    draw.rectangle([60, 200, 300, 230], fill=(50, 60, 70))

    # Calorie ring (big circle)
    ring_cx, ring_cy = W // 2, 700
    ring_r = 280
    draw.ellipse([ring_cx - ring_r, ring_cy - ring_r, ring_cx + ring_r, ring_cy + ring_r],
                 fill=(22, 27, 34), outline=(40, 50, 60), width=8)
    # Progress arc simulation: draw thick arc-like chord
    draw.arc([ring_cx - ring_r + 20, ring_cy - ring_r + 20,
              ring_cx + ring_r - 20, ring_cy + ring_r - 20],
             start=-90, end=160, fill=ACCENT_GREEN, width=40)

    # Center text placeholder
    draw.rectangle([ring_cx - 120, ring_cy - 60, ring_cx + 120, ring_cy - 20], fill=(40, 50, 60))
    draw.rectangle([ring_cx - 80, ring_cy + 10, ring_cx + 80, ring_cy + 40], fill=(40, 50, 60))

    # Macro cards row
    card_y = 1060
    card_h = 200
    card_w = (W - 100) // 3
    colors = [ACCENT_GREEN, ACCENT_ORANGE, (99, 102, 241)]
    labels = ["Protein", "Carbs", "Fat"]
    for i, (color, label) in enumerate(zip(colors, labels)):
        cx = 40 + i * (card_w + 20)
        draw.rounded_rectangle([cx, card_y, cx + card_w, card_y + card_h],
                                radius=24, fill=CARD_BG)
        draw.rounded_rectangle([cx + 20, card_y + 20, cx + 60, card_y + 60],
                                radius=8, fill=color)
        draw.rectangle([cx + 20, card_y + 80, cx + card_w - 20, card_y + 110], fill=(40, 50, 60))
        draw.rectangle([cx + 20, card_y + 125, cx + card_w - 40, card_y + 150], fill=(30, 40, 50))

    # Recent meals list
    meal_y = 1320
    for i in range(4):
        row_y = meal_y + i * 160
        draw.rounded_rectangle([40, row_y, W - 40, row_y + 140], radius=16, fill=CARD_BG)
        draw.rounded_rectangle([60, row_y + 20, 160, row_y + 120], radius=12,
                                fill=(30, 40, 50))
        draw.rectangle([180, row_y + 30, 500, row_y + 60], fill=(50, 60, 70))
        draw.rectangle([180, row_y + 75, 380, row_y + 100], fill=(40, 50, 60))
        draw.rectangle([W - 200, row_y + 45, W - 60, row_y + 75], fill=ACCENT_GREEN)

    img.save(f"{OUT}/iPhone_67_01_home.png", "PNG")
    print("Saved: home")

def screenshot_scanner():
    img, draw = make_base("", "", "")
    # Dark camera viewfinder
    draw.rectangle([0, 0, W, H], fill=(5, 5, 5))

    # Viewfinder frame
    vf_margin = 120
    vf_top = 400
    vf_bot = H - 800
    vf_w = W - 2 * vf_margin
    vf_h = vf_bot - vf_top
    # Corner brackets
    corner = 80
    lw = 8
    bracket_color = ACCENT_GREEN
    # TL
    draw.rectangle([vf_margin, vf_top, vf_margin + corner, vf_top + lw], fill=bracket_color)
    draw.rectangle([vf_margin, vf_top, vf_margin + lw, vf_top + corner], fill=bracket_color)
    # TR
    draw.rectangle([vf_margin + vf_w - corner, vf_top, vf_margin + vf_w, vf_top + lw], fill=bracket_color)
    draw.rectangle([vf_margin + vf_w - lw, vf_top, vf_margin + vf_w, vf_top + corner], fill=bracket_color)
    # BL
    draw.rectangle([vf_margin, vf_bot - lw, vf_margin + corner, vf_bot], fill=bracket_color)
    draw.rectangle([vf_margin, vf_bot - corner, vf_margin + lw, vf_bot], fill=bracket_color)
    # BR
    draw.rectangle([vf_margin + vf_w - corner, vf_bot - lw, vf_margin + vf_w, vf_bot], fill=bracket_color)
    draw.rectangle([vf_margin + vf_w - lw, vf_bot - corner, vf_margin + vf_w, vf_bot], fill=bracket_color)

    # Scan line
    scan_y = vf_top + vf_h // 2
    draw.rectangle([vf_margin + 20, scan_y - 2, vf_margin + vf_w - 20, scan_y + 2], fill=ACCENT_GREEN)

    # Simulated food in frame (colored blobs)
    draw.ellipse([300, 900, 800, 1400], fill=(180, 100, 40))
    draw.ellipse([400, 1000, 700, 1200], fill=(220, 160, 80))
    draw.ellipse([200, 1100, 500, 1300], fill=(60, 160, 60))

    # Bottom toolbar
    draw.rectangle([0, H - 500, W, H], fill=(10, 10, 10))
    # Shutter button
    btn_r = 80
    draw.ellipse([W // 2 - btn_r, H - 380 - btn_r, W // 2 + btn_r, H - 380 + btn_r],
                 fill=WHITE)
    draw.ellipse([W // 2 - 60, H - 380 - 60, W // 2 + 60, H - 380 + 60],
                 fill=(220, 220, 220))
    # Mode pills
    for i, label_color in enumerate([(ACCENT_GREEN, True), ((40, 50, 60), False), ((40, 50, 60), False)]):
        px = W // 2 - 220 + i * 220
        draw.rounded_rectangle([px - 80, H - 160, px + 80, H - 100], radius=30,
                                fill=label_color[0])

    img.save(f"{OUT}/iPhone_67_02_scanner.png", "PNG")
    print("Saved: scanner")

def screenshot_analysis():
    img, draw = make_base("", "", "")

    # Header with back nav
    draw.rectangle([0, 0, W, 220], fill=CARD_BG)
    draw.rectangle([60, 80, 140, 110], fill=(50, 60, 70))  # back button
    draw.rectangle([200, 80, 500, 110], fill=(50, 60, 70))  # title

    # Food image placeholder
    draw.rectangle([0, 220, W, 700], fill=(30, 35, 40))
    draw.ellipse([W // 2 - 200, 330, W // 2 + 200, 680], fill=(160, 100, 50))

    # Meal name card
    draw.rounded_rectangle([40, 740, W - 40, 900], radius=20, fill=CARD_BG)
    draw.rectangle([80, 775, 500, 815], fill=(60, 70, 80))
    draw.rectangle([80, 835, 380, 865], fill=(40, 50, 60))

    # Macros grid
    macro_y = 940
    macro_colors = [ACCENT_GREEN, ACCENT_ORANGE, (99, 102, 241), (236, 72, 153)]
    macro_labels = ["Calories", "Protein", "Carbs", "Fat"]
    cols, rows = 2, 2
    cell_w = (W - 80) // 2
    cell_h = 240
    for idx in range(4):
        row, col = divmod(idx, 2)
        cx = 40 + col * (cell_w + 0)
        cy = macro_y + row * (cell_h + 20)
        draw.rounded_rectangle([cx, cy, cx + cell_w - 20, cy + cell_h],
                                radius=20, fill=CARD_BG)
        draw.rounded_rectangle([cx + 20, cy + 20, cx + 80, cy + 80],
                                radius=12, fill=macro_colors[idx])
        draw.rectangle([cx + 20, cy + 100, cx + 180, cy + 140], fill=(50, 60, 70))
        draw.rectangle([cx + 20, cy + 155, cx + cell_w - 60, cy + 185], fill=(40, 50, 60))

    # Add to log button
    btn_y = H - 400
    draw.rounded_rectangle([60, btn_y, W - 60, btn_y + 120], radius=30, fill=ACCENT_GREEN)
    draw.rectangle([W // 2 - 120, btn_y + 42, W // 2 + 120, btn_y + 72], fill=BG_DARK)

    img.save(f"{OUT}/iPhone_67_03_analysis.png", "PNG")
    print("Saved: analysis")

def screenshot_calendar():
    img, draw = make_base("", "", "")

    # Header
    draw.rectangle([0, 0, W, 220], fill=CARD_BG)
    draw.rectangle([W // 2 - 160, 90, W // 2 + 160, 130], fill=(50, 60, 70))
    draw.rectangle([W - 180, 85, W - 60, 135], fill=ACCENT_GREEN)

    # Month header
    cal_y = 260
    draw.rectangle([W // 2 - 200, cal_y, W // 2 + 200, cal_y + 50], fill=(50, 60, 70))

    # Day names row
    day_w = W // 7
    for i in range(7):
        dx = i * day_w + day_w // 2
        draw.rectangle([dx - 30, cal_y + 70, dx + 30, cal_y + 100], fill=(40, 50, 60))

    # Calendar grid
    row_h = 140
    for row in range(5):
        for col in range(7):
            dx = col * day_w + day_w // 2
            dy = cal_y + 130 + row * row_h
            day_num = row * 7 + col + 1
            if day_num <= 31:
                is_today = (day_num == 11)
                has_meal = day_num in [3, 5, 7, 8, 10, 11, 12, 14, 15, 17, 18, 19, 21]
                circle_r = 44
                if is_today:
                    draw.ellipse([dx - circle_r, dy - circle_r, dx + circle_r, dy + circle_r],
                                 fill=ACCENT_GREEN)
                draw.rectangle([dx - 28, dy - 12, dx + 28, dy + 12],
                               fill=WHITE if is_today else (50, 60, 70))
                if has_meal and not is_today:
                    draw.ellipse([dx - 8, dy + 20, dx + 8, dy + 36], fill=ACCENT_GREEN)

    # Selected day meals list
    selected_y = cal_y + 130 + 5 * row_h + 40
    draw.rectangle([60, selected_y, 500, selected_y + 40], fill=(50, 60, 70))
    for i in range(3):
        row_y = selected_y + 60 + i * 160
        draw.rounded_rectangle([40, row_y, W - 40, row_y + 140], radius=16, fill=CARD_BG)
        draw.rounded_rectangle([60, row_y + 20, 160, row_y + 120], radius=12, fill=(30, 40, 50))
        draw.rectangle([180, row_y + 30, 500, row_y + 60], fill=(50, 60, 70))
        draw.rectangle([180, row_y + 75, 380, row_y + 100], fill=(40, 50, 60))
        draw.rectangle([W - 200, row_y + 45, W - 60, row_y + 75], fill=ACCENT_GREEN)

    img.save(f"{OUT}/iPhone_67_04_calendar.png", "PNG")
    print("Saved: calendar")

def screenshot_subscription():
    img, draw = make_base("", "", "")

    # Hero area
    for y in range(H // 2):
        t = y / (H // 2)
        r = int(13 + (6 - 13) * t)
        g = int(17 + (78 - 17) * t)
        b = int(23 + (59 - 23) * t)
        draw.line([(0, y), (W, y)], fill=(r, g, b))

    # App icon in hero
    icon_size = 200
    icx = W // 2
    icy = 400
    draw.ellipse([icx - icon_size, icy - icon_size, icx + icon_size, icy + icon_size],
                 fill=(22, 27, 34))
    draw.ellipse([icx - 120, icy - 120, icx + 120, icy + 120], fill=(30, 40, 50))
    draw.rectangle([icx - 15, icy - 80, icx + 15, icy + 80], fill=ACCENT_GREEN)

    # Title
    draw.rectangle([W // 2 - 280, 680, W // 2 + 280, 730], fill=WHITE)
    draw.rectangle([W // 2 - 200, 755, W // 2 + 200, 795], fill=GRAY)

    # Feature list
    features = [
        "Unlimited food photo analysis",
        "Barcode scanner",
        "Weight tracking & charts",
        "Full meal history",
        "Priority AI analysis",
    ]
    feat_y = 860
    for feat in features:
        draw.ellipse([100, feat_y + 10, 148, feat_y + 58], fill=ACCENT_GREEN)
        draw.rectangle([100, feat_y + 18, 120, feat_y + 48], fill=BG_DARK)  # checkmark
        draw.rectangle([180, feat_y + 18, 180 + len(feat) * 18, feat_y + 48], fill=(50, 60, 70))
        feat_y += 100

    # Pricing cards
    price_y = feat_y + 40
    # Monthly
    draw.rounded_rectangle([40, price_y, W // 2 - 20, price_y + 240], radius=20, fill=CARD_BG)
    draw.rectangle([100, price_y + 40, W // 2 - 60, price_y + 80], fill=(50, 60, 70))
    draw.rectangle([100, price_y + 100, W // 2 - 80, price_y + 140], fill=ACCENT_GREEN)
    draw.rectangle([100, price_y + 160, W // 2 - 100, price_y + 190], fill=(40, 50, 60))

    # Yearly (highlighted)
    draw.rounded_rectangle([W // 2 + 20, price_y, W - 40, price_y + 240], radius=20,
                            fill=ACCENT_GREEN)
    draw.rectangle([W // 2 + 80, price_y + 40, W - 80, price_y + 80], fill=BG_DARK)
    draw.rectangle([W // 2 + 80, price_y + 100, W - 100, price_y + 140], fill=BG_DARK)
    draw.rectangle([W // 2 + 80, price_y + 160, W - 120, price_y + 190], fill=(6, 95, 70))
    # "Best Value" badge
    draw.rounded_rectangle([W * 3 // 4 - 100, price_y - 30, W * 3 // 4 + 100, price_y + 20],
                            radius=15, fill=ACCENT_ORANGE)
    draw.rectangle([W * 3 // 4 - 70, price_y - 18, W * 3 // 4 + 70, price_y + 8],
                   fill=BG_DARK)

    # CTA button
    cta_y = price_y + 300
    draw.rounded_rectangle([60, cta_y, W - 60, cta_y + 120], radius=30, fill=ACCENT_GREEN)
    draw.rectangle([W // 2 - 200, cta_y + 38, W // 2 + 200, cta_y + 78], fill=BG_DARK)

    draw.rectangle([W // 2 - 160, cta_y + 180, W // 2 + 160, cta_y + 210], fill=(40, 50, 60))

    img.save(f"{OUT}/iPhone_67_05_subscription.png", "PNG")
    print("Saved: subscription")


if __name__ == "__main__":
    print("Generating App Store screenshot mockups...")
    screenshot_home()
    screenshot_scanner()
    screenshot_analysis()
    screenshot_calendar()
    screenshot_subscription()
    print(f"\nAll screenshots saved to {OUT}/")
    print("NOTE: Replace these mockups with real device screenshots before App Store submission.")
