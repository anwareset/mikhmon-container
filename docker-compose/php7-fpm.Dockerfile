FROM php:7.4-fpm-alpine
RUN apk add --no-cache curl unzip gmp-dev gettext-dev libpng-dev libjpeg-turbo-dev zlib-dev \
    && docker-php-ext-install gmp gettext iconv pcntl gd session \
    && docker-php-ext-enable gmp gettext iconv pcntl gd session
