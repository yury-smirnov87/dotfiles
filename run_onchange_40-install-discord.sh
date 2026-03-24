#!/usr/bin/env bash

set -e

echo "Installing discord"

export DEBIAN_FRONTEND=noninteractive

DISCORD_URL="https://discord.com/api/download?platform=linux&format=deb"
DISCORD_PATH="$HOME/discord.deb"

curl -s -L -o "$DISCORD_PATH" "$DISCORD_URL"
sudo apt --fix-broken -y install "$DISCORD_PATH"
rm -f "$DISCORD_PATH"

echo "Finished installing discord"
