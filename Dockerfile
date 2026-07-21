FROM php:8.2-fpm
WORKDIR /app

RUN apt-get update && apt-get install -y openssl \
        libcurl4-openssl-dev \
        libzip-dev \
        libonig-dev \
        libxml2-dev \
        libicu-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    git \
    unzip 

RUN docker-php-ext-install \
    bcmath \
    curl    \
    intl \
    gd \
    json \
    mbstring \
    pdo_mysql \
    tokenizer \
    xml\
    zip 

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer


COPY composer*.lock .
COPY composer*.json .
COPY package*.lock .
COPY package*.json .


COPY . .

RUN composer install

EXPOSE 9000
CMD [ "php-fpm" ]