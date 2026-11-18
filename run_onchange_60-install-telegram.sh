#!/usr/bin/env bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "Installing Telegram"

APP_NAME="Telegram"
INSTALL_DIR="/opt/$APP_NAME"
ARCHIVE_URL="https://telegram.org/dl/desktop/linux"
ARCHIVE_OUT_FILE="$HOME/$APP_NAME.tar.xz"

if [ ! -d "$INSTALL_DIR" ]; then
    echo "Downloading and extracting Telegram..."
    curl -s -L -o "$ARCHIVE_OUT_FILE" "$ARCHIVE_URL"

    sudo mkdir -p "$INSTALL_DIR"
    # Telegram archive contains a folder named 'Telegram'
    sudo tar -xf "$ARCHIVE_OUT_FILE" -C "/opt"

    sudo chown -R $USER:$USER "$INSTALL_DIR"
    rm -f "$ARCHIVE_OUT_FILE"
else
    echo "Telegram is already installed in $INSTALL_DIR. Skipping download."
fi

sudo mkdir -p /usr/local/bin
sudo ln -sf "$INSTALL_DIR/Telegram" "/usr/local/bin/telegram"

echo "Finished installing Telegram"
