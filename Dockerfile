FROM php:8.2-apache

# Instaliraj potrebne sistemske pakete i ekstenzije
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install zip pdo_mysql

# Omogući rewrite modul za Apache
RUN a2enmod rewrite

# Postavi radni direktorij
WORKDIR /var/www/html

# Kopiraj cijeli projekt
COPY . .

# Ako index.php stoji u rootu, stvori public mapu i premjesti ga tamo
RUN if [ -f /var/www/html/index.php ]; then \
        mkdir -p /var/www/html/public && \
        mv /var/www/html/index.php /var/www/html/public/index.php; \
    fi

# Postavi Apache DocumentRoot na public mapu
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf

# Dozvole pristupa za Apache
RUN echo '<Directory /var/www/html/public>\n\
    Options Indexes FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>' >> /etc/apache2/apache2.conf

# Kopiraj Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Instaliraj Composer pakete
RUN composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs

# Postavi vlasništvo i dozvole
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache || true

EXPOSE 80
