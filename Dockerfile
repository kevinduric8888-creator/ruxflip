FROM php:8.2-apache

# 1. Paketne ekstenzije
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install zip pdo_mysql mbstring exif pcntl bcmath gd

# 2. Apache rewrite
RUN a2enmod rewrite

WORKDIR /var/www/html

# 3. Kopiraj izvore
COPY . .

# 4. Stvaranje potrebnih struktura izvan /html (jer index.php poziva /../bootstrap/app.php)
RUN mkdir -p /var/www/bootstrap /var/www/storage/framework/views /var/www/storage/framework/cache /var/www/storage/framework/sessions /var/www/storage/logs

# 5. Generiranje bootstrap/app.php u /var/www/bootstrap/ za bootstrap učitavanje
RUN echo '<?php\n\
$app = new Illuminate\\Foundation\\Application(\n\
    $_ENV["APP_BASE_PATH"] ?? dirname(__DIR__)\n\
);\n\
$app->singleton(\n\
    Illuminate\\Contracts\\Http\\Kernel::class,\n\
    App\\Http\\Kernel::class\n\
);\n\
$app->singleton(\n\
    Illuminate\\Contracts\\Console\\Kernel::class,\n\
    App\\Console\\Kernel::class\n\
);\n\
$app->singleton(\n\
    Illuminate\\Contracts\\Debug\\ExceptionHandler::class,\n\
    App\\Exceptions\\Handler::class\n\
);\n\
return $app;' > /var/www/bootstrap/app.php

# 6. Povezivanje vendor direktorija u /var/www/
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs
RUN cp -r /var/www/html/vendor /var/www/vendor

# 7. Permisije
RUN chown -R www-data:www-data /var/www

EXPOSE 80
