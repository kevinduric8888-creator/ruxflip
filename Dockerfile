FROM php:8.2-apache

# Instaliraj potrebne sistemske pakete i ekstenzije
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install zip pdo_mysql

# Omogući rewrite modul
RUN a2enmod rewrite

WORKDIR /var/www/html

# Kopiraj cijeli projekt
COPY . .

# Osiguraj da public mapa postoji i prebaci index.php unutra ako se nalazi u rootu
RUN mkdir -p /var/www/html/public && \
    if [ -f /var/www/html/index.php ] && [ ! -f /var/www/html/public/index.php ]; then \
        cp /var/www/html/index.php /var/www/html/public/index.php; \
    fi

# Postavi Apache DocumentRoot izravno na public
RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /var/www/html/public\n\
    <Directory /var/www/html/public>\n\
        Options -Indexes +FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Kopiraj Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Instaliraj ovisnosti
RUN composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs

# Postavi dozvole
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache || true

EXPOSE 80
