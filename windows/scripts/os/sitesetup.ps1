$siteName = $args[0]
$phpVersion = $args[1]
$vmName = wp-local-env
$homeUser = wp-local-env
$vmIp = 192.168.64.2

$sslCertsDirectory = "C:\Users\$homeUser\wp-local-env\ssl-certs\"
$sitesDirectory = "C:\Users\$homeUser\wp-local-env\sites\"

Write-Host "Creating certs..."
Set-Location $sslCertsDirectory
mkcert $siteName.test

Write-Host "Setting up the hosts record..."
Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value "$vmIp $siteName.test"

Write-Host "Creating the site directory..."
Set-Location $sitesDirectory
New-Item -ItemType Directory -Path $siteName

Write-Host "Provisioning the site on the Multipass VM..."
if ($phpVersion) {
    multipass exec $vmName sudo sitesetup $siteName $phpVersion
} else {
    multipass exec $vmName sudo sitesetup $siteName
}

Write-Host "Done!"