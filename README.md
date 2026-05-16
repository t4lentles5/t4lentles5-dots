<div align="center">

# t4lentles5 Dotfiles

**Aesthetic Hyprland rice for Arch Linux — dynamic theming, Quickshell widgets, and a polished workflow out of the box.**

<img src="https://res.cloudinary.com/diu2godjy/image/upload/v1778889772/output_bjbuhy.webp" alt="Preview" />

</div>

---

## ✨ Features

- 🎨 **Dynamic Theming** — switch between 6 color schemes (Default, Tokyo Night, Catppuccin, Gruvbox, Rosé Pine, Kanagawa) with light/dark variants that instantly propagate across **all** apps: Kitty, GTK, Neovim, Yazi, and the bar itself.
- 🖥️ **Quickshell Bar & Widgets** — custom bar with dashboard, app launcher, clipboard history, wallpaper selector, color scheme selector, screenshot tool, keybinds cheat sheet, notification center, and package manager.
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

## 🖼️ Gallery & Color Schemes

All schemes include both **dark** and **light** variants, instantly switchable via `Ctrl + Alt + C`. When you switch a scheme, the bar, widgets, Kitty, GTK, Neovim, and Yazi are updated **in real time**.

### Themes (Dark / Light)

**Default**  
<img src="https://res.cloudinary.com/diu2godjy/image/upload/v1778885444/themes_iw5hxa.webp" alt="Default Theme">

**Tokyo Night**
<img src="https://res.cloudinary.com/diu2godjy/image/upload/v1778885752/themes_timq9h.webp" alt="Tokyo Night Theme">

**Catppuccin**
<img src="https://res.cloudinary.com/diu2godjy/image/upload/v1778887100/themes_uhmpmk.webp" alt="Catppuccin Theme">

**Gruvbox**
<img src="https://res.cloudinary.com/diu2godjy/image/upload/v1778887374/themes_thdlef.webp" alt="Gruvbox Theme">

**Rosé Pine**
<img src="https://res.cloudinary.com/diu2godjy/image/upload/v1778887500/themes_ttddun.webp" alt="Rosé Pine Theme">

**Kanagawa**
<img src="https://res.cloudinary.com/diu2godjy/image/upload/v1778887649/themes_ldpgbw.webp" alt="Kanagawa Theme">

## ⌨️ Keybinds

> [!NOTE]  
> You don't need to memorize these! Press `SUPER + K` at any time to open the built-in **Keybinds Cheat Sheet** directly on your desktop!

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
<summary><b>Installation errors or packages failed to install</b></summary>

The installer automatically captures all warnings and errors in a log file. You can check it to find out exactly what went wrong:

```bash
cat ~/install_errors.log
```

If packages failed to install, ensure your mirrors are up to date (`sudo pacman -Syy`) and that your AUR helper is working correctly (`yay -Syu`).

</details>
