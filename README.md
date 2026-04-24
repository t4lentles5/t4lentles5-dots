<div align="center">

# t4lentles5 Dotfiles

**Aesthetic Hyprland rice for Arch Linux — dynamic theming, Quickshell widgets, and a polished workflow out of the box.**

<img src="https://res.cloudinary.com/diu2godjy/image/upload/v1776553339/output_ddu2iw.webp" alt="Preview Dark" width="49%" />
<img src="https://res.cloudinary.com/diu2godjy/image/upload/v1777004625/output_ogo7wk.webp" alt="Preview Light" width="49%" />

</div>

---

## ✨ Features

- 🎨 **Dynamic Theming** — switch between 6 color schemes (Default, Tokyo Night, Catppuccin, Gruvbox, Rosé Pine, Kanagawa) with light/dark variants that instantly propagate across **all** apps: Kitty, GTK, Neovim, Yazi, and the bar itself.
- 🖥️ **Quickshell Bar & Widgets** — custom bar with dashboard, app launcher, clipboard history, wallpaper selector, color scheme selector, screenshot tool, keybinds cheat sheet, and notification center.
- 🖼️ **Wallpaper Selector** — browse and apply wallpapers directly from a widget, with separate Dark/Light collections.
- 🔒 **Lock Screen** — `hyprlock` with custom styling.
- ⚡ **Zsh** — configured with Starship prompt, fzf-tab, autosuggestions, syntax highlighting, and history substring search.
- 📝 **Neovim** — full Lua config with lazy.nvim, auto-synced color scheme from the system theme.
- 📁 **Yazi** — TUI file manager with dynamic theme integration.

---

## 🚀 Quick Install

```bash
# Clone this repository (shallow clone to save space and time)
git clone --depth 1 https://github.com/t4lentles5/t4lentles5-dots.git ~/.dotfiles

# Enter the directory
cd ~/.dotfiles

# Give execution permissions to the script and run it
chmod +x install.sh
./install.sh
```

> [!IMPORTANT]
>
> - This script is exclusively designed for **Arch Linux** based distributions (it uses `pacman` natively).
> - **NOTE:** Run the script as your **normal user**. The script will ask for `sudo` permissions on its own when strictly necessary to install system packages.

---

## 🔧 Post-Installation Setup

### 1. Reboot

Once the script finishes, **reboot your computer** to ensure your new `zsh` shell, global variables, themes, and system daemons are fully loaded:

```bash
sudo reboot
```

### 2. Set your profile picture (`.face`)

The Quickshell dashboard displays your user avatar from `~/.face`. Place a **square image** (PNG or JPG, 256×256 recommended) in your home directory:

```bash
# Copy your desired profile picture
cp /path/to/your/avatar.png ~/.face
```

### 3. Set your wallpaper

Wallpapers are stored in `~/Pictures/Wallpapers/` and are organized in `Dark/` and `Light/` sub-folders. You can add your own wallpapers to these directories and use the wallpaper selector widget (`Ctrl + Alt + W`) to apply them.

### 4. Monitor Configuration

The default monitor config is set to auto-detect. If you need custom resolution, refresh rate, or multi-monitor setup, edit:

```bash
~/.config/hypr/monitors.conf
```

