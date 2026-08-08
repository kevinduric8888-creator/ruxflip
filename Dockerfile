FROM php:8.2-apache

# Omogući mod_rewrite
RUN a2enmod rewrite

# Vrati Apache postavke na standardnu /var/www/html mapu i omogući dozvole
RUN sed -i 's/DocumentRoot \/var/www\/html/DocumentRoot \/var/www\/html/g' /etc/apache2/sites-available/000-default.conf

# Kopiraj projekt i postavi dozvole za sve datoteke
COPY . /var/www/html/
RUN chown -R www-data:www-data /var/www/html && \
    find /var/www/html -type d -exec chmod 755 {} \; && \
    find /var/www/html -type f -exec chmod 644 {} \;

EXPOSE 80
