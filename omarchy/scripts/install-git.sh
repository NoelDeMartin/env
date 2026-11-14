#!/bin/bash

set -e
echo "Installing Git config..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_GIT_DIR="$(cd "$SCRIPT_DIR/../../git" && pwd)"

ensure_git_config() {
    local key="$1"
    local label="$2"
    local var_name="$3"
    local value

    value="$(git config --global "$key" || true)"
    if [ -z "$value" ]; then
        read -rp "$label: " value
        if [ -z "$value" ]; then
            echo "$label is required." >&2
            exit 1
        fi
        git config --global "$key" "$value"
    fi

    printf -v "$var_name" '%s' "$value"
}

find_gpg_key() {
    gpg --list-secret-keys --with-colons "$1" 2>/dev/null | awk -F: '/^sec:/ {print $5; exit}'
}

git config --global core.excludesFile "$REPO_GIT_DIR/.gitignore"
git config --global core.editor "vim"
git config --global core.commentChar '%'
git config --global init.defaultBranch main

ensure_git_config "user.name" "Git user name" git_name
ensure_git_config "user.email" "Git user email" git_email

gpg_key="$(find_gpg_key "$git_email")"

if [ -z "$gpg_key" ]; then
    echo "No GPG key found for $git_email, generating one..."
    gpg --full-generate-key
    gpg_key="$(find_gpg_key "$git_email")"

    if [ -n "$gpg_key" ]; then
        echo ""
        echo "Add this GPG public key to your GitHub settings:"
        gpg --armor --export "$gpg_key"
    fi
else
    echo "Reusing existing GPG key: $gpg_key"
fi

if [ -n "$gpg_key" ]; then
    git config --global user.signingkey "$gpg_key"
    git config --global commit.gpgsign true
fi

echo "Git config was installed!"
