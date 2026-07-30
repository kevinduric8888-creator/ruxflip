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

WORKDIR /var/www/html

# 3. Kopiraj projekt
COPY . .

# 4. Kreiraj potrebne mape u projektu ako ne postoje
RUN mkdir -p /var/www/html/bootstrap/cache \
             /var/www/html/storage/framework/views \
             /var/www/html/storage/framework/cache \
             /var/www/html/storage/framework/sessions \
             /var/www/html/storage/logs

# 5. Rješavanje ../ putanja: Povezujemo /var/www/ sa /var/www/html/
RUN ln -s /var/www/html/vendor /var/www/vendor || true && \
    ln -s /var/www/html/bootstrap /var/www/bootstrap || true && \
    ln -s /var/www/html/storage /var/www/storage || true

# 6. Instaliraj Composer ovisnosti
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs

# 7. Dozvole
RUN chown -R www-data:www-data /var/www/html /var/www/bootstrap /var/www/storage /var/www/vendor && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80
