#!/bin/bash

# Get the directory of the current script
BASE_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")/../../")

# Source helper file
source $BASE_DIR/scripts/installer/helper.sh

log_message "Installation started for utilities section"
print_info "\nStarting utilities setup..."

# -------------------- Utilities (AUR) --------------------
run_command "yay -S --sudoloop --noconfirm --needed helium-browser-bin fastmod" "Install Utilities" "no" "no"

# -------------------- Applications & icons --------------------
run_command "\
mkdir -p /home/$SUDO_USER/.local/share/applications && \
mkdir -p /home/$SUDO_USER/.local/share/applications/icons && \
mkdir -p /home/$SUDO_USER/.local/share/icons/hicolor/48x48/apps && \
cp $BASE_DIR/assets/manu/applications/*.desktop /home/$SUDO_USER/.local/share/applications/ && \
cp $BASE_DIR/assets/manu/applications/hidden/*.desktop /home/$SUDO_USER/.local/share/applications/ && \
cp $BASE_DIR/assets/manu/applications/icons/*.png /home/$SUDO_USER/.local/share/applications/icons/ && \
cp $BASE_DIR/assets/manu/applications/icons/*.png /home/$SUDO_USER/.local/share/icons/hicolor/48x48/apps/ && \
chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.local/share/applications && \
chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.local/share/icons/hicolor/48x48/apps && \
gtk-update-icon-cache -f /home/$SUDO_USER/.local/share/icons/hicolor/ 2>/dev/null || true && \
update-desktop-database /home/$SUDO_USER/.local/share/applications/ 2>/dev/null || true" \
  "Install applications, icons and update caches" "yes" "no"

# -------------------- .XCompose --------------------
run_command "cp $BASE_DIR/assets/.XCompose /home/$SUDO_USER/ && chown $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.XCompose" "Copy .XCompose configuration to home directory" "no" "no"

# -------------------- Manu Folder (.local/share) --------------------
run_command "\
mkdir -p /home/$SUDO_USER/.local/share/manu && \
cp -r $BASE_DIR/assets/manu/* /home/$SUDO_USER/.local/share/manu/ && \
chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.local/share/manu" \
    "Copy manu folder content to .local/share" "yes" "no"

echo "------------------------------------------------------------------------"
