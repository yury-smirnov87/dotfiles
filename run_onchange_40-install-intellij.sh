#!/usr/bin/env bash

set -e

export DEBIAN_FRONTEND=noninteractive

echo "Installing IntelliJ Idea"

APP_NAME="idea"
INSTALL_DIR="/opt/$APP_NAME"
ARCHIVE_URL="https://download.jetbrains.com/product?code=IU&latest&distribution=linux"
ARCHIVE_OUT_FILE="$HOME/$APP_NAME.tar.gz"

curl -s -L -o "$ARCHIVE_OUT_FILE" "$ARCHIVE_URL"

sudo mkdir -p "$INSTALL_DIR"

sudo tar -xzf "$ARCHIVE_OUT_FILE" -C "$INSTALL_DIR" --strip-components=1

sudo chown -R $USER:$USER "$INSTALL_DIR"

sudo ln -s "$INSTALL_DIR/bin/idea" "/usr/local/bin/idea"

rm -f "$ARCHIVE_OUT_FILE"

echo "Finished installing IntelliJ Idea"
