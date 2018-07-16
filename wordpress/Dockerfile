FROM alpine:latest

LABEL description "Lightweight WordPress container with Nginx 1.12 & PHP-FPM 7.1 based on Alpine Linux."

# developed for TheDifferent by Florian Kleber for terms of use have a look at the LICENSE file
MAINTAINER Florian Kleber <kleberbaum@erebos.xyz>

# WordPress change here to desired version
ENV WORDPRESS_VERSION 4.9.7
ENV WORDPRESS_SHA1 7bf349133750618e388e7a447bc9cdc405967b7d

WORKDIR /var/www/wp-content

# update, install and cleaning
RUN echo "## Installing base ##" && \
    echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community/" >> /etc/apk/repositories && \
    apk upgrade --update-cache --available && \
    \
    apk add --force \
    	bash \
    	nginx \
	supervisor \
    	php7 \
	php7-fpm \
	php7-mysqli \
	php7-json \
	php7-openssl \
	php7-curl \
	php7-zlib \
	php7-xml \
	php7-phar \
	php7-intl \
	php7-dom \
	php7-xmlreader \
	php7-ctype \
	php7-mbstring \
	php7-gd \
        tini@community \
    \
    && chown -R nobody.nobody /var/www \
    && mkdir -p /usr/src \
    && wget "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz" -O wordpress.tar.gz \
    && echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - \
    && tar -xzf wordpress.tar.gz -C /usr/src/ \
    && rm wordpress.tar.gz \
    \
    && chown -R nobody.nobody /usr/src/wordpress \
    && rm -rf /tmp/* /var/cache/apk/* /var/cache/distfiles/*

EXPOSE 80

# disabled Volume cause it's not needed at the moment pls check notes before you consider changing
#VOLUME /var/www/wp-content

# configure nginx
ADD config/nginx.conf /etc/nginx/nginx.conf

# configure PHP-FPM
ADD config/fpm-pool.conf /etc/php7/php-fpm.d/zzz_custom.conf
ADD config/php.ini /etc/php7/conf.d/zzz_custom.ini

# configure supervisord
ADD config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# wp config
add config/wp-config.php /usr/src/wordpress
RUN chown nobody.nobody /usr/src/wordpress/wp-config.php && chmod 640 /usr/src/wordpress/wp-config.php

# append WP secrets
ADD config/wp-secrets.php /usr/src/wordpress
RUN chown nobody.nobody /usr/src/wordpress/wp-secrets.php && chmod 640 /usr/src/wordpress/wp-secrets.php

# add license
ADD LICENSE /

# deploy init script
ADD run.sh /
RUN chmod +x /run.sh

# starting via tini as init
ENTRYPOINT ["/sbin/tini", "--", "/run.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
