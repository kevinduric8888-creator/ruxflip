FROM php:8.2-apache

# Instaliraj potrebne sistemske pakete i ekstenzije
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install zip pdo_mysql

# Omogući rewrite modul za Apache
RUN a2enmod rewrite

# Postavi DocumentRoot na /var/www/html (root projekta)
RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /var/www/html\n\
    <Directory /var/www/html>\n\
        Options -Indexes +FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    ErrorLog ${APACHE_LOG_DIR}/error.log\n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

WORKDIR /var/www/html

# Kopiraj projekt
COPY . .

# Instaliraj Composer ovisnosti (ako postoji composer.json)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN if [ -f /var/www/html/composer.json ]; then composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs || true; fi

# Postavi dozvole
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
