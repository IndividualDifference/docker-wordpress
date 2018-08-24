#!/usr/bin/env bash

# developed for TheDifferent by Florian Kleber for terms of use have a look at the LICENSE file

# terminate on errors
set -xe

# define as docker compose var or default ""
WP_BACKUP_URL=${WP_BACKUP_URL:-""}
WP_GINA_GIT_REPO=${WP_GINA_GIT_REPO:-""}
WP_GINA_GIT_USER=${WP_GINA_GIT_USER:-""}
WP_GINA_GIT_PASSWD=${WP_GINA_GIT_PASSWD:-""}
WP_GINA_INTERVAL=${WP_GINA_INTERVAL:-""}

# check if volume is not empty
if [ ! -f /var/www/wp-content/index.php ]; then
	echo 'Setting up wp-content directory'
	# check if BACKUP_URL exists by downloading the first byte
	if [[ $(wget -S --spider $1  2>&1 | grep 'HTTP/1.1 200 OK') ]]; then
		# download backup from backup url
		wget -qO- "$WP_BACKUP_URL" | tar zxC /var/www
	else
		# copy wp-content from Wordpress src to directory
		cp -r /usr/src/wordpress/wp-content /var/www/
		if [[ $WP_GINA_GIT_REPO ]]; then
			# GINAvbs backup solution
			wget -qO- https://raw.githubusercontent.com/kleberbaum/GINAvbs/master/init.sh \
			| bash -s -- \
			--interval=$WP_GINA_INTERVAL \
			--repository=https://$WP_GINA_GIT_USER:$WP_GINA_GIT_PASSWD@${WP_GINA_GIT_REPO#*@}
		fi
	fi
	# set owner to nobody
	chown -R nobody:nobody /var/www
	# generate wordpress secrets
	wget https://api.wordpress.org/secret-key/1.1/salt/ -O ->> /usr/src/wordpress/wp-secrets.php
fi

# execute CMD[]
exec "$@"
