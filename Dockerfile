FROM php:8.2-apache

# Instaliraj potrebne sistemske pakete i ekstenzije
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install zip pdo_mysql

# Omogući rewrite modul za Apache
RUN a2enmod rewrite

WORKDIR /var/www/html

# Kopiraj cijeli projekt direktno u /var/www/html
COPY . .

# Kopiraj Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Pokreni composer samo ako postoji composer.json
RUN composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs || true

# Postavi prave dozvole za Apache
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
