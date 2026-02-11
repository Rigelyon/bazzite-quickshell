#!/bin/bash

set -ouex pipefail

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

dnf5 -y copr enable errornointernet/quickshell
dnf5 -y copr enable solopasha/hyprland
dnf5 -y copr enable atim/starship
dnf5 -y copr enable brycensranch/gpu-screen-recorder-git

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1


PACKAGES=(
    tmux
    python3-devel
    gcc-c++

    ## app2unit dependencies
    dash                
    desktop-file-utils
    scdoc               
    xdg-utils

    ## Caelestia dependencies
    hyprland
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    hyprpicker
    wl-clipboard
    cliphist
    inotify-tools
    trash-cli
    jq
    wireplumber
    pipewire-utils
    foot
    fish
    fastfetch
    btop
    adw-gtk3-theme
    papirus-icon-theme
    qt5ct
    qt6ct
    quickshell
    socat
    python3-pip
    git
    wget
    unzip

    ## Caelestia Cli dependencies
    libnotify
    swappy
    grim
    slurp
    gpu-screen-recorder-ui
    glib2
    fuzzel
    python-build
    python-installer
    hatch
    python-hatch-vcs
    sassc
)

rpm-ostree install "${PACKAGES[@]}"


echo "Linking sassc to sass..."
ln -sf /usr/bin/sassc /usr/bin/sass
sass --version

echo "Installing xdg-terminal-exec..."
git clone --depth=1 https://github.com/Vladimir-csp/xdg-terminal-exec.git /tmp/xdg-terminal-exec
cd /tmp/xdg-terminal-exec
make
install -Dm755 xdg-terminal-exec /usr/bin/xdg-terminal-exec
install -Dm644 xdg-terminal-exec.1 /usr/share/man/man1/xdg-terminal-exec.1
cd /
rm -rf /tmp/xdg-terminal-exec


echo "Installing App2Unit"
git clone --depth=1 https://github.com/Vladimir-csp/app2unit.git /tmp/app2unit
cd /tmp/app2unit
make
install -Dm755 app2unit /usr/bin/app2unit
install -Dm644 app2unit.1.gz /usr/share/man/man1/app2unit.1.gz
cd /
rm -rf /tmp/app2unit

echo "Installing caelestia-cli"
pip install --prefix=/usr materialyoucolor
mkdir -p /tmp/caelestia-cli
cd /tmp/caelestia-cli
git clone https://github.com/caelestia-dots/cli.git
cd cli
python3 -m build --wheel --no-isolation
pip install --prefix=/usr --no-deps --force-reinstall dist/*.whl
mkdir -p /usr/share/fish/vendor_completions.d/
cp completions/caelestia.fish /usr/share/fish/vendor_completions.d/
cd /
rm -rf /tmp/caelestia-cli

echo "Installing eza"
curl -L "https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz" | tar xz -C /tmp
mv /tmp/eza /usr/bin/eza
chmod +x /usr/bin/eza
ln -sf /usr/bin/eza /usr/bin/exa
eza --version

echo "Installing starship"
curl -sS https://starship.rs/install.sh | sh -s -- -y -b /usr/bin

echo "Installing fonts"
FONT_DIR="/usr/share/fonts/jetbrains-nerd"
mkdir -p "$FONT_DIR"
wget -P "$FONT_DIR" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -o "$FONT_DIR/JetBrainsMono.zip" -d "$FONT_DIR"
rm "$FONT_DIR/JetBrainsMono.zip"

# Update cache font sistem
fc-cache -fv

chmod -R a+r /usr/lib/python*/site-packages/

rpm-ostree cleanup -m

#### Example for enabling a System Unit File

systemctl enable podman.socket
