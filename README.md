# Simple site

Статичный сайт + автодеплой через `git push`.

## Настройка сервера (один раз)
```bash
scp server/setup.sh user@IP:~/ && ssh user@IP "sudo bash setup.sh"
```

## Подключение и деплой
```bash
git remote add production ssh://user@IP/home/user/site.git
git push production main
```
Каждый следующий `git push production main` сразу обновляет сайт.
