# [](#header-1)WordPress Docker Container

Lightweight WordPress container with Nginx 1.12 & PHP-FPM 7.1 based on Alpine Linux.

## [](#header-2)Installation

Should be used via the docker-compose.yml.

### [](#important-info) The .env which defines the password vars can be found at SharePoint

## [](#header-3)Manual Installation for testing

```bash
docker run -d -p "80:80" \
-e "DB_HOST=db" \
-e "DB_NAME=wordpress" \
-e "DB_USER=wp" \
-e "DB_PASSWORD=secret" \
thedifferent/wordpress
```

### [](#header-4)Inspired by

* https://github.com/TrafeX/docker-wordpress
* https://hub.docker.com/_/wordpress/
* https://codeable.io/wordpress-developers-intro-to-docker-part-two/
* https://github.com/TrafeX/docker-php-nginx/
* https://github.com/etopian/alpine-php-wordpress
