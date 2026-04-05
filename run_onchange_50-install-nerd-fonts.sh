#!/usr/bin/env bash

set -e

echo "Installing Nerd fonts"

export DEBIAN_FRONTEND=noninteractive

FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"
FONTS_DIR="$HOME/.local/share/fonts"
FONT_ARCHIVE_PATH="$FONTS_DIR/JetBrainsMono.zip"

mkdir -p "$FONTS_DIR"

curl -s -L -o "$FONT_ARCHIVE_PATH" "$FONT_URL"

unzip $FONT_ARCHIVE_PATH -d "FONTS_DIR"

rm -f "$FONT_ARCHIVE_PATH"

fc-cache -fv

curl -sS https://starship.rs/install.sh | sh -s -- -y

echo "Finished installing Nerd fonts"
