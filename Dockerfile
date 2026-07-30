FROM php:8.2-apache

# Instaliraj potrebne sistemske pakete i ekstenzije
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install zip pdo_mysql

# Omogući rewrite modul za Apache
RUN a2enmod rewrite

# Postavi Apache da poslužuje izravno /var/www/html
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

# Kopiraj cijeli projekt
COPY . .

# Kopiraj Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Instaliraj sve Composer ovisnosti
RUN composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs || true

# Trik: Povezujemo roditeljski direktorij natrag na html
# Tako da /var/www/html/../ zapravo pokaže na /var/www/html/
RUN rm -rf /var/www/bootstrap /var/www/vendor && \
    ln -s /var/www/html /var/www/bootstrap && \
    ln -s /var/www/html /var/www/vendor

# Postavi prave dozvole
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
