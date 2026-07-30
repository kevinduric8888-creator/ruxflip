FROM php:8.2-apache

# 1. Sistemske ekstenzije
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install zip pdo_mysql mbstring exif pcntl bcmath gd

# 2. Apache rewrite
RUN a2enmod rewrite

WORKDIR /var/www/html

# 3. Kopiraj projekt
COPY . .

# 4. Potrebni direktoriji
RUN mkdir -p /var/www/html/bootstrap/cache \
             /var/www/html/storage/framework/views \
             /var/www/html/storage/framework/cache \
             /var/www/html/storage/framework/sessions \
             /var/www/html/storage/logs

# 5. Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --no-scripts --ignore-platform-reqs

# 6. Permisije
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80
