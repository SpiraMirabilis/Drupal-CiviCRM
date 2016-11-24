#!/bin/bash
MYSQL_PID=""
APACHE_PID=""
KILL_TIMEOUT=30
DELAY="5s"

trap stop SIGHUP
trap stop SIGINT
trap stop SIGQUIT
trap stop SIGABRT
trap stop SIGKILL
trap stop SIGTERM

function stop() {
    if [ "$APACHE_PID" != "" ]; then
        echo -e "$(date): shutting down apache"
        kill -SIGTERM "$APACHE_PID"
        count=0
        while [ "$count" -lt "$KILL_TIMEOUT" ]; do
            if ! cat "/proc/${APACHE_PID}/comm" | grep -q apache; then
                echo -e "$(date): apache exited"
                count=$KILL_TIMEOUT
            fi
            count=$((count+1))
            sleep 1s
        done
    fi
    if [ "$MYSQL_PID" != "" ]; then
    echo -e "$(date): shutting down mysql"
        kill -SIGTERM "$MYSQL_PID"
        count=0
        while [ "$count" -lt "$KILL_TIMEOUT" ]; do
            if ! cat "/proc/${MYSQL_PID}/comm" | grep -q mysql; then
                echo -e "$(date): mysql exited"
                exit 0
            fi
            count=$((count+1))
            sleep 1s
        done
    fi
    echo -e "$(date): faile to shut down own or more servers"
    exit 255
}

function port_check() {
    port="$1"
    program="$2"
    if ! nc -z -w5 127.0.0.1 ${port}; then
        echo -e "$(date): ${program} health check failed"
        count=0
        while true; do
            if [ "$count" -gt "$KILL_TIMEOUT" ]; then
                echo -e "$(date): ${program} not responding"
                exit 255
            fi
            if nc -z -w5 127.0.0.1 ${port}; then
                echo -e "$(date): ${program} recovered, health check passed"
                break
            fi
            count=$((count+1))
            sleep 1s
        done
    fi
    unset port program
}
function health_check() {
    if ! cat "/proc/${APACHE_PID}/comm" | grep -q apache; then
        echo -e "$(date): apache exited unexpectedly"
        exit 255
    fi
    port_check 80 "apache"
    if ! cat "/proc/${MYSQL_PID}/comm" | grep -q mysql; then
        echo -e "$(date): mysql exited unexpectedly"
        exit 255
    fi
    port_check 3306 "mysql"
}

function startup() {
    /usr/local/bin/mysql-start.sh > /var/log/civicrm/mysql.log 2>&1 &
    MYSQL_PID=$!
    /usr/local/bin/apache2-foreground > /var/log/civicrm/apache.log 2>&1 &
    APACHE_PID=$!
    if [ "$ROOT_USER_PASSWORD" ]; then
        sleep $DELAY
        /usr/local/bin/drush upwd --password="${ROOT_USER_PASSWORD}" "root"
    fi
}

function user_variables() {
    if [ "$DRUPAL_USER" -a "$DRUPAL_PASSWORD" -a "$DRUPAL_DATABASE" ]; then
      export DRUPAL_USER="$DRUPAL_USER"
      export DRUPAL_PASSWORD="$DRUPAL_PASSWORD"
      export DRUPAL_DATABASE="$DRUPAL_DATABASE"
    else
      export DRUPAL_USER="drupal"
      export DRUPAL_PASSWORD="$(pwgen -1 32)"
      export DRUPAL_DATABASE="drupal"
      echo "Drupal user: $DRUPAL_USER"
      echo "Drupal password: $DRUPAL_PASSWORD"
      echo "Drupal database: $DRUPAL_DATABASE"
    fi

    if [ "$CIVICRM_USER" -a "$CIVICRM_PASSWORD" -a "$CIVICRM_DATABASE" ]; then
      export CIVICRM_USER="$CIVICRM_USER"
      export CIVICRM_PASSWORD="$CIVICRM_PASSWORD"
      export CIVICRM_DATABASE="$CIVICRM_DATABASE"
    else
      export CIVICRM_USER="civicrm"
      export CIVICRM_PASSWORD="$(pwgen -1 32)"
      export CIVICRM_DATABASE="civicrm"
      echo "CiviCRM user: $CIVICRM_USER"
      echo "CiviCRM password: $CIVICRM_PASSWORD"
      echo "CiviCRM database: $CIVICRM_DATABASE"
    fi

    if [ "$MYSQL_ROOT_PASSWORD" ]; then
      export MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD"
    else
      export MYSQL_ROOT_PASSWORD="$(pwgen -1 32)"
      echo "MySQL root password: $MYSQL_ROOT_PASSWORD"
    fi

    if [ "$BASE_URL" ]; then
        export BASE_URL="$BASE_URL"
    fi

    export HASH_SALT="$(pwgen -1 32)"
    export DATABASE_HOST="127.0.0.1"
}

function first_run() {
    mkdir -p /var/log/civicrm
    chmod 755 /var/log/civicrm
    user_variables
    /usr/local/bin/civicrm-firstrun.sh
    /usr/local/bin/mysql-firstrun.sh
}

if [ ! -f /var/www/html/sites/default/settings.php ]; then
    first_run
fi
startup
tail -f /var/log/civicrm/*.log &
sleep $DELAY
while true; do
    health_check
    sleep $DELAY
done