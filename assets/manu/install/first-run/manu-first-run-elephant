#!/bin/bash

# manu:summary=First run elephant
# manu:group=
# manu:name=first run elephant

LOG="$HOME/.local/share/manu/first-run.log"
echo "$(date): Starting Elephant configuration..."
elephant service enable
systemctl --user start elephant.service
echo "$(date): Elephant configuration finished."
