#!/bin/bash

# Installer
# curl -o- https://raw.githubusercontent.com/jonathanbossenger/wp-local-env/trunk/macos/install.sh > install.sh

# Launch the new instance
echo "Launching Multipass VM..."
curl -o- https://raw.githubusercontent.com/jonathanbossenger/wp-local-env/trunk/config/cloud-init-for-wp-local-env.yaml > cloud-init-for-wp-local-env.yaml
multipass launch --name wp-local-env --mem 2G --disk 10G --cpus 2 --cloud-init cloud-init-for-wp-local-env.yaml
rm cloud-init-for-wp-local-env.yaml

# Install MailHog
echo "Installing MailHog..."
multipass exec wp-local-env -- wget https://raw.githubusercontent.com/jonathanbossenger/wp-local-env/trunk/bin/mailhog.sh
multipass exec wp-local-env -- chmod +x mailhog.sh
multipass exec wp-local-env -- sudo su root ./mailhog.sh

# Set up the shared directories
echo "Setting up shared directories..."
mkdir -p ~/wp-local-env
multipass mount ~/wp-local-env wp-local-env:/home/ubuntu/wp-local-env
cd ~/wp-local-env
mkdir -p sites ssl-certs

# Install Server Scripts
echo "Installing server scripts..."
multipass exec wp-local-env -- wget https://raw.githubusercontent.com/jonathanbossenger/wp-local-env/trunk/bin/server_scripts.sh
multipass exec wp-local-env -- chmod +x server_scripts.sh
multipass exec wp-local-env -- sudo su root ./server_scripts.sh

# Install OS Scripts
echo "Installing OS scripts..."
curl -o- https://raw.githubusercontent.com/jonathanbossenger/wp-local-env/trunk/macos/scripts/os/sitesetup.sh > sitesetup.sh
curl -o- https://raw.githubusercontent.com/jonathanbossenger/wp-local-env/trunk/macos/scripts/os/sitedrop.sh > sitedrop.sh
chmod +x sitesetup.sh
chmod +x sitedrop.sh
# replace wp-local-env with $USER
# https://stackoverflow.com/questions/4247068/sed-command-with-i-option-failing-on-mac-but-works-on-linux
sed -i .bak s/"HOME_USER=wp-local-env"/"HOME_USER=$USER"/g sitesetup.sh
rm sitesetup.sh.bak
sudo mv sitesetup.sh /usr/local/bin/sitesetup
sudo mv sitedrop.sh /usr/local/bin/sitedrop

# Setup /etc/hosts record for wp-local-env.test
# echo "Setting up hosts record..."
# INSTANCE_DATA=$( multipass info --format json wp-local-env )
# read -r -d '' JXA <<EOF
# function run() {
# 	var info = JSON.parse(\`$INSTANCE_DATA\`);
# 	return info.info["wp-local-env"].ipv4;
# }
# EOF
# INSTANCE_IP=$( osascript -l 'JavaScript' <<< "${JXA}" )
# sudo echo "$INSTANCE_IP    wp-local-env.test" >> /etc/hosts
# echo "Enter your sudo password to enable the hosts record..."
# echo -n password | sudo -S echo "$INSTANCE_IP    wp-local-env.test" >> /etc/hosts

echo "Done!"