FROM php:7.3-fpm

ENV SWOOLE_VERSION=4.4.14
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
    nodejs \
    npm \
    libz-dev \
    libzip-dev\
    libssl-dev \
    libnghttp2-dev \
    libpcre3-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    && apt-get clean \
    && apt-get autoremove \
    && npm install npm@latest -g \
    && npm install -g pm2

# Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer self-update --clean-backups \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

# PDO extension
RUN docker-php-ext-install bcmath gd pdo_mysql mbstring sockets zip sysvmsg sysvsem sysvshm mysqli

# Redis extension
RUN wget http://pecl.php.net/get/redis-${PHP_REDIS}.tgz -O /tmp/redis.tar.tgz \
    && pecl install /tmp/redis.tar.tgz \
    && rm -rf /tmp/redis.tar.tgz \
    && docker-php-ext-enable redis
    
# MongoDb extension
RUN pecl install mongodb && docker-php-ext-enable mongodb

# MsgPack extension
RUN pecl install msgpack && docker-php-ext-enable msgpack

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

WORKDIR /var/www/html

EXPOSE 9500 9501 9502 9504 9505
