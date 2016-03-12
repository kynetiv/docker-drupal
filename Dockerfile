FROM nginx

MAINTAINER Miles Fink

EXPOSE 80

# VOLUME /usr/share/nginx/html/
VOLUME /app

# Silence debconf's endless prattle
ENV DEBIAN_FRONTEND noninteractive

RUN  apt-get update \
    && apt-get -y install curl \
    apt-utils \
    && echo "deb http://packages.dotdeb.org jessie all" > /etc/apt/sources.list.d/dotdeb.list \
    && curl -sS https://www.dotdeb.org/dotdeb.gpg | apt-key add - \
    && apt-get update \
    && apt-get -y --no-install-recommends --force-yes install nano \
    php7.0 \
    php7.0-fpm \
    php7.0-gd \
    php7.0-mcrypt \
    php7.0-phpdbg \
    php7.0-mysql \
    php7.0-pgsql \
    php7.0-redis \
    php7.0-opcache \
    php7.0-cli \
    php7.0-curl \
    php7.0-json \
    php7.0-xml \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*



COPY drupal.conf /etc/nginx/conf.d/default.conf
COPY www.conf /etc/php/7.0/fpm/pool.d/www.conf
COPY nginx.conf /etc/nginx/nginx.conf
#COPY php.ini /etc/php5/fpm/php.ini

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Allow NGINX UID and GID to be set at runtime so we can pass in environment variables.
ENV HOST_UID 200
ENV HOST_GID 200

CMD \
    # Commenting out until we can guarantee it works. Troubl e on Macs.
    #  usermod -u $HOST_UID nginx && \
    #  groupmod -g $HOST_GID nginx && \
    rm -rf /var/www && \
    ln -s /app/$DOCUMENT_ROOT /var/www && \
    service nginx start && \
    service php7-fpm start && \
    tail -f /var/log/php7-fpm.log \
