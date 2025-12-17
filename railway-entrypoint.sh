#!/usr/bin/env bash
set -e

###############################################################################
# 1) Volumen único Railway
###############################################################################
mkdir -p /data/upload /data/tmp /data/config

# Subdirectorios requeridos por Yii / LimeSurvey
mkdir -p /data/tmp/runtime /data/tmp/assets /data/tmp/cache /data/tmp/upload

###############################################################################
# 2) Symlinks correctos (NO borrar carpetas base del repo)
###############################################################################

# upload
if [ ! -L /var/www/html/upload ]; then
  rm -rf /var/www/html/upload
  ln -s /data/upload /var/www/html/upload
fi

# tmp
if [ ! -L /var/www/html/tmp ]; then
  rm -rf /var/www/html/tmp
  ln -s /data/tmp /var/www/html/tmp
fi

###############################################################################
# 3) Configuración persistente (NUNCA vacía)
###############################################################################

# config.php
if [ ! -f /data/config/config.php ]; then
  cat > /data/config/config.php <<'PHP'
<?php
return [];
PHP
fi

# security.php
if [ ! -f /data/config/security.php ]; then
  cat > /data/config/security.php <<'PHP'
<?php
return [];
PHP
fi

# Enlazar archivos persistentes (sin tocar internal.php)
rm -f /var/www/html/application/config/config.php || true
rm -f /var/www/html/application/config/security.php || true

ln -s /data/config/config.php /var/www/html/application/config/config.php
ln -s /data/config/security.php /var/www/html/application/config/security.php

###############################################################################
# 4) Permisos (Apache corre como www-data)
###############################################################################
chown -R www-data:www-data /data
chmod -R 775 /data

###############################################################################
# 5) Apache MPM FIX (blindaje definitivo)
###############################################################################
a2dismod mpm_event mpm_worker 2>/dev/null || true
a2enmod mpm_prefork 2>/dev/null || true

rm -f /etc/apache2/mods-enabled/mpm_event.* 2>/dev/null || true
rm -f /etc/apache2/mods-enabled/mpm_worker.* 2>/dev/null || true

###############################################################################
# 6) Arranque final
###############################################################################
exec apache2-foreground
