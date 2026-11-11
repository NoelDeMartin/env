#!/bin/bash

# Applies vscode/custom.css to VSCode, doing the same as the "Reload Custom CSS and JS" command
# from the Custom CSS extension with its settings from vscode/settings.json (custom.css as the only
# import, and the status bar indicator enabled). VSCode updates undo the patch, so this also runs
# as an Omarchy post-update hook (see install-vscode.sh).

set -e

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
CSS_FILE="$(cd "$SCRIPT_DIR/../../vscode" && pwd)/custom.css"
WORKBENCH_DIR="${VSCODE_WORKBENCH_DIR:-/usr/share/code/resources/app/out/vs/code/electron-browser/workbench}"
HTML_FILE="$WORKBENCH_DIR/workbench.html"
PRODUCT_FILE="${VSCODE_PRODUCT_FILE:-$WORKBENCH_DIR/../../../../../product.json}"
INDICATOR_FILE="$(ls -d "$HOME"/.vscode/extensions/be5invis.vscode-custom-css-*/src/statusbar.js 2> /dev/null | sort -V | tail -n 1)"

if [ ! -f "$HTML_FILE" ]; then
    echo "VSCode workbench not found at $HTML_FILE, skipping Custom CSS"
    exit 0
fi

# The extension needs to own these files in order to patch them from within VSCode.
if [ -n "$(find "$WORKBENCH_DIR" "$PRODUCT_FILE" ! -user "$(id -un)" -print -quit)" ]; then
    sudo chown -R "$(id -un)" "$WORKBENCH_DIR" "$PRODUCT_FILE"
fi

# Remove any previous patch, the same way the extension does.
clean_html() {
    perl -0pe '
        s/<!-- !! VSCODE-CUSTOM-CSS-START !! -->.*?<!-- !! VSCODE-CUSTOM-CSS-END !! -->\n*//s;
        s/<!-- !! VSCODE-CUSTOM-CSS-SESSION-ID [\w-]+ !! -->\n*//g;
        s/<script>\/\* eslint-env browser \*\/.*?__CUSTOM_CSS_JS_INDICATOR_CLS.*?<\/script>\n*//gs;
    '
}

patch_html() {
    SESSION_ID="$1" CSS_FILE="$CSS_FILE" INDICATOR_FILE="$INDICATOR_FILE" perl -0pe '
        sub slurp { local (@ARGV, $/) = (shift); scalar <> }

        my $css = slurp($ENV{CSS_FILE});
        my $inject = "<!-- !! VSCODE-CUSTOM-CSS-SESSION-ID $ENV{SESSION_ID} !! -->\n"
            . "<!-- !! VSCODE-CUSTOM-CSS-START !! -->\n"
            . "<style>$css</style>"
            . "<!-- !! VSCODE-CUSTOM-CSS-END !! -->\n";

        s/<meta\s+http-equiv="Content-Security-Policy".*?\/>//s;
        s/<\/head>/$inject<\/head>/;

        if ($ENV{INDICATOR_FILE}) {
            my $indicator = slurp($ENV{INDICATOR_FILE});
            s/<\/body>/<script>$indicator<\/script>\n<\/body>/;
        }
    '
}

# Reuse the current session id, so that nothing changes when the patch is already up to date.
session_id="$(grep -oP 'VSCODE-CUSTOM-CSS-SESSION-ID \K[0-9a-fA-F-]+' "$HTML_FILE" | head -n 1 || true)"
session_id="${session_id:-$(uuidgen)}"
backup_file="$WORKBENCH_DIR/workbench.$session_id.bak-custom-css"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

clean_html < "$HTML_FILE" > "$tmp_dir/clean.html"
patch_html "$session_id" < "$tmp_dir/clean.html" > "$tmp_dir/patched.html"

if ! grep -q "VSCODE-CUSTOM-CSS-START" "$tmp_dir/patched.html"; then
    echo "⚠️  Could not patch $HTML_FILE, has its format changed?"
    exit 1
fi

if [ -f "$backup_file" ] && cmp -s "$tmp_dir/patched.html" "$HTML_FILE"; then
    echo "VSCode Custom CSS is already up to date"
else
    # An existing backup is kept, because cleaning a patched file doesn't bring back everything the
    # patch removed (such as the Content-Security-Policy).
    if [ ! -f "$backup_file" ]; then
        rm -f "$WORKBENCH_DIR"/*.bak-custom-css
        cat "$tmp_dir/clean.html" > "$backup_file"
    fi

    cat "$tmp_dir/patched.html" > "$HTML_FILE"

    echo "VSCode Custom CSS was applied! Restart VSCode to see the changes."
fi

# VSCode compares its files against the checksums in product.json, and complains that the
# installation is corrupt when they don't match. Update the checksum of the patched file.
checksum="$(openssl dgst -sha256 -binary "$HTML_FILE" | base64 | tr -d '=')"
checksum_key="vs/code/electron-browser/workbench/workbench.html"

if ! grep -q "\"$checksum_key\": \"[^\"]*\"" "$PRODUCT_FILE"; then
    echo "⚠️  Could not find the workbench checksum in $PRODUCT_FILE, has its format changed?"
    exit 1
fi

if ! grep -qF "\"$checksum_key\": \"$checksum\"" "$PRODUCT_FILE"; then
    sed "s|\"$checksum_key\": \"[^\"]*\"|\"$checksum_key\": \"$checksum\"|" "$PRODUCT_FILE" > "$tmp_dir/product.json"
    cat "$tmp_dir/product.json" > "$PRODUCT_FILE"

    echo "VSCode checksums were updated!"
fi
