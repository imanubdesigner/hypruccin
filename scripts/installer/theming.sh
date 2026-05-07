#!/bin/bash

# Get the directory of the current script
BASE_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")/../../")

# Source helper file
source $BASE_DIR/scripts/installer/helper.sh

log_message "Installation started for theming + services setup"
print_info "\nStarting theming and service setup..."

# -------------------- Fonts --------------------
run_command "fc-cache -fv" "Refresh font cache" "no" "no"

# -------------------- Hyprland Toggles --------------------
# Define the base state directory for the user
MANU_STATE_DIR="/home/$SUDO_USER/.local/state/manu"

# Create the directory path if it doesn't exist
run_command "mkdir -p $MANU_STATE_DIR" "Create manu state directory" "no" "no"

# Copy the toggles folder (which contains hypr/flags.conf) from assets
run_command "cp -r $BASE_DIR/assets/toggles $MANU_STATE_DIR/" \
  "Copy Hyprland toggles configuration" "no" "no"

# Set correct ownership for the entire manu state tree to the real user
run_command "chown -R $SUDO_USER:$SUDO_USER $MANU_STATE_DIR" \
  "Set ownership for manu state directory" "no" "no"

# -------------------- Enable Bluetooth A2DP autoconnect --------------------
WIREPLUMBER_CONF_DIR="/home/$SUDO_USER/.config/wireplumber/wireplumber.conf.d"
run_command "mkdir -p $WIREPLUMBER_CONF_DIR" "Create WirePlumber config directory" "no" "no"
run_command "cp $BASE_DIR/assets/manu/default/wireplumber/wireplumber.conf.d/bluetooth-a2dp-autoconnect.conf $WIREPLUMBER_CONF_DIR/" "Copy WirePlumber Bluetooth A2DP autoconnect config" "no" "no"
run_command "chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.config/wireplumber" "Set ownership for WirePlumber config" "no" "no"

# -------------------- Zram Configuration --------------------
run_command "cp $BASE_DIR/assets/systemd/zram-generator.conf /etc/systemd/zram-generator.conf" "Copy zram-generator configuration" "no"
run_command "systemctl enable systemd-zram-setup@zram0.service" "Enable zram swap" "no"

# -------------------- Sysctl Tuning --------------------
run_command "cp $BASE_DIR/assets/sysctl/99-performance.conf /etc/sysctl.d/99-performance.conf" "Copy sysctl performance tuning" "no"
run_command "sysctl --system" "Apply sysctl settings" "no"

# -------------------- Rebuild bat cache for catppuccin mocha theme --------------------
run_command "bat cache --build" "Rebuild bat syntax highlighting cache" "no" "no"

# -------------------- Nautilus Python Extensions --------------------
NAUTILUS_PY_DIR="/home/$SUDO_USER/.local/share/nautilus-python/extensions"
run_command "mkdir -p $NAUTILUS_PY_DIR" "Create Nautilus Python extensions directory" "no" "no"
run_command "cp -r $BASE_DIR/assets/manu/default/nautilus-python/extensions/. $NAUTILUS_PY_DIR/" "Copy Nautilus Python extensions" "no" "no"
run_command "chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.local/share/nautilus-python" "Set ownership for Nautilus Python extensions" "no" "no"
run_command "nautilus -q" "Restart Nautilus" "no" "no"

# -------------------- Fast Shutdown Configuration --------------------
run_command "mkdir -p /etc/systemd/system.conf.d" "Create system.conf.d directory" "no"
run_command "mkdir -p /etc/systemd/system/user@.service.d" "Create user service override directory" "no"
run_command "cp $BASE_DIR/assets/systemd/faster-shutdown.conf /etc/systemd/system.conf.d/10-faster-shutdown.conf" "Copy system-wide faster-shutdown configuration" "no"
run_command "cp $BASE_DIR/assets/systemd/user@.service.d/faster-shutdown.conf /etc/systemd/system/user@.service.d/faster-shutdown.conf" "Copy user-level faster-shutdown configuration" "no"
run_command "systemctl daemon-reload" "Reload systemd daemon" "no"

# -------------------- Raise File Descriptor Limit --------------------
# Raise soft file descriptor limit from systemd's default of 1024 to 65536
# so dev tools (VS Code, Docker, dev servers, databases) get the headroom they need
run_command "mkdir -p /etc/systemd/system.conf.d /etc/systemd/user.conf.d" "Create systemd config directories" "no"
run_command "printf '[Manager]\nDefaultLimitNOFILESoft=65536\n' > /etc/systemd/system.conf.d/99-manu-nofile.conf" "Set soft file descriptor limit to 65536" "no"
run_command "cp /etc/systemd/system.conf.d/99-manu-nofile.conf /etc/systemd/user.conf.d/99-manu-nofile.conf" "Copy nofile config to user.conf.d" "no"

