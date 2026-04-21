#!/usr/bin/env bash
set -e
export DEBIAN_FRONTEND=noninteractive

# 1. Idempotency Guard: Check if zoom is already installed via dpkg
if ! dpkg -l | grep -q "^ii  zoom"; then
    echo "Zoom not found, downloading and installing..."

    ZOOM_PACKAGE_URL="https://zoom.us/client/latest/zoom_amd64.deb"
    ZOOM_PACKAGE_PATH="/tmp/zoom_amd64.deb"

    curl -s -L -o "$ZOOM_PACKAGE_PATH" "$ZOOM_PACKAGE_URL"

    sudo apt-get update -q
    sudo apt-get install -y -q "$ZOOM_PACKAGE_PATH"
    sudo apt-get install -f -y -q

    rm -f "$ZOOM_PACKAGE_PATH"

    echo "Finished installing Zoom"
else
    echo "Zoom is already installed. Skipping."
fi
