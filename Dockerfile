FROM php:8.2-apache

# 1. Instalacija sistemskih paketa i PHP ekstenzija
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install zip pdo_mysql mbstring exif pcntl bcmath gd

# 2. Omogući mod_rewrite za Apache
RUN a2enmod rewrite

# 3. DocumentRoot ostaje /var/www/html (jer nemas public/ folder)
WORKDIR /var/www/html

# 4. Kopiraj projekt
COPY . .

# 5. Rješavanje require(__DIR__.'/../vendor/autoload.php'):
# Stvaramo symlink izvan /html kako bi index.php uspio učitati autoload.php
RUN mkdir -p /var/www/vendor && \
    ln -s /var/www/html/vendor/autoload.php /var/www/vendor/autoload.php || true

# 6. Instaliraj Composer ovisnosti
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs

# 7. Dozvole
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
