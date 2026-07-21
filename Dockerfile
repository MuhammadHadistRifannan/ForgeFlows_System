FROM php:8.2-fpm
WORKDIR /app
COPY . .

COPY composer*.json .
COPY composer*.lock .

RUN apt-get update && apt-get install -y openssl \
    docker-php-ext-install \
    git \
    unzip \ 
    libzip-dev 

RUN docker-php-ext-install \
    php-bcmath \
    php-curl    \ 
    php-json \
    php-mbstring \
    php-mysql \
    php-tokenizer \ 
    php-xml\
    php-zip 

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN composer install

EXPOSE 9000
CMD [ "php-fpm" ]