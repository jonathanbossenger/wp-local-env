#!/bin/bash
wget https://raw.githubusercontent.com/jonathanbossenger/wp-local-env/trunk/macos/scripts/multipass/sitesetup.sh
wget https://raw.githubusercontent.com/jonathanbossenger/wp-local-env/trunk/macos/scripts/multipass/sitedrop.sh
chmod +x sitesetup.sh
chmod +x sitedrop.sh
cp sitesetup.sh /usr/local/bin/sitesetup
cp sitedrop.sh /usr/local/bin/sitedrop