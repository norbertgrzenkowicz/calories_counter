#!/usr/bin/env python3
"""Generate Yapper app icon - food scanner app"""
import math
import os
from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024

def lerp_color(c1, c2, t):
    return tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(3))

def create_icon(size=SIZE):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Background gradient: dark navy to vibrant teal-blue
    bg = Image.new("RGB", (size, size))
    bg_draw = ImageDraw.Draw(bg)
    top_color = (15, 23, 42)      # #0F172A - dark slate
    bot_color = (6, 95, 70)       # #065F46 - emerald dark
    for y in range(size):
        t = y / size
        r = int(top_color[0] + (bot_color[0] - top_color[0]) * t)
        g = int(top_color[1] + (bot_color[1] - top_color[1]) * t)
        b = int(top_color[2] + (bot_color[2] - top_color[2]) * t)
        bg_draw.line([(0, y), (size, y)], fill=(r, g, b))

    # Paste background
    img.paste(bg, (0, 0))
    draw = ImageDraw.Draw(img)

    cx, cy = size // 2, size // 2

    # --- Plate / circle ---
    plate_r = int(size * 0.30)
    plate_color = (255, 255, 255, 230)
    draw.ellipse(
        [cx - plate_r, cy - plate_r, cx + plate_r, cy + plate_r],
        fill=(255, 255, 255, 200)
    )

    # Inner plate ring
    inner_r = int(plate_r * 0.82)
    draw.ellipse(
        [cx - inner_r, cy - inner_r, cx + inner_r, cy + inner_r],
        fill=(240, 240, 240, 220)
    )

    # --- Fork (left of plate center) ---
    fork_x = cx - int(size * 0.075)
    fork_top = cy - int(size * 0.20)
    fork_bot = cy + int(size * 0.22)
    fork_color = (34, 197, 94)   # bright green #22C55E
    lw = max(4, size // 64)

    # Fork handle
    draw.rectangle(
        [fork_x - lw, cy, fork_x + lw, fork_bot],
        fill=fork_color
    )
    # Fork neck (connecting tines to handle)
    draw.rectangle(
        [fork_x - lw, fork_top + int(size * 0.09), fork_x + lw, cy],
        fill=fork_color
    )
    # Fork tines (3 tines)
    tine_w = max(2, size // 128)
    tine_h = int(size * 0.09)
    for offset in [-int(size * 0.025), 0, int(size * 0.025)]:
        draw.rectangle(
            [fork_x + offset - tine_w, fork_top,
             fork_x + offset + tine_w, fork_top + tine_h],
            fill=fork_color
        )

    # --- Knife (right of plate center) ---
    knife_x = cx + int(size * 0.075)
    knife_color = (34, 197, 94)

    # Knife blade
    draw.rectangle(
        [knife_x - lw, fork_top, knife_x + lw, cy + int(size * 0.05)],
        fill=knife_color
    )
    # Knife handle
    draw.rectangle(
        [knife_x - lw * 1.5, cy + int(size * 0.05),
         knife_x + lw * 1.5, fork_bot],
        fill=knife_color
    )

    # --- Scan / AI indicator: small camera icon top-right ---
    cam_size = int(size * 0.18)
    cam_x = cx + int(size * 0.26)
    cam_y = cy - int(size * 0.30)
    cam_bg_r = int(cam_size * 0.6)

    # Camera badge background
    draw.ellipse(
        [cam_x - cam_bg_r, cam_y - cam_bg_r, cam_x + cam_bg_r, cam_y + cam_bg_r],
        fill=(251, 146, 60)  # orange #FB923C
    )

    # Camera body
    cam_body_w = int(cam_size * 0.7)
    cam_body_h = int(cam_size * 0.5)
    draw.rounded_rectangle(
        [cam_x - cam_body_w // 2, cam_y - cam_body_h // 2,
         cam_x + cam_body_w // 2, cam_y + cam_body_h // 2],
        radius=int(cam_size * 0.1),
        fill=(255, 255, 255)
    )
    # Camera lens
    lens_r = int(cam_size * 0.18)
    draw.ellipse(
        [cam_x - lens_r, cam_y - lens_r, cam_x + lens_r, cam_y + lens_r],
        fill=(251, 146, 60)
    )
    lens_inner_r = int(cam_size * 0.10)
    draw.ellipse(
        [cam_x - lens_inner_r, cam_y - lens_inner_r,
         cam_x + lens_inner_r, cam_y + lens_inner_r],
        fill=(255, 255, 255)
    )
    # Camera viewfinder bump
    bump_w = int(cam_size * 0.2)
    bump_h = int(cam_size * 0.12)
    draw.rounded_rectangle(
        [cam_x - bump_w // 2, cam_y - cam_body_h // 2 - bump_h,
         cam_x + bump_w // 2, cam_y - cam_body_h // 2],
        radius=int(cam_size * 0.05),
        fill=(255, 255, 255)
    )

    # Radial vignette using gaussian-blurred dark overlay
    vignette = Image.new("L", (size, size), 0)
    v_draw = ImageDraw.Draw(vignette)
    margin = int(size * 0.12)
    v_draw.ellipse([margin, margin, size - margin, size - margin], fill=255)
    vignette = vignette.filter(ImageFilter.GaussianBlur(radius=size // 6))
    vignette_rgba = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    dark_layer = Image.new("RGBA", (size, size), (0, 0, 10, 120))
    vignette_rgba.paste(dark_layer, mask=Image.eval(vignette, lambda x: 255 - x))
    img = Image.alpha_composite(img.convert("RGBA"), vignette_rgba)

    return img.convert("RGB")


def resize_for_ios(base_img, sizes_map, output_dir):
    """Resize base image to all required iOS sizes."""
    for filename, (w, h) in sizes_map.items():
        resized = base_img.resize((w, h), Image.LANCZOS)
        out_path = os.path.join(output_dir, filename)
        resized.save(out_path, "PNG", optimize=True)
        print(f"  Saved {w}x{h} -> {filename}")


if __name__ == "__main__":
    print("Generating Yapper app icon...")
    icon = create_icon(SIZE)

    output_dir = "flutter_app/ios/Runner/Assets.xcassets/AppIcon.appiconset"

    # iOS sizes required
    ios_sizes = {
        "Icon-App-20x20@1x.png": (20, 20),
        "Icon-App-20x20@2x.png": (40, 40),
        "Icon-App-20x20@3x.png": (60, 60),
        "Icon-App-29x29@1x.png": (29, 29),
        "Icon-App-29x29@2x.png": (58, 58),
        "Icon-App-29x29@3x.png": (87, 87),
        "Icon-App-40x40@1x.png": (40, 40),
        "Icon-App-40x40@2x.png": (80, 80),
        "Icon-App-40x40@3x.png": (120, 120),
        "Icon-App-60x60@2x.png": (120, 120),
        "Icon-App-60x60@3x.png": (180, 180),
        "Icon-App-76x76@1x.png": (76, 76),
        "Icon-App-76x76@2x.png": (152, 152),
        "Icon-App-83.5x83.5@2x.png": (167, 167),
        "Icon-App-1024x1024@1x.png": (1024, 1024),
    }

    resize_for_ios(icon, ios_sizes, output_dir)

    # Android sizes
    android_sizes = {
        "flutter_app/android/app/src/main/res/mipmap-mdpi/ic_launcher.png": (48, 48),
        "flutter_app/android/app/src/main/res/mipmap-hdpi/ic_launcher.png": (72, 72),
        "flutter_app/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png": (96, 96),
        "flutter_app/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png": (144, 144),
        "flutter_app/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png": (192, 192),
    }
    for path, (w, h) in android_sizes.items():
        resized = icon.resize((w, h), Image.LANCZOS)
        resized.save(path, "PNG", optimize=True)
        print(f"  Saved Android {w}x{h} -> {path}")

    print("\nDone. Icon generation complete.")
