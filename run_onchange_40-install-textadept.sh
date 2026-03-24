#!/usr/bin/env bash

set -e

export DEBIAN_FRONTEND=noninteractive

echo "Installing Textadept"

APP_NAME="textadept"
INSTALL_DIR="/opt"
ARCHIVE_URL="https://github.com/orbitalquark/textadept/releases/download/textadept_12.9/textadept_12.9.linux.tgz"
ARCHIVE_OUT_FILE="$HOME/$APP_NAME.tgz"

curl -s -L -o "$ARCHIVE_OUT_FILE" "$ARCHIVE_URL"
sudo tar -xf "$ARCHIVE_OUT_FILE" -C "$INSTALL_DIR"
mkdir -p "$HOME/.local/bin"
sudo ln -s "$INSTALL_DIR/$APP_NAME/textadept" "$HOME/.local/bin/textadept"

echo "Finished installing Textadept"
