$siteName = $args[0]
$vmName = wp-local-env
$vmIp = 192.168.64.2

$sslCertsDirectory = "C:\Users\$homeUser\wp-local-env\ssl-certs\"
$sitesDirectory = "C:\Users\$homeUser\wp-local-env\sites\"

# Delete the C:\Users\$homeUser\wp-local-env\ssl-certs\ directory
Write-Host "Deleting the ssl-certs directory..."
Remove-Item -Path $sslCertsDirectory -Recurse -Force

# Remove the record from the /etc/hosts file
Write-Host "Removing the hosts record..."
$hostsFile = Get-Content "C:\Windows\System32\drivers\etc\hosts"
$hostsFile | Where-Object { $_ -notlike "*$siteName.test*" } | Set-Content "C:\Windows\System32\drivers\etc\hosts"

# Delete the C:\Users\$homeUser\wp-local-env\sites\ directory
Write-Host "Deleting the sites directory..."
Remove-Item -Path $sitesDirectory -Recurse -Force

# Delete the site on the Multipass VM
Write-Host "Deleting the site on the Multipass VM..."
multipass exec $vmName sudo sitedrop $siteName

Write-Host "Done!"