#!/bin/bash

set -e
echo "Installing overrides..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_HYPR_DIR="$SCRIPT_DIR/../hypr"
LOCAL_ENV_FILE="$SCRIPT_DIR/../local/.env"
UWSM_CONFIG="$HOME/.config/uwsm/env.d/99-overrides"
LEGACY_UWSM_CONFIG="$HOME/.config/uwsm/default"
HERDR_CONFIG="$HOME/.config/herdr/config.toml"
OVERRIDES_SCRIPT="$SCRIPT_DIR/../overrides.sh"
HYPRLAND_CONFIG="$HOME/.config/hypr/hyprland.lua"
MONITORS_CONFIG="$HOME/.config/hypr/monitors.lua"
SCRIPT_SOURCE_LINE=". $OVERRIDES_SCRIPT"
HYPR_FILES=(bindings.lua input.lua looknfeel.lua)

is_number() {
    [[ "$1" =~ ^[0-9]+(\.[0-9]+)?$ ]]
}

if [ -f "$LOCAL_ENV_FILE" ]; then
    set -a
    # shellcheck disable=SC1090
    . "$LOCAL_ENV_FILE"
    set +a
    echo "Loaded local overrides from $LOCAL_ENV_FILE"
fi

if [ ! -f "$HYPRLAND_CONFIG" ]; then
    echo "Hyprland config not found at $HYPRLAND_CONFIG"
    echo "Please install hyprland first"
    exit 1
fi

if ! command -v uwsm >/dev/null 2>&1; then
    echo "uwsm not found"
    echo "Please install uwsm first"
    exit 1
fi

for config_file in "${HYPR_FILES[@]}"; do
    source_file="$REPO_HYPR_DIR/$config_file"
    target_file="$HOME/.config/hypr/$config_file"
    ln -sf "$source_file" "$target_file"
    echo "Linked $target_file -> $source_file"
done

if [ -n "${MONITOR_SCALE:-}" ] && [ "$MONITOR_SCALE" != "auto" ] && ! is_number "$MONITOR_SCALE"; then
    echo "Invalid MONITOR_SCALE ($MONITOR_SCALE), expected a number or \"auto\""
    exit 1
fi

if [ -n "${GDK_SCALE:-}" ] && ! is_number "$GDK_SCALE"; then
    echo "Invalid GDK_SCALE ($GDK_SCALE), expected a number"
    exit 1
fi

if [ -f "$MONITORS_CONFIG" ]; then
    if [ -n "${MONITOR_SCALE:-}" ]; then
        if [ "$MONITOR_SCALE" = "auto" ]; then
            lua_monitor_scale='"auto"'
        else
            lua_monitor_scale="$MONITOR_SCALE"
        fi
        sed -i "s/^local omarchy_monitor_scale = .*/local omarchy_monitor_scale = $lua_monitor_scale/" "$MONITORS_CONFIG"
        echo "Configured monitor scale ($MONITOR_SCALE) in $MONITORS_CONFIG"
    fi

    if [ -n "${GDK_SCALE:-}" ]; then
        sed -i "s/^local omarchy_gdk_scale = .*/local omarchy_gdk_scale = $GDK_SCALE/" "$MONITORS_CONFIG"
        echo "Configured GDK_SCALE ($GDK_SCALE) in $MONITORS_CONFIG"
    fi
fi

if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
    if hyprctl reload >/dev/null 2>&1; then
        echo "Reloaded Hyprland config"
    else
        echo "Warning: failed to reload Hyprland config, run \`hyprctl reload\` manually"
    fi
fi

if [ ! -f "$HERDR_CONFIG" ] && [ -f "/usr/share/omarchy/config/herdr/config.toml" ]; then
    mkdir -p "$HOME/.config/herdr"
    cp "/usr/share/omarchy/config/herdr/config.toml" "$HERDR_CONFIG"
fi

if [ -f "$HERDR_CONFIG" ]; then
    sed -i 's/^new_cwd = .*/new_cwd = "~\/Work"/' "$HERDR_CONFIG"
    echo "Configured Herdr new_cwd override in $HERDR_CONFIG"
fi

mkdir -p "$(dirname "$UWSM_CONFIG")"
touch "$UWSM_CONFIG"

if grep -Fxq "$SCRIPT_SOURCE_LINE" "$UWSM_CONFIG"; then
    echo "UWSM overrides already configured in $UWSM_CONFIG"
else
    echo "Adding UWSM overrides to $UWSM_CONFIG"
    echo "" >> "$UWSM_CONFIG"
    echo "$SCRIPT_SOURCE_LINE" >> "$UWSM_CONFIG"
    echo "Source line added successfully"
fi

if [ -f "$LEGACY_UWSM_CONFIG" ] && grep -Fxq "$SCRIPT_SOURCE_LINE" "$LEGACY_UWSM_CONFIG"; then
    legacy_uwsm_config_tmp="$(mktemp)"
    grep -Fxv "$SCRIPT_SOURCE_LINE" "$LEGACY_UWSM_CONFIG" > "$legacy_uwsm_config_tmp" || true
    cat "$legacy_uwsm_config_tmp" > "$LEGACY_UWSM_CONFIG"
    rm "$legacy_uwsm_config_tmp"
    echo "Removed legacy UWSM overrides from $LEGACY_UWSM_CONFIG"
fi

echo "Setting default browser..."
xdg-mime default firefox.desktop x-scheme-handler/http
xdg-mime default firefox.desktop x-scheme-handler/https
xdg-mime default firefox.desktop text/html

echo "Overrides were installed!"
