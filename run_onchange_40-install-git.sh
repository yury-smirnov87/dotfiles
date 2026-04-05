#!/usr/bin/env bash

set -e

echo "Installing Git"

export DEBIAN_FRONTEND=noninteractive

git config --global user.name "Yury Smirnov"
git config --global user.email "yury.smirnov87@gmail.com"

GIT_COMPLETION_URL="https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash"
GIT_COMPLETION_FILE="$HOME/.git-completion.bash"

if [[ -f "$GIT_COMPLETION_FILE" ]]; then
  echo 'Git autocompletions file present, skipping.'
  exit
fi

echo "Downloading git completions to $GIT_COMPLETION_FILE"

curl -s -L -o "$GIT_COMPLETION_FILE" "$GIT_COMPLETION_URL"

#TODO: check if this is already included

cat << 'EOF' >> ~/.bashrc

# Git autocompletions
GIT_COMPLETION_FILE="$HOME/.git-completion.bash"

if [ -f "$GIT_COMPLETION_FILE" ]; then
  echo "Sourcing $GIT_COMPLETION_FILE"
  source "$GIT_COMPLETION_FILE"
fi
EOF

echo "Finished installing Git"
