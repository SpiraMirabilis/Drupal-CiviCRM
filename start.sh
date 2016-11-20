#!/bin/bash
cp -rva /sites-default-source/* /var/www/html/sites/default/
chown -R www-data:www-data /var/www/html/sites
chmod -R 755 /var/www/html/sites/default
chmod 755 /var/www/html/sites/default
exec /usr/local/bin/apache2-foreground
