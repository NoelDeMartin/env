#!/bin/bash

set -e
echo "Installing web apps..."

install_webapp() {
	local name="$1"
	local url="$2"

	if [ -f "$HOME/.local/share/applications/$name.desktop" ]; then
		echo "$name is already installed"
		return
	fi

	omarchy webapp install "$name" "$url" ""
}

install_webapp "Media Kraken" "https://noeldemartin.github.io/media-kraken/"
install_webapp "Umai" "https://umai.noeldemartin.com/"
install_webapp "Focus" "https://focus.noeldemartin.com/"
install_webapp "Photopea" "https://www.photopea.com/"

echo "Web apps were installed!"
