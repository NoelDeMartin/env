#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing everything..."

. $SCRIPT_DIR/install-overrides.sh

echo "Everything was installed!"
