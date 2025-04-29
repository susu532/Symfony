FROM php:8.2-cli

# Install dependencies
RUN apt-get update && apt-get install -y unzip git zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy Composer files
COPY composer.json composer.lock ./

# Install dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Now copy the rest of your app
COPY . .

# Fix missing var/public folders if needed
RUN mkdir -p var public && chown -R www-data:www-data var public

# Expose port and use PHP's built-in server
EXPOSE 8000
CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]
