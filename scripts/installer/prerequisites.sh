#!/bin/bash

# Get the directory of the current script
BASE_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")/../../")

# Source helper file
source $BASE_DIR/scripts/installer/helper.sh

log_message "Installation started for prerequisites section"
print_info "\nStarting prerequisites setup..."

# -------------------- Pacman Configuration --------------------
run_command "cp $BASE_DIR/assets/pacman.conf /etc/pacman.conf" "Setup pacman.conf with omarchy repo" "no"
run_command "pacman-key --recv-keys 40DFB630FF42BCFFB047046CF0134EE680CAC571 --keyserver keys.openpgp.org" "Receive omarchy GPG key" "no"
run_command "pacman-key --lsign-key 40DFB630FF42BCFFB047046CF0134EE680CAC571" "Sign omarchy GPG key locally" "no"
run_command "pacman -Syy --noconfirm" "Force sync pacman database" "no"
run_command "pacman -S --needed --noconfirm omarchy-keyring" "Install omarchy keyring" "no"

# -------------------- Base setup --------------------
run_command "pacman -S --needed --noconfirm reflector" "Install Reflector" "no"
run_command "reflector --country Italy --age 24 --protocol https --sort rate --save /etc/pacman.d/mirrorlist" "Update Pacman mirrorlist with fresh, fast mirrors" "no"
run_command "pacman -S --noconfirm --needed git base-devel" "Install git and base-devel (needed for AUR)" "no"

# -------------------- Yay (AUR helper) --------------------
if command -v yay >/dev/null; then
  print_info "Skipping yay installation (already installed)."
else
  run_command "git clone https://aur.archlinux.org/yay.git && cd yay" "Clone YAY (Must)/Breaks the script" "no" "no"
  run_command "makepkg --noconfirm -si && cd .." "Build YAY (Must)/Breaks the script" "no" "no"
fi

# -------------------- Network Configuration (iwd + systemd-networkd) --------------------

# Install iwd (Wi-Fi daemon) and Impala (TUI frontend)
run_command "pacman -S --needed --noconfirm iwd impala" "Install iwd and Impala" "no"

# Create networkd directory and copy config file
run_command "sudo mkdir -p /etc/systemd/network && sudo cp $BASE_DIR/assets/20-ethernet.network /etc/systemd/network/" "Create networkd directory and copy config file" "no"

# Enable all necessary services
run_command "systemctl enable iwd.service systemd-networkd.service systemd-resolved.service" "Enable network services" "no"

# Prevent systemd from waiting for a network connection on boot
run_command "sudo systemctl disable systemd-networkd-wait-online.service && sudo systemctl mask systemd-networkd-wait-online.service" "Prevent networkd wait-online timeout" "no"

# Configure DNS symlink
run_command "sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf" "Configure DNS symlink" "no"

# -------------------- Bluetooth --------------------
run_command "pacman -S --needed --noconfirm bluez bluetui && systemctl enable bluetooth.service" "Install and enable Bluetooth (Recommended)" "no"

# -------------------- Applications Installation --------------------
run_command "pacman -S --needed --noconfirm adw-gtk-theme alacritty alsa-utils bat btop cava chromium cliamp curl discord dust elephant-all evince eza fastfetch fcitx5 fcitx5-gtk fcitx5-qt fd ffmpeg ffmpegthumbnailer fzf glib2 glow gnome-themes-extra gobject-introspection gpu-screen-recorder gum gvfs gvfs-mtp gvfs-nfs gvfs-smb gst-plugin-pipewire hyprland-preview-share-picker-git imagemagick imv inotify-tools jdk-openjdk lazygit libadwaita libgsf librsvg libwebp limine-mkinitcpio-hook limine-snapper-sync localsend-bin luarocks kvantum-qt5 meld mise mpv nautilus nautilus-python neovim nodejs npm noto-fonts noto-fonts-emoji noto-fonts-cjk obsidian pacman-contrib pamixer p7zip pipewire pipewire-alsa pipewire-jack pipewire-pulse plocate power-profiles-daemon poppler-glib python-pyquery python-terminaltexteffects ripgrep spotify-launcher sd starship sushi swaybg swayosd tar tesseract tesseract-data-eng thermald tmux tree-sitter tree-sitter-cli ttf-jetbrains-mono-nerd typora udisks2 ufw unrar unzip walker wget wiremix wireplumber woff2-font-awesome xdg-terminal-exec xdg-user-dirs xsel xmlstarlet yaru-icon-theme yazi yt-dlp zoxide zsh zsh-completions zram-generator" "Install complete application suite (browsers, media, development, system tools)" "no"

# -------------------- Configuration Files --------------------
run_command "cp -r $BASE_DIR/configs/* /home/$SUDO_USER/.config/ && chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.config" "Copy all config folders" "no" "no"

# -------------------- Yazi: plugin "bat" --------------------
run_command "mkdir -p /home/$SUDO_USER/.config/yazi/plugins" \
  "Create Yazi plugins dir" "yes" "no"

run_command "bash -lc 'if [ -d /home/$SUDO_USER/.config/yazi/plugins/bat.yazi/.git ]; then git -C /home/$SUDO_USER/.config/yazi/plugins/bat.yazi pull --ff-only; else git clone --depth 1 https://github.com/mgumz/yazi-plugin-bat.git /home/$SUDO_USER/.config/yazi/plugins/bat.yazi; fi'" \
  "Install/Update Yazi plugin: bat" "yes" "no"

# -------------------- Yazi Plugin Restore --------------------
run_command "ya pkg install" \
  "Restore Yazi plugins from package.toml" "no" "no"

echo "------------------------------------------------------------------------"
print_info "Prerequisites setup completed successfully!"
