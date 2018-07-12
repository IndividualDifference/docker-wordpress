#!/bin/bash

# developed for TheDifferent by Florian Kleber for terms of use have a look at the LICENSE file

# terminate on errors
set -xe

# define as docker compose var or default ""
BACKUP_URL=${BACKUP_URL:-""}

# check if volume is not empty
if [ ! $(ls -A "/var/www/wp-content" 2>/dev/null) ]; then
    # check if BACKUP_URL exists by downloading the first byte
    if [ "curl --output /dev/null --silent --fail -r 0-0 '$BACKUP_URL'" ]; then
        # download backup from backup url
        curl -sfL "$BACKUP_URL" | tar -zxC /var/www
    else
        # print info to cli
        echo 'Setting up wp-content directory'
        # copy wp-content from Wordpress src to directory
        cp -r /usr/src/wordpress/wp-content /var/www/
        chown -R nobody:nobody /var/www
    fi
    # generate secrets
    curl -sf https://api.wordpress.org/secret-key/1.1/salt/ >> /usr/src/wordpress/wp-secrets.php
fi

# execute CMD[]
exec "$@"
