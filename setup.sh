#!/usr/bin/env bash
# ===========================================================================
#  Hyprland Theme — Everforest Matugen
#  One-command setup script
#  Docs: https://github.com/xtmic/hyprland
# ===========================================================================
set -euo pipefail

# ---- Colors for output ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
err()   { echo -e "${RED}[ERR]${NC}   $*"; }
die()   { err "$*"; exit 1; }

# ---- Parse flags ----
DRY_RUN=false
NO_AUR=false
RESTORE=false
CURL_MODE=false

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --no-aur)  NO_AUR=true ;;
    --restore) RESTORE=true ;;
    --help)
      echo "Usage: $0 [--dry-run] [--no-aur] [--restore]"
      echo "  --dry-run    Only show what would be done"
      echo "  --no-aur     Skip AUR packages"
      echo "  --restore    Restore previous backup"
      exit 0
      ;;
  esac
done

# ---- Detect running mode ----
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# If running via curl pipe, REPO_DIR will be /tmp or similar
if [ ! -f "$REPO_DIR/README.md" ] || [ ! -d "$REPO_DIR/config/hypr" ]; then
  CURL_MODE=true
  CURL_TMPDIR="/tmp/hyprland-setup-$$"
fi

BACKUP_DIR="$HOME/.config-backup/$(date +%Y%m%d_%H%M%S)"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# ===========================================================================
#  0. Clone if running via curl
# ===========================================================================
if [ "$CURL_MODE" = true ]; then
  info "Running from curl pipe — cloning repo to $CURL_TMPDIR ..."
  if [ "$DRY_RUN" = false ]; then
    git clone --depth=1 https://github.com/xtmic/hyprland.git "$CURL_TMPDIR" || \
      die "Failed to clone repo"
    REPO_DIR="$CURL_TMPDIR"
    ok "Cloned to $REPO_DIR"
  else
    info "[DRY-RUN] Would clone repo to $CURL_TMPDIR"
  fi
fi

