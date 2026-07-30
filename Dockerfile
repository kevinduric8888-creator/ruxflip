FROM php:8.2-apache

# Instaliraj potrebne sistemske pakete i ekstenzije
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install zip pdo_mysql

# Omogući rewrite modul za Apache (za Laravel rute)
RUN a2enmod rewrite

WORKDIR /var/www/html

# 1. Kopiraj cijeli projekt
COPY . .

# 2. Očisti sve stare/krive public smetnje i složi pravu public strukturu
RUN rm -rf /var/www/html/public_temp && \
    mkdir -p /var/www/html/public_temp && \
    if [ -d /var/www/html/public ]; then cp -r /var/www/html/public/* /var/www/html/public_temp/ || true; fi && \
    if [ -f /var/www/html/index.php ]; then cp /var/www/html/index.php /var/www/html/public_temp/index.php; fi && \
    rm -rf /var/www/html/public && \
    mv /var/www/html/public_temp /var/www/html/public

# 3. Postavi Apache da poslužuje isključivo /var/www/html/public
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

# 4. Instaliraj Composer u root (/var/www/html/vendor)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs || true

# 5. Dozvole
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
