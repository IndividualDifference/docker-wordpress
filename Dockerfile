FROM alpine:latest

LABEL description "Lightweight WordPress container with Nginx 1.12 & PHP-FPM 7.1 based on Alpine Linux."

MAINTAINER Florian Kleber <kleberbaum@erebos.xyz>

# WordPress change here to desired version
ENV WORDPRESS_VERSION 4.9.6
ENV WORDPRESS_SHA1 40616b40d120c97205e5852c03096115c2fca537

WORKDIR /var/www/wp-content

# update, install and cleaning
RUN echo "## Installing base ##" && \
    echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community/" >> /etc/apk/repositories && \
    apk upgrade --update-cache --available && \
    \
    apk add --force \
    	bash \
	curl \
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
    && curl -o wordpress.tar.gz -SL https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz \
    && echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - \
    && tar -xzf wordpress.tar.gz -C /usr/src/ \
    && rm wordpress.tar.gz \
    && chown -R nobody.nobody /usr/src/wordpress \
    && rm -rf /tmp/* /var/cache/apk/* /var/cache/distfiles/*

EXPOSE 80

# Configure nginx
ADD config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
ADD config/fpm-pool.conf /etc/php7/php-fpm.d/zzz_custom.conf
ADD config/php.ini /etc/php7/conf.d/zzz_custom.ini

# Configure supervisord
ADD config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# WP config
add config/wp-config.php /usr/src/wordpress
RUN chown nobody.nobody /usr/src/wordpress/wp-config.php && chmod 640 /usr/src/wordpress/wp-config.php

# Append WP secrets
ADD config/wp-secrets.php /usr/src/wordpress
RUN chown nobody.nobody /usr/src/wordpress/wp-secrets.php && chmod 640 /usr/src/wordpress/wp-secrets.php

# Entrypoint to copy wp-content
ADD run.sh /run.sh
ENTRYPOINT ["/sbin/tini", "--", "/run.sh" ]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
