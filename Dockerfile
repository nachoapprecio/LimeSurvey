FROM php:8.2-apache

# Apache: forzar un solo MPM compatible con mod_php
RUN a2dismod mpm_event mpm_worker || true \
  && a2enmod mpm_prefork rewrite headers

# Dependencias del sistema + extensiones PHP
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libzip-dev libicu-dev \
    libonig-dev \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j$(nproc) gd intl mbstring mysqli pdo pdo_mysql zip \
  && rm -rf /var/lib/apt/lists/*

# Configuración PHP requerida por LimeSurvey + hardening de errores para prod
RUN echo "short_open_tag=On" > /usr/local/etc/php/conf.d/limesurvey.ini \
 && echo "upload_max_filesize=50M" >> /usr/local/etc/php/conf.d/limesurvey.ini \
 && echo "post_max_size=50M" >> /usr/local/etc/php/conf.d/limesurvey.ini \
 && echo "display_errors=Off" >> /usr/local/etc/php/conf.d/limesurvey.ini \
 && echo "log_errors=On" >> /usr/local/etc/php/conf.d/limesurvey.ini \
 && echo "error_reporting=E_ALL & ~E_DEPRECATED & ~E_STRICT" >> /usr/local/etc/php/conf.d/limesurvey.ini

# Código de la app
WORKDIR /var/www/html
COPY . /var/www/html

# Entrypoint para Railway (/data) (debe existir en la raíz del repo)
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
RUN chmod +x /usr/local/bin/railway-entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
