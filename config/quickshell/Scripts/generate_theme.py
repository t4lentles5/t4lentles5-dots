#!/usr/bin/env python3
import json
import os
import subprocess
import sys


def rgb_to_hsl(r, g, b):
    r_pct = r / 255.0
    g_pct = g / 255.0
    b_pct = b / 255.0
    max_c = max(r_pct, g_pct, b_pct)
    min_c = min(r_pct, g_pct, b_pct)
    l = (max_c + min_c) / 2.0
    if max_c == min_c:
        h = s = 0.0
    else:
        d = max_c - min_c
        s = d / (2.0 - max_c - min_c) if l > 0.5 else d / (max_c + min_c)
        if max_c == r_pct:
            h = (g_pct - b_pct) / d + (6.0 if g_pct < b_pct else 0.0)
        elif max_c == g_pct:
            h = (b_pct - r_pct) / d + 2.0
        else:
            h = (r_pct - g_pct) / d + 4.0
        h /= 6.0
    return h * 360.0, s, l


def hue_distance(h1, h2):
    d = abs(h1 - h2) % 360
    return 360 - d if d > 180 else d


def clamp_rgb(val):
    return max(0, min(255, int(val)))


def to_hex(r, g, b):
    return f"#{r:02x}{g:02x}{b:02x}"


def force_hsl(h, s, l, target_s, target_l):
    s = max(target_s, s)
    c = (1.0 - abs(2.0 * target_l - 1.0)) * s
    x = c * (1.0 - abs((h / 60.0) % 2.0 - 1.0))
    m = target_l - c / 2.0
    if 0 <= h < 60:
        r, g, b = c, x, 0
    elif 60 <= h < 120:
        r, g, b = x, c, 0
    elif 120 <= h < 180:
        r, g, b = 0, c, x
    elif 180 <= h < 240:
        r, g, b = 0, x, c
    elif 240 <= h < 300:
        r, g, b = x, 0, c
    else:
        r, g, b = c, 0, x
    return to_hex(
        clamp_rgb((r + m) * 255), clamp_rgb((g + m) * 255), clamp_rgb((b + m) * 255)
    )


def get_chroma(color_obj):
    return (
        max(color_obj["r"], color_obj["g"], color_obj["b"])
        - min(color_obj["r"], color_obj["g"], color_obj["b"])
    ) / 255.0


def color_distance(c1, c2):
    r1, g1, b1 = int(c1[1:3], 16), int(c1[3:5], 16), int(c1[5:7], 16)
    r2, g2, b2 = int(c2[1:3], 16), int(c2[3:5], 16), int(c2[5:7], 16)
    return (r1 - r2) ** 2 + (g1 - g2) ** 2 + (b1 - b2) ** 2


