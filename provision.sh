#!/usr/bin/env bash

# Ensure BW is installed (runs your existing install script)
./run_before_00-install-bitwarden-cli.sh

# Log in and unlock Bitwarden vault
if [[ "$(bw status | jq -r .status)" == "unauthenticated" ]]; then
    bw login
fi

# Export session to the CURRENT terminal
export BW_SESSION=$(bw unlock --raw)

chezmoi apply --force
