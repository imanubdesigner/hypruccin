#!/bin/bash

# manu:summary=First run gnome theme
# manu:group=
# manu:name=first run gnome theme

LOG_DIR="$HOME/.local/share/manu"
LOG="$LOG_DIR/first-run.log"

# Ensure the log directory exists
mkdir -p "$LOG_DIR"
echo "$(date): Starting GNOME theme and Matugen configuration..."

# Set GNOME interface themes
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
gsettings set org.gnome.desktop.interface gtk-enable-primary-paste true

# Update icon cache to apply changes
sudo gtk-update-icon-cache /usr/share/icons/Yaru
sleep 0.5
echo "$(date): GNOME theme configuration finished."

# -------------------- Disable WiFi at first boot --------------------
echo "$(date): Disabling WiFi..."

rfkill block wifi
echo "$(date): WiFi disabled."

# -------------------- Update desktop database --------------------
update-desktop-database ~/.local/share/applications
