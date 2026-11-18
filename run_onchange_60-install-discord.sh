#!/usr/bin/env bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "Installing Discord"

if ! dpkg -l | grep -q "^ii  discord"; then
    echo "Discord not found, downloading and installing..."

    DISCORD_URL="https://discord.com/api/download?platform=linux&format=deb"
    DISCORD_PATH="/tmp/discord.deb"

    curl -s -L -o "$DISCORD_PATH" "$DISCORD_URL"

    sudo apt-get update -q
    sudo apt-get install -y -q "$DISCORD_PATH"
    sudo apt-get install -f -y -q

    rm -f "$DISCORD_PATH"

    echo "Finished installing Discord"
else
    echo "Discord is already installed. Skipping."
fi
