# [](#header-1)WordPress and MariaDB Docker Container

Lightweight MariaDB, and WordPress container with Nginx 1.12 & PHP-FPM 7.1 based on Alpine Linux.

**MariaDB:**
[![ImageOrigin](https://images.microbadger.com/badges/version/thedifferent/mariadb.svg)](https://microbadger.com/images/thedifferent/mariadb "Get your own version badge on microbadger.com")
[![Docker Stars](https://img.shields.io/docker/stars/thedifferent/mariadb.svg)](https://hub.docker.com/r/thedifferent/mariadb/)
[![Docker Pulls](https://img.shields.io/docker/pulls/thedifferent/mariadb.svg)](https://hub.docker.com/r/thedifferent/mariadb/)
[![ImageLayers](https://images.microbadger.com/badges/image/thedifferent/mariadb.svg)](https://microbadger.com/#/images/thedifferent/mariadb)

**WordPress:**
[![ImageOrigin](https://images.microbadger.com/badges/version/thedifferent/wordpress.svg)](https://microbadger.com/images/thedifferent/wordpress "Get your own version badge on microbadger.com")
[![Docker Stars](https://img.shields.io/docker/stars/thedifferent/wordpress.svg)](https://hub.docker.com/r/thedifferent/wordpress/)
[![Docker Pulls](https://img.shields.io/docker/pulls/thedifferent/wordpress.svg)](https://hub.docker.com/r/thedifferent/wordpress/)
[![ImageLayers](https://images.microbadger.com/badges/image/thedifferent/wordpress.svg)](https://microbadger.com/#/images/thedifferent/wordpress)

### [](#header-2)About us:

> ***"There is beauty in the unique; there is beauty in every skin!"***

Hello. We are TheDifferent. a Startup with an unique approach to skin analysis, designed to help you truly understand your skin and get the right products for your needs.
We are trying to turn skincare consultation into one of the world's most exciting Must-Have. Our founders saw a category that had been ignored, taken for granted, looked over, and dismissed. By creating life into something that had been overlooked, we are igniting a movement of self-discovery and 'savoir-vivre' that has drawn dermatologist, cosmeticians, make-up artists and iconic beauty influencers to the brand - a group we call the Modern Collective. By underpinning our creative roots with a relentless focus on innovation, we have ensured that TheDifferent. brings beauty to everyone who dare to be different.

### [](#header-3)Our Mission:
United by difference and tied together by uniqueness, TheDifferent. is the first modern collective celebrating and honoring individuality by introducing shoe sizes into the cosmetic industry, which is currently driven by the constraint 'one-size-fits-all'.
Our mission can be translated into these two questions:
Do you know your shoe sizes?
Do you know your skin type?
TheDifferent. is as simple as this.

## [](#header-4)Mariadb

#### []()MYSQL_ROOT_HOST
This environment variable defines which host has acces to the root user. The default is the wildcard "%". In the example below, it is being set to "localhost" for **better security**.

#### []()MYSQL_ROOT_PASSWORD
**It' s advised to define this environment variable** This environment variable sets the root password for MySQL. The default is generated with pwgen. In the example below, it is being set to "ciscocisco" please change for the sake of **security**.

> Note 1: For a more PostgreSQL image like experience the root@localhost is set to trust authentication so you may notice a password is not required when connecting from localhost (inside the same container). However, a password will be required if connecting from a different host/container.

#### []()MYSQL_ROOT_PASSWORD_LOCAL
For **better security** you can disable trust authentication for root user. If this environment variable is set to "true"
it disables local root trust authentication. The default is "false". In the example below, it is being set to "true".

#### []()MYSQL_DATABASE
This optional environment variable can be used to define a different name for the default database that is created when the image is first started. In the example below, it is being set to "wp".

#### []()MYSQL_USER
This optional environment variable is used in conjunction with MYSQL_USER_PASSWORD to set a user and its password. This variable will create the specified user with power over MYSQL_DATABASE or if MYSQL_DATABASE not defined with superuser power. In the example below, it is being set to "wordpress" and has power over the db "wp".

#### []()MYSQL_PASSWORD
This environment variable sets the user password for MYSQL_USER. The default is generated with pwgen. In the example below, it is being set to "cisco" please change for the sake of **security**.

## [](#header-6)Start via docker-compose

```bash
version: '3.1'
services:
  db:
    build: mariadb
    environment:
      - "MYSQL_ROOT_HOST=localhost"
      - "MYSQL_ROOT_PASSWORD=ciscocisco"
      - "MYSQL_ROOT_PASSWORD_LOCAL=true"
      - "MYSQL_DATABASE=wordpress"
      - "MYSQL_USER=wp"
      - "MYSQL_PASSWORD=cisco"

  wordpress:
    build: wordpress
    depends_on:
      - "db"
    ports:
      - "80:80"
    environment:
      - "DB_HOST=db"
      - "DB_NAME=wordpress"
      - "DB_USER=wp"
      - "DB_PASSWORD=cisco"
      - "WORDPRESS_SITE_URL=http://localhost"
```

## [](#header-7)Build via docker-compose

```bash
version: '3.1'
services:
  db:
    #image: thedifferent/mariadb
    build: mariadb
    environment:
      - "MYSQL_ROOT_HOST=localhost"
      - "MYSQL_ROOT_PASSWORD=ciscocisco"
      - "MYSQL_ROOT_PASSWORD_LOCAL=true"
      - "MYSQL_DATABASE=wordpress"
      - "MYSQL_USER=wp"
      - "MYSQL_PASSWORD=cisco"

  wordpress:
    #image: thedifferent/wordpress
    build: wordpress
    depends_on:
      - "db"
    ports:
      - "80:80"
    environment:
      - "DB_HOST=db"
      - "DB_NAME=wordpress"
      - "DB_USER=wp"
      - "DB_PASSWORD=cisco"
      - "WORDPRESS_SITE_URL=http://localhost"
```

## [](#header-8)Deploy via swarm

```bash
version: '3.1'

services:
  db:
    image: thedifferent/mariadb
    #build: mariadb
    networks:
      - "wp-net"
    environment:
      - "MYSQL_ROOT_HOST=localhost"
      - "MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}"
      - "MYSQL_ROOT_PASSWORD_LOCAL=true"
      - "MYSQL_DATABASE=wp"
      - "MYSQL_USER=wordpress"
      - "MYSQL_PASSWORD=${MYSQL_PASSWORD}"

    #resources:
    #  limits:
    #    cpus: '0.3'
    #    memory: 512M
    #  reservations:
    #    cpus: '0.15'
    #    memory: 256M

  wordpress:
    image: thedifferent/wordpress
    #build: wordpress
    depends_on:
      - "db"
    networks:
      - "wp-net"
    ports:
      - "${WP_PORT}:80"
    environment:
      - "DB_HOST=db"
      - "DB_NAME=wp"
      - "DB_USER=wordpress"
      - "DB_PASSWORD=${MYSQL_PASSWORD}"
      - "WORDPRESS_SITE_URL=${WP_SITE_URL}"
    #resources:
    #  limits:
    #    cpus: '0.50'
    #    memory: 1024M
    #  reservations:
    #    cpus: '0.25'
    #    memory: 512M

networks:
  wp-net:
    driver: overlay
```

### [](#header-9)Inspired by

* https://github.com/TrafeX/docker-wordpress
* https://hub.docker.com/_/wordpress/
* https://codeable.io/wordpress-developers-intro-to-docker-part-two/
* https://github.com/TrafeX/docker-php-nginx/
* https://github.com/etopian/alpine-php-wordpress
* https://github.com/yobasystems/alpine-mariadb
* https://github.com/docker-library/mariadb/tree/a7d1a184913c009c473baeb8f72385d12ae0de61/10.3
