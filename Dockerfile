FROM php:8.2-apache

# Instaliraj potrebne PHP ekstenzije i git
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install zip pdo_mysql

# Instaliraj Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Postavi radni direktorij
WORKDIR /var/www/html

# Kopiraj projekt
COPY . .

# Dozvole za spremanje
RUN chown -R www-data:www-data /var/www/html \
    && a2enmod rewrite

# Postavi DocumentRoot na public folder
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf

EXPOSE 80
