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

# 4. Kreiraj osnovne Laravel mape koje fale u repozitoriju
RUN mkdir -p /var/www/html/storage/framework/views \
             /var/www/html/storage/framework/cache \
             /var/www/html/storage/framework/sessions \
             /var/www/html/storage/logs \
             /var/www/html/bootstrap/cache \
             /var/www/html/resources/views

# 5. Rješavanje ../ putanja za index.php koji se nalazi u rootu umjesto u public/
RUN mkdir -p /var/www/vendor /var/www/bootstrap /var/www/storage && \
    ln -s /var/www/html/vendor /var/www/vendor/autoload.php || true && \
    ln -s /var/www/html/bootstrap/app.php /var/www/bootstrap/app.php || true

# 6. Instaliraj Composer ovisnosti
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs || true

# 7. Postavi dozvole
RUN chown -R www-data:www-data /var/www/html /var/www/bootstrap /var/www/storage /var/www/vendor && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80
