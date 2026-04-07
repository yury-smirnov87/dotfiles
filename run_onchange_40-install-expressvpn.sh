#!/usr/bin/env bash

set -e

echo "Installing ExpressVPN"

export DEBIAN_FRONTEND=noninteractive

INSTALLER_URL="https://www.expressvpn.works/clients/linux/expressvpn-linux-universal-14.0.0.12844_release.run"
INSTALLER_FILE="$HOME/expressvpn-linux-universal.run"

if [[ ! -f "$INSTALLER_FILE" ]]; then

echo 'Downloading expressvpn installer'
curl -s -L -o "$INSTALLER_FILE" "$INSTALLER_URL"

fi;

sh "$INSTALLER_FILE"

rm -f "$INSTALLER_FILE"

echo "Finished installing ExpressVPN"
