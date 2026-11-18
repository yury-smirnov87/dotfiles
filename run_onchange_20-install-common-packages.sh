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
    sddm-theme-debian-breeze
    desktop-base
    grub-theme-breeze
    papirus-icon-theme
    bibata-cursor-theme
)
FONTS=(
    fonts-jetbrains-mono
    fonts-firacode
    fonts-noto-core
    fonts-noto-color-emoji
    ttf-mscorefonts-installer
)
MULTIMEDIA=(
    pipewire-audio
    libavcodec-extra
    gstreamer1.0-libav
    gstreamer1.0-plugins-ugly
    gstreamer1.0-vaapi
    intel-media-va-driver-non-free
)
APPS=(
    kde-plasma-desktop
    sddm
    xserver-xorg
    kwin-x11
    systemsettings
    kde-config-sddm
    kscreen
    powerdevil
    plasma-nm
    plasma-pa
    plasma-systemmonitor
    kde-config-screenlocker
    kde-spectacle
    ark
    gwenview
    kio-extras
    kio-fuse
    xdg-desktop-portal-kde
    xdg-desktop-portal-gtk
    chromium
    firefox-esr
    ktorrent
    okular
    strawberry
    haruna
)

# Pre-accept Microsoft EULA for unattended font installation
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections

sudo apt-get install -y --no-install-recommends \
    "${DEV_TOOLS[@]}" "${THEMES[@]}" "${FONTS[@]}" "${MULTIMEDIA[@]}" "${APPS[@]}"

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
    apply_gsettings() {
        gsettings set org.gnome.desktop.interface gtk-theme "Breeze" || true
        gsettings set org.gnome.desktop.interface color-scheme "prefer-light" || true
        gsettings set org.gnome.desktop.interface icon-theme "Papirus-Light" || true
        gsettings set org.gnome.desktop.interface cursor-theme "Bibata-Modern-Ice" || true
        gsettings set org.gnome.desktop.interface cursor-size 24 || true
        gsettings set org.gnome.desktop.interface monospace-font-name "JetBrains Mono 11" || true
        gsettings set org.gnome.desktop.interface font-antialiasing "rgba" || true
        gsettings set org.gnome.desktop.interface font-hinting "full" || true
        gsettings set org.gnome.desktop.interface font-rgba-order "rgb" || true
    }
    if [ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
        apply_gsettings
    elif command -v dbus-run-session &> /dev/null; then
        dbus-run-session -- bash -c "$(declare -f apply_gsettings); apply_gsettings" || true
    fi
fi

# 4. Keyboard Layouts (US + RU) with Alt+Shift toggle
kwriteconfig6 --file kxkbrc --group Layout --key Use true
kwriteconfig6 --file kxkbrc --group Layout --key LayoutList "us,ru"
kwriteconfig6 --file kxkbrc --group Layout --key Options "grp:alt_shift_toggle"
kwriteconfig6 --file kxkbrc --group Layout --key ResetOldOptions true

# 5. Dolphin File Manager preferences (global view properties, split view, details mode, hidden files, maximized)
kwriteconfig6 --file dolphinrc --group General --key GlobalViewProps true
kwriteconfig6 --file dolphinrc --group General --key SplitView true
kwriteconfig6 --file dolphinrc --group General --key RememberOpenedTabs false
kwriteconfig6 --file dolphinrc --group FoldersPanel --key HiddenFilesShown true
kwriteconfig6 --file dolphinrc --group DetailsMode --key IconSize 16
kwriteconfig6 --file dolphinrc --group CompactMode --key IconSize 16
kwriteconfig6 --file dolphinrc --group IconsMode --key IconSize 32

rm -rf "$HOME/.local/share/dolphin/view_properties/global"
mkdir -p "$HOME/.local/share/dolphin/view_properties/global"
kwriteconfig6 --file "$HOME/.local/share/dolphin/view_properties/global/.directory" --group Dolphin --key ViewMode 1
kwriteconfig6 --file "$HOME/.local/share/dolphin/view_properties/global/.directory" --group Settings --key HiddenFilesShown true
rm -f "$HOME/.config/session/dolphin_"*

# Open Dolphin maximized via KWin window rule (resolution-independent)
RULE_ID="dolphin-maximized"
EXISTING_RULES=$(kreadconfig6 --file kwinrulesrc --group General --key rules 2>/dev/null || true)
if [ -z "$EXISTING_RULES" ]; then
    kwriteconfig6 --file kwinrulesrc --group General --key count 1
    kwriteconfig6 --file kwinrulesrc --group General --key rules "$RULE_ID"
elif ! echo ",$EXISTING_RULES," | grep -q ",$RULE_ID,"; then
    NEW_RULES="${EXISTING_RULES},${RULE_ID}"
    NEW_COUNT=$(echo "$NEW_RULES" | awk -F',' '{print NF}')
    kwriteconfig6 --file kwinrulesrc --group General --key count "$NEW_COUNT"
    kwriteconfig6 --file kwinrulesrc --group General --key rules "$NEW_RULES"
fi
kwriteconfig6 --file kwinrulesrc --group "$RULE_ID" --key Description "Maximize Dolphin"
kwriteconfig6 --file kwinrulesrc --group "$RULE_ID" --key wmclass "org.kde.dolphin"
kwriteconfig6 --file kwinrulesrc --group "$RULE_ID" --key wmclassmatch 1
kwriteconfig6 --file kwinrulesrc --group "$RULE_ID" --key maximizehoriz true
kwriteconfig6 --file kwinrulesrc --group "$RULE_ID" --key maximizehorizrule 3
kwriteconfig6 --file kwinrulesrc --group "$RULE_ID" --key maximizevert true
kwriteconfig6 --file kwinrulesrc --group "$RULE_ID" --key maximizevertrule 3

# 6. Default BitTorrent & magnet link handler (KTorrent)
if command -v xdg-mime &> /dev/null; then
    xdg-mime default org.kde.ktorrent.desktop application/x-bittorrent x-scheme-handler/magnet || true
fi

# 6b. Haruna Video Player (enable hardware decoding via libmpv)
mkdir -p "$HOME/.config/haruna"
kwriteconfig6 --file "$HOME/.config/haruna/haruna.conf" --group Playback --key UseHWDecoding true
kwriteconfig6 --file "$HOME/.config/haruna/haruna.conf" --group Playback --key HWDecodingBackend auto-safe

# 7. Night Light (Always on at 5000K)
kwriteconfig6 --file kwinrc --group NightColor --key Active true
kwriteconfig6 --file kwinrc --group NightColor --key Mode Constant
kwriteconfig6 --file kwinrc --group NightColor --key NightTemperature 5000

# 8. Mouse wheel scroll lines for Qt/KDE apps
kwriteconfig6 --file kdeglobals --group KDE --key WheelScrollLines 6

# 9. Default Web Browser (Firefox ESR)
kwriteconfig6 --file kdeglobals --group General --key BrowserApplication "firefox-esr.desktop"
if command -v xdg-settings &> /dev/null; then
    xdg-settings set default-web-browser firefox-esr.desktop || true
fi

# 10. Default Terminal Emulator (WezTerm - system-wide & KDE)
if [ -x /usr/bin/open-wezterm-here ]; then
    sudo update-alternatives --set x-terminal-emulator /usr/bin/open-wezterm-here || true
fi
kwriteconfig6 --file kdeglobals --group General --key TerminalApplication "wezterm"
kwriteconfig6 --file kdeglobals --group General --key TerminalService "org.wezfurlong.wezterm.desktop"

# 11. Plasma Panel (Auto-hide, non-floating, unpin Discover, pin WezTerm)
PLASMA_SHELL_RC="$HOME/.config/plasmashellrc"
PANEL_GROUPS=()
if [ -f "$PLASMA_SHELL_RC" ]; then
    while IFS= read -r panel_group; do
        PANEL_GROUPS+=("$panel_group")
    done < <(grep -oE '^\[PlasmaViews\]\[Panel [0-9]+\]$' "$PLASMA_SHELL_RC" | sed -E 's/^\[PlasmaViews\]\[(.*)\]$/\1/')
fi
if [ ${#PANEL_GROUPS[@]} -eq 0 ]; then
    PANEL_GROUPS=("Panel 2")
fi
for panel_group in "${PANEL_GROUPS[@]}"; do
    kwriteconfig6 --file plasmashellrc --group PlasmaViews --group "$panel_group" --key floating 0
    kwriteconfig6 --file plasmashellrc --group PlasmaViews --group "$panel_group" --key panelVisibility 1
done

APPLETS_RC="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
if [ -f "$APPLETS_RC" ]; then
    while IFS=':' read -r containment_id applet_id; do
        [ -z "$containment_id" ] || [ -z "$applet_id" ] && continue
        current_launchers=$(kreadconfig6 --file plasma-org.kde.plasma.desktop-appletsrc \
            --group Containments --group "$containment_id" --group Applets --group "$applet_id" \
            --group Configuration --group General --key launchers 2>/dev/null || true)
        if [ -z "$current_launchers" ]; then
            current_launchers="applications:systemsettings.desktop,applications:org.kde.discover.desktop,preferred://filemanager,preferred://browser"
        fi
        new_launchers=$(echo "$current_launchers" | tr ',' '\n' | grep -vxE 'applications:org\.kde\.discover\.desktop|org\.kde\.discover\.desktop|preferred://terminal' | paste -sd ',' -)
        if ! echo ",$new_launchers," | grep -q ',applications:org\.wezfurlong\.wezterm\.desktop,'; then
            new_launchers="${new_launchers:+$new_launchers,}applications:org.wezfurlong.wezterm.desktop"
        fi
        kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc \
            --group Containments --group "$containment_id" --group Applets --group "$applet_id" \
            --group Configuration --group General --key launchers "$new_launchers"
    done < <(awk '
        /^\[Containments\]\[[0-9]+\]\[Applets\]\[[0-9]+\]$/ {
            gsub(/\[Containments\]\[|\]\[Applets\]\[|\]/, ":")
            sub(/^:/, ""); sub(/:$/, "")
            key = $0
            next
        }
        /^\[/ { key = "" }
        key != "" && /^plugin=org\.kde\.plasma\.(icontasks|taskmanager)$/ {
            print key
            key = ""
        }
    ' "$APPLETS_RC")
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
        dbus-send --session --type=method_call --dest=org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript 'string:panels().forEach(p => { p.hiding = "autohide"; p.floating = false; p.widgets().forEach(w => { if (w.type === "org.kde.plasma.icontasks" || w.type === "org.kde.plasma.taskmanager") { w.currentConfigGroup = ["General"]; let raw = w.readConfig("launchers", "applications:systemsettings.desktop,applications:org.kde.discover.desktop,preferred://filemanager,preferred://browser"); let arr = Array.isArray(raw) ? raw : String(raw || "").split(","); let filtered = arr.map(s => String(s).trim()).filter(s => s && s !== "applications:org.kde.discover.desktop" && s !== "org.kde.discover.desktop" && s !== "preferred://terminal"); if (!filtered.includes("applications:org.wezfurlong.wezterm.desktop")) { filtered.push("applications:org.wezfurlong.wezterm.desktop"); } w.writeConfig("launchers", filtered.join(",")); } }); });' || true
    fi
fi

# 12. Configure graphical GRUB theme (Breeze)
GRUB_FILE="/etc/default/grub"
BREEZE_THEME=""
for candidate in /boot/grub/themes/breeze/theme.txt /usr/share/grub/themes/breeze/theme.txt; do
    if [ -f "$candidate" ]; then
        BREEZE_THEME="$candidate"
        break
    fi
done

if [ -f "$GRUB_FILE" ] && [ -n "$BREEZE_THEME" ]; then
    echo "Configuring GRUB Breeze graphical theme..."
    sudo sed -i -E 's/^GRUB_TERMINAL=console/#GRUB_TERMINAL=console/' "$GRUB_FILE"

    if grep -qE '^#?GRUB_GFXMODE=' "$GRUB_FILE"; then
        sudo sed -i -E 's/^#?GRUB_GFXMODE=.*/GRUB_GFXMODE=auto/' "$GRUB_FILE"
    else
        echo 'GRUB_GFXMODE=auto' | sudo tee -a "$GRUB_FILE" > /dev/null
    fi

    if grep -qE '^#?GRUB_THEME=' "$GRUB_FILE"; then
        sudo sed -i -E "s|^#?GRUB_THEME=.*|GRUB_THEME=\"$BREEZE_THEME\"|" "$GRUB_FILE"
    else
        echo "GRUB_THEME=\"$BREEZE_THEME\"" | sudo tee -a "$GRUB_FILE" > /dev/null
    fi

    if command -v update-grub &> /dev/null; then
        sudo update-grub
    fi
fi

# 13. Hand over Wi-Fi from ifupdown (/etc/network/interfaces) to NetworkManager
if [ -f /etc/network/interfaces ] && command -v nmcli &> /dev/null && command -v python3 &> /dev/null; then
    MIGRATED_WIFI=$(sudo python3 - <<'EOF'
import os
import re

path = "/etc/network/interfaces"
with open(path, "r", encoding="utf-8", errors="replace") as f:
    lines = f.readlines()

stanzas = []
current = None
for idx, raw in enumerate(lines):
    s = raw.strip()
    if not s or s.startswith("#"):
        if current and not s:
            current = None
        continue
    m = re.match(r"^(?:iface|mapping)\s+(\S+)", s)
    if m:
        current = {"iface": m.group(1), "lines": [idx], "options": {}}
        stanzas.append(current)
        continue
    if re.match(r"^(?:auto|allow-\S+|source(?:-directory)?)\b", s):
        current = None
        continue
    if current is not None and (raw[0].isspace()):
        current["lines"].append(idx)
        parts = s.split(None, 1)
        if len(parts) == 2:
            current["options"][parts[0]] = parts[1].strip()
    else:
        current = None

wifi_ifaces = set()
line_indices_to_comment = set()
migrated = []

for st in stanzas:
    iface = st["iface"]
    if iface == "lo":
        continue
    is_wifi = (
        any(k.startswith(("wpa-", "wireless-")) for k in st["options"])
        or os.path.exists(f"/sys/class/net/{iface}/wireless")
    )
    if is_wifi:
        wifi_ifaces.add(iface)
        line_indices_to_comment.update(st["lines"])
        ssid = st["options"].get("wpa-ssid", "").strip("\"'")
        psk = st["options"].get("wpa-psk", "").strip("\"'")
        migrated.append((iface, ssid, psk))

if wifi_ifaces:
    for idx, raw in enumerate(lines):
        s = raw.strip()
        m = re.match(r"^(?:auto|allow-\S+)\s+(.+)$", s)
        if m:
            tokens = m.group(1).split()
            if any(t in wifi_ifaces for t in tokens):
                line_indices_to_comment.add(idx)

    new_lines = [
        f"# {raw}" if i in line_indices_to_comment and not raw.lstrip().startswith("#") else raw
        for i, raw in enumerate(lines)
    ]
    with open(path, "w", encoding="utf-8") as f:
        f.writelines(new_lines)

    for iface, ssid, psk in migrated:
        print(f"{iface}\t{ssid}\t{psk}")
EOF
)

    if [ -n "$MIGRATED_WIFI" ]; then
        echo "Handing Wi-Fi interface(s) over from ifupdown to NetworkManager..."
        while IFS=$'\t' read -r wifi_iface wifi_ssid wifi_psk; do
            [ -z "$wifi_iface" ] && continue
            sudo ip link set "$wifi_iface" down || true
            sudo pkill -f "wpa_supplicant.*$wifi_iface" || true
        done <<< "$MIGRATED_WIFI"

        sudo systemctl enable --now NetworkManager || true
        sudo systemctl restart NetworkManager || true

        while IFS=$'\t' read -r wifi_iface wifi_ssid wifi_psk; do
            [ -z "$wifi_iface" ] || [ -z "$wifi_ssid" ] && continue
            if ! nmcli -t -f NAME connection show 2>/dev/null | grep -Fxq "$wifi_ssid"; then
                if [ -n "$wifi_psk" ]; then
                    sudo nmcli connection add type wifi ifname "$wifi_iface" con-name "$wifi_ssid" ssid "$wifi_ssid" \
                        wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$wifi_psk" || true
                else
                    sudo nmcli connection add type wifi ifname "$wifi_iface" con-name "$wifi_ssid" ssid "$wifi_ssid" || true
                fi
            fi
            sudo nmcli connection up "$wifi_ssid" || true
        done <<< "$MIGRATED_WIFI"

        sudo nm-online -q -t 15 || true
    fi
fi

echo "Finished installing common packages and desktop assets"
