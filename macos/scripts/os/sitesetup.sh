#!/bin/bash

SITE_NAME=$1
VM_NAME=wp-local-env
HOME_USER=wp-local-env

VM_DATA=$( multipass info --format json wp-local-env )
read -r -d '' JXA <<EOF
function run() {
	var info = JSON.parse(\`$VM_DATA\`);
	return info.info["wp-local-env"].ipv4;
}
EOF
VM_IP=$( osascript -l 'JavaScript' <<< "${JXA}" )

SSL_CERTS_DIRECTORY=~/wp-local-env/ssl-certs
SITES_DIRECTORY=~/wp-local-env/sites

echo "Creating certs.."

cd $SSL_CERTS_DIRECTORY
mkcert "$SITE_NAME".test

echo "Setting up hosts record..."

echo "$VM_IP    $SITE_NAME.test" >> /etc/hosts

echo "Creating websites directory"

mkdir $SITES_DIRECTORY/"$SITE_NAME"
chown -R "$HOME_USER" $SITES_DIRECTORY/"$SITE_NAME"

echo "Provisioning site on Multipass VM..."

multipass exec $VM_NAME sudo sitesetup "$SITE_NAME"

echo "Done!"