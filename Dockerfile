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

# 4. Stvaranje potrebnih struktura
RUN mkdir -p /var/www/bootstrap /var/www/storage/framework/views /var/www/storage/framework/cache /var/www/storage/framework/sessions /var/www/storage/logs

# 5. Bootstrap app.php s točnom baznom putanjom (/var/www/html)
RUN echo '<?php\n\
$app = new Illuminate\\Foundation\\Application(\n\
    "/var/www/html"\n\
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

# 6. Composer i autoloader
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs
RUN cp -r /var/www/html/vendor /var/www/vendor
RUN composer dump-autoload -o

# 7. Permisije
RUN chown -R www-data:www-data /var/www /var/www/html

EXPOSE 80
