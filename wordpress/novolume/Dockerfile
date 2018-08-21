FROM alpine:latest

LABEL description "Lightweight WordPress container with Nginx & PHP-FPM based on Alpine Linux."

# developed for TheDifferent by Florian Kleber for terms of use have a look at the LICENSE file
MAINTAINER Florian Kleber <kleberbaum@erebos.xyz>

# WordPress change here to desired version
ARG WORDPRESS_VERSION=4.9.8
ARG WORDPRESS_SHA1=0945bab959cba127531dceb2c4fed81770812b4f

# Config change here to desired config backup
ARG CONFIG_URL=https://github.com/IndividualDifference/docker-wordpress/releases/download/1.0/config.tar.gz
ARG CONFIG_SHA1=ac54253b369f0e7e67b8fe5bf47e33a8f00c710f

WORKDIR /var/www/wp-content

# update, install and cleaning
RUN echo "## Installing base ##" && \
    echo "@main http://dl-cdn.alpinelinux.org/alpine/edge/main/" >> /etc/apk/main && \
    echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community/" >> /etc/apk/repositories && \
    apk upgrade --update-cache --available && \
    \
    apk add --force \
        bash@main \
        nginx@main \
        php7@community \
        php7-fpm@community \
        php7-mysqli@community \
        php7-json@community \
        php7-openssl@community \
        php7-curl@community \
        php7-zlib@community \
        php7-xml@community \
        php7-phar@community \
        php7-intl@community \
        php7-dom@community \
        php7-xmlreader@community \
        php7-ctype@community \
        php7-mbstring@community \
        php7-gd@community \
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
