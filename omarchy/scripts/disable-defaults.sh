#!/bin/bash

set -e
echo "Disabling defaults..."

omarchy plugin disable omarchy.elsewhen
omarchy pkg drop hype
omarchy-remove-dictation-superwhisper

for app in "Discord" "Zoom" "Basecamp" "Google Photos" "Google Messages" "Google Maps" "YouTube" "X" "WhatsApp" "Google Contacts" "HEY"; do
	OMARCHY_REMOVE_NOTIFY=false omarchy webapp remove "$app"
done

echo "Defaults disabled!"
