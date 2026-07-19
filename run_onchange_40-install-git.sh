#!/usr/bin/env bash

set -e

echo "Installing Git"

export DEBIAN_FRONTEND=noninteractive

git config --global user.name "Yury Smirnov"
git config --global user.email "yury.smirnov87@gmail.com"
git config --global core.autocrlf input
git config --global init.defaultBranch main

GIT_COMPLETION_URL="https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash"
GIT_COMPLETION_FILE="$HOME/.git-completion.bash"

if [[ ! -f "$GIT_COMPLETION_FILE" ]]; then
    echo "Downloading git completions to $GIT_COMPLETION_FILE"
    curl -s -L -o "$GIT_COMPLETION_FILE" "$GIT_COMPLETION_URL"
else
    echo "Git autocompletions file already present."
fi

echo "Finished installing Git"
