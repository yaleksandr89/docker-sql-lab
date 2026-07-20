# Начало работы

[← Вернуться к README](../../../README.md)

**Русский — Выбран** | [English](../en/getting-started.md) | [Español](../es/getting-started.md) | [中文](../zh/getting-started.md) | [Français](../fr/getting-started.md) | [Deutsch](../de/getting-started.md)

**Разделы этого языка:** **Начало работы** · [Базы и samples](databases.md) · [Проверки и операции](operations.md) · [Диагностика](troubleshooting.md)

<a id="section-requirements"></a>
## Требования

- Docker Engine или Docker Desktop с командой `docker compose` v2.
- GNU Make, Bash и стандартные Unix-утилиты, используемые скриптами (`awk`,
  `sed`, `grep`, `find`, `realpath` и `stat`).
- Для загрузки optional samples: `curl` и `git`; для MySQL samples также нужны
  `unzip` и `sha256sum`.

Выполняйте команды из корня репозитория. Ветка проекта по умолчанию — `master`.

<a id="section-quick-start"></a>
## Быстрый старт

Создайте `.docker.env` из отслеживаемого примера, проверьте настроенные пути,
создайте рабочие каталоги и запустите полный стенд:

```bash
make init
make up
```

`make up` запускает MySQL, PostgreSQL и Adminer. С конфигурацией по умолчанию
Adminer доступен по адресу `http://127.0.0.1:8081`.

Полезные следующие команды:

```bash
make status
make logs
make down
```

`make down` удаляет контейнеры и сеть, но сохраняет bind-mounted данные СУБД.

<a id="section-startup-modes"></a>
## Режимы запуска

| Команда | MySQL | PostgreSQL | Adminer |
|---|---|---|---|
| `make up` | Запускает | Запускает | Запускает |
| `make up-no-ui` | Запускает | Запускает | Останавливает |
| `make up-mysql` | Запускает | Не запускает | Не запускает |
| `make up-postgres` | Не запускает | Запускает | Не запускает |

Команды одной СУБД не останавливают уже работающую другую; Adminer управляется отдельно.

<details>
<summary>Полная таблица режимов запуска</summary>

| Команда | MySQL | PostgreSQL | Adminer |
|---|---|---|---|
| `make up` | Запускает | Запускает | Запускает |
| `make up-no-ui` | Запускает или оставляет активным | Запускает или оставляет активным | Останавливает, если запущен |
| `make up-mysql` | Запускает | Не запускает автоматически | Не запускает автоматически |
| `make up-mysql-ui` | Запускает | Не запускает автоматически | Запускает |
| `make up-postgres` | Не запускает автоматически | Запускает | Не запускает автоматически |
| `make up-postgres-ui` | Не запускает автоматически | Запускает | Запускает |
| `make up-ui` | Не меняет состояние | Не меняет состояние | Запускает |
| `make down-ui` | Не меняет состояние | Не меняет состояние | Останавливает |

Команды одиночного запуска не останавливают другую уже работающую СУБД.
Adminer можно запускать и останавливать отдельно; он не привязан только к
MySQL.

</details>

<a id="section-connections"></a>
## Подключения

### Adminer

Внутри Compose-сети Adminer предлагает два заранее заданных сервера:

```text
MySQL (mysql)
PostgreSQL (postgres)
```

Выберите сервер, затем укажите `DB_USER`, `DB_PASSWORD` и имя базы, например
`demo`. Имена сервисов `mysql` и `postgres` работают внутри Compose-сети; для
desktop-клиентов на хосте это не адреса серверов.

### Клиенты на хосте

DataGrip, DBeaver, PhpStorm и host CLI подключаются через опубликованный адрес
и порт:

| СУБД | Хост по умолчанию | Переменная порта | Пользователь | База по умолчанию |
|---|---|---|---|---|
| MySQL | `127.0.0.1` | `MYSQL_PORT` | `DB_USER` | `demo` |
| PostgreSQL | `127.0.0.1` | `POSTGRES_PORT` | `DB_USER` | `demo` |

Если вы изменили `BIND_ADDRESS`, при необходимости используйте вместо
`127.0.0.1` доступный адрес этого интерфейса.

### CLI в контейнерах

Make-targets передают пароли через environment контейнера и не помещают их в
историю shell:

```bash
make mysql          # администратор MySQL, база demo
make mysql-user     # DB_USER, база demo
make postgres       # superuser PostgreSQL, база demo
make postgres-user  # DB_USER, база demo
```

<a id="section-credentials"></a>
## Учётные данные

При копировании `.docker.env.example` создаётся `.docker.env`; этот файл
исключён из Git. Храните пароли в нём и не хардкодьте их в Compose, SQL или
отслеживаемой конфигурации клиентов.

| Назначение | Настройка пользователя | Настройка пароля |
|---|---|---|
| Общий учебный пользователь двух СУБД | `DB_USER` | `DB_PASSWORD` |
| Администратор MySQL | `root` | `MYSQL_ROOT_PASSWORD` |
| Администратор/superuser PostgreSQL | `POSTGRES_SUPERUSER` | `POSTGRES_SUPERUSER_PASSWORD` |

`POSTGRES_SUPERUSER` и `DB_USER` должны быть разными ролями. Для обычных
упражнений используйте общего учебного пользователя, а не root или superuser.
Замените пароли из примера до предоставления общего доступа или публикации
любого сервиса за пределами локального компьютера.

<a id="section-network-exposure"></a>
## Порты и `BIND_ADDRESS`

Порты хоста настраиваются в `.docker.env`:

| Сервис | Переменная порта | Значение примера |
|---|---|---|
| MySQL | `MYSQL_PORT` | `3306` |
| PostgreSQL | `POSTGRES_PORT` | `5432` |
| Adminer | `ADMINER_PORT` | `8081` |

По умолчанию все три сервиса публикуются только на loopback:

```env
BIND_ADDRESS=127.0.0.1
```

Это безопасный default для локального стенда. Значение
`BIND_ADDRESS=0.0.0.0` публикует настроенные порты на всех сетевых интерфейсах.
Для доступа через VPN или LAN предпочтительнее адрес конкретного интерфейса.
Меняйте binding осознанно, учитывая правила firewall, надёжность паролей и
доверие ко всем подключённым сетям.

[LICENSE.md](../../../LICENSE.md) · [THIRD_PARTY_NOTICES.md](../../../THIRD_PARTY_NOTICES.md)

[Вернуться к README](../../../README.md)
