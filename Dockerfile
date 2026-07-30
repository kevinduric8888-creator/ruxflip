FROM php:8.2-apache

# Instaliraj sistemske pakete i ekstenzije
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install zip pdo_mysql

# Omogući rewrite modul za Apache
RUN a2enmod rewrite

# Postavi Apache na /var/www/html
RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /var/www/html\n\
    <Directory /var/www/html>\n\
        Options Indexes FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Kopiraj Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Kopiraj projekt
COPY . .

# Instaliraj Composer ovisnosti
RUN composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs

# Kopiraj sve mape iz html u parent direktorij /var/www za index.php
RUN cp -rn /var/www/html/* /var/www/ 2>/dev/null || true

# Postavi dozvole
RUN chown -R www-data:www-data /var/www

EXPOSE 80
