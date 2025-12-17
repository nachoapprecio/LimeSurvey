#!/usr/bin/env bash
set -e

# Volumen único
mkdir -p /data/upload /data/tmp /data/config

# Subcarpetas que Yii/LimeSurvey necesita dentro de tmp
mkdir -p /data/tmp/runtime /data/tmp/assets /data/tmp/cache /data/tmp/upload

# Symlink de upload y tmp completos
if [ ! -L /var/www/html/upload ]; then
  rm -rf /var/www/html/upload
  ln -s /data/upload /var/www/html/upload
fi

if [ ! -L /var/www/html/tmp ]; then
  rm -rf /var/www/html/tmp
  ln -s /data/tmp /var/www/html/tmp
fi

# Persistir SOLO config.php y security.php (no tocar internal.php)
touch /data/config/config.php /data/config/security.php
rm -f /var/www/html/application/config/config.php /var/www/html/application/config/security.php || true
ln -s /data/config/config.php /var/www/html/application/config/config.php
ln -s /data/config/security.php /var/www/html/application/config/security.php

# Permisos (Apache/PHP corre como www-data)
chown -R www-data:www-data /data
chmod -R 775 /data

# Fix MPM (blindado)
a2dismod mpm_event mpm_worker 2>/dev/null || true
a2enmod mpm_prefork 2>/dev/null || true
rm -f /etc/apache2/mods-enabled/mpm_event.* /etc/apache2/mods-enabled/mpm_worker.* 2>/dev/null || true

exec apache2-foreground
