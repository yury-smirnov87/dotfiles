#!/usr/bin/env bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "Installing Zen Browser"

APP_NAME="zen"
INSTALL_DIR="/opt/$APP_NAME"
ARCHIVE_URL="https://github.com/zen-browser/desktop/releases/latest/download/zen.linux-x86_64.tar.xz"
ARCHIVE_OUT_FILE="$HOME/$APP_NAME.tar.xz"

if [ ! -d "$INSTALL_DIR" ]; then
    echo "Downloading and extracting Zen Browser..."
    curl -s -L -o "$ARCHIVE_OUT_FILE" "$ARCHIVE_URL"

    sudo mkdir -p "$INSTALL_DIR"
    sudo tar -xf "$ARCHIVE_OUT_FILE" -C "$INSTALL_DIR" --strip-components=1

    sudo chown -R $USER:$USER "$INSTALL_DIR"
    rm -f "$ARCHIVE_OUT_FILE"
else
    echo "Zen Browser is already installed in $INSTALL_DIR. Skipping download."
fi

sudo mkdir -p /usr/local/bin
sudo ln -sf "$INSTALL_DIR/zen" "/usr/local/bin/zen"

DESKTOP_FILE="/usr/share/applications/zen.desktop"
if [ ! -f "$DESKTOP_FILE" ]; then
    echo "Creating desktop entry for Zen Browser..."
    sudo bash -c "cat << 'EOF' > $DESKTOP_FILE
[Desktop Entry]
Version=1.0
Name=Zen Browser
Comment=Experience a more mindful internet browsing experience
Exec=/opt/zen/zen %u
Icon=/opt/zen/browser/chrome/icons/default/default128.png
Terminal=false
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;image/svg+xml;message/rfc822;x-scheme-handler/http;x-scheme-handler/https;
StartupWMClass=zen-alpha
EOF"
fi

echo "Finished installing Zen Browser"
