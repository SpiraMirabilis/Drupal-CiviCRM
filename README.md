# Discontinued
After spending some time trying configure CiviCRM, I've decided that for the project I had in mind, it requires too much effort to configure, and it doesn't have the ease of use necessary for bringing in non-technical volunteers. While CiciCRM looks great on paper, and I believe would make a good choice for many non-profits, for my needs it would require too many resources to get basic functionality. 

I'm no longer planning to update this repo, but I will leave it up as an example of how you can deploy CiviCRM in a docker container.

## What is CiviCRM?

CiviCRM is a web-based, open source, internationalized suite of computer software for constituency relationship management, that falls under the broad rubric of customer relationship management. It is specifically designed for the needs of non-profit, non-governmental, and advocacy groups, and serves as an association management system. CiviCRM is designed to manage information about an organization's donors, members, event registrants, subscribers, grant application seekers and funders, and case contacts. Volunteers, activists, voters as well as more general sorts of business contacts such as employees, clients, or vendors can be managed using CiviCRM.

## What is Drupal?

Drupal is an open source content management platform powering millions of websites and applications.

## Start CiviCRM

```
docker run -d --name civicrm -p 80:80 valuablesquirrel/drupal-civicrm
```

Default user name is "root", and the default password is "drupal", change this immediately, or set it with the ROOT_USER_PASSWORD environment variable.

## Environment Variables
When you start the CiviCRM image, you can adjust the configuration of the CiviCRM instance by passing one or more environment variables on the docker run command line. Do note that none of the variables below will have any effect if you start the container with a data directory that already contains a database: any pre-existing database will always be left untouched on container startup.

#### ROOT_USER_PASSWORD
The Drupal administrator user password. When this variable is set, the password for the administrator user (root), is set each time the container starts. Defaults to drupal.

#### DRUPAL_USER
Specifies a custom Drupal database user. This variable is not used unless the variables DRUPAL_USER, DRUPAL_PASSWORD, and DRUPAL_DATABASE are all set. Defaults to drupal.

#### DRUPAL_PASSWORD
Specifies a custom Drupal database user password. This variable is not used unless the variables DRUPAL_USER, DRUPAL_PASSWORD, and DRUPAL_DATABASE are all set. If left blank, a random password will be generated, and logged to standard out.

#### DRUPAL_DATABASE
Specifies the Drupal database name in the database. This variable is not used unless the variables DRUPAL_USER, DRUPAL_PASSWORD, and DRUPAL_DATABASE are all set. Defaults to drupal.

#### CIVICRM_USER
Specifies a custom CiviCRM database user. This variable is not used unless the variables CIVICRM_USER, CIVICRM_PASSWORD, CIVICRM_DATABSE are all set. Defaults to civicrm.

#### CIVICRM_PASSWORD
Specifies a custom CiviCRM database user password. This variable is not used unless the variables CIVICRM_USER, CIVICRM_PASSWORD, CIVICRM_DATABSE are all set. If left blank, a random password will be generated, and logged to standard out.

#### CIVICRM_DATABASE
Specifies the CiviCRM database name in the database. This variable is not used unless the variables CIVICRM_USER, CIVICRM_PASSWORD, CIVICRM_DATABSE are all set. Defaults to civicrm.

#### MYSQL_ROOT_PASSWORD
Specifies the root password for Mariadb. If left blank, a random password will be generated, and logged to standard out.

## Using an external Mariadb\MySQL server

todo: implement this option

## Specifying database credentials
The Drupal, and CiviCRM database credentials can be set manually by specifying their environment variables. All three environment variables for the Drupal, or CiviCRM database must be set for them to be used. On first run, if no database volume is set, the users, and databases will be created automatically.

```
docker run \
  -d \
  --name civicrm \
  -p 80:80 \
  -v /srv/civicrm/settings:/var/www/html/sites/default \
  -e DRUPAL_USER="someuser" \
  -e DRUPAL_PASSWORD="somepassword" \
  -e DRUPAL_DATABASE="somedatabase" \
  valuablesquirrel/drupal-civicrm
```

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
  valuablesquirrel/drupal-civicrm
  ```
