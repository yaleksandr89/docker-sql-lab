# Диагностика

[← Вернуться к README](../../../README.md)

**Русский — Выбран** | [English](../en/troubleshooting.md) | [Español](../es/troubleshooting.md) | [中文](../zh/troubleshooting.md) | [Français](../fr/troubleshooting.md) | [Deutsch](../de/troubleshooting.md)

**Разделы этого языка:** [Начало работы](getting-started.md) · [Базы и samples](databases.md) · [Проверки и операции](operations.md) · **Диагностика**

Сначала соберите диагностику, затем исправьте конкретную причину. Если
изменение всё же требует переинициализации, сначала сделайте backup и только
после этого используйте подтверждённый `reinit-... CONFIRM=1` как
осознанную последнюю меру.

Канонические описания жизненного цикла и операций: [базы](databases.md#section-initialization) · [операции](operations.md#section-clean-reinitialize).

<a id="section-configuration"></a>
## Ошибка конфигурации или storage-path validation

Выполните `make check-env` и найдите в ошибке отклонённую переменную и путь.
Managed data paths должны находиться строго внутри каталога проекта `data/`, а
sample paths — внутри `samples/`. Они не могут содержать symlink-компоненты,
пересекаться между собой или использовать зарезервированные каталоги проекта.
Исправьте `.docker.env`, затем повторите `make check-env` и `make config`.

<a id="section-readiness"></a>
## Сервис не переходит в состояние готовности

До изменения данных проверьте состояние и логи:

```bash
make status
make log SERVICE=mysql
make log SERVICE=postgres
```

Убедитесь, что Docker запущен, настроенный host port свободен, а
`.docker.env` содержит обязательные значения. Исправьте конкретную настройку
или конфликт порта и снова запустите сервис.

<a id="section-init-samples"></a>
## Изменения init или optional samples не появились

Для уже инициализированного data-каталога это ожидаемое поведение. Проверьте
настроенные data- и sample-пути и успешность команды подготовки. Если
существующие данные важны, сохраните их. Используйте соответствующую команду
`reinit-... CONFIRM=1` только как осознанную последнюю меру: она удаляет данные
этой СУБД.

<a id="section-sample-integrity"></a>
## Optional sample неполон или имеет неожиданного владельца

Loader намеренно не перезаписывает и не исправляет неожиданную базу. Повторите
подходящую подготовку `make samples-mysql` или `make samples-postgres` и
изучите ошибку. Сохраните нужные данные, прежде чем рассматривать
переинициализацию с подтверждением.

<a id="section-connections-troubleshooting"></a>
## Клиент не подключается

Клиенты на хосте используют опубликованный host address и `MYSQL_PORT` или
`POSTGRES_PORT`, а не имя Compose-сервиса. Adminer использует `mysql` или
`postgres` внутри Compose-сети. Проверьте `BIND_ADDRESS`, firewall, выбранную
базу и неадминистративные credentials `DB_USER`.

[LICENSE.md](../../../LICENSE.md) · [THIRD_PARTY_NOTICES.md](../../../THIRD_PARTY_NOTICES.md)

[Вернуться к README](../../../README.md)
