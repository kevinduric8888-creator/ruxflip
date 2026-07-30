FROM php:8.2-apache

# 1. Instalacija sistemskih paketa i ekstenzija
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install zip pdo_mysql mbstring exif pcntl bcmath gd

# 2. Omogući mod_rewrite za Apache
RUN a2enmod rewrite

WORKDIR /var/www/html

# 3. Kopiraj projekt
COPY . .

# 4. Kreiraj nužne mape i osiguraj osnovnu strukturu za Laravel
RUN mkdir -p /var/www/html/bootstrap/cache \
             /var/www/html/storage/framework/views \
             /var/www/html/storage/framework/cache \
             /var/www/html/storage/framework/sessions \
             /var/www/html/storage/logs \
             /var/www/html/resources/views \
             /var/www/html/vendor

# 5. Stvori osnovni autoloader da indeksna skripta ne baca grešku
RUN echo "<?php\n\
// Osnovni bypass za autoloader\n\
spl_autoload_register(function (\$class) {\n\
    \$file = __DIR__ . '/../app/' . str_replace('\\\\', '/', substr(\$class, 4)) . '.php';\n\
    if (file_exists(\$file)) {\n\
        require_once \$file;\n\
    }\n\
});\n" > /var/www/html/vendor/autoload.php

# 6. Postavi dozvole
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80
