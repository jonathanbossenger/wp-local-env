#!/bin/bash

SITE_NAME=$1
VM_NAME=wp-local-env
VM_IP=192.168.0.2

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