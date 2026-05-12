#!/bin/bash

# manu:summary=Set theme (Miasma) and related configs
# manu:group=
# manu:name=set theme

LOG="$HOME/.local/share/manu/first-run.log"
echo "$(date): Starting theme setup..."

# Set symbolic links for Nautilus action icons
sudo ln -snf /usr/share/icons/Adwaita/symbolic/actions/go-previous-symbolic.svg /usr/share/icons/Yaru/scalable/actions/go-previous-symbolic.svg
sudo ln -snf /usr/share/icons/Adwaita/symbolic/actions/go-next-symbolic.svg /usr/share/icons/Yaru/scalable/actions/go-next-symbolic.svg

# Setup user theme directory
mkdir -p ~/.config/manu/themes

# Chromium policy directory for theme
sudo mkdir -p /etc/chromium/policies/managed
sudo chmod a+rw /etc/chromium/policies/managed

# Apply the initial theme using the custom tool
manu-theme-set "Miasma"

# Remove Chromium singleton lock (prevents issues if the session crashed or was owned by archiso)
rm -f ~/.config/chromium/SingletonLock

# Link theme-specific configurations for terminal and notification apps
mkdir -p ~/.config/btop/themes
ln -snf ~/.config/manu/current/theme/btop.theme ~/.config/btop/themes/current.theme

mkdir -p ~/.config/mako
ln -snf ~/.config/manu/current/theme/mako.ini ~/.config/mako/config

# Default Chromium to follow system appearance ("device") instead of dark
echo '{"browser":{"theme":{"color_scheme":0,"color_scheme2":0}}}' | sudo tee /usr/lib/chromium/initial_preferences >/dev/null

echo "$(date): Theme setup finished."
