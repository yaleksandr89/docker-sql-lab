# MySQL Trainer (Docker)

Локальный SQL-стенд на MySQL **8.0.21** с учебными базами:

- `demo`;
- `world`;
- `sakila`.

Для работы с базами доступны MySQL CLI, PhpStorm Database Tools и Adminer.

## Быстрый старт

```bash
make init
make pull
make up
make check
```

После запуска:

- MySQL: `127.0.0.1:3306`;
- Adminer: `http://localhost:8081`.

## Локальные credentials

Стенд использует известные учебные credentials:

| Назначение | Пользователь | Пароль |
|---|---|---|
| Администратор MySQL | `root` | `root` |
| Учебный пользователь | `student` | `student` |

Эти значения предназначены только для локального учебного окружения.

Они задаются в `.docker.env`:

```dotenv
MYSQL_ROOT_PASSWORD=root
DB_USER=student
DB_PASSWORD=student
```

Реальный `.docker.env` исключён из Git. В репозитории хранится
`.docker.env.example` с теми же локальными значениями по умолчанию.

## Подключение через Adminer

Откройте:

```text
http://localhost:8081
```

Параметры подключения:

| Поле | Значение |
|---|---|
| Движок | `MySQL / MariaDB` |
| Сервер | `mysql` |
| Имя пользователя | `student` |
| Пароль | `student` |
| База данных | имя конкретной базы или пустое поле |

Внутри Docker-сети сервер называется `mysql`, а не `db`, `localhost`
или `127.0.0.1`.

Чтобы сразу открыть конкретную учебную базу, укажите в поле
«База данных» одно из значений:

```text
demo
world
sakila
```

Чтобы увидеть все доступные учебные базы одновременно, оставьте поле
«База данных» пустым и выполните вход только с логином и паролем:

```text
student
student
```

После входа Adminer покажет `demo`, `world` и `sakila`.

В списке также может отображаться системная схема `information_schema`.
Это нормальное поведение MySQL: схема содержит метаданные и её наличие
не означает, что пользователю `student` выданы административные права.

## Подключение через PhpStorm

Используйте:

| Поле | Значение |
|---|---|
| Host | `127.0.0.1` |
| Port | `3306` |
| User | `student` |
| Password | `student` |

PhpStorm работает на хосте, поэтому подключается через опубликованный порт
`127.0.0.1:3306`.

Adminer работает внутри Docker-сети, поэтому подключается к серверу `mysql`.

## Учебные базы

### `demo`

Небольшая песочница для базовых операций:

- `SELECT`;
- `INSERT`;
- `UPDATE`;
- `DELETE`;
- создание простых запросов и ограничений.

Стартовая таблица:

```text
demo.demo_users
```

### `world`

Учебная база MySQL с информацией о странах, городах и языках.

Подходит для:

- фильтрации;
- группировки;
- простых и составных `JOIN`;
- подзапросов.

### `sakila`

Более крупная учебная база видеопроката.

Подходит для:

- сложных связей;
- агрегатных запросов;
- аналитики;
- представлений;
- процедур и функций.

## Модель доступа

`MYSQL_ROOT_PASSWORD` используется только административным пользователем MySQL.

`DB_USER` и `DB_PASSWORD` используются общим учебным пользователем.

Скрипт:

```text
initdb/090_grant_training_access.sh
```

выполняет следующие действия:

1. создаёт пользователя `DB_USER`, если он отсутствует;
2. обновляет его пароль;
3. получает список всех несистемных баз;
4. выдаёт пользователю права отдельно на каждую базу.

Глобальные административные права на `*.*` не выдаются.

Системные базы исключены:

```text
information_schema
mysql
performance_schema
sys
```

Проверочный скрипт:

```text
initdb/099_check_training_access.sh
```

проверяет:

- доступ ко всем пользовательским базам;
- чтение;
- создание временной таблицы;
- временную запись;
- наличие данных в `demo`, `world` и `sakila`.

Ручная проверка:

```bash
make mysql-grants
make check-mysql-access
```

Полная проверка Compose и MySQL-доступов:

```bash
make check
```

## Порядок init-файлов

```text
001_demo.sql
010_world.sql
020_sakila_schema.sql
021_sakila_data.sql
090_grant_training_access.sh
099_check_training_access.sh
```

Шаблон:

```text
030_training_database.sql.example
```

не выполняется автоматически, потому что его имя заканчивается на
`.sql.example`.

Назначение файлов:

| Файл | Назначение |
|---|---|
| `001_demo.sql` | Создание маленькой базы `demo` |
| `010_world.sql` | Создание и заполнение `world` |
| `020_sakila_schema.sql` | Создание схемы `sakila` |
| `021_sakila_data.sql` | Загрузка данных `sakila` |
| `030_training_database.sql.example` | Шаблон новой учебной базы |
| `090_grant_training_access.sh` | Создание пользователя и выдача прав |
| `099_check_training_access.sh` | Проверка фактического доступа |

Рабочие init-файлы выполняются в лексикографическом порядке.

Каталог `/docker-entrypoint-initdb.d` обрабатывается только при первом запуске
MySQL с пустым каталогом данных.

Изменение файлов в `initdb/` не изменяет уже созданный MySQL автоматически.

## Добавление новой учебной базы

### Вариант 1. Новая база при чистой инициализации

Скопируйте шаблон:

```bash
cp initdb/030_training_database.sql.example initdb/030_shop.sql
```

Замените в новом файле:

```text
training_database
```

на:

```text
shop
```

Затем выполните:

```bash
make reinit-mysql CONFIRM=1
```

Команда полностью удалит текущие данные MySQL и повторно выполнит все
рабочие init-файлы.

