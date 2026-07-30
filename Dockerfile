FROM php:8.2-apache

# 1. Sistemske ekstenzije
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

# 3. Kopiraj projekt
COPY . .

# 4. Stvori SVE potrebne Laravel mape kako sustav nikad ne bi bacio DirectoryNotFoundException
RUN mkdir -p /var/www/html/app/Http \
             /var/www/html/app/Exceptions \
             /var/www/html/app/Console \
             /var/www/html/config \
             /var/www/html/routes \
             /var/www/html/resources/views \
             /var/www/html/public \
             /var/www/html/bootstrap/cache \
             /var/www/html/storage/framework/views \
             /var/www/html/storage/framework/cache \
             /var/www/html/storage/framework/sessions \
             /var/www/html/storage/logs

# 5. Osiguraj osnovne konfiguracije i rute ako nedostaju u repozitoriju
RUN if [ ! -f /var/www/html/config/app.php ]; then echo '<?php return ["name" => "Ruxflip", "env" => "production", "debug" => true, "url" => "http://localhost", "timezone" => "UTC", "locale" => "en", "key" => "base64:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=", "cipher" => "AES-256-CBC", "providers" => \Illuminate\Support\ServiceProvider::defaultProviders()->toArray()];' > /var/www/html/config/app.php; fi && \
    if [ ! -f /var/www/html/routes/web.php ]; then echo '<?php use Illuminate\Support\Facades\Route; Route::get("/", function () { return "Ruxflip radi!"; });' > /var/www/html/routes/web.php; fi

# 6. Composer instalacija
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --no-scripts --ignore-platform-reqs

# 7. Permisije
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80
