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
