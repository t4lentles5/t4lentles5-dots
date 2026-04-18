<div align="center">

# t4lentles5 Dotfiles

<img src="https://res.cloudinary.com/diu2godjy/image/upload/v1776481208/output_jwytio.gif" alt="Preview 1" width="49%" />
<img src="https://res.cloudinary.com/diu2godjy/image/upload/v1776480694/output_vaxokt.gif" alt="Preview 2" width="49%" />
<img src="https://res.cloudinary.com/diu2godjy/image/upload/v1776483790/output_xzwcft.gif" alt="Preview 2" width="49%" />
</div>

## 🚀 Quick Install

Open your terminal and run the following commands:

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

## 🔄 Next steps after installation

- Once the script finishes, it is highly recommended to **reboot your computer** (e.g. using `sudo reboot`) to ensure your new `zsh` shell, global variables, themes, and system daemons are fully loaded.
- If anything fails, remember you have complete copies of your previous configurations under your user folder in `~/.dotfiles_backup/`.

---

## 🧩 Stack & Components

| Component         | Tool                                                 |
| ----------------- | ---------------------------------------------------- |
| **Compositor**    | [Hyprland](https://hyprland.org/)                    |
| **Shell**         | Zsh + [Starship](https://starship.rs/) prompt        |
| **Terminal**      | [Kitty](https://sw.kovidgoyal.net/kitty/)            |
| **Editor**        | [Neovim](https://neovim.io/)                         |
| **File Manager**  | Nautilus / [Ranger](https://ranger.github.io/) (TUI) |
| **Bar / Widgets** | [Quickshell](https://quickshell.org/)                |

---

## ⌨️ Keybinds

> `SUPER` = Windows/Meta key. All keybinds are defined in `config/hypr/keybinds.conf`.

### 🖥️ Applications

| Keybind                 | Action                       |
| ----------------------- | ---------------------------- |
| `SUPER + Enter`         | Open terminal (Kitty)        |
| `SUPER + SHIFT + Enter` | Open floating terminal       |
| `SUPER + E`             | Open file manager (Nautilus) |
| `SUPER + B`             | Open Browser                 |

### 🪟 Window Management

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

### 🧰 Quickshell Widgets

| Keybind             | Action                     |
| ------------------- | -------------------------- |
| `SUPER + A`         | Open app launcher          |
| `SUPER + V`         | Open clipboard history     |
| `SUPER + SHIFT + S` | Take screenshot            |
| `SUPER + K`         | Open keybinds cheat sheet  |
| `CTRL + ALT + W`    | Open wallpaper selector    |
| `CTRL + ALT + C`    | Open color scheme selector |

### 🧭 Navigation

| Keybind                         | Action                     |
| ------------------------------- | -------------------------- |
| `SUPER + ←/→/↑/↓`               | Move focus between windows |
| `SUPER + SHIFT + ←/→/↑/↓`       | Move window position       |
| `SUPER + ALT + ←/→/↑/↓`         | Resize active window       |
| `SUPER + ALT + SHIFT + ←/→/↑/↓` | Swap window with neighbor  |

### 🗃️ Workspaces

| Keybind                  | Action                        |
| ------------------------ | ----------------------------- |
| `SUPER + 1..0`           | Switch to workspace 1–10      |
| `SUPER + SHIFT + 1..0`   | Send window to workspace 1–10 |
| `CTRL + SUPER + ←/→`     | Previous / next workspace     |
| `SUPER + Scroll Up/Down` | Scroll through workspaces     |
