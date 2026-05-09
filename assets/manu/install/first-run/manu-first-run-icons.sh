#!/bin/bash

# manu:summary=First run icons
# manu:group=
# manu:name=first run icons

LOG="$HOME/.local/share/manu/first-run.log"

echo "$(date): Starting icons installation..." >>"$LOG"

# Copy all bundled icons to the applications/icons directory
ICON_DIR="$HOME/.local/share/applications/icons"
mkdir -p "$ICON_DIR"
cp ~/.local/share/manu/applications/icons/*.png "$ICON_DIR/"

echo "$(date): Icons installation completed." >>"$LOG"
