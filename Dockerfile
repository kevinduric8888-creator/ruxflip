FROM php:8.2-apache

# Omogući mod_rewrite
RUN a2enmod rewrite

# Kopiraj projekt i postavi dozvole za sve datoteke
COPY . /var/www/html/
RUN chown -R www-data:www-data /var/www/html && \
    find /var/www/html -type d -exec chmod 755 {} \; && \
    find /var/www/html -type f -exec chmod 644 {} \;

EXPOSE 80
