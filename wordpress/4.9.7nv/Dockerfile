FROM alpine:latest

LABEL description "Lightweight WordPress container with Nginx 1.12 & PHP-FPM 7.1 based on Alpine Linux."

# developed for TheDifferent by Florian Kleber for terms of use have a look at the LICENSE file
MAINTAINER Florian Kleber <kleberbaum@erebos.xyz>

# WordPress change here to desired version
ARG WORDPRESS_VERSION=4.9.7
ARG WORDPRESS_SHA1=7bf349133750618e388e7a447bc9cdc405967b7d

# Config change here to desired config backup
ARG CONFIG_URL=https://github.com/IndividualDifference/docker-wordpress/releases/download/1.0/config.tar.gz
ARG CONFIG_SHA1=2fda6cf79b0d6920053d76be5fe10e030f9b2663

WORKDIR /var/www/wp-content

# update, install and cleaning
RUN echo "## Installing base ##" && \
    echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/main/" >> /etc/apk/main && \
    echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community/" >> /etc/apk/repositories && \
    apk upgrade --update-cache --available && \
    \
    apk add --force \
        bash@main \
        nginx@main \
        php7@main \
        php7-fpm@main \
        php7-mysqli@main \
        php7-json@main \
        php7-openssl@main \
        php7-curl@main \
        php7-zlib@main \
        php7-xml@main \
        php7-phar@main \
        php7-intl@main \
        php7-dom@main \
        php7-xmlreader@main \
        php7-ctype@main \
        php7-mbstring@main \
        php7-gd@main \
        supervisor@main \
        tini@community \
    \
    && chown -R nobody.nobody /var/www \
    && mkdir -p /usr/src \
    && echo "## Installing wordpress ##" \
    && wget "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz" -O wordpress.tar.gz \
    && echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - \
    && tar -xzf wordpress.tar.gz -C /usr/src/ \
    && chown -R nobody.nobody /usr/src/wordpress \
    && echo "## Downloading config ##" \
    && wget "${CONFIG_URL}" \
    && echo "$CONFIG_SHA1 *config.tar.gz" | sha1sum -c - \
    && echo "## Configuring nginx ##" \
    && tar -xzf config.tar.gz -C /etc/nginx/ nginx.conf \
    && echo "## Configuring php-fpm ##" \
    && tar -xzf config.tar.gz -C /etc/php7/php-fpm.d/ zzz_custom.conf \
    && tar -xzf config.tar.gz -C /etc/php7/conf.d/ zzz_custom.ini \
    && echo "## Configuring supervisord ##" \
    && tar -xzf config.tar.gz -C /etc/ supervisord.conf \
    && echo "## Configuring nginx ##" \
    && tar -xzf config.tar.gz -C /usr/src/wordpress/ wp-config.php \
    && chown nobody.nobody /usr/src/wordpress/wp-config.php  \
    && chmod 640 /usr/src/wordpress/wp-config.php \
    && echo "## Configuring wordpress ##" \
    && tar -xzf config.tar.gz -C /usr/src/wordpress/ wp-secrets.php \
    && chown nobody.nobody /usr/src/wordpress/wp-secrets.php \
    && chmod 640 /usr/src/wordpress/wp-secrets.php \
    \
    && rm wordpress.tar.gz \
    && rm config.tar.gz \
    && rm -rf /tmp/* /var/cache/apk/* /var/cache/distfiles/*

EXPOSE 80

# version w/ volume disabled
#VOLUME /var/www/wp-content

# add license
ADD LICENSE /

# deploy init script
ADD run.sh /

# starting via tini as init
ENTRYPOINT ["/sbin/tini", "--", "/run.sh"]

CMD ["/usr/bin/supervisord"]
