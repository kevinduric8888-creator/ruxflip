FROM php:8.2-apache

# 1. Instalacija sistemskih ekstenzija
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

# 3. Radni direktorij
WORKDIR /var/www/html

# 4. Kopiraj projekt
COPY . .

# 5. Stvori potrebne mape ako ne postoje
RUN mkdir -p /var/www/html/bootstrap/cache \
             /var/www/html/storage/framework/views \
             /var/www/html/storage/framework/cache \
             /var/www/html/storage/framework/sessions \
             /var/www/html/storage/logs

# 6. Instalacija Composer ovisnosti i regeneracija autoload mapa
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs && \
    composer dump-autoload -o --no-scripts

# 7. Permisije za Laravel storage i cache
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80
