#!/bin/bash

# manu:summary=First run restore visudo
# manu:group=
# manu:name=first run restore visudo

LOG="$HOME/.local/share/manu/first-run.log"
echo "$(date): Restoring sudoers to restricted permissions..."

# We use 'manu-first-run' to overwrite the temporary global permissions
SUDOERS_FILE="/etc/sudoers.d/manu-first-run"

# Permissions kept for daily theme changes and power management
# Added: gtk-update-icon-cache, ln, mkdir, chmod for theming support
NEW_SUDOERS="manu ALL=(ALL) NOPASSWD: /usr/bin/powerprofilesctl, /usr/bin/tee, /usr/bin/gtk-update-icon-cache, /usr/bin/ln, /usr/bin/mkdir, /usr/bin/chmod"

# Overwrite the temporary file with restricted permissions
echo "$NEW_SUDOERS" | sudo /usr/bin/tee "$SUDOERS_FILE" >/dev/null

# Final check and security fix
if [ $? -eq 0 ]; then
  sudo chmod 0440 "$SUDOERS_FILE"
  echo "$(date): Sudoers restricted successfully in $SUDOERS_FILE."
else
  echo "$(date): ERROR: Failed to restore sudoers."
  exit 1
fi