Refer to the [Hyprland Wiki — Monitors](https://wiki.hyprland.org/Configuring/Monitors/) for syntax details.

### 5. Restore from Backup

If anything goes wrong, the installer creates a timestamped backup of your previous configuration:

```
~/.dotfiles_backup/<timestamp>/
```

---

## 🎨 Color Schemes

All schemes include both **dark** and **light** variants, instantly switchable via `Ctrl + Alt + C`:

| Scheme      | Dark Variant  | Light Variant   |
| ----------- | ------------- | --------------- |
| Default     | Default       | Default Light   |
| Tokyo Night | Tokyo Night   | Tokyo Night Day |
| Catppuccin  | Mocha         | Latte           |
| Gruvbox     | Gruvbox Dark  | Gruvbox Light   |
| Rosé Pine   | Rose Pine     | Rose Pine Dawn  |
| Kanagawa    | Kanagawa Wave | Kanagawa Lotus  |

When you switch a scheme, the following are updated **in real time**:

- Quickshell bar & all widgets
- Kitty terminal colors
- GTK 3/4 theme (Catppuccin dark ↔ light)
- Neovim color scheme
- Yazi file manager theme

---

## ⌨️ Keybinds

> `SUPER` = Windows/Meta key.

### Applications

| Keybind                 | Action                       |
| ----------------------- | ---------------------------- |
| `SUPER + Enter`         | Open terminal (Kitty)        |
| `SUPER + SHIFT + Enter` | Open floating terminal       |
| `SUPER + E`             | Open file manager (Nautilus) |
| `SUPER + B`             | Open Browser                 |

### Window Management

| Keybind             | Action                        |
| ------------------- | ----------------------------- |
| `SUPER + Q`         | Close active window           |
| `SUPER + SHIFT + M` | Exit Hyprland                 |
| `SUPER + L`         | Lock screen (hyprlock)        |
| `SUPER + W`         | Toggle floating mode          |
| `SUPER + F`         | Toggle fullscreen             |
| `SUPER + P`         | Toggle pseudo-tiling          |
| `SUPER + J`         | Toggle split direction        |
| `SUPER + C`         | Center floating window        |
| `SUPER + SHIFT + P` | Pin window on all workspaces  |
| `SUPER + N`         | Minimize window to scratchpad |
| `SUPER + SHIFT + N` | Restore minimized windows     |

### Quickshell Widgets

| Keybind             | Action                     |
| ------------------- | -------------------------- |
| `SUPER + A`         | Open app launcher          |
| `SUPER + V`         | Open clipboard history     |
| `SUPER + SHIFT + S` | Take screenshot            |
| `SUPER + K`         | Open keybinds cheat sheet  |
| `CTRL + ALT + W`    | Open wallpaper selector    |
| `CTRL + ALT + C`    | Open color scheme selector |

### Navigation

| Keybind                         | Action                     |
| ------------------------------- | -------------------------- |
| `SUPER + ←/→/↑/↓`               | Move focus between windows |
| `SUPER + SHIFT + ←/→/↑/↓`       | Move window position       |
| `SUPER + ALT + ←/→/↑/↓`         | Resize active window       |
| `SUPER + ALT + SHIFT + ←/→/↑/↓` | Swap window with neighbor  |

### Workspaces

| Keybind                  | Action                        |
| ------------------------ | ----------------------------- |
| `SUPER + 1..0`           | Switch to workspace 1–10      |
| `SUPER + SHIFT + 1..0`   | Send window to workspace 1–10 |
| `CTRL + SUPER + ←/→`     | Previous / next workspace     |
| `SUPER + Scroll Up/Down` | Scroll through workspaces     |

---

## 🛠️ Customization

### Adding Wallpapers

Drop images into `~/Pictures/Wallpapers/Dark/` or `~/Pictures/Wallpapers/Light/`, then open the wallpaper selector with `Ctrl + Alt + W`.

### Changing Default Applications

Edit `~/.config/hypr/keybinds.conf` to change which apps are launched by each keybind.

### Adjusting Animations

Tweak animation curves and durations in `~/.config/hypr/animations.conf`.

### Shell Aliases

Common aliases defined in `~/.zshrc`:

| Alias       | Command                        |
| ----------- | ------------------------------ |
| `cat`       | `bat --theme=base16`           |
| `ls`        | `eza --icons -a`               |
| `ll`        | `eza --icons -la`              |
| `cls`       | `clear`                        |
| `fastfetch` | `clear && fastfetch`           |
| `update`    | `sudo pacman -Syu && yay -Syu` |

---

## ❓ Troubleshooting

<details>
<summary><b>Quickshell dashboard shows a generic avatar</b></summary>

Place a square image at `~/.face` (PNG or JPG). The dashboard reads it from `$HOME/.face`. SDDM also uses this file for the login screen.

```bash
cp /path/to/avatar.png ~/.face
```

</details>

<details>
<summary><b>No wallpapers appear in the wallpaper selector</b></summary>

Make sure `~/Pictures/Wallpapers/Dark/` and `~/Pictures/Wallpapers/Light/` exist and contain image files. The installer copies wallpapers from the repo if the `Wallpapers/` directory is present.

</details>

<details>
<summary><b>GTK apps don't follow the theme change</b></summary>

Nautilus is automatically restarted when switching between light ↔ dark mode. For other GTK apps, you may need to close and reopen them. The `nwg-look` tool is used during installation to apply the initial GTK settings.

</details>

<details>
<summary><b>Notifications aren't showing</b></summary>

The installer disables `dunst` because Quickshell handles notifications natively. If you installed another notification daemon, it may conflict. Check with:

```bash
systemctl --user status dunst.service
```

</details>

<details>
<summary><b>Some packages failed to install</b></summary>

The installer will print warnings for any packages that couldn't be installed. Ensure your mirrors are up to date:

```bash
sudo pacman -Syy
```

For AUR packages, make sure `yay` is working correctly:

```bash
yay -Syu
```

</details>

---

## 🙏 Credits & Inspiration

- [Hyprland](https://hypr.land/) — the Wayland compositor
- [Quickshell](https://quickshell.org/) — the Qt-based shell framework
- [Catppuccin](https://catppuccin.com/) — the GTK theme used for light/dark switching
- [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme) — color scheme inspiration
- [Starship](https://starship.rs/) — the cross-shell prompt
- The Arch & Hyprland communities for all the rice inspiration ❤️
