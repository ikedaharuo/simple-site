#!/usr/bin/env bash
# Запускать на СЕРВЕРЕ один раз: sudo bash setup.sh
# Ставит nginx + rsync, создаёт /var/www/site и отдаёт его на порту 80.
set -euo pipefail

DEPLOY_USER=${SUDO_USER:-$USER}
WEBROOT=/var/www/site

apt-get update -y && apt-get install -y nginx rsync

mkdir -p "$WEBROOT"
chown -R "$DEPLOY_USER":"$DEPLOY_USER" "$WEBROOT"

cat > /etc/nginx/sites-available/site <<NGINX
server {
    listen 80 default_server;
    server_name _;
    root $WEBROOT;
    index index.html;
    location / { try_files \$uri \$uri/ =404; }
}
NGINX
ln -sf /etc/nginx/sites-available/site /etc/nginx/sites-enabled/site
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx
echo "Готово. Пользователь для деплоя: $DEPLOY_USER"
