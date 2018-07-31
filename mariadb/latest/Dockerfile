FROM alpine:latest

LABEL description "MariaDB is a full-featured open-source SQL server"

# developed for TheDifferent by Florian Kleber for terms of use have a look at the LICENSE file
MAINTAINER Florian Kleber <kleberbaum@erebos.xyz>

# update, install and cleaning
RUN echo "## Installing base ##" && \
    echo "@main http://dl-cdn.alpinelinux.org/alpine/edge/main/" >> /etc/apk/main && \
    echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community/" >> /etc/apk/repositories && \
    apk upgrade --update-cache --available && \
    \
    apk add --force \
        bash@main \
        grep@main \
        mariadb@main \
        tini@community \
    \
    && mkdir -m 777 /var/lib/mysqld \
    && chown -R mysql:mysql /var/lib/mysql \
    && find /etc/mysql/ -name '*.cnf' -print0 \
        | xargs -0 grep -lZE '^(bind-address|log)' \
        | xargs -rt -0 sed -Ei 's/^(bind-address|log)/#&/' \
    && mkdir -m 777 /etc/mysql/conf.d/ \
    && echo '[mysqld]\nskip-host-cache\nskip-name-resolve' > /etc/mysql/conf.d/docker.cnf \
    \
    && ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin \
    && rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

EXPOSE 3306/tcp

VOLUME /var/lib/mysql

# add license
ADD LICENSE /

# deploy init script
ADD run.sh /

# starting via tini as init
ENTRYPOINT ["/sbin/tini", "--", "/run.sh"]

CMD ["/usr/bin/mysqld", "--user=mysql", "--console"]
