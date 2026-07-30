FROM php:8.2-apache

# Instaliraj sistemske pakete i ekstenzije
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install zip pdo_mysql

# Omogući rewrite modul za Apache
RUN a2enmod rewrite

# Postavi DocumentRoot na /var/www/html
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

# Postavi radni direktorij i kopiraj projekt
WORKDIR /var/www/html
COPY . .

# Napravi symlinkove za sve glavne mape prema gore za svaki slučaj
RUN ln -s /var/www/html /var/www/public 2>/dev/null || true
RUN ln -s /var/www/html/vendor /var/www/vendor 2>/dev/null || true
RUN ln -s /var/www/html/bootstrap /var/www/bootstrap 2>/dev/null || true
RUN ln -s /var/www/html/storage /var/www/storage 2>/dev/null || true

# Instaliraj ovisnosti
RUN composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs

# Postavi dozvole
RUN chown -R www-data:www-data /var/www /var/www/html

EXPOSE 80
