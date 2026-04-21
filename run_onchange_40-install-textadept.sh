#!/usr/bin/env bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "Installing Textadept"

APP_NAME="textadept"
INSTALL_DIR="/opt/$APP_NAME"
ARCHIVE_URL="https://github.com/orbitalquark/textadept/releases/download/textadept_12.9/textadept_12.9.linux.tgz"
ARCHIVE_OUT_FILE="$HOME/$APP_NAME.tgz"

if [ ! -d "$INSTALL_DIR" ]; then
    echo "Downloading and extracting Textadept..."
    curl -s -L -o "$ARCHIVE_OUT_FILE" "$ARCHIVE_URL"

    sudo mkdir -p "$INSTALL_DIR"
    # --strip-components=1 handles the versioned folder inside the tarball
    sudo tar -xf "$ARCHIVE_OUT_FILE" -C "$INSTALL_DIR" --strip-components=1

    sudo chown -R $USER:$USER "$INSTALL_DIR"
    rm -f "$ARCHIVE_OUT_FILE"
else
    echo "Textadept is already installed in $INSTALL_DIR. Skipping download."
fi

sudo mkdir -p /usr/local/bin
sudo ln -sf "$INSTALL_DIR/textadept-gtk" /usr/local/bin/textadept

echo "Finished installing Textadept"
