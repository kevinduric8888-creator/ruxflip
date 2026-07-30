FROM php:8.2-apache

# Instaliraj potrebne sistemske pakete i ekstenzije
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install zip pdo_mysql

# Omogući rewrite modul za Apache
RUN a2enmod rewrite

# Postavi Apache da poslužuje direktno korijenski direktorij /var/www/html
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

# Napravi prečace (symlinks) za vendor i bootstrap izvan html direktorija
# jer index.php traži '../vendor/autoload.php' i '../bootstrap/app.php'
RUN ln -s /var/www/html/vendor /var/www/vendor || true
RUN ln -s /var/www/html/bootstrap /var/www/bootstrap || true

# Postavi prave dozvole
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
