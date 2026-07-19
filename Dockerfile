################################################
# Composer
################################################

FROM composer:2 AS composer

WORKDIR /app

COPY composer.json composer.lock ./

RUN composer install \
    --no-dev \
    --prefer-dist \
    --no-interaction \
    --no-scripts \
    --optimize-autoloader

COPY . .

RUN composer dump-autoload \
    --optimize \
    --classmap-authoritative

################################################
# Node Build
################################################

FROM node:22-alpine AS node

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .

RUN npm run build

################################################
# Production
################################################

FROM php:8.4-fpm-alpine

WORKDIR /var/www/html

RUN apk add --no-cache \
    libzip-dev \
    icu-dev \
    libpng-dev \
    jpeg-dev \
    freetype-dev

RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg

RUN docker-php-ext-install \
    pdo_mysql \
    bcmath \
    intl \
    zip \
    gd \
    opcache \
    pcntl

RUN pecl install redis \
    && docker-php-ext-enable redis

COPY --from=composer /app .
COPY --from=node /app/public/build public/build

RUN chown -R www-data:www-data \
    storage \
    bootstrap/cache

EXPOSE 9000

CMD ["php-fpm"]