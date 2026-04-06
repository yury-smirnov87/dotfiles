#!/usr/bin/env bash

set -e

echo "Installing Telegram"

export DEBIAN_FRONTEND=noninteractive

APP_NAME="Telegram"
INSTALL_DIR="/opt"
ARCHIVE_URL="https://telegram.org/dl/desktop/linux"
ARCHIVE_OUT_FILE="$HOME/$APP_NAME.tar.xz"

curl -s -L -o "$ARCHIVE_OUT_FILE" "$ARCHIVE_URL"
sudo tar -xf "$ARCHIVE_OUT_FILE" -C "$INSTALL_DIR"
sudo ln -s "$INSTALL_DIR/$APP_NAME/Telegram" "/usr/local/bin/telegram"
rm -f $ARCHIVE_OUT_FILE

echo "Finished installing Telegram"
