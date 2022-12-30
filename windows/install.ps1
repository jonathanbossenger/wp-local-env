# Download the config file for the multipass instance
Invoke-WebRequest -URI "https://raw.githubusercontent.com/jonathanbossenger/wp-local-env/trunk/config/cloud-init-for-wp-local-env.yaml" -OutFile "cloud-init-for-wp-local-env.yaml"
# Launch the multipass instance 
multipass launch --timeout 600 --name wp-local-env --mem 2G --disk 10G --cpus 2 --cloud-init cloud-init-for-wp-local-env.yaml
# Delete the cloud-init file
Remove-Item cloud-init-for-wp-local-env.yaml
# Get the IP address of the instance
$ip = multipass info wp-local-env | Select-String -Pattern "IPv4" | Select-Object -ExpandProperty Line | Select-Object -Skip 1 | Select-Object -ExpandProperty Line

# Create the local wp-local-env directory
New-Item -ItemType Directory -Path "$HOME\wp-local-env"
# Mount the wp-local-env directory to the multipass wp-local-env directory
multipass mount $HOME\wp-local-env wp-local-env:/home/ubuntu/wp-local-env
# Create the sites and ssl-certs directories in the wp-local-env directory
New-Item -ItemType Directory -Path "$HOME\wp-local-env\sites"
New-Item -ItemType Directory -Path "$HOME\wp-local-env\ssl-certs"

# Install MailHog on the multipass instance
Write-Host "Installing MailHog..."
multipass exec wp-local-env -- wget https://raw.githubusercontent.com/jonathanbossenger/wp-local-env/trunk/bin/mailhog.sh
multipass exec wp-local-env -- chmod +x mailhog.sh
multipass exec wp-local-env -- sudo su root ./mailhog.sh

# Install Server Scripts
Write-Host "Installing server scripts..."
multipass exec wp-local-env -- wget https://raw.githubusercontent.com/jonathanbossenger/wp-local-env/trunk/bin/server_scripts.sh
multipass exec wp-local-env -- chmod +x server_scripts.sh
multipass exec wp-local-env -- sudo su root ./server_scripts.sh

# Download the OS scripts
Invoke-WebRequest -URI "https://raw.githubusercontent.com/jonathanbossenger/wp-local-env/trunk/windows/scripts/os/sitesetup.ps1" -OutFile "sitesetup.ps1"
Invoke-WebRequest -URI "https://raw.githubusercontent.com/jonathanbossenger/wp-local-env/trunk/windows/scripts/os/sitedrop.ps1" -OutFile "sitedrop.ps1"

# Replace HOME_USER=wp-local-env with HOME_USER=$env:UserName in the sitesetup.ps1 and sitedrop.ps1 files
$content = Get-Content -Path "sitesetup.ps1"
$newContent = $content -replace "HOME_USER=wp-local-env", "HOME_USER=$env:UserName"
$newContent | Set-Content -Path 'sitesetup.ps1'
$content = Get-Content -Path "sitedrop.ps1"
$newContent = $content -replace "HOME_USER=wp-local-env", "HOME_USER=$env:UserName"
$newContent | Set-Content -Path 'sitedrop.ps1'

# Replace VM_IP=192.168.64.2 with VM_IP=ip in the sitesetup.ps1 and sitedrop.ps1 files
$content = Get-Content -Path "sitesetup.ps1"
$newContent = $content -replace "VM_IP=192.168.64.2", "VM_IP=$ip"
$newContent | Set-Content -Path 'sitesetup.ps1'
$content = Get-Content -Path "sitedrop.ps1"
$newContent = $content -replace "VM_IP=192.168.64.2", "VM_IP=$ip"
$newContent | Set-Content -Path 'sitedrop.ps1'

Write-Host "Done, wp-local-env is ready to use at $ip!"
