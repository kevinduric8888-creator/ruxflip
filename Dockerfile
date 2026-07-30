FROM php:8.2-apache

# 1. Instalacija sistemskih paketa i ekstenzija
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

# 4. Ako composer.json ne postoji ili je neispravan, stvorit ćemo ga
RUN if [ ! -f composer.json ]; then \
    echo '{"require": {"laravel/framework": "^10.0", "guzzlehttp/guzzle": "^7.2"}}' > composer.json; \
fi

# 5. Kreiraj nužne mape
RUN mkdir -p /var/www/html/bootstrap/cache \
             /var/www/html/storage/framework/views \
             /var/www/html/storage/framework/cache \
             /var/www/html/storage/framework/sessions \
             /var/www/html/storage/logs \
             /var/www/html/resources/views

# 6. Instaliraj Composer ovisnosti ispravno
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1

RUN composer install --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs

# 7. Postavi dozvole
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80
