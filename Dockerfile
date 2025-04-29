FROM php:8.2-cli

# Install system dependencies
RUN apt-get update && apt-get install -y unzip git zip && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy everything
COPY . .

# Install PHP dependencies (now that full code is present)
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Ensure needed directories exist
RUN mkdir -p var public && chown -R www-data:www-data var public

# Expose the port
EXPOSE 8000

# Start server
CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]
