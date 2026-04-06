#!/usr/bin/env bash

set -e

export DEBIAN_FRONTEND=noninteractive

echo "Configuring additional repositories"


APT_SOURCES_FILE="/etc/apt/sources.list"
REQUIRED_REPOS="main contrib non-free non-free-firmware"

echo "Updating $APT_SOURCES_FILE to include contrib and non-free components..."

sudo sed -i -E "s/^(deb(-src)? +[^ ]+ +[^ ]+ +)main.*/\1$REQUIRED_REPOS/" "$APT_SOURCES_FILE"

echo "Adding XanMod repository"
if [[ ! -f "/etc/apt/keyrings/xanmod-archive-keyring.gpg" ]]; then
   wget -qO - https://dl.xanmod.org/archive.key | sudo gpg --yes --dearmor -vo /etc/apt/keyrings/xanmod-archive-keyring.gpg
fi
echo "deb [signed-by=/etc/apt/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org $(lsb_release -sc) main non-free" | sudo tee /etc/apt/sources.list.d/xanmod-release.list    

echo "Adding Dropbox repository"
if [[ ! -f "/etc/apt/keyrings/dropbox.gpg" ]]; then
   wget -qO - https://linux.dropbox.com/fedora/rpm-public-key.asc | sudo tee /etc/apt/keyrings/dropbox.gpg > /dev/null
fi
echo "deb [signed-by=/etc/apt/keyrings/dropbox.gpg] http://linux.dropbox.com/debian trixie main" | sudo tee /etc/apt/sources.list.d/dropbox.list

echo "Adding WezTerm repository"
if [[ ! -f "/etc/apt/keyrings/wezterm-fury.gpg" ]]; then
   wget -qO - https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -vo /etc/apt/keyrings/wezterm-fury.gpg
   echo "Finished ending wez gpg key"
fi
echo 'deb [signed-by=/etc/apt/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
#sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg

sudo apt-get update

echo "Finished configuring additional repositories"
