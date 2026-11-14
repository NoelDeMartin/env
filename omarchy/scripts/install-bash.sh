#!/bin/bash

set -e
echo "Installing Bash config..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_BASH_DIR="$(cd "$SCRIPT_DIR/../../bash" && pwd)"
BASHRC_FILE="$HOME/.bashrc"
BASH_ALIASES_TARGET="$HOME/.bash_aliases"
BASH_ALIASES_SOURCE="$REPO_BASH_DIR/.bash_aliases"
BASHRC_SOURCE_LINE="source \"$REPO_BASH_DIR/.bashrc\""
ALIASES_SOURCE_LINE="[ -f \"$BASH_ALIASES_TARGET\" ] && source \"$BASH_ALIASES_TARGET\""

ln -sf "$BASH_ALIASES_SOURCE" "$BASH_ALIASES_TARGET"
echo "Linked $BASH_ALIASES_TARGET -> $BASH_ALIASES_SOURCE"

touch "$BASHRC_FILE"

ensure_bashrc_line() {
	local line="$1"
	if grep -Fxq "$line" "$BASHRC_FILE"; then
		echo "Already configured in $BASHRC_FILE: $line"
	else
		echo "" >>"$BASHRC_FILE"
		echo "$line" >>"$BASHRC_FILE"
		echo "Added to $BASHRC_FILE: $line"
	fi
}

ensure_bashrc_line "$BASHRC_SOURCE_LINE"
ensure_bashrc_line "$ALIASES_SOURCE_LINE"

echo "Bash config was installed!"
