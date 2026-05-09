#!/bin/bash

# manu:summary=First run limine snapper
# manu:group=
# manu:name=first run limine snapper

LOG="$HOME/.local/share/manu/first-run.log"
echo "$(date): Starting Limine/Snapper configuration..."

# -------------------- Snapper /home config --------------------
if command -v snapper &>/dev/null; then
    if ! sudo snapper list-configs 2>/dev/null | grep -q "home"; then
        sudo snapper -c home create-config /home
    fi

    # -------------------- Btrfs quota --------------------
    sudo btrfs quota enable /

    # -------------------- Tweak snapper limits --------------------
    for config in root home; do
        sudo sed -i 's/^TIMELINE_CREATE="yes"/TIMELINE_CREATE="no"/' /etc/snapper/configs/$config
        sudo sed -i 's/^NUMBER_LIMIT="50"/NUMBER_LIMIT="5"/' /etc/snapper/configs/$config
        sudo sed -i 's/^NUMBER_LIMIT_IMPORTANT="10"/NUMBER_LIMIT_IMPORTANT="5"/' /etc/snapper/configs/$config
        sudo sed -i 's/^SPACE_LIMIT="0.5"/SPACE_LIMIT="0.3"/' /etc/snapper/configs/$config
        sudo sed -i 's/^FREE_LIMIT="0.2"/FREE_LIMIT="0.3"/' /etc/snapper/configs/$config
    done

    # -------------------- Snapper & Limine services --------------------
    sudo systemctl enable --now snapper-timeline.timer
    sudo systemctl enable --now snapper-cleanup.timer
    sudo systemctl enable --now limine-snapper-sync.service
fi

# -------------------- Limine update --------------------
if command -v limine &>/dev/null; then
    sudo limine-update
    if ! grep -q "^/+" /boot/limine.conf; then
        echo "$(date): ERROR: limine-update failed to add boot entries!"
        notify-send "First-run ERROR" "limine-update failed to add boot entries!" -u critical 2>/dev/null || true
        exit 1
    fi
fi
echo "$(date): Limine/Snapper configuration finished."
