@echo off

rem Download the installer file from the internet
curl -o cloud-init-for-wp-local-env.yaml https://raw.githubusercontent.com/jonathanbossenger/wp-local-env/trunk/config/cloud-init-for-wp-local-env.yaml
rem Launch the multipass instance using the cloud-init file
multipass launch --timeout 600 --name wp-local-env --mem 2G --disk 10G --cpus 2 --cloud-init cloud-init-for-wp-local-env.yaml
rem Delete the cloud-init file
del cloud-init-for-wp-local-env.yaml

rem Read the IP address from the multipass info command
set /p INSTANCE_IP=< <(multipass info wp-local-env | findstr IPv4)

rem Create the local wp-env-local directory
mkdir wp-env-local
rem Mount the wp-env-local directory to the multipass wp-local-env directory
multipass mount wp-local-env wp-local-env:/home/ubuntu/wp-local-env
rem Create the sites and ssl-certs directories in the wp-env-local directory
mkdir wp-env-local/sites
mkdir wp-env-local/ssl-certs

rem Install MailHog
echo "Installing MailHog..."
multipass exec wp-local-env -- wget https://raw.githubusercontent.com/jonathanbossenger/wp-local-env/trunk/bin/mailhog.sh
multipass exec wp-local-env -- chmod +x mailhog.sh
multipass exec wp-local-env -- sudo su root ./mailhog.sh

rem Install Server Scripts
echo "Installing server scripts..."
multipass exec wp-local-env -- wget https://raw.githubusercontent.com/jonathanbossenger/wp-local-env/trunk/bin/server_scripts.sh
multipass exec wp-local-env -- chmod +x server_scripts.sh
multipass exec wp-local-env -- sudo su root ./server_scripts.sh

rem Install OS Scripts
echo "Installing OS scripts..."
curl -o- https://raw.githubusercontent.com/jonathanbossenger/wp-local-env/trunk/linux/scripts/os/sitesetup.bat > sitesetup.bat
curl -o- https://raw.githubusercontent.com/jonathanbossenger/wp-local-env/trunk/linux/scripts/os/sitedrop.bat > sitedrop.bat
rem replace HOME_USER=wp-local-env with HOME_USER=%USERNAME% in the sitesetup.bat and sitedrop.bat files
sed -i "s/HOME_USER=wp-local-env/HOME_USER=%USERNAME%/g" sitesetup.bat
sed -i "s/HOME_USER=wp-local-env/HOME_USER=%USERNAME%/g" sitedrop.bat
rem replace VM_IP=192.168.64.2 with VM_IP=%INSTANCE_IP% in the sitesetup.bat and sitedrop.bat files
sed -i s/"VM_IP=192.168.64.2"/"VM_IP=%INSTANCE_IP%"/g sitesetup.bat
sed -i s/"VM_IP=192.168.64.2"/"VM_IP=%INSTANCE_IP%"/g sitedrop.bat
rem replace runuser -l wp-local-env with runuser -l %USERNAME%
sed -i s/"runuser -l wp-local-env"/"runuser -l %USERNAME%"/g sitesetup.bat
