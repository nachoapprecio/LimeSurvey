#!/usr/bin/env bash
set -e

# 1) Persistencia con volumen único
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

# 2) FIX: asegurar un solo MPM cargado (prefork) ANTES de iniciar Apache
a2dismod mpm_event mpm_worker 2>/dev/null || true
a2enmod mpm_prefork 2>/dev/null || true

# Blindaje extra: si existe la carpeta mods-enabled, elimina symlinks de event/worker
rm -f /etc/apache2/mods-enabled/mpm_event.load /etc/apache2/mods-enabled/mpm_event.conf 2>/dev/null || true
rm -f /etc/apache2/mods-enabled/mpm_worker.load /etc/apache2/mods-enabled/mpm_worker.conf 2>/dev/null || true

exec apache2-foreground