# ===========================================================================
#  1. OS / Distro check
# ===========================================================================
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  Hyprland Theme Setup — Everforest Matugen${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

info "Checking OS ..."

if [ ! -f /etc/os-release ]; then
  die "/etc/os-release not found. Unsupported distro."
fi

source /etc/os-release

IS_ARCH=false
if [[ "$ID" == "arch" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
  IS_ARCH=true
fi

if [ "$IS_ARCH" = false ]; then
  warn "Not an Arch-based distro ($ID)."
  warn "You'll need to install packages manually. Setup will still copy configs."
fi

ok "OS: $NAME"

# ===========================================================================
#  2. Detect AUR helper
# ===========================================================================
AUR_HELPER=""

if [ "$IS_ARCH" = true ] && [ "$NO_AUR" = false ]; then
  for helper in yay paru; do
    if command -v "$helper" &>/dev/null; then
      AUR_HELPER="$helper"
      break
    fi
  done

  if [ -z "$AUR_HELPER" ]; then
    warn "No AUR helper found (yay/paru). AUR packages will be skipped."
    warn "Install one manually:"
    warn "  git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si"
    NO_AUR=true
  else
    ok "AUR helper: $AUR_HELPER"
  fi
fi

# ===========================================================================
#  3. Install packages
# ===========================================================================
echo ""
info "Step 1/8 — Installing packages ..."

PACMAN_PKGS=(
  hyprland waybar rofi kitty swaync
  grim wl-clipboard cliphist jq python python-pip
  playerctl brightnessctl pacman-contrib cpupower wf-recorder
  slurp imagemagick bc fastfetch tmux
)

AUR_PKGS=(
  matugen-bin swayosd-glibc-git hyprpicker
  hyprlock hypridle awww-git rofimoji-bin
  ttf-jetbrains-mono-nerd
)

# Some AUR packages might be in official repos
PACMAN_EXTRA=()
for pkg in "${AUR_PKGS[@]}"; do
  pacman -Si "$pkg" &>/dev/null && PACMAN_EXTRA+=("$pkg")
done

# Remove AUR packages that are found in pacman
AUR_ONLY=()
for pkg in "${AUR_PKGS[@]}"; do
  if ! pacman -Si "$pkg" &>/dev/null; then
    AUR_ONLY+=("$pkg")
  fi
done

ALL_PACMAN=("${PACMAN_PKGS[@]}" "${PACMAN_EXTRA[@]}")

if [ "$IS_ARCH" = true ]; then
  if [ "$DRY_RUN" = false ]; then
    info "Installing pacman packages ..."
    sudo pacman -S --needed "${ALL_PACMAN[@]}" || warn "Some packages failed to install"
    ok "pacman packages done"
  else
    info "[DRY-RUN] sudo pacman -S --needed ${ALL_PACMAN[*]}"
  fi

  if [ -n "$AUR_HELPER" ] && [ "$NO_AUR" = false ] && [ "${#AUR_ONLY[@]}" -gt 0 ]; then
    if [ "$DRY_RUN" = false ]; then
      info "Installing AUR packages via $AUR_HELPER ..."
      "$AUR_HELPER" -S --needed "${AUR_ONLY[@]}" || warn "Some AUR packages failed"
      ok "AUR packages done"
    else
      info "[DRY-RUN] $AUR_HELPER -S --needed ${AUR_ONLY[*]}"
    fi
  fi

  # Pip packages
  if [ "$DRY_RUN" = false ]; then
    pip install --user playwright 2>/dev/null || warn "playwright pip install failed"
  else
    info "[DRY-RUN] pip install --user playwright"
  fi
else
  info "Skipping package installation (non-Arch). Install these manually:"
  info "  pacman: ${ALL_PACMAN[*]}"
  info "  aur:    ${AUR_ONLY[*]}"
  info "  pip:    playwright"
fi

# ===========================================================================
#  4. Backup existing configs
# ===========================================================================
echo ""
info "Step 2/8 — Backing up current configs ..."

BACKUP_DIRS=(
  "$XDG_CONFIG_HOME/hypr"
  "$XDG_CONFIG_HOME/waybar"
  "$XDG_CONFIG_HOME/rofi"
  "$XDG_CONFIG_HOME/kitty"
  "$XDG_CONFIG_HOME/swaync"
  "$HOME/Scripts/General"
)

HAS_BACKUP=false
for dir in "${BACKUP_DIRS[@]}"; do
  if [ -e "$dir" ]; then
    HAS_BACKUP=true
    break
  fi
done

# Restore mode
if [ "$RESTORE" = true ]; then
  echo ""
  # Find latest backup
  LATEST=$(ls -d "$HOME/.config-backup"/*/ 2>/dev/null | sort | tail -1)
  if [ -z "$LATEST" ]; then
    die "No backup found in $HOME/.config-backup/"
  fi
  info "Restoring from: $LATEST"
  if [ "$DRY_RUN" = false ]; then
    for dir in "${BACKUP_DIRS[@]}"; do
      BASENAME=$(basename "$dir")
      PARENT=$(dirname "$dir")
      SRC="$LATEST/$BASENAME"
      if [ -e "$SRC" ]; then
        rm -rf "$dir" 2>/dev/null
        cp -r "$SRC" "$PARENT/" && ok "Restored $dir"
      fi
    done
    ok "Restore complete"
  else
    info "[DRY-RUN] Would restore from $LATEST"
  fi
  exit 0
fi

if [ "$HAS_BACKUP" = true ]; then
  if [ "$DRY_RUN" = false ]; then
    mkdir -p "$BACKUP_DIR"
    for dir in "${BACKUP_DIRS[@]}"; do
      if [ -e "$dir" ]; then
        cp -r "$dir" "$BACKUP_DIR/" && ok "Backed up $dir"
      fi
    done
    ok "Backup saved to $BACKUP_DIR"
  else
    info "[DRY-RUN] Would backup to $BACKUP_DIR"
  fi
else
  info "No existing configs to back up"
fi

# ===========================================================================
#  5. Install fonts
# ===========================================================================
echo ""
info "Step 3/8 — Installing JetBrains Mono Nerd Font ..."

FONT_DIR="$HOME/.local/share/fonts"
FONT_CHECK=$(fc-list | grep -i "JetBrainsMono.*Nerd" | head -1)

if [ -n "$FONT_CHECK" ]; then
  ok "JetBrains Mono Nerd Font already installed"
else
  if [ "$DRY_RUN" = false ]; then
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
    FONT_TMP="/tmp/jetbrains-mono-nerd.tar.xz"

    info "Downloading JetBrains Mono Nerd Font ..."
    curl -fsSL "$FONT_URL" -o "$FONT_TMP" || die "Font download failed"

    mkdir -p "$FONT_DIR"
    tar -xf "$FONT_TMP" -C "$FONT_DIR" 2>/dev/null || die "Font extraction failed"
    fc-cache -fv &>/dev/null
    rm -f "$FONT_TMP"
    ok "Fonts installed"
  else
    info "[DRY-RUN] Would download and install JetBrains Mono Nerd Font"
  fi
fi

# ===========================================================================
#  6. Copy configs
# ===========================================================================
echo ""
info "Step 4/8 — Deploying config files ..."

DEPLOY_DIRS=(
  "config/hypr:$XDG_CONFIG_HOME/hypr"
  "config/waybar:$XDG_CONFIG_HOME/waybar"
  "config/rofi:$XDG_CONFIG_HOME/rofi"
  "config/kitty:$XDG_CONFIG_HOME/kitty"
  "config/swaync:$XDG_CONFIG_HOME/swaync"
)

if [ "$DRY_RUN" = false ]; then
  for pair in "${DEPLOY_DIRS[@]}"; do
    SRC="$REPO_DIR/${pair%%:*}"
    DEST="${pair##*:}"
    PARENT="$(dirname "$DEST")"
    BASENAME="$(basename "$DEST")"

    if [ ! -d "$SRC" ]; then
      warn "Source not found: $SRC — skipping"
      continue
    fi

    # Remove existing symlink or dir
    rm -rf "$DEST" 2>/dev/null
    mkdir -p "$PARENT"
    cp -r "$SRC" "$PARENT/$BASENAME"
    ok "Deployed $BASENAME → $DEST"
  done

  # Scripts
  mkdir -p "$HOME/Scripts"
  rm -rf "$HOME/Scripts/General" 2>/dev/null
  cp -r "$REPO_DIR/scripts/General" "$HOME/Scripts/General"
  ok "Deployed scripts → ~/Scripts/General"

  # Wallpapers
  mkdir -p "$HOME/Pictures"
  if [ -d "$HOME/Pictures/Wallpaper" ]; then
    cp -rn "$REPO_DIR/wallpaper"/* "$HOME/Pictures/Wallpaper/" 2>/dev/null || true
  else
    cp -r "$REPO_DIR/wallpaper" "$HOME/Pictures/Wallpaper"
  fi
  ok "Deployed wallpapers → ~/Pictures/Wallpaper"
else
  for pair in "${DEPLOY_DIRS[@]}"; do
    SRC="$REPO_DIR/${pair%%:*}"
    DEST="${pair##*:}"
    info "[DRY-RUN] cp -r $SRC → $DEST"
  done
  info "[DRY-RUN] cp -r $REPO_DIR/scripts/General → ~/Scripts/General"
  info "[DRY-RUN] cp -r $REPO_DIR/wallpaper → ~/Pictures/Wallpaper"
fi

# ===========================================================================
#  7. Setup Matugen templates
# ===========================================================================
echo ""
info "Step 5/8 — Setting up Matugen templates ..."

MATUGEN_DIR="$XDG_CONFIG_HOME/matugen/templates"

if command -v matugen &>/dev/null; then
  if [ "$DRY_RUN" = false ]; then
    mkdir -p "$MATUGEN_DIR"

    # Copy existing configs as templates if not already present
    TEMPLATE_FILES=(
      "$XDG_CONFIG_HOME/hypr/colors.conf"
      "$XDG_CONFIG_HOME/waybar/colors.css"
      "$XDG_CONFIG_HOME/rofi/colors/matugen.rasi"
      "$XDG_CONFIG_HOME/kitty/current-theme.conf"
      "$XDG_CONFIG_HOME/swaync/colors/matugen.css"
    )

    for tf in "${TEMPLATE_FILES[@]}"; do
      if [ -f "$tf" ]; then
        TNAME="$(basename "$tf")"
        cp "$tf" "$MATUGEN_DIR/$TNAME"
        ok "Matugen template: $TNAME"
      fi
    done

    # Also copy from repo templates if they exist
    if [ -d "$REPO_DIR/config/matugen/templates" ]; then
      cp -rn "$REPO_DIR/config/matugen/templates"/* "$MATUGEN_DIR/" 2>/dev/null || true
      ok "Matugen templates from repo copied"
    fi
  else
    info "[DRY-RUN] Would copy templates to $MATUGEN_DIR"
  fi
else
  warn "matugen not installed — skipping template setup"
fi

# ===========================================================================
#  8. Make scripts executable
# ===========================================================================
echo ""
info "Step 6/8 — Making scripts executable ..."

if [ "$DRY_RUN" = false ]; then
  chmod +x "$XDG_CONFIG_HOME/hypr/scripts"/*.sh 2>/dev/null || true
  chmod +x "$XDG_CONFIG_HOME/hypr/scripts"/*.py 2>/dev/null || true
  chmod +x "$XDG_CONFIG_HOME/waybar/scripts"/*.sh 2>/dev/null || true
  chmod +x "$HOME/Scripts/General"/*.sh 2>/dev/null || true
  ok "Scripts are executable"
else
  info "[DRY-RUN] Would chmod +x all scripts"
fi

# ===========================================================================
#  9. Apply wallpaper + Matugen theme
# ===========================================================================
echo ""
info "Step 7/8 — Applying wallpaper and generating theme ..."

WALLPAPER_SCRIPT="$HOME/Scripts/General/wallpaper.sh"
DEFAULT_WALL="$HOME/Pictures/Wallpaper/Everforest/waterfall.png"

if [ -f "$WALLPAPER_SCRIPT" ] && [ -f "$DEFAULT_WALL" ]; then
  if [ "$DRY_RUN" = false ]; then
    info "Setting wallpaper and generating Matugen palette ..."
    bash "$WALLPAPER_SCRIPT" "$DEFAULT_WALL" && ok "Theme generated from wallpaper" || warn "Theme generation failed — run wallpaper.sh manually"
  else
    info "[DRY-RUN] bash $WALLPAPER_SCRIPT $DEFAULT_WALL"
  fi
else
  if [ ! -f "$WALLPAPER_SCRIPT" ]; then
    warn "wallpaper.sh not found at $WALLPAPER_SCRIPT"
  fi
  if [ ! -f "$DEFAULT_WALL" ]; then
    warn "Default wallpaper not found at $DEFAULT_WALL"
  fi
  info "Skip wallpaper step — set it manually later:"
  info "  ~/Scripts/General/wallpaper.sh ~/Pictures/Wallpaper/Everforest/waterfall.png"
fi

# ===========================================================================
#  10. Verification
# ===========================================================================
echo ""
info "Step 8/8 — Verifying installation ..."
echo ""

VERIFY_FAIL=false

verify_cmd() {
  local cmd=$1
  local name=$2
  if command -v "$cmd" &>/dev/null; then
    ok "$name — installed"
  else
    warn "$name — NOT FOUND"
    VERIFY_FAIL=true
  fi
}

verify_dir() {
  local dir=$1
  local name=$2
  if [ -d "$dir" ]; then
    ok "$name — exists"
  else
    warn "$name — NOT FOUND"
    VERIFY_FAIL=true
  fi
}

verify_file() {
  local file=$1
  local name=$2
  if [ -f "$file" ]; then
    ok "$name — exists"
  else
    warn "$name — NOT FOUND"
    VERIFY_FAIL=true
  fi
}

if [ "$DRY_RUN" = false ]; then
  verify_cmd hyprctl        "Hyprland"
  verify_cmd waybar         "Waybar"
  verify_cmd rofi           "Rofi"
  verify_cmd kitty          "Kitty"
  verify_cmd swaync         "SwayNC"
  verify_cmd matugen        "Matugen"
  verify_cmd awww           "Awww"
  verify_cmd grimblast      "Grimblast"
  verify_cmd wl-copy        "wl-clipboard"
  verify_cmd cliphist       "Cliphist"
  verify_cmd jq             "jq"
  verify_cmd playerctl      "Playerctl"
  verify_cmd brightnessctl  "Brightnessctl"
  verify_cmd hyprpicker     "Hyprpicker"
  verify_cmd wf-recorder    "wf-recorder"
  verify_cmd slurp          "Slurp"
  verify_cmd tmux           "tmux"
  verify_cmd hyprlock       "Hyprlock"
  verify_cmd hypridle       "Hypridle"

  verify_dir "$XDG_CONFIG_HOME/hypr"         "Config: hypr"
  verify_dir "$XDG_CONFIG_HOME/waybar"       "Config: waybar"
  verify_dir "$XDG_CONFIG_HOME/rofi"         "Config: rofi"
  verify_dir "$XDG_CONFIG_HOME/kitty"        "Config: kitty"
  verify_dir "$XDG_CONFIG_HOME/swaync"       "Config: swaync"
  verify_dir "$HOME/Scripts/General"         "Scripts: General"
  verify_dir "$HOME/Pictures/Wallpaper"      "Wallpapers"

  verify_file "$XDG_CONFIG_HOME/hypr/hyprland.conf" "Config: hyprland.conf"
  verify_file "$XDG_CONFIG_HOME/waybar/config.jsonc" "Config: waybar config"
  verify_file "$XDG_CONFIG_HOME/waybar/style.css"    "Config: waybar style"
  verify_file "$HOME/Scripts/General/wallpaper.sh"   "Script: wallpaper.sh"

  echo ""
  if [ "$VERIFY_FAIL" = true ]; then
    warn "Some components are missing. Check warnings above."
  else
    ok "All components verified!"
  fi
fi

# ===========================================================================
#  11. Final message
# ===========================================================================
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Setup complete!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  Next steps:"
echo "  1. Reboot or start Hyprland:"
echo "       exec Hyprland (from TTY) or select in DM"
echo ""
echo "  2. If colors didn't apply, re-run theme generation:"
echo "       ~/Scripts/General/wallpaper.sh"
echo ""
echo "  3. To restore previous configs:"
echo "       $0 --restore"
echo ""
echo "  4. Backup location: $BACKUP_DIR"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Cleanup tmp dir if running via curl
if [ "$CURL_MODE" = true ] && [ "$DRY_RUN" = false ]; then
  rm -rf "$CURL_TMPDIR"
fi
