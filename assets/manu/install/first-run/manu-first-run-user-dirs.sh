#!/bin/bash

# manu:summary=First run user dirs
# manu:group=
# manu:name=first run user dirs

LOG="$HOME/.local/share/manu/first-run.log"
echo "$(date): Starting User-Dirs configuration..."

# Ensure essential user directories and config folders exist
mkdir -p ~/Downloads ~/Pictures ~/Videos ~/.config/gtk-3.0

# Redirect unused XDG user directories to HOME to keep the root clean
xdg-user-dirs-update --set TEMPLATES "$HOME"
xdg-user-dirs-update --set PUBLICSHARE "$HOME"
xdg-user-dirs-update --set DESKTOP "$HOME"

# Remove the physical directories if they are empty
# Errors are suppressed in case the folders were already deleted or contain files
rmdir ~/Templates ~/Public ~/Desktop 2>/dev/null || true

# Update GTK bookmarks for file managers
# This ensures easy access to the main folders in the sidebar
touch ~/.config/gtk-3.0/bookmarks
for dir in Downloads Projects Pictures Videos; do
  printf 'file://%s/%s %s\n' "$HOME" "$dir" "$dir" >>~/.config/gtk-3.0/bookmarks
done
echo "$(date): User-Dirs configuration finished."
