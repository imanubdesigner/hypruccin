#!/bin/bash

# manu:summary=First run mise
# manu:group=
# manu:name=first run mise

LOG="$HOME/.local/share/manu/first-run.log"
echo "$(date): Starting MISE configuration..."

# Create the main work directory and a subfolder for experiments
echo "   Creating Work directories..."
mkdir -p "$HOME/Work/tries"

# Create a local .mise.toml in ~/Work.
# This configuration automatically adds any "bin" folder
# inside project directories to your PATH.
echo "   Configuring dynamic PATH in ~/Work..."
cat >"$HOME/Work/.mise.toml" <<'EOF'
[env]
_.path = "{{ cwd }}/bin"
EOF

# Trust the configuration file so mise can load it without asking for permission
echo "   Trusting ~/Work/.mise.toml..."
mise trust "$HOME/Work/.mise.toml"
echo "   Mise setup completed!"
echo "Note: Node.js will be auto-installed by mise when you run your wrappers."
echo "$(date): MISE configuration finished."
