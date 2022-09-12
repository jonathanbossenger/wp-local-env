#!/bin/bash

# Setup /etc/hosts record for wp-local-env.test
echo "Setting up hosts record..."
INSTANCE_DATA=$( multipass info --format json wp-local-env )
read -r -d '' JXA <<EOF
function run() {
	var info = JSON.parse(\`$INSTANCE_DATA\`);
	return info.info["wp-local-env"].ipv4;
}
EOF
INSTANCE_IP=$( osascript -l 'JavaScript' <<< "${JXA}" )
echo "$INSTANCE_IP    wp-local-env.test" >> /etc/hosts