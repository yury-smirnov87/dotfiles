#!/usr/bin/env bash

set -e
export DEBIAN_FRONTEND=noninteractive

echo "==> Provisioning Node.js Infrastructure"

# Install FNM if missing
if [ ! -d "$HOME/.local/share/fnm" ]; then
    echo "Installing Fast Node Manager (fnm)..."
    curl -fsSL https://fnm.vercel.app/install | bash
else
    echo "FNM is already installed. Skipping."
fi

# Load FNM purely inside this subshell to download Node
export FNM_DIR="$HOME/.local/share/fnm"
export PATH="$FNM_DIR:$PATH"
eval "$(fnm env --use-on-cd)"

echo "Ensuring Node.js LTS is installed and active..."
fnm install --lts
fnm use lts-latest

echo "Node.js infrastructure successfully configured."
