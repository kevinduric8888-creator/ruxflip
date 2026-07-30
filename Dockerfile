FROM php:8.2-apache

# Instaliraj potrebne sistemske pakete i ekstenzije
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install zip pdo_mysql

# Omogući rewrite modul za Apache
RUN a2enmod rewrite

# Postavi Apache direktno na /var/www/html
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

# Kopiraj sve datoteke projekta
COPY . .

# Instaliraj ovisnosti
RUN composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs

# Stvori prečace u /var/www/ za sve mape koje index.php traži izvan html foldera
RUN ln -s /var/www/html/vendor /var/www/vendor && \
    ln -s /var/www/html/bootstrap /var/www/bootstrap && \
    ln -s /var/www/html/storage /var/www/storage

# Postavi dozvole za www-data korisnika
RUN chown -R www-data:www-data /var/www/html /var/www/vendor /var/www/bootstrap /var/www/storage

EXPOSE 80
