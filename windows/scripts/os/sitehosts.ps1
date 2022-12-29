# Setup /etc/hosts record for wp-local-env.test

# Get the ip address of the wp-local-env multipass instance
$ip = multipass info wp-local-env | Select-String -Pattern "IPv4" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }

# Add a hosts record for wp-local-env.test using the ip address
Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value "$ip wp-local-env.test"
