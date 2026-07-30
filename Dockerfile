FROM php:8.2-apache

# Instaliraj sistemske ovisnosti i git
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install zip pdo_mysql

# Omogući mod_rewrite za Apache
RUN a2enmod rewrite

# Instaliraj Composer unutar kontejnera
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Postavi radni direktorij
WORKDIR /var/www/html

# Kopiraj sve datoteke projekta
COPY . .

# Pokreni composer da stvori vendor mapu
RUN composer install --no-dev --optimize-autoloader --ignore-platform-reqs

# Postavi dozvole za www-data korisnika
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
