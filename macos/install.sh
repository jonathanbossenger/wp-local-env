#!/bin/bash

multipass launch --name wp-local-env --cloud-init ./cloud-init-for-wp-local-env.yaml

mkdir -p ~/wp-local-env

multipass mount ~/wp-local-env wp-local-env:/home/ubuntu/wp-local-env

cd ~/wp-local-env

mkdir -p sites ssh-keys