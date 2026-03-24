#!/usr/bin/env bash

set -e

echo "Installing Zoom"

export DEBIAN_FRONTEND=noninteractive

ZOOM_PACKAGE_URL="https://zoom.us/client/latest/zoom_amd64.deb"
ZOOM_PACKAGE_PATH="$HOME/zoom_amd64.deb"

curl -s -L -o "$ZOOM_PACKAGE_PATH" "$ZOOM_PACKAGE_URL"
sudo apt --fix-broken -y install "$ZOOM_PACKAGE_PATH"
rm -f "$ZOOM_PACKAGE_PATH"

echo "Finished installing Zoom"
