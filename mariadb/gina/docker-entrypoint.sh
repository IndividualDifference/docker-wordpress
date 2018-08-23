#!/usr/bin/env bash

# developed for TheDifferent by Florian Kleber for terms of use have a look at the LICENSE file

# terminate on errors
set -xe

if [ -d "/run/mysqld" ]; then
	echo "[i] mysqld already present, skipping creation"
else
	echo "[i] mysqld not found, creating...."
	mkdir -p /run/mysqld
fi

# define owner
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

if [ -d /var/lib/mysql/mysql ]; then
	echo "[i] MySQL directory already present, skipping creation"

else
	echo "[i] MySQL data directory not found, creating initial DBs"

	mysql_install_db --user=mysql > /dev/null

	if [ "$MYSQL_ROOT_PASSWORD" = "" ]; then
		MYSQL_ROOT_PASSWORD=`pwgen 16 1`
		echo "[i] MySQL root Password: $MYSQL_ROOT_PASSWORD"
	fi

	# define as docker compose var or default
	MYSQL_ROOT_PASSWORD_LOCAL=${MYSQL_ROOT_PASSWORD_LOCAL:-"false"}
	MYSQL_ROOT_HOST=${MYSQL_ROOT_HOST:-"%"}
	MYSQL_DATABASE=${MYSQL_DATABASE:-""}
	MYSQL_USER=${MYSQL_USER:-""}
	MYSQL_PASSWORD=${MYSQL_PASSWORD:-""}

	tfile=`mktemp`
	if [ ! -f "$tfile" ]; then
		return 1
	fi

	cat <<- EOSQL > $tfile
		-- What's done in this file shouldn't be replicated
		--  or products like mysql-fabric won't work
		SET @@SESSION.SQL_LOG_BIN=0;
		USE mysql;
		FLUSH PRIVILEGES;
		DELETE FROM mysql.user WHERE user NOT IN ('mysql.sys', 'mysqlxsys', 'root') OR host NOT IN ('localhost');
		GRANT ALL ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
	EOSQL

	if [ "$MYSQL_ROOT_PASSWORD_LOCAL" == "true" ]; then
		cat <<- EOSQL >> $tfile
			SET PASSWORD FOR 'root'@'localhost'=PASSWORD('${MYSQL_ROOT_PASSWORD}');
		EOSQL
	fi

	if [ "$MYSQL_ROOT_HOST" != "localhost" ]; then
		cat <<- EOSQL >> $tfile
			CREATE USER 'root'@'${MYSQL_ROOT_HOST}' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
			GRANT ALL ON *.* TO 'root'@'${MYSQL_ROOT_HOST}' WITH GRANT OPTION;
			DROP DATABASE IF EXISTS test;
			FLUSH PRIVILEGES;
		EOSQL
	fi

	if [ "$MYSQL_DATABASE" == "*" ]; then
		if [ "$MYSQL_USER" != "" ]; then
			echo "[i] Creating user: $MYSQL_USER with password $MYSQL_PASSWORD"
			echo "GRANT ALL ON *.* to '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';" >> $tfile
		fi

	elif [ "$MYSQL_DATABASE" != "" ]; then
		echo "[i] Creating database: $MYSQL_DATABASE"
		echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $tfile

		if [ "$MYSQL_USER" != "" ]; then
			echo "[i] Creating user: $MYSQL_USER with password $MYSQL_PASSWORD"
			echo "GRANT ALL ON \`$MYSQL_DATABASE\`.* to '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';" >> $tfile
		fi
	fi

	/usr/bin/mysqld --user=mysql --bootstrap --verbose=0 < $tfile
	rm -f $tfile
fi

# define as docker compose var or default ""
WP_BACKUP_GIT_REPO=${WP_BACKUP_GIT_REPO:-""}
WP_BACKUP_GIT_USER=${WP_BACKUP_GIT_USER:-""}
WP_BACKUP_GIT_PASSWD=${WP_BACKUP_GIT_PASSWD:-""}
WP_BACKUP_INTERVAL=${WP_BACKUP_INTERVAL:-""}

# check if git repo is set
if [[ $WP_BACKUP_GIT_REPO ]]; then
	# GINAvbs backup solution
	wget -qO- https://raw.githubusercontent.com/kleberbaum/GINAvbs/master/init.sh \
	| bash -s -- \
	--sql \
	--interval=$WP_BACKUP_INTERVAL \
	--repository=https://$WP_BACKUP_GIT_USER:$WP_BACKUP_GIT_PASSWD@${WP_BACKUP_GIT_REPO#*@}
fi

# execute CMD[]
exec "$@"
