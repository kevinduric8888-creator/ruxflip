FROM php:8.2-apache

# Omogući mod_rewrite
RUN a2enmod rewrite

# Postavi Apache DocumentRoot na public folder
RUN sed -ri -s 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -s 's!/var/www/!/var/www/html/public!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

COPY . /var/www/html/
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
