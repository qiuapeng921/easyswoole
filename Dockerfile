FROM php:7.3

ENV SWOOLE_VERSION=4.4.12
ENV PHP_REDIS=5.0.2


# Libs
RUN apt-get update \
    && apt-get install -y \
    curl \
    wget \
    git \
    zip \
    unzip \
    procps \
    lsof \
    tcpdump \
    htop \
    openssl \
    vim \
    libz-dev \
    libzip-dev\
    libssl-dev \
    libnghttp2-dev \
    libpcre3-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    && apt-get clean \
    && apt-get autoremove

# Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer self-update --clean-backups \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

# PDO extension
RUN docker-php-ext-install bcmath gd pdo_mysql mbstring sockets zip sysvmsg sysvsem sysvshm

# Redis extension
RUN wget http://pecl.php.net/get/redis-${PHP_REDIS}.tgz -O /tmp/redis.tar.tgz \
    && pecl install /tmp/redis.tar.tgz \
    && rm -rf /tmp/redis.tar.tgz \
    && docker-php-ext-enable redis

# Swoole extension
RUN wget https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz -O swoole.tar.gz \
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

EXPOSE 9501
