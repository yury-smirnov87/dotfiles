#!/usr/bin/env bash

set -e
export DEBIAN_FRONTEND=noninteractive

echo "==> Provisioning Antigravity CLI"

# Install the native binary
if ! command -v agy &> /dev/null; then
    echo "Installing Google Antigravity CLI..."
    curl -fsSL https://antigravity.google/cli/install.sh | bash
else
    echo "Antigravity CLI (agy) is already present. Skipping."
fi

echo "Antigravity installation complete."
