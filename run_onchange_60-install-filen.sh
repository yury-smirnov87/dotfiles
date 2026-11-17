#!/usr/bin/env bash
set -e
export DEBIAN_FRONTEND=noninteractive

# 1. Idempotency Guard: Check if filen or filen-desktop is already installed via dpkg
if ! dpkg -l | grep -qE "^ii  (filen|filen-desktop)\b"; then
    echo "Filen Desktop not found, downloading and installing..."

    FILEN_PACKAGE_URL="https://cdn.filen.io/@filen/desktop/release/latest/Filen_linux_amd64.deb"
    FILEN_PACKAGE_PATH="/tmp/filen_linux_amd64.deb"

    curl -s -L -o "$FILEN_PACKAGE_PATH" "$FILEN_PACKAGE_URL"

    sudo apt-get update -q
    sudo apt-get install -y -q "$FILEN_PACKAGE_PATH"
    sudo apt-get install -f -y -q

    rm -f "$FILEN_PACKAGE_PATH"

    echo "Finished installing Filen Desktop"
else
    echo "Filen Desktop is already installed. Skipping."
fi

# 2. Create folder for future mapping
mkdir -p "$HOME/filen"

