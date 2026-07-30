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

# 2. Apache rewrite
RUN a2enmod rewrite

WORKDIR /var/www/html

# 3. Kopiraj projekt u /var/www/html
COPY . .

# 4. Kreiraj potrebne direktorije u samom projektu
RUN mkdir -p /var/www/html/bootstrap/cache \
             /var/www/html/storage/framework/views \
             /var/www/html/storage/framework/cache \
             /var/www/html/storage/framework/sessions \
             /var/www/html/storage/logs

# 5. Instalacija Composer ovisnosti i optimizacija autoloada
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs

# 6. Povezivanje /var/www/ mapa na /var/www/html preko symlinkova
# Ovo omogućuje da index.php pronađe ../vendor i ../bootstrap bez narušavanja Composer putanja
RUN ln -s /var/www/html/vendor /var/www/vendor && \
    ln -s /var/www/html/bootstrap /var/www/bootstrap && \
    ln -s /var/www/html/storage /var/www/storage

# 7. Postavljanje vlasništva i permisija
RUN chown -R www-data:www-data /var/www/html /var/www/html/storage /var/www/html/bootstrap/cache && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80