Файл новой базы должен сортироваться раньше:

```text
090_grant_training_access.sh
```

Примеры имён:

```text
030_shop.sql
040_library.sql
050_orders.sql
```

### Вариант 2. Добавление без удаления текущих данных

Подготовьте SQL:

```bash
cp initdb/030_training_database.sql.example initdb/030_shop.sql
```

После редактирования выполните:

```bash
make mysql-import FILE=initdb/030_shop.sql
```

Команда:

1. импортирует SQL от имени root;
2. повторно применит grants;
3. проверит доступ пользователя `student`.

### Вариант 3. Импорт готового dump

Если dump содержит:

```sql
CREATE DATABASE ...;
USE ...;
```

его можно импортировать напрямую:

```bash
make mysql-import FILE=/path/to/shop.sql
```

Если dump содержит только таблицы и данные, добавьте в его начало:

```sql
CREATE DATABASE IF NOT EXISTS `shop`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE `shop`;
```

### Вариант 4. Раздельные схема и данные

Можно использовать несколько файлов:

```text
030_shop_schema.sql
031_shop_data.sql
```

Они будут выполнены по порядку, а `090_grant_training_access.sh` выдаст права
после загрузки обоих файлов.

### База создана вручную

После создания базы через MySQL CLI или PhpStorm выполните:

```bash
make mysql-grants
make check-mysql-access
```

Grant-скрипт обнаружит новую несистемную базу автоматически.

## Владельцы файлов в `data/mysql`

MySQL внутри контейнера работает от системного пользователя `mysql`.

При использовании bind mount файлы сохраняются на хосте с числовым UID/GID
контейнерного пользователя.

На хосте тот же UID может принадлежать другому локальному пользователю, например
`nginx`. Поэтому `ls` может показывать:

```text
nginx
systemd-journal
```

Это не означает, что Nginx или systemd создают базы.

Проверить числовые значения:

```bash
stat -c '%u:%g %U:%G %n' data/mysql
docker compose exec mysql id mysql
```

Файлы MySQL в `data/mysql` нельзя редактировать вручную.

Для работы с данными используйте:

- SQL;
- MySQL CLI;
- PhpStorm;
- Adminer;
- `mysqldump`;
- команды `make dump` и `make restore`.

Для удаления каталога используйте:

```bash
make clean-mysql CONFIRM=1
```

Команда удаляет каталог через временный Docker-контейнер с root-правами, поэтому
не требует ручного `sudo rm -rf`.

После удаления пустой каталог создаётся с UID/GID текущего пользователя хоста.
После нового запуска MySQL содержимое снова будет принадлежать контейнерному
пользователю `mysql` — это ожидаемое поведение.

## Основные команды

| Команда | Описание |
|---|---|
| `make help` | Показать список основных команд |
| `make init` | Создать `.docker.env` и необходимые каталоги |
| `make pull` | Скачать образы MySQL и Adminer |
| `make samples` | Повторно скачать World и Sakila |
| `make config` | Проверить итоговую Compose-конфигурацию |
| `make up` | Запустить MySQL и Adminer |
| `make down` | Остановить сервисы без удаления данных |
| `make restart` | Перезапустить сервисы |
| `make status` | Показать состояние контейнеров |
| `make logs` | Смотреть все логи |
| `make log mysql` | Смотреть логи MySQL |
| `make in mysql` | Открыть shell внутри MySQL-контейнера |
| `make mysql` | Открыть MySQL CLI от имени root |
| `make mysql-user` | Открыть MySQL CLI от имени `DB_USER` |
| `make mysql-grants` | Повторно выдать права на все учебные базы |
| `make check-mysql-access` | Проверить доступ учебного пользователя |
| `make check` | Проверить Compose и MySQL-доступы |
| `make mysql-import FILE=...` | Импортировать новую базу и выдать права |
| `make dump` | Создать backup базы `demo` |
| `make restore` | Восстановить `demo` из backup |
| `make clean-mysql CONFIRM=1` | Удалить данные MySQL |
| `make reinit-mysql CONFIRM=1` | Удалить данные и выполнить полную инициализацию |

Цель `reset` намеренно отключена.

Для обычного перезапуска:

```bash
make restart
```

Для полного сброса:

```bash
make reinit-mysql CONFIRM=1
```

## Настройки MySQL

- версия: `8.0.21`;
- основной порт: `3306`;
- кодировка: `utf8mb4`;
- collation: `utf8mb4_0900_ai_ci`;
- строгий SQL mode;
- timezone: `Europe/Moscow`;
- каталог данных: `./data/mysql`;
- конфигурация: `./conf/my.cnf`;
- init-файлы: `./initdb`.

Порт MySQL X Protocol `33060` не публикуется, поскольку текущий стенд использует
обычный MySQL-протокол через порт `3306`.

## Структура проекта

```text
.
├── .docker.env.example
├── .editorconfig
├── .gitignore
├── Makefile
├── README.md
├── docker-compose.yml
├── conf/
│   └── my.cnf
├── initdb/
│   ├── 001_demo.sql
│   ├── 010_world.sql
│   ├── 020_sakila_schema.sql
│   ├── 021_sakila_data.sql
│   ├── 030_training_database.sql.example
│   ├── 090_grant_training_access.sh
│   └── 099_check_training_access.sh
├── data/
└── backup/
```

## Git и локальные данные

В Git не должны попадать:

```text
.docker.env
data/
backup/
.tmp/
```

Проверка:

```bash
git status
git check-ignore .docker.env data/mysql
```

---

Автор: **Александр Юрченко**
Лицензия: MIT
