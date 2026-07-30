FROM php:8.2-apache

# Instaliraj potrebne sistemske pakete i ekstenzije
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install zip pdo_mysql

# Omogući rewrite modul za Apache
RUN a2enmod rewrite

WORKDIR /var/www/html

# 1. Kopiraj cijeli projekt
COPY . .

# 2. Složi pravu public strukturu
RUN rm -rf /var/www/html/public_temp && \
    mkdir -p /var/www/html/public_temp && \
    if [ -d /var/www/html/public ]; then cp -r /var/www/html/public/* /var/www/html/public_temp/ || true; fi && \
    if [ -f /var/www/html/index.php ]; then cp /var/www/html/index.php /var/www/html/public_temp/index.php; fi && \
    rm -rf /var/www/html/public && \
    mv /var/www/html/public_temp /var/www/html/public

# 3. Ako fali bootstrap/app.php, stvori minimalnu bootstrap strukturu
RUN mkdir -p /var/www/html/bootstrap/cache && \
    if [ ! -f /var/www/html/bootstrap/app.php ]; then \
        echo '<?php\n$app = new Illuminate\\Foundation\\Application(\n    $_ENV["APP_BASE_PATH"] ?? dirname(__DIR__)\n);\n$app->singleton(\n    Illuminate\\Contracts\\Http\\Kernel::class,\n    App\\Http\\Kernel::class\n);\n$app->singleton(\n    Illuminate\\Contracts\\Console\\Kernel::class,\n    App\\Console\\Kernel::class\n);\n$app->singleton(\n    Illuminate\\Contracts\\Debug\\ExceptionHandler::class,\n    App\\Exceptions\\Handler::class\n);\nreturn $app;' > /var/www/html/bootstrap/app.php; \
    fi

# 4. Postavi Apache DocumentRoot na public
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

# 5. Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs || true

# 6. Dozvole
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache || true

EXPOSE 80
