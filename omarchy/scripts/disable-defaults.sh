#!/bin/bash

set -e
echo "Disabling defaults..."

omarchy plugin disable omarchy.elsewhen
omarchy pkg drop hype

echo "Defaults disabled!"
