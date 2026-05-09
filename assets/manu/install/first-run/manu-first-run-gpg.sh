LOG="$HOME/.local/share/manu/first-run.log"
echo "$(date): Starting GPG keyserver configuration..."

sudo mkdir -p /etc/gnupg
sudo cp ~/.local/share/manu/default/gpg/dirmngr.conf /etc/gnupg/
sudo chmod 644 /etc/gnupg/dirmngr.conf
sudo gpgconf --kill dirmngr || true
sudo gpgconf --launch dirmngr || true

echo "$(date): GPG keyserver configuration completed."
