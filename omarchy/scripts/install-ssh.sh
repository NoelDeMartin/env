#!/bin/bash

set -e
echo "Installing SSH key..."

SSH_DIR="$HOME/.ssh"
SSH_KEY="$SSH_DIR/id_ed25519"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [ -f "$SSH_KEY" ]; then
    echo "Reusing existing SSH key: $SSH_KEY"
else
    ssh_comment="$(id -un)@$(uname -n)"

    echo "No SSH key found at $SSH_KEY, generating an ed25519 key ($ssh_comment)..."
    ssh-keygen -t ed25519 -C "$ssh_comment" -f "$SSH_KEY"

    if [ -f "$SSH_KEY.pub" ]; then
        echo ""
        echo "Add this SSH public key to your GitHub settings:"
        cat "$SSH_KEY.pub"
    fi
fi

echo "SSH key setup complete!"
