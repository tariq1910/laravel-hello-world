FROM php:7.4-fpm

EXPOSE 8080

# Install packages
RUN apt-get update && apt-get install -y \
     git\
     curl\
     libpng-dev\
     libonig-dev\
     libxml2-dev\
     zip\
     libzip-dev\
     unzip

RUN apt-get install -y cron

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN docker-php-ext-configure zip

RUN docker-php-ext-install zip

RUN docker-php-ext-install pdo_mysql mbstring gd

WORKDIR "/laravel"


COPY . .

ADD email-cron /etc/cron.d/email-cron

RUN rm package-lock.json
RUN rm composer.lock

RUN composer install

#Update local php configuration
RUN cp ./php-conf/uploads.ini /usr/local/etc/php/conf.d/uploads.ini

RUN php artisan passport:install
RUN php artisan optimize:clear

RUN chmod 755 /laravel/start.sh
CMD /laravel/start.sh
