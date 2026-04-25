#!/usr/bin/env bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "Configuring Docker Upstream Repository and Tools"

DOCKER_PACKAGES=(
    docker-ce
    docker-ce-cli
    containerd.io
    docker-buildx-plugin
    docker-compose-plugin
)

echo "Installing Docker Engine..."
sudo apt-get install -y -q --no-install-recommends "${DOCKER_PACKAGES[@]}"

if [ -n "$USER" ] && [ "$USER" != "root" ]; then
    if ! getent group docker > /dev/null; then
        sudo groupadd docker
    fi

    if ! groups "$USER" | grep -q "\bdocker\b"; then
        echo "Adding $USER to the docker group..."
        sudo usermod -aG docker "$USER"
        echo "Note: You may need to log out and back in for group changes to take effect."
    fi
fi

# 5. Enable services
sudo systemctl enable --now docker.service
sudo systemctl enable --now containerd.service

echo "Finished installing Docker"
