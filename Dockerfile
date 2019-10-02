FROM php:7.3.9

ENV SWOOLE_VERSION=4.4.7
ENV PHP_REDIS=5.0.2

RUN apt-get update \
    && apt-get install -y \
        curl wget git zip unzip vim procps iputils-ping net-tools lsof tcpdump htop openssl \
        libz-dev \
        libssl-dev \
        libnghttp2-dev \
        libpcre3-dev \
        libjpeg-dev \
        libpng-dev \
        libfreetype6-dev

RUN echo "alias ll='ls -la'" >> ~/.bashrc && source ~/.bashrc

RUN docker-php-ext-install \
    gd intl bz2 pcntl pdo_mysql opcache mysqli mbstring exif bcmath sockets zip sysvmsg sysvsem sysvshm mongodb inotify

RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer self-update --clean-backups \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

RUN wget http://pecl.php.net/get/redis-${PHP_REDIS}.tgz -O /tmp/redis.tar.tgz \
    && pecl install /tmp/redis.tar.tgz \
    && rm -rf /tmp/redis.tar.tgz \
    && docker-php-ext-enable redis

RUN wget https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz -O swoole.tar.gz \
    && mkdir -p swoole \
    && tar -xf swoole.tar.gz -C swoole --strip-components=1 \
    && rm swoole.tar.gz \
    && ( \
        cd swoole \
        && phpize \
        && ./configure --enable-mysqlnd --enable-sockets --enable-openssl --enable-http2 \
        && make -j$(nproc) \
        && make install \s
    ) \
    && rm -r swoole \
    && docker-php-ext-enable swoole

