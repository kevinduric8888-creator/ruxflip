FROM php:8.2-apache

# Instaliraj potrebne sistemske pakete i ekstenzije
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install zip pdo_mysql

# Omogući rewrite modul za Apache
RUN a2enmod rewrite

# Postavi DocumentRoot na public mapu unutar projekta
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf

# Omogući sve dozvole pristupa za public mapu
RUN echo '<Directory /var/www/html/public>\n\
    Options -Indexes +FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>' >> /etc/apache2/apache2.conf

WORKDIR /var/www/html

# Kopiraj cijeli projekt
COPY . .

# Kopiraj Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Instaliraj ovisnosti u root direktorij gdje je composer.json
RUN composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs

# Postavi vlasništvo nad datotekama
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
