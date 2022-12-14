#!/bin/bash

SITE_NAME=$1
PHP_VERSION=$2
VM_NAME=wp-local-env
HOME_USER=wp-local-env
VM_IP=192.168.64.2

SSL_CERTS_DIRECTORY=/home/$HOME_USER/wp-local-env/ssl-certs
SITES_DIRECTORY=/home/$HOME_USER/wp-local-env/sites

echo "Creating certs.."

MKCERT_EXECUTABLE=/home/linuxbrew/.linuxbrew/bin/mkcert
runuser -l wp-local-env -c "cd $SSL_CERTS_DIRECTORY && $MKCERT_EXECUTABLE $SITE_NAME.test"

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