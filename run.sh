#!/bin/bash

# terminate on errors
set -xe

# check if volume is not empty
if [ ! "$(ls -A "/var/www/wp-content" 2>/dev/null)" ]; then

    # print info to cli
    echo 'Setting up wp-content volume'

    # copy wp-content from Wordpress src to volume
    cp -r /usr/src/wordpress/wp-content /var/www/
    chown -R nobody:nobody /var/www

    # generate secrets
    curl -f https://api.wordpress.org/secret-key/1.1/salt/ >> /usr/src/wordpress/wp-secrets.php
fi

# this is a workaround cause depends_on doesn't always work
sleep 5

# execute CMD[]
exec "$@"
