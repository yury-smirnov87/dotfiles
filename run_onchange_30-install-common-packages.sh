#!/usr/bin/env bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "Installing common packages and desktop assets"

# Grouping by purpose for easier maintenance
DEV_TOOLS=(age curl git zip unzip wezterm nodejs npm sqlite3 sqlitebrowser)
THEMES=(
    breeze-gtk-theme
    kde-config-gtk-style
    xsettingsd
    sddm-theme-breeze
    papirus-icon-theme
    bibata-cursor-theme
)
FONTS=(fonts-jetbrains-mono fonts-firacode ttf-mscorefonts-installer)
MULTIMEDIA=(
    libavcodec-extra
    gstreamer1.0-libav
    gstreamer1.0-plugins-ugly
    gstreamer1.0-vaapi
    intel-media-va-driver-non-free
)
APPS=(
    kde-plasma-desktop
    sddm
    kwin-x11
    systemsettings
    kscreen
    powerdevil
    plasma-nm
    plasma-pa
    kde-config-screenlocker
    kde-spectacle
    kio-extras
    kio-fuse
    xdg-desktop-portal-kde
    chromium
    ktorrent
    okular
)

# Pre-accept Microsoft EULA for unattended font installation
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections

sudo apt-get install -y --no-install-recommends \
    "${DEV_TOOLS[@]}" "${THEMES[@]}" "${FONTS[@]}" "${MULTIMEDIA[@]}" "${APPS[@]}"

# Remove Evince if present
sudo apt-get purge -y --auto-remove evince evince-common || true

# Update font cache silently
fc-cache -fv > /dev/null

echo "Applying KDE Plasma UI preferences..."

# Apply base Look & Feel first in an active session so subsequent overrides are not reset
if pgrep -x "plasmashell" > /dev/null; then
    plasma-apply-lookandfeel -a org.kde.breeze.desktop || true
fi

# 1. Global Theme & Light Color Scheme (Breeze Light)
kwriteconfig6 --file kdeglobals --group KDE --key LookAndFeelPackage "org.kde.breeze.desktop"
kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle "Breeze"
kwriteconfig6 --file kdeglobals --group General --key ColorScheme "BreezeLight"

# 2. Icons, Cursor & Monospace Font
kwriteconfig6 --file kdeglobals --group Icons --key Theme "Papirus-Light"
kwriteconfig6 --file kcminputrc --group Mouse --key cursorTheme "Bibata-Modern-Ice"
kwriteconfig6 --file kcminputrc --group Mouse --key cursorSize 24
kwriteconfig6 --file kdeglobals --group General --key fixed "JetBrains Mono,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"

# 3. GTK application consistency under KDE (Breeze Light)
if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.interface gtk-theme "Breeze" || true
    gsettings set org.gnome.desktop.interface color-scheme "prefer-light" || true
    gsettings set org.gnome.desktop.interface icon-theme "Papirus-Light" || true
    gsettings set org.gnome.desktop.interface cursor-theme "Bibata-Modern-Ice" || true
    gsettings set org.gnome.desktop.interface cursor-size 24 || true
    gsettings set org.gnome.desktop.interface monospace-font-name "JetBrains Mono 11" || true
fi

# 4. Keyboard Layouts (US + RU) with Alt+Shift toggle
kwriteconfig6 --file kxkbrc --group Layout --key Use true
kwriteconfig6 --file kxkbrc --group Layout --key LayoutList "us,ru"
kwriteconfig6 --file kxkbrc --group Layout --key Options "grp:alt_shift_toggle"
kwriteconfig6 --file kxkbrc --group Layout --key ResetOldOptions true

# 5. Dolphin File Manager preferences (global view properties & small icon sizes)
kwriteconfig6 --file dolphinrc --group General --key GlobalViewProps true
kwriteconfig6 --file dolphinrc --group DetailsMode --key IconSize 16
kwriteconfig6 --file dolphinrc --group CompactMode --key IconSize 16
kwriteconfig6 --file dolphinrc --group IconsMode --key IconSize 32

# 6. Default BitTorrent & magnet link handler (KTorrent)
if command -v xdg-mime &> /dev/null; then
    xdg-mime default org.kde.ktorrent.desktop application/x-bittorrent x-scheme-handler/magnet || true
fi

# Apply changes immediately if running inside an active Plasma session
if pgrep -x "plasmashell" > /dev/null; then
    plasma-apply-colorscheme BreezeLight || true
    plasma-apply-cursortheme --size 24 Bibata-Modern-Ice || true
    for changeicons_bin in /usr/libexec/plasma-changeicons /usr/lib/x86_64-linux-gnu/libexec/plasma-changeicons; do
        if [ -x "$changeicons_bin" ]; then
            "$changeicons_bin" Papirus-Light || true
            break
        fi
    done
    if command -v dbus-send &> /dev/null; then
        dbus-send --session --type=signal /Layouts org.kde.keyboard.reloadConfig || true
        dbus-send --session --type=method_call --dest=org.kde.KWin /KWin org.kde.KWin.reconfigure || true
    fi
fi

echo "Finished installing common packages and desktop assets"