# -------------------- Power Management --------------------
run_command "systemctl enable thermald.service" "Enable thermald" "no"
run_command "systemctl enable power-profiles-daemon.service" "Enable power-profiles-daemon" "no"
run_command "echo 'manu ALL=(ALL) NOPASSWD: ALL' | tee /etc/sudoers.d/manu-first-run && chmod 0440 /etc/sudoers.d/manu-first-run" "Configure global passwordless sudo for setup" "no"

# -------------------- Set default shell --------------------
run_command "chsh -s /usr/bin/zsh $SUDO_USER" "Set default shell to zsh for user $SUDO_USER" "no" "no"

# -------------------- Override Autologin --------------------
run_command "mkdir -p /etc/systemd/system/getty@tty1.service.d" "Create TT1 directory" "no"
run_command "cp $BASE_DIR/assets/override.conf /etc/systemd/system/getty@tty1.service.d" "Copy override.conf" "no"

# -------------------- .zprofile for uwsm autologin --------------------
run_command "cp $BASE_DIR/assets/.zprofile /home/$SUDO_USER/ && chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.zprofile" "Copy zprofile configuration" "no" "no"

# -------------------- Fstab Configuration for SSD Auto Mount --------------------
FSTAB_ENTRY="# SSD Auto Mount\nUUID=0C1A3D631A3D4ACA /mnt/Dati ntfs3 defaults,noatime,nofail,windows_names,prealloc,uid=1000,gid=1000 0 0"

run_command "echo -e \"$FSTAB_ENTRY\" | tee -a /etc/fstab" \
  "Add SSD auto-mount entry to /etc/fstab" \
  "no"

# -------------------- Reflector Configuration --------------------
run_command "mkdir -p /etc/xdg/reflector && cp $BASE_DIR/assets/reflector/reflector.conf /etc/xdg/reflector/reflector.conf && mkdir -p /etc/systemd/system/reflector.timer.d && cp $BASE_DIR/assets/reflector/override.conf /etc/systemd/system/reflector.timer.d/override.conf && systemctl daemon-reload && systemctl enable reflector.timer" "Setup and enable reflector timer" "no"

# -------------------- Snapper + Snap-pac Configuration --------------------
print_bold_blue "\n=== Configuring Snapper + Snap-pac ==="

# Step 1: Copy Snapper root configuration
run_command "mkdir -p /etc/snapper/configs && cp $BASE_DIR/assets/snap/root /etc/snapper/configs/root" \
  "Copy Snapper root configuration" \
  "no"

# Step 3: Enable Snapper automatic cleanup timer
run_command "systemctl enable snapper-cleanup.timer" \
  "Enable Snapper automatic cleanup timer" \
  "no"

# -------------------- Mkinitcpio & Nvidia Configuration (BEFORE driver installation) --------------------
print_bold_blue "\n=== Preparing NVIDIA Kernel Configuration ==="

# Step 1: Copy nvidia.conf (modprobe options)
run_command "mkdir -p /etc/modprobe.d && cp $BASE_DIR/assets/nvidia.conf /etc/modprobe.d/nvidia.conf" "Enable NVIDIA Modeset (KMS) for Wayland" "no"

# Step 2: Copy mkinitcpio drop-in configs
run_command "cp -r $BASE_DIR/assets/mkinitcpio.conf.d /etc/" "Copy mkinitcpio drop-in configs (nvidia, hooks, thunderbolt)" "no"

print_success "Kernel configuration prepared. NVIDIA drivers will trigger initramfs rebuild automatically."

# -------------------- Limine Wipe limine.conf hook --------------------
run_command "install -D -m 0644 -o root -g root \"$BASE_DIR/assets/99-limine-wipe-efi-conf.hook\" \"/etc/pacman.d/hooks/99-limine-wipe-efi-conf.hook\"" "Install Limine wipe-efi-conf pacman hook" "no"

# -------------------- NVIDIA Drivers Installation --------------------
print_bold_blue "\n=== Installing NVIDIA Drivers ==="
print_info "The installation will automatically compile DKMS modules and rebuild initramfs..."

run_command "pacman -S --noconfirm --needed linux-headers nvidia-open-dkms nvidia-utils libva libva-utils lib32-nvidia-utils libva-nvidia-driver egl-wayland mesa lib32-mesa" "Install Nvidia Open DKMS (will auto-run mkinitcpio)" "no"

run_command "pacman -S --noconfirm --needed lact && systemctl enable --now lactd" "Install LACT for GPU" "no"

print_success "NVIDIA drivers installed and initramfs rebuilt automatically!"

