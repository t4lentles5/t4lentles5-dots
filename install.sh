#!/usr/bin/env bash

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${CYAN}[INFO]${NC} $1"; }
ok() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() {
  echo -e "${RED}[ERROR]${NC} $1"
  exit 1
}

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# ── 1. yay ───────────────────────────────────────────────────────────────────
log "Installing yay (AUR helper)..."
if ! command -v yay &>/dev/null; then
  sudo pacman -S --needed --noconfirm git base-devel
  tmp=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$tmp/yay"
  (cd "$tmp/yay" && makepkg -si --noconfirm)
  rm -rf "$tmp"
  ok "yay installed."
else
  ok "yay is already installed, skipping."
fi

# ── 2. official dependencies ──────────────────────────────────────────────────
log "Installing dependencies from official repositories..."
dependencies=(
  hyprland kitty openssh polkit-kde-agent qt5-wayland qt6-wayland
  smartmontools uwsm vim wget wireless_tools xdg-desktop-portal-hyprland
  xdg-utils bat bc btop cava eza fd fzf gnome-calculator gnome-font-viewer
  gnome-disk-utility gvfs gvfs-mtp highlight hypridle hyprlock hyprpicker
  hyprsunset imagemagick inetutils iwd jq lazygit loupe nautilus network-manager-applet
  networkmanager noto-fonts-emoji nwg-look openssl pacman-contrib pamixer pavucontrol
  pipewire pipewire-alsa pipewire-audio pipewire-pulse python-gobject python-pygments
  python-pip ranger rfkill ripgrep starship ttf-cascadia-code-nerd ttf-jetbrains-mono-nerd
  tumbler unzip upower wireplumber wl-clipboard wlsunset
  xclip xdg-desktop-portal-gtk zsh zsh-autosuggestions zsh-history-substring-search 
  zsh-syntax-highlighting brightnessctl blueman bluez bluez-utils grim slurp cliphist
  fastfetch neovim curl unrar socat qt6-imageformats mpv fnm polkit-gnome ntfs-3g 
  gnome-keyring libsecret awww playerctl
)

sudo pacman -S --needed --noconfirm "${dependencies[@]}" ||
  warn "Some official packages could not be installed (check the messages above)."
ok "Official dependencies processed."

# ── 3. AUR dependencies ───────────────────────────────────────────────────────
log "Installing AUR dependencies..."
aur_dependencies=(
  bibata-cursor-theme-bin
  catppuccin-gtk-theme-mocha
  fzf-tab-git
  quickshell
  sddm-theme-tokyo-night-git
  tela-circle-icon-theme-dracula-git
  xxhash
  pokemon-colorscripts-git
)

yay -S --needed --noconfirm "${aur_dependencies[@]}" ||
  warn "Some AUR packages could not be installed (check the messages above)."
ok "AUR dependencies processed."

# ── 4. backup & copy dotfiles ─────────────────────────────────────────────────
log "Backing up existing dotfiles to $BACKUP_DIR ..."
mkdir -p "$BACKUP_DIR"

# config/ → ~/.config/ (backup only folders that exist in repo)
if [ -d "$REPO_DIR/config" ]; then
  mkdir -p "$BACKUP_DIR/config"

  # Pass 1: backup existing configs
  while IFS= read -r -d '' dir; do
    rel="${dir#$REPO_DIR/config/}"
    dest="$HOME/.config/$rel"
    if [ -e "$dest" ]; then
      mkdir -p "$BACKUP_DIR/config/$(dirname "$rel")"
      cp -r "$dest" "$BACKUP_DIR/config/$rel"
    fi
  done < <(find "$REPO_DIR/config" -maxdepth 1 -mindepth 1 -print0)
  ok "Conflicting configs backed up to $BACKUP_DIR/config"

  # Pass 2: copy new configs
  while IFS= read -r -d '' dir; do
    cp -r "$dir" "$HOME/.config/"
  done < <(find "$REPO_DIR/config" -maxdepth 1 -mindepth 1 -print0)
  ok "config/ → ~/.config/"
else
  warn "config/ not found in repo, skipping."
fi

