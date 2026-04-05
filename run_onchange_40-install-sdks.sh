#!/usr/bin/env bash

set -e

echo "Installing SDKMan and sdks"

export DEBIAN_FRONTEND=noninteractive

if [[ ! -f "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
  echo 'SDKMan not found, installing'
  
  curl -s "https://get.sdkman.io" | bash
fi

source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 21.0.8-zulu
sdk install maven 3.9.9

echo "Finished installing SDKMan and sdks"
