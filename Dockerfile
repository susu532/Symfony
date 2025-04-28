# syntax=docker/dockerfile:1

# 1. Composer stage
FROM composer:2.7 as composer

# 2. Build assets with Node.js
FROM node:20-alpine as assets
WORKDIR /app
COPY assets/ ./assets
COPY package.json package-lock.json* yarn.lock* ./
RUN if [ -f package-lock.json ]; then npm ci; elif [ -f yarn.lock ]; then yarn install --frozen-lockfile; fi
RUN if [ -f package.json ]; then npm run build || yarn build || echo 'No build script'; fi

# 3. PHP/Nginx build stage
FROM php:8.2-fpm-alpine as phpbase
RUN apk add --no-cache nginx bash icu-dev libzip-dev libpng-dev libjpeg-turbo-dev libwebp-dev zlib-dev libxml2-dev oniguruma-dev git unzip libpq-dev
RUN docker-php-ext-install intl pdo pdo_pgsql opcache zip gd xml mbstring
COPY --from=composer /usr/bin/composer /usr/bin/composer
WORKDIR /var/www/html
COPY . .
ENV APP_ENV=prod
RUN composer install --no-dev --optimize-autoloader --no-interaction

# 4. Copy built assets from Node.js stage
COPY --from=assets /app/assets ./assets
# If you use public/build or another output dir, adjust accordingly:
# COPY --from=assets /app/public/build ./public/build

RUN chown -R www-data:www-data /var/www/html/var /var/www/html/public

# Use your own nginx.conf only

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]
