FROM php:8.2-apache

# Apache + PHP extensions típicas para apps como LimeSurvey
RUN a2enmod rewrite headers \
  && apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libzip-dev libicu-dev \
    libonig-dev \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j$(nproc) gd intl mbstring mysqli pdo pdo_mysql zip \
  && rm -rf /var/lib/apt/lists/*

# LimeSurvey necesita short_open_tag ON
RUN { \
  echo "short_open_tag=On"; \
  echo "upload_max_filesize=50M"; \
  echo "post_max_size=50M"; \
  } > /usr/local/etc/php/conf.d/limesurvey.ini

WORKDIR /var/www/html
COPY . /var/www/html

# Permisos para carpetas que LimeSurvey usa para escribir
RUN chown -R www-data:www-data /var/www/html \
  && chmod -R 775 /var/www/html/tmp /var/www/html/upload

EXPOSE 80
