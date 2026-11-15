#!/usr/bin/env bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "Installing common packages and desktop assets"

# Grouping by purpose for easier maintenance
DEV_TOOLS=(age curl git zip unzip wezterm nodejs npm sqlite3 sqlitebrowser)
THEMES=(arc-theme papirus-icon-theme bibata-cursor-theme)
FONTS=(fonts-jetbrains-mono fonts-firacode ttf-mscorefonts-installer)
MULTIMEDIA=(
    libavcodec-extra
    gstreamer1.0-libav
    gstreamer1.0-plugins-ugly
    gstreamer1.0-vaapi
    intel-media-va-driver-non-free
)
APPS=(kde-plasma-desktop chromium transmission)

# Pre-accept Microsoft EULA for unattended font installation
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections

sudo apt-get install -y --no-install-recommends \
    "${DEV_TOOLS[@]}" "${THEMES[@]}" "${FONTS[@]}" "${MULTIMEDIA[@]}" "${APPS[@]}"

# Update font cache silently
fc-cache -fv > /dev/null

echo "Finished installing common packages and desktop assets"
