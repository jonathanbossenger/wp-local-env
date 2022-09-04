#!/bin/bash

# Launch the new instance
multipass launch --name wp-local-env --mem 2G --disk 10G --cpus 2 --cloud-init ../config/cloud-init-for-wp-local-env.yaml

# Install MailHog
multipass exec wp-local-env -- wget https://github.com/jonathanbossenger/wp-local-env/blob/trunk/bin/mailhog.sh
multipass exec wp-local-env -- chmod +x mailhog.sh
multipass exec wp-local-env -- sudo -u root ./mailhog.sh

# Set up the shared directories
mkdir -p ~/wp-local-env
multipass mount ~/wp-local-env wp-local-env:/home/ubuntu/wp-local-env
cd ~/wp-local-env
mkdir -p sites ssl-certs

# Install Server Scripts
multipass exec wp-local-env -- wget https://github.com/jonathanbossenger/wp-local-env/blob/trunk/macos/scripts/multipass/sitesetup.sh
multipass exec wp-local-env -- wget https://github.com/jonathanbossenger/wp-local-env/blob/trunk/macos/scripts/multipass/sitedrop.sh
multipass exec wp-local-env -- chmod +x sitesetup.sh
multipass exec wp-local-env -- chmod +x sitedrop.sh
multipass exec wp-local-env -- sudo -u cp sitesetup.sh /usr/local/bin/sitesetup
multipass exec wp-local-env -- sudo -u cp sitedrop.sh /usr/local/bin/sitedrop

# Install OS Scripts
chmod +x ./scripts/os/sitesetup.sh
chmod +x ./scripts/os/sitedrop.sh
sudo cp ./scripts/os/sitesetup.sh /usr/local/bin/sitesetup
sudo cp ./scripts/os/sitedrop.sh /usr/local/bin/sitedrop
