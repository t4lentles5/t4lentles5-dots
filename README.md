<div align="center">

# t4lentles5 Dotfiles

<img src="https://res.cloudinary.com/diu2godjy/image/upload/v1775658862/output_pr1rht.gif" alt="Preview 1" />
<img src="https://res.cloudinary.com/diu2godjy/image/upload/v1775658639/output_eazyne.gif" alt="Preview 2" />

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

## 🛠️ What exactly does the installation script do?

The `install.sh` script is designed to prevent breaking your system. Here are the steps it performs automatically:

1. **Installs `yay`**: Checks if the AUR helper is present; otherwise, it compiles and configures it.
2. **Official Dependencies**: Installs modern tools like `eza`, `fzf`, `ripgrep`, `btop`, fonts (Nerd Fonts), Wayland ecosystem utilities (hyprlock, hypridle, etc.), and much more from the official Arch repositories.
3. **AUR Dependencies**: Installs community add-ons, including GTK themes (`Catppuccin Mocha`), cursor themes (`Bibata`), icon themes (`Tela Circle Dracula`), among others.
4. **Safe Backups 🛡️**: Before modifying your files, it makes a copy of your existing configurations in `~/.dotfiles_backup/YYYYMMDD_HHMMSS`.
5. **Dotfiles Deployment**:
   - Copies the contents from `config/` to `~/.config/`
   - Deploys base files from `home/` to your home root `~/`
   - Moves images from `Wallpapers/` to `~/Pictures/Wallpapers/`
6. **Visual Autoconfiguration**: Runs extra utilities (`nwg-look`) to automatically inject your new GTK theme.
7. **Disables dunst**: Stops and masks [dunst](https://dunst-project.org/) to avoid conflicts, since **all notifications are handled natively by QuickShell**.
8. **Terminal Setup**: Changes your default shell to `zsh` using the new configuration.
9. **Web Development Environment**: Installs `fnm` and prepares the latest LTS version of **Node.js**.

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

## 📂 How is it organized?

- 📁 `config/`: Everything intended for your system's `~/.config/` folder.
- 📁 `etc/`: System-level configuration files (e.g. SDDM theme) copied to `/etc/`.
- 📁 `home/`: Standalone hidden files (e.g. your `.zshrc`) that are placed directly in `~/`.
- 📁 `Wallpapers/`: Your wallpaper collection used by the configuration.
- 📜 `install.sh`: The main orchestration script.

---

## ⌨️ Keybinds

> `SUPER` = Windows/Meta key. All keybinds are defined in `config/hypr/keybinds.conf`.

### 🖥️ Applications

| Keybind                 | Action                       |
| ----------------------- | ---------------------------- |
| `SUPER + Enter`         | Open terminal (Kitty)        |
| `SUPER + SHIFT + Enter` | Open floating terminal       |
| `SUPER + E`             | Open file manager (Nautilus) |

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

### 🔧 Tools

| Keybind             | Action                           |
| ------------------- | -------------------------------- |
| `SUPER + SHIFT + C` | Pick color (hyprpicker)          |
| `SUPER + SPACE`     | Switch keyboard layout (US ↔ ES) |

### 🧰 Quickshell Widgets

| Keybind             | Action                    |
| ------------------- | ------------------------- |
| `SUPER + A`         | Open app launcher         |
| `SUPER + V`         | Open clipboard history    |
| `SUPER + SHIFT + S` | Take screenshot           |
| `SUPER + K`         | Open keybinds cheat sheet |
| `CTRL + ALT + W`    | Open wallpaper picker     |

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

---

## ✏️ Customization

- **Keybinds**: Edit `config/hypr/keybinds.conf`.
- **Monitor setup**: Edit `config/hypr/monitors.conf` — see the [Hyprland wiki](https://wiki.hyprland.org/Configuring/Monitors/) for options.
- **Keyboard layout**: The default is `us,es` (toggle with `SUPER + SPACE`). Change it in `config/hypr/userprefs.conf` under `input.kb_layout`.
- **Colors / borders**: Edit the `rgba()` values in `config/hypr/userprefs.conf` to match your preferred palette.
- **Autostart apps**: Add or remove entries in `config/hypr/autostart.conf`.
- **Wallpapers**: Drop new wallpapers into `~/Pictures/Wallpapers/` and use the wallpaper picker (`CTRL + ALT + W`).

---

## 🆘 Troubleshooting

| Problem                           | Solution                                                                   |
| --------------------------------- | -------------------------------------------------------------------------- |
| Quickshell widgets not responding | Make sure `quickshell` is running: `quickshell &`                          |
| Clipboard history empty           | Check `wl-paste` and `cliphist` are installed and running                  |
| Wrong keyboard layout             | Verify `kb_layout` in `userprefs.conf`; toggle with `SUPER + SPACE`        |
| GTK theme not applied             | Run `nwg-look` manually after logging in                                   |
| Fonts look broken                 | Install a Nerd Font manually: `yay -S ttf-jetbrains-mono-nerd`             |
| `yay` not found after install     | Restart your shell or run `source ~/.zshrc`                                |
| Notifications not appearing       | They are handled by QuickShell, not dunst. Make sure QuickShell is running |
| Want to use dunst instead?        | Run `systemctl --user unmask dunst.service` and restore its D-Bus file     |

---

I hope you enjoy this environment! ✨
