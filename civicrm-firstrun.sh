#!/bin/bash

touch /var/log/civicrm/apache.log
chown www-data:www-data /var/log/civicrm/apache.log
cp -r /sites-default-source/* /var/www/html/sites/default/
find /var/www/html/sites/default -type d -exec chmod 755 {} \;
find /var/www/html/sites/default -type f -exec chmod 666 {} \;
chown -R www-data:www-data /var/www/html/
