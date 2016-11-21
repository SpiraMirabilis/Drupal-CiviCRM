## What is CiviCRM?

CiviCRM is a web-based, open source, internationalized suite of computer software for constituency relationship management, that falls under the broad rubric of customer relationship management. It is specifically designed for the needs of non-profit, non-governmental, and advocacy groups, and serves as an association management system. CiviCRM is designed to manage information about an organization's donors, members, event registrants, subscribers, grant application seekers and funders, and case contacts. Volunteers, activists, voters as well as more general sorts of business contacts such as employees, clients, or vendors can be managed using CiviCRM.

## Start CiviCRM

```docker run -d --name civicrm -p 80:80 jmizell/drupal-civicrm```

## Environment Variables
When you start the CiviCRM image, you can adjust the configuration of the CiviCRM instance by passing one or more environment variables on the docker run command line. Do note that none of the variables below will have any effect if you start the container with a data directory that already contains a database: any pre-existing database will always be left untouched on container startup.

#### DRUPAL_USER
Specified a custom Drupal Mariadb user. Defaults to drupal.

#### DRUPAL_PASSWORD
Specified a custom Drupal Mariadb user password. If left blank, a random password will be generated, and logged to stdout.

#### DRUPAL_DATABASE
Specifies the Drupal database name in Mariadb. Defaults to drupal.

#### CIVICRM_USER
Specified a custom CiviCRM Mariadb user. Defaults to civicrm.

#### CIVICRM_PASSWORD
Specified a custom CiviCRM Mariadb user password. If left blank, a random password will be generated, and logged to stdout.

#### CIVICRM_DATABASE
Specifies the CiviCRM database name in Mariadb. Defaults to civicrm.

#### MYSQL_ROOT_PASSWORD
Specified the root password for Mariadb. If left blank, a random password will be generated, and logged to stdout.

## Using an external Mariadb\MySQL server

todo: implement this option

## Specificing database credentials

todo: implement this option

## Where to Store Data

```
docker run \
  -d \
  --name civicrm \
  --restart=always \
  -p 80:80 \
  -v /srv/civicrm/settings:/var/www/html/sites/default \
  -v /srv/civicrm/themes:/var/www/html/sites/all/themes \
  -v /srv/civicrm/mariadb:/var/lib/mysql \
  -v /srv/civicrm/logs:/var/log/civicrm \
  jmizell/drupal-civicrm
  ```
