#!/bin/bash

set -e
echo "Installing overrides..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYPRLAND_CONFIG="$HOME/.config/hypr/hyprland.conf"
UWSM_CONFIG="$HOME/.config/uwsm/default"
OVERRIDES_CONFIG="$SCRIPT_DIR/../overrides.conf"
OVERRIDES_SCRIPT="$SCRIPT_DIR/../overrides.sh"
CONFIG_SOURCE_LINE="source = $OVERRIDES_CONFIG"
SCRIPT_SOURCE_LINE=". $OVERRIDES_SCRIPT"

# Check if hyprland config exists
if [ ! -f "$HYPRLAND_CONFIG" ]; then
    echo "Hyprland config not found at $HYPRLAND_CONFIG"
    echo "Please install hyprland first"
    exit 1
fi

# Check if uwsm config exists
if [ ! -f "$UWSM_CONFIG" ]; then
    echo "UWSM config not found at $UWSM_CONFIG"
    echo "Please install uwsm first"
    exit 1
fi

# Check if overrides config exists
if [ ! -f "$OVERRIDES_CONFIG" ]; then
    echo "Overrides config not found at $OVERRIDES_CONFIG"
    exit 1
fi

# Check if overrides script exists
if [ ! -f "$OVERRIDES_SCRIPT" ]; then
    echo "Overrides script not found at $OVERRIDES_SCRIPT"
    exit 1
fi

# Check if source line already exists in hyprland.conf
if grep -Fxq "$CONFIG_SOURCE_LINE" "$HYPRLAND_CONFIG"; then
    echo "Source line already exists in $HYPRLAND_CONFIG"
else
    echo "Adding source line to $HYPRLAND_CONFIG"
    echo "" >> "$HYPRLAND_CONFIG"
    echo "$CONFIG_SOURCE_LINE" >> "$HYPRLAND_CONFIG"
    echo "Source line added successfully"
fi

# Check if source line already exists in uwsm.conf
if grep -Fxq "$SCRIPT_SOURCE_LINE" "$UWSM_CONFIG"; then
    echo "Source line already exists in $UWSM_CONFIG"
else
    echo "Adding source line to $UWSM_CONFIG"
    echo "" >> "$UWSM_CONFIG"
    echo "$SCRIPT_SOURCE_LINE" >> "$UWSM_CONFIG"
    echo "Source line added successfully"
fi

echo "Setting default browser..."
xdg-settings set default-web-browser firefox.desktop

echo "Overrides were installed!"
