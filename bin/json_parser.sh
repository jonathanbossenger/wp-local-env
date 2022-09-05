#!/bin/bash

INSTANCEDATA=$( multipass info --format json wp-local-env )

read -r -d '' JXA <<EOF
function run() {
	var info = JSON.parse(\`$INSTANCEDATA\`);
	return info.info["wp-local-env"].ipv4;
}
EOF

IP=$( osascript -l 'JavaScript' <<< "${JXA}" )

echo "${IP}"