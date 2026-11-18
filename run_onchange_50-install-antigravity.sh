#!/usr/bin/env bash

set -e
export DEBIAN_FRONTEND=noninteractive

echo "==> Provisioning Antigravity CLI"

# Install the native binary
if ! command -v agy &> /dev/null; then
    echo "Installing Google Antigravity CLI..."
    curl -fsSL https://antigravity.google/cli/install.sh | bash
else
    echo "Antigravity CLI (agy) is already present. Skipping binary install."
fi

SETTINGS_DIR="$HOME/.gemini/antigravity-cli"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"
mkdir -p "$SETTINGS_DIR"

python3 - "$SETTINGS_FILE" "$HOME/.local/share/chezmoi" <<'EOF'
import json
import os
import sys

settings_file, workspace = sys.argv[1], sys.argv[2]

data = {}
if os.path.exists(settings_file) and os.path.getsize(settings_file) > 0:
    try:
        with open(settings_file, "r", encoding="utf-8") as f:
            loaded = json.load(f)
            if isinstance(loaded, dict):
                data = loaded
    except Exception:
        data = {}

def merge_unique(existing, additions):
    res = list(existing) if isinstance(existing, list) else []
    seen = set(res)
    for item in additions:
        if item not in seen:
            res.append(item)
            seen.add(item)
    return res

data["enableTerminalSandbox"] = True
data["trustedWorkspaces"] = merge_unique(data.get("trustedWorkspaces"), [workspace])

perm = data.get("permission")
if not isinstance(perm, dict):
    perm = {}

allow_additions = [
    # Tier 1: File & codebase search / text processing
    "command(find)",
    "command(rg)",
    "command(fd)",
    "command(tree)",
    "command(file)",
    "command(sort)",
    "command(uniq)",
    "command(cut)",
    "command(tr)",
    "command(paste)",
    "command(awk)",
    "command(getfattr)",
    # Tier 2: Git read-only & Chezmoi inspection
    "command(git status)",
    "command(git log)",
    "command(git diff)",
    "command(git show)",
    "command(git branch)",
    "command(git remote)",
    "command(git tag)",
    "command(git stash list)",
    "command(git shortlog)",
    "command(git blame)",
    "command(git rev-parse)",
    "command(git ls-files)",
    "command(git config --get)",
    "command(git config --list)",
    "command(chezmoi status)",
    "command(chezmoi diff)",
    "command(chezmoi managed)",
    "command(chezmoi data)",
    "command(chezmoi dump-config)",
    "command(chezmoi verify)",
    # Tier 3: Debian / system / hardware diagnostics (read-only)
    "command(dpkg -l)",
    "command(dpkg -L)",
    "command(dpkg -S)",
    "command(apt-cache policy)",
    "command(apt-cache show)",
    "command(apt-cache depends)",
    "command(apt-cache search)",
    "command(systemctl status)",
    "command(systemctl is-active)",
    "command(systemctl is-enabled)",
    "command(systemctl list-units)",
    "command(journalctl)",
    "command(lspci)",
    "command(lsusb)",
    "command(lsblk)",
    "command(lscpu)",
    "command(ip addr)",
    "command(ip route)",
    "command(ip link show)",
    "command(nmcli device status)",
    "command(nmcli connection show)",
    "command(kreadconfig6)",
    # Tier 4: Safe syntax / build / test verification
    "command(bash -n)",
    "command(sh -n)",
    "command(shellcheck)",
    "command(mvn test)",
    "command(mvn test-compile)",
    "command(npm test)",
    # GitHub MCP read-only tools
    "mcp(github/get_file_contents)",
    "mcp(github/get_issue)",
    "mcp(github/get_issue_comments)",
    "mcp(github/get_pull_request)",
    "mcp(github/get_pull_request_comments)",
    "mcp(github/get_pull_request_files)",
    "mcp(github/get_pull_request_reviews)",
    "mcp(github/get_pull_request_status)",
    "mcp(github/list_branches)",
    "mcp(github/list_commits)",
    "mcp(github/list_issues)",
    "mcp(github/list_pull_requests)",
    "mcp(github/search_code)",
    "mcp(github/search_issues)",
    "mcp(github/search_repositories)",
    "mcp(github/search_users)",
]

ask_additions = [
    "command(git commit)",
    "command(git push)",
    "command(sudo)",
]

deny_additions = [
    "command(git push --force)",
    "command(git push -f)",
    "command(git reset --hard)",
]

perm["allow"] = merge_unique(perm.get("allow"), allow_additions)
perm["ask"] = merge_unique(perm.get("ask"), ask_additions)
perm["deny"] = merge_unique(perm.get("deny"), deny_additions)
data["permission"] = perm

with open(settings_file, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
    f.write("\n")

os.chmod(settings_file, 0o600)
EOF

echo "Antigravity installation and configuration complete."
