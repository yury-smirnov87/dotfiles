#!/usr/bin/env bash
set -e

# Ensure local bin directory exists and is in PATH
mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

# Ensure prerequisite (git) is installed
if ! command -v git &> /dev/null; then
    echo "Missing required prerequisite: git"
    echo "Installing git via apt-get..."

    SUDO=""
    if [ "$EUID" -ne 0 ]; then
        if command -v sudo &> /dev/null; then
            SUDO="sudo"
        else
            echo "Error: sudo is not installed and script is not run as root. Cannot install packages." >&2
            exit 1
        fi
    fi

    $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y git
fi

# Idempotently install chezmoi
if ! command -v chezmoi &> /dev/null; then
    echo "Installing chezmoi..."
    sh -c "$(wget -qO- https://chezmoi.io/get)" -- -b "$HOME/.local/bin"
fi

# Bitwarden credentials configuration
# Supports environment variables (BW_CLIENTID, BW_CLIENTSECRET, BW_PASSWORD) or prompts via /dev/tty
BW_CLIENTID="${BW_CLIENTID:-}"
BW_CLIENTSECRET="${BW_CLIENTSECRET:-}"
BW_PASSWORD="${BW_PASSWORD:-}"

# Ensure BW is installed (runs your existing install script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
if [ -f "$SCRIPT_DIR/run_before_00-install-bitwarden-cli.sh" ]; then
    "$SCRIPT_DIR/run_before_00-install-bitwarden-cli.sh"
elif [ -f "$HOME/.local/share/chezmoi/run_before_00-install-bitwarden-cli.sh" ]; then
    "$HOME/.local/share/chezmoi/run_before_00-install-bitwarden-cli.sh"
fi

# 1. Authenticate with Bitwarden using Personal API Key (bypasses 2FA prompts)
if bw status | grep -q '"status":"unauthenticated"'; then
    if [ -z "$BW_CLIENTID" ]; then
        if [ -e /dev/tty ]; then
            read -r -p "Enter Bitwarden Client ID: " BW_CLIENTID < /dev/tty
        else
            echo "Error: BW_CLIENTID is required for API key authentication." >&2
            exit 1
        fi
    fi
    export BW_CLIENTID

    if [ -z "$BW_CLIENTSECRET" ]; then
        if [ -e /dev/tty ]; then
            read -s -r -p "Enter Bitwarden Client Secret: " BW_CLIENTSECRET < /dev/tty
            echo ""
        else
            echo "Error: BW_CLIENTSECRET is required for API key authentication." >&2
            exit 1
        fi
    fi
    export BW_CLIENTSECRET

    echo "Logging into Bitwarden with API key..."
    bw login --apikey

    # Clean up client secret from environment
    unset BW_CLIENTSECRET
fi

# 2. Unlock Bitwarden vault to obtain session key
if bw status | grep -q '"status":"locked"'; then
    if [ -z "$BW_PASSWORD" ]; then
        if [ -e /dev/tty ]; then
            read -s -r -p "Enter Bitwarden master password: " BW_PASSWORD < /dev/tty
            echo ""
        else
            echo "Error: Bitwarden password is required but no interactive TTY is available." >&2
            exit 1
        fi
    fi
    export BW_PASSWORD

    echo "Unlocking Bitwarden vault..."
    export BW_SESSION=$(bw unlock --passwordenv BW_PASSWORD --raw)

    # Clean up master password from environment
    unset BW_PASSWORD
fi

# 3. Verify session key
if [ -z "${BW_SESSION:-}" ]; then
    echo "Error: Failed to obtain Bitwarden session key." >&2
    exit 1
fi

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
