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

# 4. Postavi ispravnu minimalnu bootstrap/app.php datoteku koja uključuje osnovne servise
RUN mkdir -p /var/www/html/bootstrap /var/www/html/storage/framework/views /var/www/html/storage/framework/cache /var/www/html/storage/framework/sessions /var/www/html/storage/logs /var/www/html/bootstrap/cache /var/www/html/resources/views

RUN echo "<?php\n\
$app = new Illuminate\Foundation\Application(\n\
    \$_ENV['APP_BASE_PATH'] ?? dirname(__DIR__)\n\
);\n\
$app->singleton(\n\
    Illuminate\Contracts\Http\Kernel::class,\n\
    App\Http\Kernel::class\n\
);\n\
$app->singleton(\n\
    Illuminate\Contracts\Console\Kernel::class,\n\
    App\Console\Kernel::class\n\
);\n\
$app->singleton(\n\
    Illuminate\Contracts\Debug\ExceptionHandler::class,\n\
    App\Exceptions\Handler::class\n\
);\n\
return $app;" > /var/www/html/bootstrap/app.php

# 5. Instaliraj Composer ovisnosti
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs || true

# 6. Dozvole
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80
