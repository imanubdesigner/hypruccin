#!/bin/bash

# manu:summary=First run tui
# manu:group=
# manu:name=first run tui

LOG="$HOME/.local/share/manu/first-run.log"
ICON_DIR="$HOME/.local/share/applications/icons"

echo "$(date): Starting TUI applications installation..."

manu-tui-install "Disk Usage" "bash -c 'dust -r; read -n 1 -s'" float "$ICON_DIR/Disk Usage.png"

echo "$(date): TUI applications installation completed."
