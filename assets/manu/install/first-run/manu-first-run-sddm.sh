#!/bin/bash

LOG="$HOME/.local/share/manu/first-run.log"
echo "$(date): Starting SDDM setup..."

# Refresh SDDM theme, install packages, and clean up tty1 autologin leftovers
manu-refresh-sddm

# Deploy Wayland session entry for SDDM
sudo mkdir -p /usr/local/share/wayland-sessions
sudo cp "$MANU_PATH/default/wayland-sessions/hypruccin.desktop" /usr/local/share/wayland-sessions/hypruccin.desktop
sudo cp "$MANU_PATH/default/sddm/hyprland.conf" /usr/share/sddm/hyprland.conf

# Configure SDDM to use Wayland backend
sudo mkdir -p /etc/sddm.conf.d
cat <<EOF | sudo tee /etc/sddm.conf.d/10-wayland.conf >/dev/null
[General]
DisplayServer=wayland

[Wayland]
CompositorCommand=start-hyprland -- --config /usr/share/sddm/hyprland.conf
EOF

# Enable autologin with hypruccin session and theme
cat <<EOF | sudo tee /etc/sddm.conf.d/autologin.conf >/dev/null
[Autologin]
User=$USER
Session=hypruccin

[Theme]
Current=hypruccin
EOF

# Drop gnome-keyring PAM entries to avoid conflicts with passwordless Default_keyring
sudo sed -i '/-auth.*pam_gnome_keyring\.so/d' /etc/pam.d/sddm
sudo sed -i '/-password.*pam_gnome_keyring\.so/d' /etc/pam.d/sddm

# Enable SDDM service (skip --now to avoid issues in chroot / manual installs)
sudo systemctl enable sddm.service

echo "$(date): SDDM setup completed."
