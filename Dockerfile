FROM php:8.2-apache

# Instaliraj potrebne sistemske pakete i ekstenzije
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install zip pdo_mysql

# Omogući rewrite modul za Apache
RUN a2enmod rewrite

# Postavi DocumentRoot na /var/www/html/public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf

# Omogući dozvole pristupa za Apache (briše 403 Forbidden grešku)
RUN echo '<Directory /var/www/html/public>\n\
    Options Indexes FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>' >> /etc/apache2/apache2.conf

# Kopiraj Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Kopiraj sve datoteke projekta
COPY . .

# Instaliraj sve ovisnosti
RUN composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs

# Postavi dozvole za www-data korisnika
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
