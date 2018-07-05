# [](#header-1)WordPress and MariaDB Docker Container

Lightweight MariaDB, and WordPress container with Nginx 1.12 & PHP-FPM 7.1 based on Alpine Linux.

## [](#header-2)Deploy via swarm

```bash
docker stack deploy --compose-file /var/docker-swarm/stacks/td-wp/td-wp.yml td-wp
```

## [](#header-2)Build via docker-compose

### [](#important-info) The .env which defines the password vars can be found at SharePoint

```bash
docker-compose up -d
```

### [](#header-3)Inspired by

* https://github.com/TrafeX/docker-wordpress
* https://hub.docker.com/_/wordpress/
* https://codeable.io/wordpress-developers-intro-to-docker-part-two/
* https://github.com/TrafeX/docker-php-nginx/
* https://github.com/etopian/alpine-php-wordpress
* https://github.com/yobasystems/alpine-mariadb
* https://github.com/docker-library/mariadb/tree/a7d1a184913c009c473baeb8f72385d12ae0de61/10.3
