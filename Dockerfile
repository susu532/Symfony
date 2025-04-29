# syntax=docker/dockerfile:1

# 1. Composer stage
FROM composer:2.7 as composer

# 2. PHP/Nginx build stage
FROM php:8.2-fpm-alpine as phpbase
RUN apk add --no-cache nginx bash icu-dev libzip-dev libpng-dev libjpeg-turbo-dev libwebp-dev zlib-dev libxml2-dev oniguruma-dev git unzip libpq-dev
RUN docker-php-ext-install intl pdo pdo_pgsql opcache zip gd xml mbstring
COPY --from=composer /usr/bin/composer /usr/bin/composer
WORKDIR /var/www/html
COPY . .
ENV APP_ENV=prod
RUN curl -sS https://get.symfony.com/cli/installer | bash
RUN mv /root/.symfony*/bin/symfony /usr/local/bin/symfony

RUN composer install --no-dev --optimize-autoloader --no-interaction

RUN chown -R www-data:www-data /var/www/html/var /var/www/html/public

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]