# home/ → ~/ (only the files that exist in the repo, not all of $HOME)
if [ -d "$REPO_DIR/home" ]; then
  mkdir -p "$BACKUP_DIR/home"

  # Pass 1: backup existing home files
  while IFS= read -r -d '' file; do
    rel="${file#$REPO_DIR/home/}"
    dest="$HOME/$rel"
    if [ -e "$dest" ]; then
      mkdir -p "$BACKUP_DIR/home/$(dirname "$rel")"
      cp -r "$dest" "$BACKUP_DIR/home/$rel"
    fi
  done < <(find "$REPO_DIR/home" -maxdepth 1 -mindepth 1 -print0)
  ok "Conflicting home files backed up to $BACKUP_DIR/home"

  # Pass 2: copy new home files
  while IFS= read -r -d '' file; do
    rel="${file#$REPO_DIR/home/}"
    dest="$HOME/$rel"
    mkdir -p "$HOME/$(dirname "$rel")"
    cp -r "$file" "$dest"
  done < <(find "$REPO_DIR/home" -maxdepth 1 -mindepth 1 -print0)
  ok "home/ → ~/"
else
  warn "home/ not found in repo, skipping."
fi

# Wallpapers/ → ~/Pictures/Wallpapers/
if [ -d "$REPO_DIR/Wallpapers" ]; then
  mkdir -p "$HOME/Pictures/Wallpapers"
  if [ -n "$(ls -A "$HOME/Pictures/Wallpapers" 2>/dev/null)" ]; then
    cp -r "$HOME/Pictures/Wallpapers" "$BACKUP_DIR/Wallpapers"
    ok "Backed up ~/Pictures/Wallpapers → $BACKUP_DIR/Wallpapers"
  fi
  cp -r "$REPO_DIR/Wallpapers/." "$HOME/Pictures/Wallpapers/"
  ok "Wallpapers/ → ~/Pictures/Wallpapers/"
else
  warn "Wallpapers/ not found in repo, skipping."
fi

# ── 5. apply GTK theme via nwg-look ──────────────────────────────────────────
log "Applying GTK theme..."
if command -v nwg-look &>/dev/null; then
  nwg-look -a && ok "nwg-look applied settings." || warn "nwg-look -a failed, check your gtk config files."
fi

# ── 6. SDDM theme ─────────────────────────────────────────────────────────────
log "Configuring SDDM theme..."
if [ -f "$REPO_DIR/etc/sddm.conf" ]; then
  if [ -f /etc/sddm.conf ]; then
    cp /etc/sddm.conf "$BACKUP_DIR/sddm.conf.bak"
    ok "Existing /etc/sddm.conf backed up."
  fi
  sudo cp "$REPO_DIR/etc/sddm.conf" /etc/sddm.conf
  ok "SDDM theme set to tokyo-night."
else
  warn "etc/sddm.conf not found in repo, skipping SDDM config."
fi

# ── 7. disable dunst (notifications handled by QuickShell) ────────────────────
log "Disabling dunst (notifications are managed by QuickShell)..."
if command -v dunst &>/dev/null; then
  # Kill any running dunst instance
  killall dunst 2>/dev/null && ok "Stopped running dunst process."

  # Mask the systemd user service so it never starts again
  systemctl --user mask dunst.service 2>/dev/null &&
    ok "dunst.service masked." ||
    warn "Could not mask dunst.service (may not exist as a systemd service)."

  # Disable D-Bus activation if the service file exists
  DBUS_SERVICE="/usr/share/dbus-1/services/org.knopwob.dunst.service"
  if [ -f "$DBUS_SERVICE" ]; then
    sudo mv "$DBUS_SERVICE" "${DBUS_SERVICE}.disabled"
    ok "dunst D-Bus activation disabled."
  fi

  ok "dunst disabled — QuickShell will handle notifications."
else
  ok "dunst is not installed, no conflicts."
fi

# ── 8. zsh shell (mandatory) ──────────────────────────────────────────────────
log "Setting zsh as default shell..."
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)" || error "Could not change shell to zsh. Run manually: chsh -s \$(which zsh)"
  ok "Shell changed to zsh."
else
  ok "zsh is already the default shell."
fi

# ── 9. Node.js LTS via fnm ────────────────────────────────────────────────────
log "Installing Node.js LTS with fnm..."
if command -v fnm &>/dev/null; then
  export FNM_DIR="${FNM_DIR:-$HOME/.local/share/fnm}"
  eval "$(fnm env)"
  fnm install --lts
  fnm use lts-latest
  ok "Node.js LTS installed: $(node --version 2>/dev/null || echo 'restart your terminal to activate it')."
else
  warn "fnm not found in PATH. Make sure ~/.local/bin is in your PATH and re-run."
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Installation completed successfully     ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
log "Backup saved at: $BACKUP_DIR"
warn "Please reboot your computer for all changes to take effect."
