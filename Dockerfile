FROM php:8.2-apache

# Instaliraj potrebne PHP ekstenzije i git
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install zip pdo_mysql

# Omogući mod_rewrite za Apache
RUN a2enmod rewrite

# Postavi radni direktorij
WORKDIR /var/www/html

# Kopiraj projekt
COPY . .

# Postavi dozvole za sve datoteke
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
