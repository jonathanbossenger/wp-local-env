#!/bin/bash

multipass launch --name wp-local-env --mem 2G --disk 10G --cpus 2 --cloud-init ../config/cloud-init-for-wp-local-env.yaml

mkdir -p ~/wp-local-env

multipass mount ~/wp-local-env wp-local-env:/home/ubuntu/wp-local-env

cd ~/wp-local-env

mkdir -p sites ssh-keys

# copy mailhog script to the server, and chmod +x it
# run the mailhog script to install mailhog
# multipass exec wp-local-env -- sudo -u root ./mailhog.sh