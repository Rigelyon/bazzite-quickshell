#!/bin/bash

set -ouex pipefail

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

dnf copr enable -y errornointernet/quickshell

dnf copr enable -y solopasha/hyprland

dnf copr enable atim/starship

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos

# Dependencies for Caelestia
PACKAGES=(
    # Core Hyprland & Portals
    hyprland
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    hyprpicker
    
    # Clipboard & Files
    wl-clipboard
    cliphist
    inotify-tools
    trash-cli
    jq
    
    # Audio & Media
    wireplumber
    pipewire-utils
    
    # Shell & Terminal
    foot
    fishs
    fastfetch
    btop
    
    # Theme & Appearance
    adw-gtk3-theme
    papirus-icon-theme
    qt5ct
    qt6ct
    
    # Caelestia Specifics
    quickshell
    socat           # Dibutuhkan untuk komunikasi socket
    python3-pip     # Untuk install script python nanti
    git
    wget
    unzip
)

rpm-ostree install "${PACKAGES[@]}"

# Install eza from repo
curl -L "https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz" | tar xz -C /tmp
mv /tmp/eza /usr/bin/eza
chmod +x /usr/bin/eza
ln -sf /usr/bin/eza /usr/bin/exa
eza --version

curl -sS https://starship.rs/install.sh | sh -s -- -y -b /usr/bin

dnf5 install -y tmux 

FONT_DIR="/usr/share/fonts/jetbrains-nerd"
mkdir -p "$FONT_DIR"
wget -P "$FONT_DIR" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -o "$FONT_DIR/JetBrainsMono.zip" -d "$FONT_DIR"
rm "$FONT_DIR/JetBrainsMono.zip"

# Update cache font sistem
fc-cache -fv

rpm-ostree cleanup -m

#### Example for enabling a System Unit File

systemctl enable podman.socket
