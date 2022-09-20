#!/bin/bash

SITE_NAME=$1
PHP_VERSION=$2
VM_NAME=wp-local-env
HOME_USER=wp-local-env
VM_IP=192.168.0.2

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

if [ -n "$2" ]; then ## if the second parameter was set
  multipass exec $VM_NAME sudo sitesetup "$SITE_NAME" "$PHP_VERSION"
else
  multipass exec $VM_NAME sudo sitesetup "$SITE_NAME"
fi


echo "Done!"