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

# 4. Ako composer.json fali, generirat ćemo ispravan Laravel composer.json
RUN if [ ! -f composer.json ]; then \
    echo '{\
        "name": "laravel/laravel",\
        "type": "project",\
        "description": "The Laravel Framework.",\
        "require": {\
            "php": "^8.2",\
            "guzzlehttp/guzzle": "^7.2",\
            "laravel/framework": "^10.0",\
            "laravel/sanctum": "^3.2",\
            "laravel/tinker": "^2.8"\
        },\
        "autoload": {\
            "psr-4": {\
                "App\\": "app/",\
                "Database\\Factories\\": "database/factories/",\
                "Database\\Seeders\\": "database/seeders/"\
            }\
        }\
    }' > composer.json; \
fi

# 5. Kreiraj nužne mape
RUN mkdir -p /var/www/html/bootstrap/cache \
             /var/www/html/storage/framework/views \
             /var/www/html/storage/framework/cache \
             /var/www/html/storage/framework/sessions \
             /var/www/html/storage/logs \
             /var/www/html/resources/views

# 6. Instaliraj Composer i preuzmi ovisnosti
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1

RUN composer install --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs || composer update --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs

# 7. Postavi dozvole
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80
