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

# Kopiraj cijeli projekt
COPY . .

# Osiguraj da public mapa postoji i prebaci index.php u nju ako je u rootu
RUN mkdir -p /var/www/html/public
RUN if [ -f /var/www/html/index.php ]; then cp /var/www/html/index.php /var/www/html/public/index.php; fi

# Postavi Apache DocumentRoot na public mapu uz pune dozvole
RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /var/www/html/public\n\
    <Directory /var/www/html/public>\n\
        Options -Indexes +FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    ErrorLog ${APACHE_LOG_DIR}/error.log\n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Kopiraj Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Instaliraj sve Composer ovisnosti u root
RUN composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs || true

# Postavi prave dozvole nad svim datotekama
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
