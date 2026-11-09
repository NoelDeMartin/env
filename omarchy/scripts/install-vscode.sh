#!/bin/bash

set -e
echo "Installing VSCode config..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_VSCODE_DIR="$(cd "$SCRIPT_DIR/../../vscode" && pwd)"
PROJECTS_PATH="$(cd "$REPO_VSCODE_DIR/../.." && pwd)"
VSCODE_USER_DIR="$HOME/.config/Code/User"
SETTINGS_FILE="$VSCODE_USER_DIR/settings.json"

if ! command -v code > /dev/null; then
    # Stub setsid so omarchy-install-editor-vscode doesn't open VSCode when it finishes.
    (
        setsid() { :; }
        export -f setsid
        omarchy-install-editor-vscode
    )
fi

mkdir -p "$VSCODE_USER_DIR"

# Settings are copied rather than linked because Omarchy rewrites the theme in this file.
sed "s|\[projects-path\]|$PROJECTS_PATH|g" "$REPO_VSCODE_DIR/settings.json" > "$SETTINGS_FILE"
omarchy-theme-set-vscode

echo "Copied $SETTINGS_FILE (projects path: $PROJECTS_PATH)"

ln -sf "$REPO_VSCODE_DIR/keybindings.json" "$VSCODE_USER_DIR/keybindings.json"
echo "Linked $VSCODE_USER_DIR/keybindings.json"

echo "Installing extensions..."

# Extensions that aren't published in the marketplace, installed from GitHub releases instead.
declare -A VSIX_URLS=(
    [calebporzio.simple-project-switcher]="https://github.com/calebporzio/sps/releases/download/v0.1.5/simple-project-switcher-0.1.5.vsix"
)

installed_extensions=$(code --list-extensions)
extensions=$(grep -oE '"[^"]+\.[^"]+"' "$REPO_VSCODE_DIR/extensions.json" | tr -d '"')

for extension in $extensions; do
    if grep -qix "$extension" <<< "$installed_extensions"; then
        echo "$extension is already installed"
        continue
    fi

    url="${VSIX_URLS[$extension]}"

    if [ -z "$url" ]; then
        code --install-extension "$extension" || echo "⚠️  Could not install $extension"
        continue
    fi

    vsix_dir="$(mktemp -d)"
    vsix_file="$vsix_dir/$(basename "$url")"
    curl -fsSL "$url" -o "$vsix_file" && code --install-extension "$vsix_file" \
        || echo "⚠️  Could not install $extension"
    rm -rf "$vsix_dir"
done

echo "VSCode config was installed!"
