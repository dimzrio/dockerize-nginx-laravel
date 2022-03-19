FROM alpine:latest

WORKDIR /var/www/html/

# Setup & install system requirement
RUN addgroup www-php -g 500 && \
    adduser -D -H -s /sbin/nologin -G www-php -u 500 www-php && \
    apk add --no-cache zip unzip curl sqlite nginx supervisor bash nano tzdata && \
    cat /usr/share/zoneinfo/Asia/Jakarta > /etc/localtime && \
    sed -i 's/bin\/ash/bin\/bash/g' /etc/passwd

# Installing php
RUN apk add --no-cache php8 \
    php8-common \
    php8-fpm \
    php8-pdo \
    php8-opcache \
    php8-zip \
    php8-phar \
    php8-iconv \
    php8-cli \
    php8-curl \
    php8-openssl \
    php8-mbstring \
    php8-tokenizer \
    php8-fileinfo \
    php8-json \
    php8-xml \
    php8-xmlwriter \
    php8-simplexml \
    php8-dom \
    php8-pdo_mysql \
    php8-pdo_sqlite \
    php8-tokenizer \
    php8-pecl-redis && \
    ln -s /usr/bin/php8 /usr/bin/php

# Installing composer
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN rm -rf composer-setup.php

# Setup php
COPY ./config/php/php.ini /etc/php8/php.ini
COPY ./config/php/php-fpm.conf /etc/php8/php-fpm.d/www.conf
RUN sed -i 's/;daemonize = yes/daemonize = no/g' /etc/php8/php-fpm.conf

# Setup nginx
COPY ./config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./config/nginx/default.conf /etc/nginx/http.d/default.conf

# Setup supervisor
RUN mkdir -p /etc/supervisor.d/
COPY ./config/supervisor/supervisord.ini /etc/supervisor.d/supervisord.ini

# Setup apps
COPY ./apps/ /var/www/html/apps
RUN chown www-php. -R /var/www/html/

EXPOSE 80
CMD ["supervisord", "-c", "/etc/supervisor.d/supervisord.ini"]