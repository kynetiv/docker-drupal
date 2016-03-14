# see https://github.com/phusion/baseimage-docker for perks
FROM phusion/baseimage:0.9.18

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

EXPOSE 80

# VOLUME /usr/share/nginx/html/
VOLUME /app

RUN DEBIAN_FRONTEND="noninteractive"

RUN apt-get update
RUN apt-get -y --no-install-recommends install \
    vim \
    nano \
    curl \
    wget \
    build-essential \
    python-software-properties
RUN add-apt-repository -y ppa:ondrej/php
RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive"
RUN apt-get -y --no-install-recommends install \
    php7.0-fpm \
    php7.0-dev \
    php7.0-cli \
    php7.0-common \
    php7.0-gd \
    php7.0-mcrypt \
    php7.0-mbstring \
    php7.0-tidy \
    php7.0-intl \
    php7.0-phpdbg \
    php7.0-mysql \
    php7.0-pgsql \
    php-redis \
    php7.0-recode \
    php7.0-opcache \
    php7.0-curl \
    php7.0-json \
    php7.0-xml \
    php7.0-zip

RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y nginx

RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.0/fpm/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/"  /etc/php/7.0/fpm/php.ini

COPY conf/drupal.conf   /etc/nginx/sites-available/default
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

RUN mkdir           /etc/service/nginx
ADD init/nginx.sh   /etc/service/nginx/run
RUN chmod +x        /etc/service/nginx/run

RUN mkdir           /etc/service/phpfpm
ADD init/phpfpm.sh  /etc/service/phpfpm/run
RUN chmod +x        /etc/service/phpfpm/run

RUN rm -rf /var/www
RUN ln -s /app/docroot /var/www

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

