#!/bin/bash

#!/bin/bash

VM_IP=192.168.64.2
VM_NAME=triangle
HOME_USER=jonathanbossenger

SITE_NAME=$1

SSL_CERTS_DIRECTORY=/Users/$HOME_USER/ssl-certs
SITES_DIRECTORY=/Users/$HOME_USER/development/websites

echo "Creating certs.."

cd $SSL_CERTS_DIRECTORY
mkcert $SITE_NAME.test

echo "Setting up hosts record..."

echo "$VM_IP    $SITE_NAME.test" >> /etc/hosts

echo "Creating websites directory"

mkdir $SITES_DIRECTORY/"$SITE_NAME"
chown -R $HOME_USER $SITES_DIRECTORY/"$SITE_NAME"

echo "Provisioning site on Multipass VM..."

multipass exec $VM_NAME sudo sitesetup $SITE_NAME

echo "Done!"