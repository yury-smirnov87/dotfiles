#!/usr/bin/env bash
set -e
export DEBIAN_FRONTEND=noninteractive

if [ ! -f "$FONTS_DIR/JetBrainsMonoNerdFont-Regular.ttf" ]; then
    echo "Nerd Fonts not found, installing..."

    FONTS_DIR="$HOME/.local/share/fonts"
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"
    FONT_ARCHIVE_PATH="$FONTS_DIR/JetBrainsMono.zip"

    mkdir -p "$FONTS_DIR"
    curl -s -L -o "$FONT_ARCHIVE_PATH" "$FONT_URL"
    unzip -q "$FONT_ARCHIVE_PATH" -d "$FONTS_DIR"
    rm -f "$FONT_ARCHIVE_PATH"

    fc-cache -fv

    echo "Finished installing Nerd fonts"
else
    echo "JetBrainsMono Nerd Font is already installed. Skipping."
fi

if ! command -v starship &> /dev/null; then
    echo "Starship not found, installing..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    echo "Finished installing Starship"
else
    echo "Starship is already installed. Skipping."
fi
