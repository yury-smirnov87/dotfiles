#!/usr/bin/env bash
set -e

if ! pgrep -x "plasmashell" > /dev/null; then
    echo "No active Plasma session detected. Skipping live Plasma configuration."
    exit 0
fi

echo "Applying live KDE Plasma session preferences..."

# Refresh KDE service and icon caches so desktop launchers (WezTerm, System Settings) resolve cleanly
rm -f "$HOME/.cache/icon-cache.kcache"
if command -v kbuildsycoca6 &> /dev/null; then
    kbuildsycoca6 --noincremental || true
fi

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

echo "Finished applying live KDE Plasma session preferences."
