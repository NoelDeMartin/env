#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing everything..."

bash "$SCRIPT_DIR/install-packages.sh"
bash "$SCRIPT_DIR/install-overrides.sh"
bash "$SCRIPT_DIR/install-bash.sh"
bash "$SCRIPT_DIR/install-fonts.sh"
bash "$SCRIPT_DIR/install-git.sh"
bash "$SCRIPT_DIR/install-ssh.sh"
bash "$SCRIPT_DIR/install-vscode.sh"
bash "$SCRIPT_DIR/disable-defaults.sh"
bash "$SCRIPT_DIR/install-webapps.sh"

echo "Everything was installed!"
