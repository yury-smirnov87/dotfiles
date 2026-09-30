#!/usr/bin/env bash
set -e

# Ensure local bin directory exists and is in PATH
mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

# Ensure prerequisites (curl, git) are installed
MISSING_PKGS=()
for pkg in curl git; do
    if ! command -v "$pkg" &> /dev/null; then
        MISSING_PKGS+=("$pkg")
    fi
done

if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    echo "Missing required prerequisites: ${MISSING_PKGS[*]}"
    echo "Installing missing packages via apt-get..."

    SUDO=""
    if [ "$EUID" -ne 0 ]; then
        if command -v sudo &> /dev/null; then
            SUDO="sudo"
        else
            echo "Error: sudo is not installed and script is not run as root. Cannot install packages." >&2
            exit 1
        fi
    fi

    $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y "${MISSING_PKGS[@]}"
fi

# Idempotently install chezmoi
if ! command -v chezmoi &> /dev/null; then
    echo "Installing chezmoi..."
    sh -c "$(curl -fsLS https://chezmoi.io/get)" -- -b "$HOME/.local/bin"
fi

# Bitwarden account configuration (CLI argument > env var > default)
BW_EMAIL="${1:-${BW_EMAIL:-yury.smirnov87@gmail.com}}"

# Ensure BW is installed (runs your existing install script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
if [ -f "$SCRIPT_DIR/run_before_00-install-bitwarden-cli.sh" ]; then
    "$SCRIPT_DIR/run_before_00-install-bitwarden-cli.sh"
elif [ -f "$HOME/.local/share/chezmoi/run_before_00-install-bitwarden-cli.sh" ]; then
    "$HOME/.local/share/chezmoi/run_before_00-install-bitwarden-cli.sh"
fi

# Log in and unlock Bitwarden vault (streamlined into a single prompt on fresh machines)
if bw status | grep -q '"status":"unauthenticated"'; then
    echo "Logging into Bitwarden as $BW_EMAIL..."
    export BW_SESSION=$(bw login "$BW_EMAIL" --raw)
elif bw status | grep -q '"status":"locked"'; then
    echo "Unlocking Bitwarden vault..."
    export BW_SESSION=$(bw unlock --raw)
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
