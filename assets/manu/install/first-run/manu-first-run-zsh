#!/bin/bash

# manu:summary=First run zsh
# manu:group=
# manu:name=first run zsh

LOG="$HOME/.local/share/manu/first-run.log"
SOURCE_DIR="/mnt/Dati/Dati/MSI-Z790/LinuxWorld/MY-HYPRLAND/zsh-Modular"
echo "$(date): Starting ZSH configuration..."

# Copy .zsh folder and .zshrc to Home
if [ -d "$SOURCE_DIR/.zsh" ] && [ -f "$SOURCE_DIR/.zshrc" ]; then
  echo "$(date): Copying .zsh folder and .zshrc to Home..."
  cp -rf "$SOURCE_DIR/.zsh" "$HOME/"
  cp -f "$SOURCE_DIR/.zshrc" "$HOME/"
else
  echo "$(date): ERROR: .zsh folder or .zshrc not found in $SOURCE_DIR"
fi
echo "$(date): ZSH configuration completed."
