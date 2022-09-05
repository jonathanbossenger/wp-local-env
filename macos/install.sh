#!/bin/bash

# Launch the new instance
wget https://github.com/jonathanbossenger/wp-local-env/blob/trunk/config/cloud-init-for-wp-local-env.yaml
multipass launch --name wp-local-env --mem 2G --disk 10G --cpus 2 --cloud-init cloud-init-for-wp-local-env.yaml
rm cloud-init-for-wp-local-env.yaml

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
multipass exec wp-local-env -- sudo -u mv sitesetup.sh /usr/local/bin/sitesetup
multipass exec wp-local-env -- sudo -u mv sitedrop.sh /usr/local/bin/sitedrop

# Install OS Scripts
wget https://github.com/jonathanbossenger/wp-local-env/blob/trunk/macos/scripts/os/sitesetup.sh
wget https://github.com/jonathanbossenger/wp-local-env/blob/trunk/macos/scripts/os/sitedrop.sh
chmod +x sitesetup.sh
chmod +x sitedrop.sh
sudo mv sitesetup.sh /usr/local/bin/sitesetup
sudo mv sitedrop.sh /usr/local/bin/sitedrop

# Setup /etc/hosts record for wp-local-env.test
INSTANCE_DATA=$( multipass info --format json wp-local-env )
read -r -d '' JXA <<EOF
function run() {
	var info = JSON.parse(\`$INSTANCE_DATA\`);
	return info.info["wp-local-env"].ipv4;
}
EOF
INSTANCE_IP=$( osascript -l 'JavaScript' <<< "${JXA}" )
echo "$INSTANCE_IP    wp-local-env.test" >> /etc/hosts