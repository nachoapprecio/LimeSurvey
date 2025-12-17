#!/usr/bin/env bash
set -e

###############################################################################
# 1) Volumen único Railway
###############################################################################
mkdir -p /data/upload /data/tmp /data/config

# Subdirectorios requeridos por Yii / LimeSurvey
mkdir -p /data/tmp/runtime /data/tmp/assets /data/tmp/cache /data/tmp/upload

###############################################################################
# 2) Symlinks para upload y tmp (estos sí se persisten completos)
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
# 3) Configuración persistente (SIN inventar config.php/security.php)
#    - Deja que el instalador los genere.
#    - Una vez existan, se copian a /data/config (una sola vez)
#    - Y desde entonces, se enlazan desde /data/config.
###############################################################################

# Si en el volumen existe config.php/security.php (generados previamente), enlázalos
if [ -f /data/config/config.php ]; then
  rm -f /var/www/html/application/config/config.php || true
  ln -s /data/config/config.php /var/www/html/application/config/config.php
fi

if [ -f /data/config/security.php ]; then
  rm -f /var/www/html/application/config/security.php || true
  ln -s /data/config/security.php /var/www/html/application/config/security.php
fi

# Si el instalador ya creó los archivos en la app pero aún no existen en /data, cópialos una vez
if [ ! -f /data/config/config.php ] && [ -f /var/www/html/application/config/config.php ]; then
  cp /var/www/html/application/config/config.php /data/config/config.php
fi

if [ ! -f /data/config/security.php ] && [ -f /var/www/html/application/config/security.php ]; then
  cp /var/www/html/application/config/security.php /data/config/security.php
fi

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
