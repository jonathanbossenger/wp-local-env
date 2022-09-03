!/bin/bash

SITE_NAME=$1

SSL_CERTS_DIRECTORY=/home/ubuntu/ssl-certs
SITES_DIRECTORY=/home/ubuntu/sites

MYSQL_DATABASE=$(echo $SITE_NAME | sed 's/[^a-zA-Z0-9]//g')
SITE_CONFIG_PATH=/etc/apache2/sites-available/$SITE_NAME.conf
SSL_SITE_CONFIG_PATH=/etc/apache2/sites-available/$SITE_NAME-ssl.conf

echo "Disabling virtual hosts..."

a2dissite "$SITE_NAME".conf
a2dissite "$SITE_NAME"-ssl.conf

echo "Deleting virtual hosts..."

rm -rf "$SITE_CONFIG_PATH"
rm -rf "$SSL_SITE_CONFIG_PATH"

echo "Deleting database.."

mysql -uroot -ppassword --execute="DROP DATABASE $MYSQL_DATABASE;"

echo "Restarting Apache..."

service apache2 restart