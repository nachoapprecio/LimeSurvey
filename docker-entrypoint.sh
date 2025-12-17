#!/usr/bin/env bash
set -e

mkdir -p /data/upload /data/tmp /data/config

chown -R www-data:www-data /data
chmod -R 775 /data

exec apache2-foreground
