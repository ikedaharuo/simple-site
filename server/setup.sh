#!/usr/bin/env bash
# Запускать на СЕРВЕРЕ один раз (от root или через sudo).
# Создаёт bare-репозиторий и post-receive хук, который выкладывает сайт в /var/www/site.
set -euo pipefail

REPO=/home/${SUDO_USER:-$USER}/site.git
WEBROOT=/var/www/site
BRANCH=main

apt-get update -y && apt-get install -y git nginx

mkdir -p "$WEBROOT" "$REPO"
chown -R "${SUDO_USER:-$USER}":"${SUDO_USER:-$USER}" "$WEBROOT" "$REPO"

sudo -u "${SUDO_USER:-$USER}" git init --bare -b $BRANCH "$REPO"

cat > "$REPO/hooks/post-receive" <<HOOK
#!/usr/bin/env bash
while read oldrev newrev ref; do
  if [ "\$ref" = "refs/heads/$BRANCH" ]; then
    git --work-tree=$WEBROOT --git-dir=$REPO checkout -f $BRANCH
    echo ">>> Сайт обновлён в $WEBROOT"
  fi
done
HOOK
chmod +x "$REPO/hooks/post-receive"
chown "${SUDO_USER:-$USER}" "$REPO/hooks/post-receive"

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

echo "Готово. На локальной машине выполните:"
echo "  git remote add production ssh://${SUDO_USER:-$USER}@<IP_СЕРВЕРА>$REPO"
echo "  git push production main"
