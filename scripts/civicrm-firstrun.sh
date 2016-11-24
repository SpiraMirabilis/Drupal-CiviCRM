#!/bin/bash
## add apache logging file
touch /var/log/civicrm/apache.log
chown www-data:www-data /var/log/civicrm/apache.log

## copy drupal site settings to working directory
cp -r /sites-default-source/* /var/www/html/sites/default/

## set drupal database variables
sed -i 's/##DATABASE_HOST##/'"${DATABASE_HOST}"'/g' /var/www/html/sites/default/settings.php
sed -i 's/##DRUPAL_USER##/'"${DRUPAL_USER}"'/g' /var/www/html/sites/default/settings.php
sed -i 's/##DRUPAL_PASSWORD##/'"${DRUPAL_PASSWORD}"'/g' /var/www/html/sites/default/settings.php
sed -i 's/##DRUPAL_DATABASE##/'"${DRUPAL_DATABASE}"'/g' /var/www/html/sites/default/settings.php
sed -i 's/##HASH_SALT##/'"${HASH_SALT}"'/g' /var/www/html/sites/default/settings.php
if [ "$BASE_URL" ]; then
    sed -i 's%##BASE_URL##%$base_url = '"'${BASE_URL}'"';%g' /var/www/html/sites/default/settings.php
fi

## set drupal database name in sql
sed -i 's/##DRUPAL_DATABASE##/'"${DRUPAL_DATABASE}"'/g' /mysql-initdb.d/drupal.sql

## set civicrm database sql source
sed -i 's/##DATABASE_HOST##/'"${DATABASE_HOST}"'/g' /var/www/html/sites/default/civicrm.settings.php
sed -i 's/##DRUPAL_USER##/'"${DRUPAL_USER}"'/g' /var/www/html/sites/default/civicrm.settings.php
sed -i 's/##DRUPAL_PASSWORD##/'"${DRUPAL_PASSWORD}"'/g' /var/www/html/sites/default/civicrm.settings.php
sed -i 's/##DRUPAL_DATABASE##/'"${DRUPAL_DATABASE}"'/g' /var/www/html/sites/default/civicrm.settings.php
sed -i 's/##CIVICRM_USER##/'"${CIVICRM_USER}"'/g' /var/www/html/sites/default/civicrm.settings.php
sed -i 's/##CIVICRM_PASSWORD##/'"${CIVICRM_PASSWORD}"'/g' /var/www/html/sites/default/civicrm.settings.php
sed -i 's/##CIVICRM_DATABASE##/'"${CIVICRM_DATABASE}"'/g' /var/www/html/sites/default/civicrm.settings.php

## set civicrm datbase in sql source
sed -i 's/##CIVICRM_DATABASE##/'"${CIVICRM_DATABASE}"'/g' /mysql-initdb.d/civicrm.sql

## set permissions on drupal files
find /var/www/html/sites/default -type d -exec chmod 755 {} \;
find /var/www/html/sites/default -type f -exec chmod 666 {} \;
chown -R www-data:www-data /var/www/html/
