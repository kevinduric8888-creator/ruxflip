FROM php:8.2-apache

# Instaliraj sistemske pakete i ekstenzije
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install zip pdo_mysql

# Omogući rewrite modul
RUN a2enmod rewrite

# Postavi DocumentRoot na /var/www/html/public
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

# Kopiraj projekt u /var/www/html
WORKDIR /var/www/html
COPY . .

# Stvori public folder i prebaci index.php i .htaccess u njega ako već nisu tamo
RUN mkdir -p public && \
    if [ -f index.php ]; then mv index.php public/; fi && \
    if [ -f .htaccess ]; then cp .htaccess public/; fi

# Instaliraj ovisnosti
RUN composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs

# Postavi dozvole
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
