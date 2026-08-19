#!/bin/bash

set -e
echo "Installing overrides..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_HYPR_DIR="$SCRIPT_DIR/../hypr"
UWSM_CONFIG="$HOME/.config/uwsm/default"
OVERRIDES_SCRIPT="$SCRIPT_DIR/../overrides.sh"
HYPRLAND_CONFIG="$HOME/.config/hypr/hyprland.lua"
SCRIPT_SOURCE_LINE=". $OVERRIDES_SCRIPT"
HYPR_FILES=(bindings.lua input.lua looknfeel.lua)

if [ ! -f "$HYPRLAND_CONFIG" ]; then
    echo "Hyprland config not found at $HYPRLAND_CONFIG"
    echo "Please install hyprland first"
    exit 1
fi

if [ ! -f "$UWSM_CONFIG" ]; then
    echo "UWSM config not found at $UWSM_CONFIG"
    echo "Please install uwsm first"
    exit 1
fi

for config_file in "${HYPR_FILES[@]}"; do
    source_file="$REPO_HYPR_DIR/$config_file"
    target_file="$HOME/.config/hypr/$config_file"
    ln -sf "$source_file" "$target_file"
    echo "Linked $target_file -> $source_file"
done

if grep -Fxq "$SCRIPT_SOURCE_LINE" "$UWSM_CONFIG"; then
    echo "USWM overrides already configured in $UWSM_CONFIG"
else
    echo "Adding USWM overrides to $UWSM_CONFIG"
    echo "" >> "$UWSM_CONFIG"
    echo "$SCRIPT_SOURCE_LINE" >> "$UWSM_CONFIG"
    echo "Source line added successfully"
fi

echo "Setting default browser..."
xdg-mime default firefox.desktop x-scheme-handler/http
xdg-mime default firefox.desktop x-scheme-handler/https
xdg-mime default firefox.desktop text/html

echo "Overrides were installed!"
