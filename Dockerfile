FROM php:8.2-apache

# Instaliraj potrebne sistemske pakete i ekstenzije
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install zip pdo_mysql

# Omogući rewrite modul za Apache
RUN a2enmod rewrite

# Postavi DocumentRoot na /var/www/html/public i dodaj 'Require all granted' unutar VirtualHosta
RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /var/www/html/public\n\
    <Directory /var/www/html/public>\n\
        Options Indexes FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

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
