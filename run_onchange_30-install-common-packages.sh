#!/usr/bin/env bash

set -e

echo "Installing general packages, fonts, themes, cursors, etc"

export DEBIAN_FRONTEND=noninteractive

PACKAGES=(
    arc-theme
    papirus-icon-theme
    bibata-cursor-theme
    fonts-jetbrains-mono
    fonts-firacode
    geany
    curl
    git
    zip
    unzip
    transmission
    libavcodec-extra
    gstreamer1.0-libav
    gstreamer1.0-plugins-ugly
    gstreamer1.0-vaapi
    intel-media-va-driver-non-free
)
sudo apt-get install -y --no-install-recommends "${PACKAGES[@]}"

echo "Updating fonts cache"

fc-cache -fv

echo "Applying Cinnamon settings..."

gsettings set org.cinnamon.theme name "Arc"
gsettings set org.cinnamon.desktop.interface gtk-theme "Arc"
gsettings set org.cinnamon.desktop.wm.preferences theme "Arc"
gsettings set org.cinnamon.desktop.interface icon-theme "Papirus"
gsettings set org.cinnamon.desktop.interface cursor-theme "Bibata-Modern-Ice"
gsettings set org.gnome.desktop.interface monospace-font-name "JetBrains Mono 11"

echo "Finished Installing general packages, fonts, themes, cursors, etc."
