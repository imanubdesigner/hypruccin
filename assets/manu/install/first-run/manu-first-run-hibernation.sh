#!/bin/bash

# manu:summary=Set up hibernation before the UKI rebuild triggered by limine-snapper
# manu:group=
# manu:name=first run hibernation

LOG="$HOME/.local/share/manu/first-run.log"
echo "$(date): Starting hibernation setup..."

# Run before limine-snapper.sh so the resume hook + cmdline drop-ins are in
# place when `pacman -S limine-mkinitcpio-hook` triggers its single full UKI
# rebuild. The --no-rebuild flag tells the script to skip its own rebuild —
# limine-snapper's pacman install will produce a UKI that already includes
# hibernation.
manu-hibernation-setup --force --no-rebuild

echo "$(date): Hibernation setup finished."
