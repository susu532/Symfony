# syntax=docker/dockerfile:1

FROM php:8.2-fpm-alpine as base

# Install system dependencies
RUN apk add --no-cache nginx bash icu-dev libzip-dev libpng-dev libjpeg-turbo-dev libwebp-dev zlib-dev libxml2-dev oniguruma-dev git unzip libpq-dev

# Install PHP extensions
RUN docker-php-ext-install intl pdo pdo_pgsql opcache zip gd xml mbstring

ENV APP_ENV=prod

# Install Composer
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy Symfony app files
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Build assets (if using asset mapper or encore, adjust as needed)
# RUN npm install && npm run build

# Set permissions
RUN chown -R www-data:www-data /var/www/html/var /var/www/html/public

# Nginx config
COPY --from=nginx:1.25-alpine /etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start PHP-FPM and Nginx
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]
