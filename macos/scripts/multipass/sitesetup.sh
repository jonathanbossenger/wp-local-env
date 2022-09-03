#!/bin/bash

SITE_NAME=$1
PHP_VERSION=$2

SSL_CERTS_DIRECTORY=/home/ubuntu/ssl-certs
SITES_DIRECTORY=/home/ubuntu/sites

MYSQL_DATABASE=$(echo "$SITE_NAME" | sed 's/[^a-zA-Z0-9]//g')
SITE_CONFIG_PATH=/etc/apache2/sites-available/$SITE_NAME.conf
SSL_SITE_CONFIG_PATH=/etc/apache2/sites-available/$SITE_NAME-ssl.conf

echo "Setting up virtual hosts..."

VIRTUAL_HOST="<VirtualHost *:80>
    ServerName $SITE_NAME.test
    Redirect / https://$SITE_NAME.test
</VirtualHost>"

echo "$VIRTUAL_HOST" | sudo tee -a "$SITE_CONFIG_PATH"

SSL_VIRTUAL_HOST="<IfModule mod_ssl.c>
    <VirtualHost _default_:443>
        ServerName $SITE_NAME.test
        ServerAdmin webmaster@$SITE_NAME.test
        DocumentRoot $SITES_DIRECTORY/$SITE_NAME
        <Directory \"$SITES_DIRECTORY/$SITE_NAME\">
            #Require local
            Order allow,deny
            Allow from all
            AllowOverride all
            # New directive needed in Apache 2.4.3:
            Require all granted
        </Directory>
        ErrorLog \${APACHE_LOG_DIR}/$SITE_NAME-error.log
        CustomLog \${APACHE_LOG_DIR}/$SITE_NAME-access.log combined
        SSLEngine on
        SSLCertificateFile  $SSL_CERTS_DIRECTORY/$SITE_NAME.test.pem
        SSLCertificateKeyFile $SSL_CERTS_DIRECTORY/$SITE_NAME.test-key.pem
        <FilesMatch \"\.(cgi|shtml|phtml|php)\$\">
                SSLOptions +StdEnvVars
        </FilesMatch>
        <Directory /usr/lib/cgi-bin>
                SSLOptions +StdEnvVars
        </Directory>
    </VirtualHost>
</IfModule>"

if [ PHP_VERSION == '7.4' ]; then
    SSL_VIRTUAL_HOST="<IfModule mod_ssl.c>
        <VirtualHost _default_:443>
            ServerName $SITE_NAME.test
            ServerAdmin webmaster@$SITE_NAME.test
            DocumentRoot $SITES_DIRECTORY/$SITE_NAME
            <Directory \"$SITES_DIRECTORY/$SITE_NAME\">
                #Require local
                Order allow,deny
                Allow from all
                AllowOverride all
                # New directive needed in Apache 2.4.3:
                Require all granted
            </Directory>
            ErrorLog \${APACHE_LOG_DIR}/$SITE_NAME-error.log
            CustomLog \${APACHE_LOG_DIR}/$SITE_NAME-access.log combined
            SSLEngine on
            SSLCertificateFile  $SSL_CERTS_DIRECTORY/$SITE_NAME.test.pem
            SSLCertificateKeyFile $SSL_CERTS_DIRECTORY/$SITE_NAME.test-key.pem
            <FilesMatch \.php$>
                # From the Apache version 2.4.10 and above, use the SetHandler to run PHP as a fastCGI process s>
                SetHandler \"proxy:unix:/run/php/php7.4-fpm.sock|fcgi://localhost\"
            </FilesMatch>
            <FilesMatch \"\.(cgi|shtml|phtml|php)\$\">
                    SSLOptions +StdEnvVars
            </FilesMatch>
            <Directory /usr/lib/cgi-bin>
                    SSLOptions +StdEnvVars
            </Directory>
        </VirtualHost>
    </IfModule>"
fi

echo "$SSL_VIRTUAL_HOST" | sudo tee -a "$SSL_SITE_CONFIG_PATH"

echo "Enabling virtual hosts..."

a2ensite "$SITE_NAME".conf
a2ensite "$SITE_NAME"-ssl.conf

echo "Creating database.."

mysql -uroot -ppassword --execute="CREATE DATABASE $MYSQL_DATABASE;"

echo "Restarting Apache..."

service apache2 restart