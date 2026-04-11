#!/usr/bin/env python3
"""Parse hyprland keybinds.conf and output JSON for KeybindsCheatSheet."""

import json
import os
import re
import sys

KEY_MAP = {
    "Return": "Enter",
    "SPACE": "Space",
    "Tab": "Tab",
    "left": "←",
    "right": "→",
    "up": "↑",
    "down": "↓",
    "mouse_down": "Scroll ↓",
    "mouse_up": "Scroll ↑",
    "mouse:272": "LClick",
    "mouse:273": "RClick",
    "XF86AudioRaiseVolume": "Vol ↑",
    "XF86AudioLowerVolume": "Vol ↓",
    "XF86AudioMute": "Mute",
    "XF86AudioMicMute": "Mic Mute",
    "XF86MonBrightnessUp": "Bri ↑",
    "XF86MonBrightnessDown": "Bri ↓",
    "XF86AudioPlay": "Play/Pause",
    "XF86AudioNext": "Next",
    "XF86AudioPrev": "Prev",
    "XF86AudioStop": "Stop",
}

MOD_MAP = {
    "$mainMod": "Super",
    "SUPER": "Super",
    "SHIFT": "Shift",
    "CTRL": "Ctrl",
    "ALT": "Alt",
}


def parse_mods(mod_str):
    parts = re.split(r"[\s]+", mod_str.strip())
    return [MOD_MAP.get(p, p) for p in parts if p]


def parse_key(key_str):
    k = key_str.strip()
    return KEY_MAP.get(k, k.upper() if len(k) == 1 else k)


def parse_keybinds(filepath):
    sections = []
    current_section = None
    current_desc = None
    seen_group = {}

    with open(filepath) as f:
        for line in f:
            line = line.rstrip()

            if not line or line.startswith("$"):
                continue

            if line.startswith("## "):
                current_section = {"section": line[3:].strip(), "binds": []}
                sections.append(current_section)
                seen_group = {}
                continue

            if line.startswith("# "):
                current_desc = line[2:].strip()
                continue

            m = re.match(r"^bind[a-z]*\s*=\s*(.*?),\s*(.+?),", line)
            if not m or not current_section:
                continue

            mods = parse_mods(m.group(1))
            key = parse_key(m.group(2))

            if not current_desc:
                continue

            group_key = current_desc
            if group_key in seen_group:
                current_desc = None
                continue

            seen_group[group_key] = True

            hint_match = re.search(r"\((.+?)\)", current_desc)
            if hint_match:
                desc_clean = current_desc[: hint_match.start()].strip()
                hint_keys = hint_match.group(1)
                keys = mods + [hint_keys]
            else:
                desc_clean = current_desc
                keys = mods + [key]

            current_section["binds"].append({"keys": keys, "desc": desc_clean})
            current_desc = None

    print(json.dumps(sections))


if __name__ == "__main__":
    conf = os.path.expanduser("~/.config/hypr/keybinds.conf")
    if len(sys.argv) > 1:
        conf = sys.argv[1]
    parse_keybinds(conf)
