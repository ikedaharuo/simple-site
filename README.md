# Simple site

Статичный сайт. Автодеплой: push в `main` -> GitHub Actions -> rsync на сервер.

## 1. Сервер (один раз)
```bash
scp server/setup.sh user@IP:~/ && ssh user@IP "sudo bash setup.sh"
```

## 2. SSH-ключ для деплоя
```bash
ssh-keygen -t ed25519 -f deploy_key -N "" -C github-deploy
ssh-copy-id -i deploy_key.pub user@IP
```
Содержимое `deploy_key` (приватный) идёт в секрет GitHub, потом файл удалить.

## 3. Секреты репозитория (Settings -> Secrets and variables -> Actions)
- `SSH_HOST` — IP сервера
- `SSH_USER` — пользователь
- `SSH_PRIVATE_KEY` — приватный ключ целиком
- `SSH_PORT` — необязательно, по умолчанию 22

## 4. Деплой
```bash
git remote add origin git@github.com:<you>/<repo>.git
git push -u origin main
```
