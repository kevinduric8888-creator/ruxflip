FROM php:8.2-apache

# Instaliraj potrebne sistemske pakete i ekstenzije
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install zip pdo_mysql

# Omogući rewrite modul za Laravel rute
RUN a2enmod rewrite

# Postavi radni direktorij na korijen projekta
WORKDIR /var/www/html

# Kopiraj cijeli projekt
COPY . .

# Postavi Apache DocumentRoot na public folder i odobri sve dozvole
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

# Instaliraj sve Composer pakete
RUN composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs

# Postavi dozvole za Apache i Laravel pohranu
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache || true

EXPOSE 80
