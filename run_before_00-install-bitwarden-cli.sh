#!/usr/bin/env bash

set -e
export DEBIAN_FRONTEND=noninteractive

echo "Installing Bitwarden CLI"

BINARY_NAME="bw"
INSTALL_PATH="/usr/local/bin/$BINARY_NAME"
DOWNLOAD_URL="https://vault.bitwarden.com/download/?app=cli&platform=linux"
TEMP_ZIP="/tmp/bw.zip"

if ! command -v "$BINARY_NAME" &> /dev/null; then
    echo "Bitwarden CLI not found. Downloading..."

    curl -s -L -o "$TEMP_ZIP" "$DOWNLOAD_URL"
    sudo unzip -o "$TEMP_ZIP" -d "/usr/local/bin"
    sudo chmod +x "$INSTALL_PATH"
    rm -f "$TEMP_ZIP"

    echo "Bitwarden CLI installed successfully to $INSTALL_PATH"
else
    echo "Bitwarden CLI is already installed. Skipping."
fi
