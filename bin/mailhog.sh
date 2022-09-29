#!/bin/bash

# MailHog
echo "Installing MailHog"
mkdir /run/gocode
echo "export GOPATH=/run/gocode" >> ~/.profile
source ~/.profile
go install github.com/mailhog/MailHog@latest
go install github.com/mailhog/mhsendmail@latest
cp /run/gocode/bin/MailHog /usr/local/bin/mailhog
cp /run/gocode/bin/mhsendmail /usr/local/bin/mhsendmail
# Configure Sendmail for PHP
echo "sendmail_path=/usr/local/bin/mhsendmail" >> /etc/php/8.1/apache2/conf.d/user.ini
service apache2 restart
# Configure MailHog to start as a system service
IP="$(hostname -I | cut -f1 -d' ')"
touch /etc/systemd/system/mailhog.service
echo "[Unit]" >> /etc/systemd/system/mailhog.service
echo "Description=MailHog service" >> /etc/systemd/system/mailhog.service
echo "[Service]" >> /etc/systemd/system/mailhog.service
echo "ExecStart=/usr/local/bin/mailhog -api-bind-addr $IP:8025 -ui-bind-addr $IP:8025 -smtp-bind-addr 127.0.0.1:1025" >> /etc/systemd/system/mailhog.service
echo "[Install]" >> /etc/systemd/system/mailhog.service
echo "WantedBy=multi-user.target" >> /etc/systemd/system/mailhog.service
systemctl enable mailhog
service mailhog start
