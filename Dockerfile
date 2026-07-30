FROM php:8.2-apache

# Instaliraj sistemske pakete i ekstenzije
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install zip pdo_mysql

# Omogući rewrite modul za Apache
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

# Postavi radni direktorij i kopiraj projekt
WORKDIR /var/www/html
COPY . .

# Napravi public folder i premjesti index.php i .htaccess ako postoje (bez rušenja ako ih nema)
RUN mkdir -p public && \
    cp -f index.php public/ 2>/dev/null || true && \
    cp -f .htaccess public/ 2>/dev/null || true

# Instaliraj ovisnosti
RUN composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs

# Postavi dozvole
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
