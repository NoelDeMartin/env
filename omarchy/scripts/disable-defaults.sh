#!/bin/bash

set -e
echo "Disabling defaults..."

omarchy plugin disable omarchy.elsewhen
omarchy pkg drop hype aether
omarchy-remove-dictation-superwhisper
mise uninstall --all gh

for app in "Discord" "Zoom" "Basecamp" "Google Photos" "Google Messages" "Google Maps" "YouTube" "X" "WhatsApp" "Google Contacts" "HEY"; do
	OMARCHY_REMOVE_NOTIFY=false omarchy webapp remove "$app"
done

echo "Defaults disabled!"
