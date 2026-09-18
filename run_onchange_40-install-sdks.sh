#!/usr/bin/env bash
set -e
export DEBIAN_FRONTEND=noninteractive
export sdkman_auto_answer=true

echo "Installing SDKMan and sdks"

if [[ ! -f "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
  echo 'SDKMan not found, installing'

  curl -s "https://get.sdkman.io" | bash
fi

source "$HOME/.sdkman/bin/sdkman-init.sh"

if [[ ! -d "$HOME/.sdkman/candidates/java/25.0.4-tem" ]]; then
    sdk install java 25.0.4-tem
fi
sdk default java 25.0.4-tem

if [[ ! -d "$HOME/.sdkman/candidates/maven/3.9.16" ]]; then
    sdk install maven 3.9.16
fi
sdk default maven 3.9.16


echo "Finished installing SDKMan and sdks"
