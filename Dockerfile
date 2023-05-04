FROM composer:2.5.5 as vendor_installer

WORKDIR /app
COPY database/ database/
COPY artisan composer.json composer.lock ./
RUN composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --prefer-dist \
    --optimize-autoloader \
    --no-dev

FROM breakhack/php-cli:8.2
WORKDIR /var/www/html
COPY --from=vendor_installer /app/vendor/ /var/www/html/vendor/
COPY php.ini-production /usr/local/etc/php/php.ini
COPY --chown=1000:1000 . .
RUN php artisan storage:link

EXPOSE 8000
CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=8000
