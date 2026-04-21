#!/usr/bin/env bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "Installing SDKMan and sdks"

if [[ ! -f "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
  echo 'SDKMan not found, installing'

  curl -s "https://get.sdkman.io" | bash
fi

source "$HOME/.sdkman/bin/sdkman-init.sh"

if [[ ! -d "$HOME/.sdkman/candidates/java/21.0.8-zulu" ]]; then
    sdk install java 21.0.8-zulu
fi

if [[ ! -d "$HOME/.sdkman/candidates/maven/3.9.9" ]]; then
    sdk install maven 3.9.9
fi

echo "Finished installing SDKMan and sdks"
