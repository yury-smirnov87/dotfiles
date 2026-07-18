#!/usr/bin/env bash

# Ensure local bin directory exists and is in PATH
mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

# Idempotently install chezmoi
if ! command -v chezmoi &> /dev/null; then
    echo "Installing chezmoi..."
    sh -c "$(curl -fsLS https://chezmoi.io/get)" -- -b "$HOME/.local/bin"
fi

# Ensure BW is installed (runs your existing install script)
./run_before_00-install-bitwarden-cli.sh

# Log in and unlock Bitwarden vault
if bw status | grep -q '"status":"unauthenticated"'; then
    bw login
fi

# Export session to the CURRENT terminal
export BW_SESSION=$(bw unlock --raw)

# Idempotently initialize chezmoi with HTTPS URL (no SSH key required to clone)
if [ ! -d "$HOME/.local/share/chezmoi/.git" ]; then
    echo "Initializing chezmoi with HTTPS URL..."
    chezmoi init https://github.com/yury-smirnov87/dotfiles.git
else
    echo "Chezmoi is already initialized."
fi

chezmoi apply --force

# Ensure chezmoi source directory uses SSH git repository URL now that keys are restored
chezmoi git -- remote set-url origin git@github.com:yury-smirnov87/dotfiles.git
