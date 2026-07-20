<p align="center">
  <img
    src="docs/assets/docker-sql-lab-cover.png"
    alt="Docker SQL Lab — локальный стенд MySQL и PostgreSQL"
    width="100%"
  >
</p>

# Docker SQL Lab

## Выберите язык

| Русский | English | Español | 中文 | Français | Deutsch |
| --- | --- | --- | --- | --- | --- |
| **Выбран** | [English](docs/langs/README_en.md) | [Español](docs/langs/README_es.md) | [中文](docs/langs/README_zh.md) | [Français](docs/langs/README_fr.md) | [Deutsch](docs/langs/README_de.md) |

Локальный стенд на Docker Compose для изучения и сравнения MySQL и PostgreSQL.
Каждую СУБД можно запускать независимо, обе можно использовать одновременно,
а Adminer подключать только при необходимости браузерного UI.

## Стек

- MySQL 9.7.1 LTS
- PostgreSQL 18.4
- Adminer 5.4.2 Docker Official Image
- Docker Compose v2
- GNU Make и Bash для команд проекта и init-скриптов

Версии образов закреплены в `.docker.env`. Не используйте стенд как шаблон
production-развёртывания без отдельного анализа учётных данных, сетевой
доступности, хранения данных, резервного копирования и эксплуатации.

## Основные возможности

- Независимые сервисы MySQL и PostgreSQL, которые также работают одновременно.
- Общий для двух СУБД опциональный Adminer без зависимости от конкретного
  сервиса базы данных.
- Обязательная база `demo` в каждой СУБД с одинаковыми пятью пользователями.
- Опциональные Sakila и Chinook для MySQL, Pagila и Chinook для PostgreSQL.
- Раздельные bind-mounted data-, init- и sample-каталоги каждой СУБД.
- Общие учебные credentials и отдельные credentials администраторов СУБД.
- Статические проверки конфигурации, защита managed storage paths, runtime-
  проверки доступа и smoke-test импорта доверенного SQL.
- Явное подтверждение destructive-команд очистки и переинициализации.

## Требования

- Docker Engine или Docker Desktop с командой `docker compose` v2.
- GNU Make, Bash и стандартные Unix-утилиты, используемые скриптами (`awk`,
  `sed`, `grep`, `find`, `realpath` и `stat`).
- Для загрузки optional samples: `curl` и `git`; для MySQL samples также нужны
  `unzip` и `sha256sum`.

Выполняйте команды из корня репозитория. Ветка проекта по умолчанию — `master`.

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

## Режимы запуска

| Команда | MySQL | PostgreSQL | Adminer |
|---|---|---|---|
| `make up` | Запускает | Запускает | Запускает |
| `make up-no-ui` | Запускает | Запускает | Останавливает |
| `make up-mysql` | Запускает | Не запускает | Не запускает |
| `make up-postgres` | Не запускает | Запускает | Не запускает |

Команды одной СУБД не останавливают уже работающую другую; Adminer управляется отдельно.

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

## Кратко об учётных данных

| Назначение | Пользователь | Пароль |
|---|---|---|
| Общий учебный пользователь двух СУБД | `DB_USER` | `DB_PASSWORD` |
| Администратор MySQL | `root` | `MYSQL_ROOT_PASSWORD` |
| Superuser PostgreSQL | `POSTGRES_SUPERUSER` | `POSTGRES_SUPERUSER_PASSWORD` |

`POSTGRES_SUPERUSER` и `DB_USER` должны быть разными ролями. Для обычных упражнений используйте общего учебного пользователя и замените примерные пароли до публикации сервисов.

## Базы и ключевые проверки

Обе СУБД создают обязательную базу `demo` с эквивалентной таблицей `demo_users`. Optional samples: Chinook и Sakila для MySQL, Pagila и Chinook для PostgreSQL. Подготовка samples не импортирует их в уже инициализированные данные.

Статическая проверка не требует запуска СУБД:

```bash
make check-env
make config
make test-storage-paths
```

После запуска обеих СУБД `make check` проверяет доступ `DB_USER`, а `make test-sql-imports` — публичные trusted import targets. Подробные команды, ограничения и порядок безопасных действий вынесены в документацию ниже.

Data-, init- и sample-каталоги MySQL/PostgreSQL разделены и настраиваются через `.docker.env`. Managed path validator не допускает выход за `data/` или `samples/`, symlink-компоненты, пересечения и зарезервированные каталоги. Полностью отсутствующий optional sample пропускается, а частичный набор или неожиданная существующая sample-база отклоняются без автоматического исправления.

Подготовка samples загружает закреплённые upstream-файлы, проверяет integrity и оставляет их локально; provenance и лицензии находятся в `THIRD_PARTY_NOTICES.md`. Runtime-проверки также подтверждают обязательные строки `demo`, read/write-доступ учебного пользователя и установленные samples.

## Безопасность и жизненный цикл

- `BIND_ADDRESS=127.0.0.1` публикует сервисы только на loopback.
- `BIND_ADDRESS=0.0.0.0` публикует их на всех интерфейсах: заранее настройте
  firewall, надёжные credentials и доверенную сеть.
- Официальные entrypoints выполняют init только для пустого data-каталога.
- `make mysql-import` и `make postgres-import` принимают только доверенный
  SQL. Это не sandbox: возможна частичная запись без полного automatic rollback.
  Перед важным импортом сделайте backup.
- Встроенные `make dump` и `make restore` покрывают только MySQL `demo`;
  встроенного backup target для PostgreSQL нет.
- Все `clean-*` и `reinit-*` destructive и требуют точного `CONFIRM=1`.

## Документация

- [Начало работы](docs/langs/ru/getting-started.md)
- [Базы и samples](docs/langs/ru/databases.md)
- [Проверки и операции](docs/langs/ru/operations.md)
- [Диагностика](docs/langs/ru/troubleshooting.md)

## Лицензии и сторонние компоненты

Docker SQL Lab распространяется по лицензии MIT; см.
[LICENSE.md](LICENSE.md). Optional sample-базы сохраняют upstream-лицензии и
уведомления; источники, закреплённые ревизии, integrity information и тексты
лицензий приведены в [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

---

<p align="center">
  <a href="https://yaleksandr89.github.io/" title="yaleksandr89.github.io">
    <img
      src="docs/assets/ya-logo-dark-50px.png"
      alt="YA"
      width="32"
    >
  </a>
  <br>
  <a href="https://yaleksandr89.github.io/">yaleksandr89.github.io</a>
</p>
