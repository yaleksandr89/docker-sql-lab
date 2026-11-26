# Участие в разработке

## Выберите язык

| Русский | English | Español | 中文 | Français | Deutsch |
|---|---|---|---|---|---|
| **Русский** | [English](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/en/CONTRIBUTING.md) | [Español](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/es/CONTRIBUTING.md) | [中文](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/zh/CONTRIBUTING.md) | [Français](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/fr/CONTRIBUTING.md) | [Deutsch](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/de/CONTRIBUTING.md) |

## Перед началом

Воспроизводимые ошибки сообщайте через [GitHub Issues](https://github.com/yaleksandr89/docker-sql-lab/issues); вопросы и предложения обсуждайте в [GitHub Discussions](https://github.com/yaleksandr89/docker-sql-lab/discussions). Существенные изменения предварительно согласуйте с владельцем. Не публикуйте пароли, реальные данные или подробности уязвимостей.

Уязвимости — [политика безопасности](https://github.com/yaleksandr89/docker-sql-lab/blob/master/.github/SECURITY.md).

## Границы изменений

Сохраняйте публичные Make-команды, разделение СУБД, обязательную `demo`, необязательные учебные базы и права `DB_USER`. Изменения версий образов, схемы, привилегий, сетевого доступа, импорта и удаления данных согласуйте заранее. Не добавляйте сторонние SQL-файлы и локальные `.docker.env` в Git.

## Проверки

Работайте в отдельной одноразовой копии с синтетическими данными, уникальным именем Compose-проекта и портами. Перед runtime-командами проверьте реальные пути хранения и подключение к БД.

```bash
make check-env
make config
make test-storage-paths
```

Для изменений инициализации, образов, импорта или Adminer выполните соответствующие проверки в отдельном стенде. `clean-*` и `reinit-*` удаляют данные; не используйте их на рабочем стенде.

[Начало работы](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/ru/guides/getting-started.md) · [Руководство по эксплуатации](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/ru/guides/operations.md).

## Pull Request

Создайте тематическую ветку от `master` и один логически цельный подписанный коммит. Используйте Conventional Commits с русским описанием, например `docs: уточнить порядок запуска`. В PR укажите изменение, влияние на данные и безопасность, фактические проверки и обновления документации. Синхронизируйте все шесть локалей; перед merge должны пройти все три CI.

[Сайт автора](https://yaleksandr89.github.io/)
