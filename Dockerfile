FROM php:8.2-apache

# Apache: dejar 1 solo MPM (prefork) para mod_php
RUN a2dismod mpm_event mpm_worker || true \
  && a2enmod mpm_prefork rewrite headers

# Dependencias + extensiones PHP necesarias
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libzip-dev libicu-dev \
    libonig-dev \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j$(nproc) gd intl mbstring mysqli pdo pdo_mysql zip \
  && rm -rf /var/lib/apt/lists/*

# Config PHP para LimeSurvey
RUN { \
  echo "short_open_tag=On"; \
  echo "upload_max_filesize=50M"; \
  echo "post_max_size=50M"; \
  } > /usr/local/etc/php/conf.d/limesurvey.ini

# App
WORKDIR /var/www/html
COPY . /var/www/html

# Entrypoint: prepara volumen único /data y persiste upload/tmp/config vía symlinks
RUN set -eux; \
  cat > /usr/local/bin/railway-entrypoint.sh <<'SH'; \
#!/usr/bin/env bash
set -e

mkdir -p /data/upload /data/tmp /data/config

if [ ! -L /var/www/html/upload ]; then
  rm -rf /var/www/html/upload
  ln -s /data/upload /var/www/html/upload
fi

if [ ! -L /var/www/html/tmp ]; then
  rm -rf /var/www/html/tmp
  ln -s /data/tmp /var/www/html/tmp
fi

if [ ! -L /var/www/html/application/config ]; then
  rm -rf /var/www/html/application/config
  ln -s /data/config /var/www/html/application/config
fi

chown -R www-data:www-data /data
chmod -R 775 /data

exec apache2-foreground
SH \
  chmod +x /usr/local/bin/railway-entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