# -------------------- Limine Customization (Hypruccin Theme) --------------------
print_bold_blue "\n=== Customizing Limine Bootloader ==="

if command -v limine &>/dev/null; then
  # Detect boot mode
  [[ -d /sys/firmware/efi ]] && EFI=true

  # Find current Limine config to extract CMDLINE
  if [[ -f /boot/EFI/arch-limine/limine.conf ]]; then
    limine_config="/boot/EFI/arch-limine/limine.conf"
  elif [[ -f /boot/EFI/BOOT/limine.conf ]]; then
    limine_config="/boot/EFI/BOOT/limine.conf"
  elif [[ -f /boot/EFI/limine/limine.conf ]]; then
    limine_config="/boot/EFI/limine/limine.conf"
  elif [[ -f /boot/limine/limine.conf ]]; then
    limine_config="/boot/limine/limine.conf"
  elif [[ -f /boot/limine.conf ]]; then
    limine_config="/boot/limine.conf"
  else
    print_error "Error: Limine config not found"
    exit 1
  fi

  # Extract the current kernel command line
  CMDLINE=$(grep "^[[:space:]]*cmdline:" "$limine_config" | head -1 | sed 's/^[[:space:]]*cmdline:[[:space:]]*//')

  # Prepare /etc/default/limine
  run_command "cp $BASE_DIR/assets/limine/default.conf /etc/default/limine" \
    "Copy custom Limine default configuration" "no" "yes"

  run_command "sed -i \"s|@@CMDLINE@@|$CMDLINE|g\" /etc/default/limine" \
    "Inject detected CMDLINE" "no" "yes"

  # Append any drop-in kernel cmdline configs
  for dropin in /etc/limine-entry-tool.d/*.conf; do
    [ -f "$dropin" ] && cat "$dropin" | sudo tee -a /etc/default/limine >/dev/null
  done

  # Remove old config if not in /boot/limine.conf
  if [[ "$limine_config" != "/boot/limine.conf" ]] && [[ -f "$limine_config" ]]; then
    run_command "rm \"$limine_config\"" "Remove old config file" "no" "yes"
  fi

  # Overwrite /boot/limine.conf with the theme
  run_command "cp $BASE_DIR/assets/limine/limine.conf /boot/limine.conf" \
    "Copy themed limine.conf to /boot" "no" "yes"

  # Snapper configuration
  if ! snapper list-configs 2>/dev/null | grep -q "root"; then
    if [[ -f "$BASE_DIR/assets/snap/root" ]]; then
      run_command "mkdir -p /etc/snapper/configs && cp $BASE_DIR/assets/snap/root /etc/snapper/configs/root" \
        "Copy Snapper root configuration" "no" "yes"
    else
      run_command "snapper -c root create-config /" "Create Snapper root config" "no" "yes"
    fi
  fi

  run_command "btrfs quota enable /" "Enable Btrfs quota" "no" "yes"

  # Tweak Snapper configs (As per limine-snapper.sh)
  run_command "sed -i 's/^TIMELINE_CREATE=\"yes\"/TIMELINE_CREATE=\"no\"/' /etc/snapper/configs/root" "Disable timeline snapshots" "no" "yes"
  run_command "sed -i 's/^NUMBER_LIMIT=\"50\"/NUMBER_LIMIT=\"5\"/' /etc/snapper/configs/root" "Set number limit" "no" "yes"
  run_command "sed -i 's/^NUMBER_LIMIT_IMPORTANT=\"10\"/NUMBER_LIMIT_IMPORTANT=\"5\"/' /etc/snapper/configs/root" "Set important limit" "no" "yes"
  run_command "sed -i 's/^SPACE_LIMIT=\"0.5\"/SPACE_LIMIT=\"0.3\"/' /etc/snapper/configs/root" "Set space limit" "no" "yes"
  run_command "sed -i 's/^FREE_LIMIT=\"0.2\"/FREE_LIMIT=\"0.3\"/' /etc/snapper/configs/root" "Set free limit" "no" "yes"

  run_command "systemctl enable limine-snapper-sync.service" "Enable Limine Snapper service" "no" "yes"

  # FINAL GENERATION - This is what creates the :Hypruccin entry in /boot/limine.conf
  run_command "limine-update && limine-snapper-sync" "Generate boot entries" "no" "yes"

  # Cleanup duplicate EFI entries
  if [[ -n "$EFI" ]] && command -v efibootmgr &>/dev/null; then
    efibootmgr | grep -E "Arch Linux Limine" | sed 's/^Boot\([0-9]\{4\}\).*/\1/' | xargs -I{} efibootmgr -b {} -B >/dev/null 2>&1
  fi

else
  print_warning "Limine not found. Skipping bootloader customization."
fi

print_success "Theming and services setup module finished."
echo "------------------------------------------------------------------------"
