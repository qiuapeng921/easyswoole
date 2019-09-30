FROM php:7.3.8-fpm

ENV PHP_SWOOLE=4.4.7
ENV PHP_REDIS=5.0.2
ENV HIREDIS_VERSION=0.14.0

RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak
COPY ./sources.list /etc/apt/sources.list

# Libs

RUN apt-get update && apt-get install libssl-dev build-essential zlibc libidn11-dev libidn11 -y

RUN apt-get update \
    && apt-get install -y \
    curl \
    wget \
    git \
    zip \
    iputils-ping \
    net-tools \
    lsof \
    && apt-get clean \
    && apt-get autoremove
# Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer self-update --clean-backups \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

# PDO extension
RUN docker-php-ext-install pdo_mysql

# Redis extension
RUN wget http://pecl.php.net/get/redis-${PHP_REDIS}.tgz -O /tmp/redis.tar.tgz \
    && pecl install /tmp/redis.tar.tgz \
    && rm -rf /tmp/redis.tar.tgz \
    && docker-php-ext-enable redis

# MongoDB extension
RUN pecl install mongodb \
    && docker-php-ext-enable mongodb

RUN pecl install inotify \
    && docker-php-ext-enable inotify

# Hiredis
RUN wget https://github.com/redis/hiredis/archive/v${HIREDIS_VERSION}.tar.gz -O hiredis.tar.gz \
    && mkdir -p hiredis \
    && tar -xf hiredis.tar.gz -C hiredis --strip-components=1 \
    && rm hiredis.tar.gz \
    && ( \
        cd hiredis \
        && make -j$(nproc) \
        && make install \
        && ldconfig \
    ) \
    && rm -r hiredis

# Swoole extension
RUN wget https://github.com/swoole/swoole-src/archive/v${PHP_SWOOLE}.tar.gz -O swoole.tar.gz \
    && mkdir -p swoole \
    && tar -xf swoole.tar.gz -C swoole --strip-components=1 \
    && rm swoole.tar.gz \
    && ( \
    cd swoole \
        && phpize \
        && ./configure --enable-async-redis --enable-mysqlnd --enable-openssl --enable-http2 \
        && make -j$(nproc) \
        && make install \
    ) \
    && rm -r swoole \
    && docker-php-ext-enable swoole

RUN echo alias ll='ls -la' >> ~/.bashrc

# More extensions
RUN apt install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && docker-php-ext-install intl \
    && docker-php-ext-install bz2 \
    && docker-php-ext-install pcntl \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install opcache \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install exif \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install sockets \
