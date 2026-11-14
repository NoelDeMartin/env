#!/bin/bash

set -e
echo "Installing packages..."

omarchy pkg add vim

if command -v vp >/dev/null 2>&1; then
    echo "Vite+ already installed"
else
    curl -fsSL https://vite.plus | bash
fi

echo "Packages were installed!"
