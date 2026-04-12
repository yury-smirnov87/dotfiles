#!/usr/bin/env bash

set -e

export DEBIAN_FRONTEND=noninteractive

echo "Installing Textadept"

APP_NAME="textadept"
INSTALL_DIR="/opt/$APP_NAME"
ARCHIVE_URL="https://github.com/orbitalquark/textadept/releases/download/textadept_12.9/textadept_12.9.linux.tgz"
ARCHIVE_OUT_FILE="$HOME/$APP_NAME.tgz"

curl -s -L -o "$ARCHIVE_OUT_FILE" "$ARCHIVE_URL"

sudo mkdir -p "$INSTALL_DIR"

sudo tar -xf "$ARCHIVE_OUT_FILE" -C "$INSTALL_DIR"

sudo chown -R $USER:$USER "$INSTALL_DIR"

sudo ln -s "$INSTALL_DIR/$APP_NAME/textadept-gtk" /usr/local/bin/textadept-gtk

rm -f $ARCHIVE_OUT_FILE

echo "Finished installing Textadept"
