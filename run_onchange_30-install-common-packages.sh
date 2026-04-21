#!/usr/bin/env bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "Installing common packages and desktop assets"

# Grouping by purpose for easier maintenance
DEV_TOOLS=(age curl git zip unzip wezterm)
THEMES=(arc-theme papirus-icon-theme bibata-cursor-theme)
FONTS=(fonts-jetbrains-mono fonts-firacode)
MULTIMEDIA=(
    libavcodec-extra
    gstreamer1.0-libav
    gstreamer1.0-plugins-ugly
    gstreamer1.0-vaapi
    intel-media-va-driver-non-free
)
APPS=(transmission)

sudo apt-get install -y --no-install-recommends \
    "${DEV_TOOLS[@]}" "${THEMES[@]}" "${FONTS[@]}" "${MULTIMEDIA[@]}" "${APPS[@]}"

# Update font cache silently
fc-cache -fv > /dev/null

# Apply UI settings only if Cinnamon is detected
if pgrep -x "cinnamon" > /dev/null; then
    echo "Applying Cinnamon UI preferences..."
    gsettings set org.cinnamon.theme name "Arc"
    gsettings set org.cinnamon.desktop.interface gtk-theme "Arc"
    gsettings set org.cinnamon.desktop.wm.preferences theme "Arc"
    gsettings set org.cinnamon.desktop.interface icon-theme "Papirus"
    gsettings set org.cinnamon.desktop.interface cursor-theme "Bibata-Modern-Ice"
    gsettings set org.gnome.desktop.interface monospace-font-name "JetBrains Mono 11"
else
    echo "Cinnamon session not detected; skipping UI configuration."
fi

echo "Finished installing common packages and desktop assets"
