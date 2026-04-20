#!/usr/bin/env bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "Configuring additional repositories"

sudo apt-get install -y wget gpg lsb-release sed

# 1. Update main sources to include contrib/non-free
if ! grep -qE "\bnon-free($|[[:space:]])\b" /etc/apt/sources.list; then
    echo "Updating sources.list to include contrib and non-free..."
    sudo sed -i -E "s/^(deb(-src)? +[^ ]+ +[^ ]+ +)main.*/\1 main contrib non-free non-free-firmware/" /etc/apt/sources.list
fi


# Function to safely add a repo only if the list doesn't exist
add_repo() {
    local name=$1
    local key_url=$2
    local repo_line=$3
    local keyring="/etc/apt/keyrings/${name}.gpg"
    local listfile="/etc/apt/sources.list.d/${name}.list"

    if [[ ! -f "$keyring" ]]; then
        echo "Adding $name GPG key..."
        wget -qO - "$key_url" | sudo gpg --dearmor -o "$keyring"
        sudo chmod 644 "$keyring"
    fi

    if [[ ! -f "$listfile" ]]; then
        echo "Adding $name repository list..."
        echo "$repo_line" | sudo tee "$listfile" > /dev/null
    fi
}

sudo mkdir -p /etc/apt/keyrings

# 2. XanMod
add_repo "xanmod" \
    "https://dl.xanmod.org/archive.key" \
    "deb [signed-by=/etc/apt/keyrings/xanmod.gpg] http://deb.xanmod.org $(lsb_release -sc) main non-free"

# 3. Dropbox (Fixed: de-armor the key)
add_repo "dropbox" \
    "https://linux.dropbox.com/fedora/rpm-public-key.asc" \
    "deb [signed-by=/etc/apt/keyrings/dropbox.gpg] http://linux.dropbox.com/debian $(lsb_release -sc) main"

# 4. WezTerm
add_repo "wezterm" \
    "https://apt.fury.io/wez/gpg.key" \
    "deb [signed-by=/etc/apt/keyrings/wezterm.gpg] https://apt.fury.io/wez/ * *"

sudo apt-get update

echo "Finished configuring additional repositories"
