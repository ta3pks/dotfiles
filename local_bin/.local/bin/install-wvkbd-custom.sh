#!/bin/bash
# Builds custom wvkbd with:
#   - Ctr/Alt/Sup on bottom row (both portrait & landscape)
#   - All four arrow keys on main layout, grouped together
#   - No Cmp key
set -e

SRCDIR="$(dirname "$0")"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

cd "$TMPDIR"
git clone https://github.com/jjsullivan5196/wvkbd.git --depth 1

# Replace layout with our custom one
cp "$SRCDIR/wvkbd-layout.mobintl.h" wvkbd/layout.mobintl.h

cd wvkbd
make -j$(nproc)
mkdir -p "$HOME/.local/bin"
cp wvkbd-mobintl "$HOME/.local/bin/wvkbd-mobintl-custom"
echo "Installed $HOME/.local/bin/wvkbd-mobintl-custom"
