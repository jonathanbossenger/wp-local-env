#!/bin/bash

VM_IP=192.168.64.2
VM_NAME=triangle
HOME_USER=jonathanbossenger

SITE_NAME=$1

SSL_CERTS_DIRECTORY=/Users/$HOME_USER/ssl-certs
SITES_DIRECTORY=/Users/$HOME_USER/development/websites

echo "Deleting certs.."

rm -rf $SSL_CERTS_DIRECTORY/"$SITE_NAME"*

echo "Remove hosts record.."

perl -pi -e "s,^$VM_IP.*$SITE_NAME.test\n$,," /etc/hosts

echo "Removing websites directory..."

rm -rf $SITES_DIRECTORY/"$SITE_NAME"

echo "Removing site from Multipass VM..."

multipass exec $VM_NAME sudo sitedrop $SITE_NAME

echo "Done!"