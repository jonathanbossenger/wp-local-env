#!/bin/bash

SITE_NAME=$1
VM_NAME=wp-local-env

VM_DATA=$( multipass info --format json wp-local-env )
read -r -d '' JXA <<EOF
function run() {
	var info = JSON.parse(\`VM_DATA\`);
	return info.info["wp-local-env"].ipv4;
}
EOF
VM_IP=$( osascript -l 'JavaScript' <<< "${JXA}" )

SSL_CERTS_DIRECTORY=~/wp-local-env/ssl-certs
SITES_DIRECTORY=~/wp-local-env/sites

echo "Deleting certs.."

rm -rf $SSL_CERTS_DIRECTORY/"$SITE_NAME"*

echo "Remove hosts record.."

perl -pi -e "s,^$VM_IP.*$SITE_NAME.test\n$,," /etc/hosts

echo "Removing websites directory..."

rm -rf $SITES_DIRECTORY/"$SITE_NAME"

echo "Removing site from Multipass VM..."

multipass exec $VM_NAME sudo sitedrop "$SITE_NAME"

echo "Done!"