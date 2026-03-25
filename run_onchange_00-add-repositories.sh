#!/usr/bin/env bash

set -e

export DEBIAN_FRONTEND=noninteractive

echo "Configuring additional repositories"

echo "Adding contrib and non-free repositories"
echo "deb http://deb.debian.org/debian/ trixie contrib non-free" | sudo tee /etc/apt/sources.list.d/extra-repos.list

echo "Adding XanMod repository"
wget -qO - https://dl.xanmod.org/archive.key | sudo gpg --dearmor -vo /etc/apt/keyrings/xanmod-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org $(lsb_release -sc) main non-free" | sudo tee /etc/apt/sources.list.d/xanmod-release.list    

echo "Adding Dropbox repository"
wget -qO - https://linux.dropbox.com/fedora/rpm-public-key.asc | sudo tee /etc/apt/keyrings/dropbox.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/dropbox.gpg] http://linux.dropbox.com/debian trixie main" | sudo tee /etc/apt/sources.list.d/dropbox.list

sudo apt-get update

echo "Finished configuring additional repositories"
