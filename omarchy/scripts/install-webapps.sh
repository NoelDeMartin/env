#!/bin/bash

set -e
echo "Installing web apps..."

omarchy webapp install "Media Kraken" "https://noeldemartin.github.io/media-kraken/" ""
omarchy webapp install "Umai" "https://umai.noeldemartin.com/" ""
omarchy webapp install "Focus" "https://focus.noeldemartin.com/" ""

echo "Web apps were installed!"