def main():
    if len(sys.argv) < 2:
        print("Usage: generate_theme.py <image_path>")
        sys.exit(1)

    image_path = sys.argv[1]
    if not os.path.exists(image_path):
        print(f"Error: image not found: {image_path}")
        sys.exit(1)

    # 1. Determine if the wallpaper is dark or light using ImageMagick mean brightness
    try:
        cmd_mean = [
            "magick",
            image_path + "[0]",
            "-colorspace",
            "gray",
            "-format",
            "%[fx:mean]",
            "info:",
        ]
        res_mean = subprocess.run(
            cmd_mean,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=True,
        )
        out_clean = res_mean.stdout.strip()
        val = out_clean.split()[0] if out_clean else "0.2"
        import re

        match = re.search(r"[0-9\.]+", val)
        if match:
            brightness = float(match.group(0))
        else:
            brightness = 0.2
    except Exception as e:
        print("Error getting image mean, falling back to dark:", e)
        brightness = 0.2

    is_dark = brightness <= 0.4
    palette = "dark" if is_dark else "light"

    # 2. Run wallust with the appropriate palette option
    try:
        cmd = ["wallust", "run", "-s", "-p", palette, "--print-scheme", image_path]
        result = subprocess.run(
            cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True
        )
    except subprocess.CalledProcessError as e:
        print("Error running wallust:", e.stderr)
        sys.exit(1)

    hex_colors = []
    for line in result.stdout.splitlines():
        line = line.strip()
        if line.startswith("#") and (len(line) == 7 or len(line) == 9):
            hex_colors.append(line[:7].lower())

    if len(hex_colors) < 16:
        print(f"Error: wallust returned only {len(hex_colors)} colors, expected 16.")
        sys.exit(1)

    # 3. Extract extra colors from ImageMagick histogram to get a rich sample and pixel counts
    import re

    histogram_colors = {}
    try:
        cmd_magick = [
            "magick",
            image_path + "[0]",
            "-resize",
            "100x100",
            "-colors",
            "32",
            "-format",
            "%c",
            "histogram:info:",
        ]
        res_magick = subprocess.run(
            cmd_magick,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=True,
        )
        for line in res_magick.stdout.splitlines():
            m = re.search(r"(\d+):\s*\(.*?\)\s*(#[0-9a-fA-F]{6})", line)
            if m:
                count = int(m.group(1))
                hex_c = m.group(2).lower()
                histogram_colors[hex_c] = histogram_colors.get(hex_c, 0) + count
    except Exception as e:
        print("Warning: failed to extract colors from ImageMagick histogram:", e)

    # 4. Merge and deduplicate, keeping wallust colors first (since color 0, 8, 15 are base choices)
    seen = set()
    unique_hex = []
    for c in hex_colors:
        if c not in seen:
            seen.add(c)
            unique_hex.append(c)
    for c in histogram_colors.keys():
        if c not in seen:
            seen.add(c)
            unique_hex.append(c)

    # Convert all to HSL and assign pixel counts
    color_objs = []
    for hex_c in unique_hex:
        r = int(hex_c[1:3], 16)
        g = int(hex_c[3:5], 16)
        b = int(hex_c[5:7], 16)
        h, s, l = rgb_to_hsl(r, g, b)

        # Get pixels from histogram
        if hex_c in histogram_colors:
            pixels = histogram_colors[hex_c]
        else:
            if histogram_colors:
                closest_hex = min(
                    histogram_colors.keys(), key=lambda hc: color_distance(hc, hex_c)
                )
                pixels = histogram_colors[closest_hex]
            else:
                pixels = 1

        color_objs.append(
            {
                "hex": hex_c,
                "r": r,
                "g": g,
                "b": b,
                "h": h,
                "s": s,
                "l": l,
                "pixels": pixels,
            }
        )

    # Base colors
    bg_color = color_objs[0]
    fg_color = color_objs[min(15, len(color_objs) - 1)]
    muted_color = color_objs[min(8, len(color_objs) - 1)]

    # Accent candidates (all colors except bg/fg to prevent bg bleeding into accents)
    accent_candidates = [
        c for c in color_objs if c["hex"] not in [bg_color["hex"], fg_color["hex"]]
    ]
    if not accent_candidates:
        accent_candidates = color_objs

    # Calculate ratios and classify dominant theme
    total_colorful_pixels = sum(
        c["pixels"] for c in color_objs if get_chroma(c) >= 0.08
    )
    total_neutral_pixels = sum(c["pixels"] for c in color_objs if get_chroma(c) < 0.08)
    total_pixels = total_colorful_pixels + total_neutral_pixels
    colorful_pixel_ratio = (
        total_colorful_pixels / total_pixels if total_pixels > 0 else 0.0
    )

    is_dominantly_colorful = colorful_pixel_ratio >= 0.15

    # Find most frequent colorful candidate
    colorful_candidates = [c for c in color_objs if get_chroma(c) >= 0.08]
    if colorful_candidates:
        dominant_cand = max(colorful_candidates, key=lambda c: c["pixels"])
        dominant_hue = dominant_cand["h"]
        dominant_sat = dominant_cand["s"]
    else:
        dominant_cand = None
        dominant_hue = 0.0
        dominant_sat = 0.0

    # Determine if monochromatic (single hue family or grayscale)
    is_monochromatic = True
    if is_dominantly_colorful:
        # Check if there's any OTHER colorful hue family with significant presence
        other_hues = [
            c
            for c in accent_candidates
            if get_chroma(c) >= 0.08 and hue_distance(c["h"], dominant_hue) > 45
        ]
        for c in other_hues:
            if total_colorful_pixels > 0 and (
                c["pixels"] >= 0.10 * total_colorful_pixels
            ):
                is_monochromatic = False
                break

    generated = {}

    if is_monochromatic:
        # Monochromatic generation: ONLY use the top 2-3 most frequent colors
        sorted_by_pixels = sorted(color_objs, key=lambda c: c["pixels"], reverse=True)
        top_colors = sorted_by_pixels[:3]

        colorful_top = [c for c in top_colors if get_chroma(c) >= 0.08]
        if colorful_top:
            primary_accent = max(colorful_top, key=get_chroma)
        else:
            primary_accent = top_colors[0]

        is_grayscale_theme = get_chroma(primary_accent) < 0.08

        if is_grayscale_theme:
            # Grayscale layouts
            bg_val = force_hsl(0, 0.0, bg_color["l"], 0.0, 0.04 if is_dark else 0.92)
            bg_sec_val = force_hsl(
                0, 0.0, bg_color["l"], 0.0, 0.08 if is_dark else 0.85
            )
            bg_ter_val = force_hsl(
                0, 0.0, bg_color["l"], 0.0, 0.12 if is_dark else 0.78
            )

            fg_val = force_hsl(0, 0.0, fg_color["l"], 0.0, 0.92 if is_dark else 0.12)
            muted_val = force_hsl(
                0, 0.0, muted_color["l"], 0.0, 0.35 if is_dark else 0.60
            )

            accent_color = force_hsl(0, 0.0, 0.0, 0.0, 0.95 if is_dark else 0.05)
            accent_secondary_color = force_hsl(0, 0.0, 0.0, 0.0, 0.50)

            # Map terminal colors to grayscale
            lightness_targets = {
                "red": 0.65 if is_dark else 0.20,
                "yellow": 0.80 if is_dark else 0.40,
                "green": 0.70 if is_dark else 0.15,
                "cyan": 0.75 if is_dark else 0.35,
                "blue": 0.60 if is_dark else 0.10,
                "purple": 0.85 if is_dark else 0.30,
                "orange": 0.78 if is_dark else 0.25,
                "pink": 0.83 if is_dark else 0.45,
            }
            for name, target_l in lightness_targets.items():
                generated[name] = force_hsl(0, 0.0, 0.0, 0.0, target_l)
        else:
            # Color monochromatic theme (all backgrounds, accents, and terminal slots use primary_accent)
            bg_s = max(0.10, min(0.20, primary_accent["s"] * 0.5))
            bg_val = force_hsl(
                primary_accent["h"],
                bg_s,
                bg_color["l"],
                bg_s,
                0.04 if is_dark else 0.92,
            )
            bg_sec_val = force_hsl(
                primary_accent["h"],
                bg_s * 1.2,
                bg_color["l"],
                bg_s * 1.2,
                0.08 if is_dark else 0.85,
            )
            bg_ter_val = force_hsl(
                primary_accent["h"],
                bg_s * 1.4,
                bg_color["l"],
                bg_s * 1.4,
                0.12 if is_dark else 0.78,
            )

            fg_val = force_hsl(
                primary_accent["h"],
                primary_accent["s"] * 0.2,
                fg_color["l"],
                0.0,
                0.92 if is_dark else 0.12,
            )
            muted_val = force_hsl(
                primary_accent["h"],
                primary_accent["s"] * 0.3,
                muted_color["l"],
                0.0,
                0.35 if is_dark else 0.60,
            )

            accent_color = force_hsl(
                primary_accent["h"],
                primary_accent["s"],
                primary_accent["l"],
                0.50,
                0.60 if is_dark else 0.45,
            )
            accent_secondary_color = force_hsl(
                primary_accent["h"],
                primary_accent["s"] * 0.8,
                primary_accent["l"],
                0.40,
                0.50 if is_dark else 0.55,
            )

            # Map all terminal colors to primary_accent's hue and saturation
            lightness_targets = {
                "red": 0.65 if is_dark else 0.20,
                "yellow": 0.80 if is_dark else 0.40,
                "green": 0.70 if is_dark else 0.15,
                "cyan": 0.75 if is_dark else 0.35,
                "blue": 0.60 if is_dark else 0.10,
                "purple": 0.85 if is_dark else 0.30,
                "orange": 0.78 if is_dark else 0.25,
                "pink": 0.83 if is_dark else 0.45,
            }
            for name, target_l in lightness_targets.items():
                generated[name] = force_hsl(
                    primary_accent["h"], primary_accent["s"], 0.0, 0.40, target_l
                )

        generated.update(
            {"bg": bg_val, "bgSecondary": bg_sec_val, "fg": fg_val, "muted": muted_val}
        )
    else:
        # Colorful wallpaper theme: full hue mapping
        bg_s = max(0.10, min(0.20, dominant_sat * 0.5))
        bg_val = force_hsl(
            dominant_hue, bg_s, bg_color["l"], bg_s, 0.04 if is_dark else 0.92
        )
        bg_ter_val = force_hsl(
            dominant_hue,
            bg_s * 1.4,
            bg_color["l"],
            bg_s * 1.4,
            0.12 if is_dark else 0.78,
        )

        other_candidates = []
        for c in accent_candidates:
            if get_chroma(c) >= 0.08 and hue_distance(c["h"], dominant_hue) > 45:
                if total_colorful_pixels > 0 and (
                    c["pixels"] >= 0.10 * total_colorful_pixels
                ):
                    other_candidates.append(c)

        if other_candidates:
            chosen_other = max(other_candidates, key=lambda c: c["pixels"])
            bg_sec_s = max(0.08, min(0.18, chosen_other["s"] * 0.4))
            bg_sec_val = force_hsl(
                chosen_other["h"],
                bg_sec_s,
                bg_color["l"],
                bg_sec_s,
                0.08 if is_dark else 0.85,
            )
        else:
            bg_sec_val = force_hsl(
                dominant_hue,
                bg_s * 1.2,
                bg_color["l"],
                bg_s * 1.2,
                0.08 if is_dark else 0.85,
            )

        fg_val = force_hsl(
            fg_color["h"], fg_color["s"], fg_color["l"], 0.0, 0.92 if is_dark else 0.12
        )
        muted_val = force_hsl(
            muted_color["h"],
            muted_color["s"],
            muted_color["l"],
            0.0,
            0.35 if is_dark else 0.60,
        )

        accent1_cand = max(accent_candidates, key=get_chroma)
        different_hue_candidates = [
            c for c in accent_candidates if hue_distance(c["h"], accent1_cand["h"]) > 45
        ]
        if different_hue_candidates:
            accent2_cand = max(different_hue_candidates, key=get_chroma)
        else:
            remaining = [c for c in accent_candidates if c != accent1_cand]
            accent2_cand = max(remaining, key=get_chroma) if remaining else accent1_cand

        accent_color = force_hsl(
            accent1_cand["h"],
            accent1_cand["s"],
            accent1_cand["l"],
            0.50,
            0.60 if is_dark else 0.45,
        )
        accent_secondary_color = force_hsl(
            accent2_cand["h"],
            accent2_cand["s"],
            accent2_cand["l"],
            0.50,
            0.60 if is_dark else 0.45,
        )

        generated.update(
            {"bg": bg_val, "bgSecondary": bg_sec_val, "fg": fg_val, "muted": muted_val}
        )

        # Map terminal colors to closest actual hues in the wallpaper
        target_hues = {
            "red": 0,
            "yellow": 60,
            "green": 120,
            "cyan": 180,
            "blue": 240,
            "purple": 300,
        }
        search_candidates = (
            colorful_candidates if colorful_candidates else accent_candidates
        )
        for name, target_h in target_hues.items():
            best_c = min(
                search_candidates, key=lambda c: hue_distance(c["h"], target_h)
            )
            dist = hue_distance(best_c["h"], target_h)
            is_neutral = get_chroma(best_c) < 0.08
            if is_neutral or dist > 60:
                generated[name] = force_hsl(
                    target_h, 0.10, best_c["l"], 0.08, 0.62 if is_dark else 0.46
                )
            else:
                generated[name] = force_hsl(
                    best_c["h"],
                    best_c["s"],
                    best_c["l"],
                    0.50,
                    0.62 if is_dark else 0.46,
                )

        for name, target_h in [("orange", 30), ("pink", 330)]:
            best_c = min(
                search_candidates, key=lambda c: hue_distance(c["h"], target_h)
            )
            dist = hue_distance(best_c["h"], target_h)
            is_neutral = get_chroma(best_c) < 0.08
            if is_neutral or dist > 60:
                generated[name] = force_hsl(
                    target_h, 0.10, best_c["l"], 0.08, 0.62 if is_dark else 0.46
                )
            else:
                generated[name] = force_hsl(
                    best_c["h"],
                    best_c["s"],
                    best_c["l"],
                    0.50,
                    0.62 if is_dark else 0.46,
                )

    # Save to quickshell cache
    home = os.path.expanduser("~")
    cache_dir = os.path.join(home, ".cache", "quickshell")
    os.makedirs(cache_dir, exist_ok=True)

    # Always save to wallpaper_colorscheme.json
    wallpaper_generated = dict(generated)
    wallpaper_generated["name"] = "Wallpaper Theme"
    wallpaper_generated["generateFromWallpaper"] = True

    wallpaper_file = os.path.join(cache_dir, "wallpaper_colorscheme.json")
    with open(wallpaper_file, "w") as f:
        json.dump(wallpaper_generated, f, indent=2)

    # Check if we should overwrite the active colorscheme.json
    should_write_active = True
    active_file = os.path.join(cache_dir, "colorscheme.json")
    if os.path.exists(active_file):
        try:
            with open(active_file, "r") as f:
                curr_data = json.load(f)
                should_write_active = curr_data.get("generateFromWallpaper", False)
        except Exception:
            pass

    if should_write_active:
        with open(active_file, "w") as f:
            json.dump(wallpaper_generated, f, indent=2)
        print(
            f"Success: Generated {'dark' if is_dark else 'light'} colorscheme.json and wallpaper_colorscheme.json"
        )
    else:
        print(
            f"Success: Generated {'dark' if is_dark else 'light'} wallpaper_colorscheme.json (active colorscheme preserved)"
        )


if __name__ == "__main__":
    main()
