#!/bin/bash

# install
# curl -o- curl -o- https://raw.githubusercontent.com/jonathanbossenger/wp-local-env/e476fb0dc5103a72feab6ea67cfb2a1c256660ba/macos/install.sh > install.sh

# Launch the new instance
curl -o- https://raw.githubusercontent.com/jonathanbossenger/wp-local-env/e476fb0dc5103a72feab6ea67cfb2a1c256660ba/config/cloud-init-for-wp-local-env.yaml > cloud-init-for-wp-local-env.yaml
multipass launch --name wp-local-env --mem 2G --disk 10G --cpus 2 --cloud-init cloud-init-for-wp-local-env.yaml
rm cloud-init-for-wp-local-env.yaml

# Install MailHog
multipass exec wp-local-env -- wget https://raw.githubusercontent.com/jonathanbossenger/wp-local-env/e476fb0dc5103a72feab6ea67cfb2a1c256660ba/bin/mailhog.sh > mailhog.sh
multipass exec wp-local-env -- chmod +x mailhog.sh
multipass exec wp-local-env -- sudo -u root ./mailhog.sh

# Set up the shared directories
mkdir -p ~/wp-local-env
multipass mount ~/wp-local-env wp-local-env:/home/ubuntu/wp-local-env
cd ~/wp-local-env
mkdir -p sites ssl-certs

# Install Server Scripts
multipass exec wp-local-env -- wget https://raw.githubusercontent.com/jonathanbossenger/wp-local-env/e476fb0dc5103a72feab6ea67cfb2a1c256660ba/macos/scripts/multipass/sitesetup.sh > sitesetup.sh
multipass exec wp-local-env -- wget https://raw.githubusercontent.com/jonathanbossenger/wp-local-env/e476fb0dc5103a72feab6ea67cfb2a1c256660ba/macos/scripts/multipass/sitedrop.sh > sitedrop.sh
multipass exec wp-local-env -- chmod +x sitesetup.sh
multipass exec wp-local-env -- chmod +x sitedrop.sh
multipass exec wp-local-env -- sudo -u mv sitesetup.sh /usr/local/bin/sitesetup
multipass exec wp-local-env -- sudo -u mv sitedrop.sh /usr/local/bin/sitedrop

# Install OS Scripts
curl -o- https://raw.githubusercontent.com/jonathanbossenger/wp-local-env/e476fb0dc5103a72feab6ea67cfb2a1c256660ba/macos/scripts/os/sitesetup.sh > sitesetup.sh
curl -o- https://raw.githubusercontent.com/jonathanbossenger/wp-local-env/e476fb0dc5103a72feab6ea67cfb2a1c256660ba/macos/scripts/os/sitedrop.sh > sitedrop.sh
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