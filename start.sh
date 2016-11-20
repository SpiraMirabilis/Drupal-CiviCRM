#!/bin/bash

cp -rva /sites-default-source/* /var/www/html/sites/default/
chown -R www-data:www-data /var/www/html/sites
chmod -R 755 /var/www/html/sites/default
chmod 755 /var/www/html/sites/default

if [ "$DRUPAL_USER" -a "$DRUPAL_PASSWORD" -a "$DRUPAL_DATABASE" ]; then
  export DRUPAL_USER="$DRUPAL_USER"
  export DRUPAL_PASSWORD="$DRUPAL_PASSWORD"
  export DRUPAL_DATABASE="$DURPAL_DATABASE"
else
  export DRUPAL_USER="drupal"
  export DRUPAL_PASSWORD="drupal"
  export DRUPAL_DATABASE="drupal"
fi
if [ "$CIVICRM_USER" -a "$CIVICRM_PASSWORD" -a "$CIVICRM_DATABASE" ]; then
  export CIVICRM_USER="$CIVICRM_USER" 
  export CIVICRM_PASSWORD="$CIVICRM_PASSWORD"
  export CIVICRM_DATABASE="$CIVICRM_DATABSE"
else
  export CIVICRM_USER="civicrm"
  export CIVICRM_PASSWORD="civicrm"
  export CIVICRM_DATABASE="civicrm"
fi
if [ "$MYSQL_ROOT_PASSWORD" ]; then
  export MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD"
else
  export MYSQL_ROOT_PASSWORD="$(pwgen -1 32)"
  echo "GENERATED ROOT PASSWORD: $MYSQL_ROOT_PASSWORD"
fi

/usr/local/bin/mysql-entrypoint.sh "mysqld" &
exec /usr/local/bin/apache2-foreground