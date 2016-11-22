#!/bin/bash
set -eo pipefail
shopt -s nullglob

_check_config() {
	toRun=( "mysqld" --verbose --help --log-bin-index="$(mktemp -u)" )
	if ! errors="$("${toRun[@]}" 2>&1 >/dev/null)"; then
		cat >&2 <<-EOM

			ERROR: mysqld failed while attempting to check config
			command was: "${toRun[*]}"

			$errors
		EOM
		exit 1
	fi
}

_datadir() {
	"mysqld" --verbose --help --log-bin-index="$(mktemp -u)" 2>/dev/null | awk '$1 == "datadir" { print $2; exit }'
}

# allow the container to be started with `--user`
if [ "$(id -u)" = '0' ]; then
	_check_config "mysqld"
	DATADIR="$(_datadir "mysqld")"
	touch /var/log/civicrm/mysql.log
    chown mysql:mysql /var/log/civicrm/mysql.log
	mkdir -p "$DATADIR"
	chown -R mysql:mysql "$DATADIR"
	exec gosu mysql "$BASH_SOURCE"
fi

# still need to check config, container may have started with --user
_check_config "mysqld"
# Get config
DATADIR="$(_datadir "mysqld")"

if [ ! -d "$DATADIR/mysql" ]; then
    if [ -z "$MYSQL_ROOT_PASSWORD" -a -z "$MYSQL_ALLOW_EMPTY_PASSWORD" -a -z "$MYSQL_RANDOM_ROOT_PASSWORD" ]; then
        echo >&2 'error: database is uninitialized and password option is not specified '
        echo >&2 '  You need to specify one of MYSQL_ROOT_PASSWORD, MYSQL_ALLOW_EMPTY_PASSWORD and MYSQL_RANDOM_ROOT_PASSWORD'
        exit 1
    fi

    mkdir -p "$DATADIR"

    echo 'Initializing database'
    mysql_install_db --datadir="$DATADIR" --rpm
    echo 'Database initialized'

    "mysqld" --skip-networking &
    pid="$!"

    mysql=( mysql --protocol=socket -uroot )

    for i in {30..0}; do
        if echo 'SELECT 1' | "${mysql[@]}" &> /dev/null; then
            break
        fi
        echo 'MySQL init process in progress...'
        sleep 1
    done
    if [ "$i" = 0 ]; then
        echo >&2 'MySQL init process failed.'
        exit 1
    fi

    if [ -z "$MYSQL_INITDB_SKIP_TZINFO" ]; then
        # sed is for https://bugs.mysql.com/bug.php?id=20545
        mysql_tzinfo_to_sql /usr/share/zoneinfo | sed 's/Local time zone must be set--see zic manual page/FCTY/' | "${mysql[@]}" mysql
    fi

    if [ ! -z "$MYSQL_RANDOM_ROOT_PASSWORD" ]; then
        MYSQL_ROOT_PASSWORD="$(pwgen -1 32)"
        echo "GENERATED ROOT PASSWORD: $MYSQL_ROOT_PASSWORD"
    fi

    echo "-- What's done in this file shouldn't be replicated
    --  or products like mysql-fabric won't work
    SET @@SESSION.SQL_LOG_BIN=0;

    DELETE FROM mysql.user ;
    CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;
    GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
    DROP DATABASE IF EXISTS test ;
    FLUSH PRIVILEGES ;" | "${mysql[@]}"

    if [ ! -z "$MYSQL_ROOT_PASSWORD" ]; then
        mysql+=( -p"${MYSQL_ROOT_PASSWORD}" )
    fi

    # create drupal database and user
    echo "CREATE DATABASE IF NOT EXISTS \`$DRUPAL_DATABASE\`;
    CREATE USER '$DRUPAL_USER'@'%' IDENTIFIED BY '$DRUPAL_PASSWORD';
    GRANT ALL ON \`$DRUPAL_DATABASE\`.* TO '$DRUPAL_USER'@'%';
    CREATE DATABASE IF NOT EXISTS \`$CIVICRM_DATABASE\`;
    CREATE USER '$CIVICRM_USER'@'%' IDENTIFIED BY '$CIVICRM_PASSWORD';
    GRANT ALL ON \`$CIVICRM_DATABASE\`.* TO '$CIVICRM_USER'@'%';" | "${mysql[@]}"

    echo 'FLUSH PRIVILEGES ;' | "${mysql[@]}"

    echo
    for f in /mysql-initdb.d/*; do
        case "$f" in
            *.sh)     echo "$0: running $f"; . "$f" ;;
            *.sql)    echo "$0: running $f"; "${mysql[@]}" < "$f"; echo ;;
            *.sql.gz) echo "$0: running $f"; gunzip -c "$f" | "${mysql[@]}"; echo ;;
            *)        echo "$0: ignoring $f" ;;
        esac
        echo
    done

    if ! kill -s TERM "$pid" || ! wait "$pid"; then
        echo >&2 'MySQL init process failed.'
        exit 1
    fi

    echo
    echo 'MySQL init process done. Ready for start up.'
    echo
fi