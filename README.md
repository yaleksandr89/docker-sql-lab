# SQL Lab (Docker)

Локальный учебный SQL-стенд на Docker Compose с независимыми сервисами:

- MySQL 9.7.1 LTS;
- PostgreSQL 18.4 — последняя стабильная major-ветка с пятилетним сроком
  поддержки;
- один опциональный Adminer Docker Official Image 5.4.2 для обеих СУБД.

Upstream Adminer уже выпускает 5.4.4, но официальный Docker image пока
закреплён на 5.4.2. Поэтому стенд использует точный официальный тег 5.4.2 и не
собирает собственный образ только ради расхождения версий.

В MySQL и PostgreSQL всегда создаётся небольшая база `demo`. Официальные
учебные базы World и Sakila доступны как опциональные samples только для
MySQL.

## Быстрый старт

Полный стенд с Adminer:

```bash
make init
make up
```

Полный стенд без UI:

```bash
make up-no-ui
```

Одиночные режимы:

```bash
make up-mysql
make up-mysql-ui
make up-postgres
make up-postgres-ui
```

Adminer можно добавить к уже работающим СУБД или остановить отдельно:

```bash
make up-ui
make down-ui
```

Команды одиночного запуска не останавливают уже работающие сервисы. Они лишь
не запускают другие сервисы автоматически.

## Режимы запуска

| Команда | MySQL | PostgreSQL | Adminer |
|---|---|---|---|
| `make up` | запускает | запускает | запускает |
| `make up-no-ui` | запускает или оставляет активным | запускает или оставляет активным | останавливает, если запущен |
| `make up-mysql` | запускает | не запускает автоматически | не запускает автоматически |
| `make up-mysql-ui` | запускает | не запускает автоматически | запускает |
| `make up-postgres` | не запускает автоматически | запускает | не запускает автоматически |
| `make up-postgres-ui` | не запускает автоматически | запускает | запускает |
| `make up-ui` | не меняет состояние | не меняет состояние | запускает |
| `make down-ui` | не меняет состояние | не меняет состояние | останавливает |

`make up-no-ui` не выполняет общий `docker compose down`: сначала он
останавливает только Adminer, затем запускает или оставляет запущенными обе
СУБД и ждёт их готовности.

## Порты

Порты задаются в `.docker.env`:

| Сервис | Переменная | Значение по умолчанию |
|---|---|---|
| MySQL | `MYSQL_PORT` | `3306` |
| PostgreSQL | `POSTGRES_PORT` | `5432` |
| Adminer | `ADMINER_PORT` | `8081` |

При значениях по умолчанию Adminer открыт на
`http://127.0.0.1:8081`.

## Credentials

`.docker.env.example` содержит только локальные учебные значения:

| Назначение | Пользователь | Пароль |
|---|---|---|
| Администратор MySQL | `MYSQL_ROOT_PASSWORD` задаёт пароль пользователя `root` | `MYSQL_ROOT_PASSWORD` |
| Администратор PostgreSQL | `POSTGRES_SUPERUSER` | `POSTGRES_SUPERUSER_PASSWORD` |
| Общий учебный пользователь | `DB_USER` | `DB_PASSWORD` |

Административная PostgreSQL-роль и `DB_USER` обязаны различаться. Реальный
`.docker.env` исключён из Git.

Значения из примера нельзя использовать в production, публичном окружении или
на доступном извне сервере.

## Один Adminer для двух СУБД

Adminer находится в общей Compose-сети с MySQL и PostgreSQL, не зависит от их
состояния и включается профилем `ui`. Это лёгкий optional UI с дизайном
`nette`; без профиля он не запускается и не расходует ресурсы.

Plugin `adminer/plugins-enabled/001-login-servers.php` заменяет свободный ввод
движка и сервера выпадающим списком из двух допустимых подключений:

```text
MySQL (mysql)
PostgreSQL (postgres)
```

Невалидный default server `db` в форме отсутствует. Пользователь выбирает
одно подключение, затем вводит общий `DB_USER`/`DB_PASSWORD` и базу.

Страница входа содержит локальную подсказку: выбрать MySQL или PostgreSQL,
использовать значения `DB_USER`/`DB_PASSWORD` из `.docker.env` и базу `demo`;
optional World и Sakila доступны только для MySQL.

Вход в MySQL:

```text
Server: MySQL (mysql)
Username: значение DB_USER
Password: значение DB_PASSWORD
Database: demo, world, sakila или пустое поле
```

Вход в PostgreSQL:

```text
Server: PostgreSQL (postgres)
Username: значение DB_USER
Password: значение DB_PASSWORD
Database: demo
```

Имена `mysql` и `postgres` применяются только внутри Docker-сети.

## Внешние клиенты

Полноценные IDE-клиенты — PhpStorm, DataGrip, DBeaver — и CLI на хосте
подключаются к `127.0.0.1` и опубликованному порту, а не к имени
Compose-сервиса.

MySQL:

```text
Host: 127.0.0.1
Port: значение MYSQL_PORT
User: значение DB_USER
Password: значение DB_PASSWORD
Database: demo
```

PostgreSQL:

```text
Host: 127.0.0.1
Port: значение POSTGRES_PORT
User: значение DB_USER
Password: значение DB_PASSWORD
Database: demo
```

CLI внутри контейнеров не требует размещать пароль в shell history:

```bash
make mysql
make mysql-user
make postgres
make postgres-user
```

## Учебные базы

MySQL:

- `demo` — обязательная база с таблицей `demo.demo_users`;
- `world` — опциональная официальная учебная база;
- `sakila` — опциональная официальная учебная база.

PostgreSQL:

- `demo` — обязательная база с таблицей `public.demo_users`.

Обе таблицы `demo_users` имеют одинаковую смысловую структуру:

| Поле | Назначение |
|---|---|
| `id` | автоматически создаваемый integer primary key |
| `name` | `varchar(100) NOT NULL` |
| `email` | `varchar(150) NOT NULL UNIQUE` |
| `created_at` | обязательный timestamp с `CURRENT_TIMESTAMP` по умолчанию |

MySQL использует `TIMESTAMP`, PostgreSQL — `timestamptz`. В обе базы
идемпотентно добавляются одинаковые обязательные строки:

| Name | Email | Created at |
|---|---|---|
| Alice | `alice@example.com` | `2025-01-10 09:00:00+03` |
| Bob | `bob@example.com` | `2025-01-11 10:15:00+03` |
| Carol | `carol@example.com` | `2025-01-12 11:30:00+03` |
| Dave | `dave@example.com` | `2025-01-13 12:45:00+03` |
| Eve | `eve@example.com` | `2025-01-14 14:00:00+03` |

Дополнительные пользовательские строки разрешены и не считаются ошибкой при
проверках.

Обычные `make init`, `make up`, `make up-no-ui` и `make up-mysql` не скачивают
World или Sakila. MySQL полностью работоспособен только с `demo`.

## Optional samples MySQL

Скачать официальные архивы World и Sakila и подготовить локальные SQL-файлы:

```bash
make samples-mysql
```

Для нового пустого каталога данных:

```bash
make samples-mysql
make up-mysql
```

Для уже инициализированного MySQL:

```bash
make samples-mysql
make reinit-mysql CONFIRM=1
```

MySQL выполняет init-файлы только при первом запуске с пустым
`MYSQL_DATA_DIR`. Загрузка samples не изменяет данные и не перезапускает
контейнеры автоматически.

Файлы сохраняются детерминированно:

```text
samples/mysql/
├── 010_world.sql
├── 020_sakila_schema.sql
└── 021_sakila_data.sql
```

Эти загруженные SQL-файлы считаются локально сгенерированными и исключены из
Git. `initdb/mysql/050_load_optional_samples.sh` пропускает отсутствующие
samples и прекращает init с ошибкой при неполной паре schema/data Sakila.

## Инициализация и порядок файлов

```text
initdb/
├── mysql/
│   ├── 001_demo.sql
│   ├── 030_training_database.sql.example
│   ├── 050_load_optional_samples.sh
│   ├── 090_grant_training_access.sh
│   └── 099_check_training_access.sh
└── postgres/
    ├── 001_create_training_role.sh
    ├── 010_initialize_demo.sh
    ├── 030_training_database.sh.example
    └── 099_check_training_access.sh
```

Файлы `.example` служат шаблонами и не выполняются entrypoint автоматически.
MySQL-шаблон показывает добавление новой базы перед grants. PostgreSQL-шаблон
безопасно передаёт значения через psql variables, назначает `DB_USER`
владельцем новой базы и создаёт начальную таблицу от его имени.

Оба официальных entrypoint обрабатывают init-каталог только для пустого
data-каталога. Изменение init-файлов не обновляет существующую базу.

## Конфигурация СУБД

```text
conf/
├── mysql/
│   └── my.cnf
└── postgres/
    └── postgresql.conf.example
```

`conf/mysql/my.cnf` подключается к MySQL и фиксирует `utf8mb4`, collation
`utf8mb4_0900_ai_ci`, строгий SQL mode с `ONLY_FULL_GROUP_BY`, часовой пояс
`+03:00` и отключение DNS lookup клиентов. Performance-настройки оставлены
только понятными закомментированными примерами: универсальных значений для
лимитов памяти, соединений и slow query log нет.

`conf/postgres/postgresql.conf.example` полностью закомментирован и
автоматически к Compose не подключается. Он показывает, как ресурсы и тип
нагрузки влияют на `shared_buffers`, `work_mem`, `maintenance_work_mem` и
временную диагностику медленных запросов. Активного PostgreSQL performance
tuning и отдельного logging collector нет: сервер продолжает писать в штатные
Docker logs.

## Права учебного пользователя

В MySQL `090_grant_training_access.sh` создаёт или обновляет `DB_USER` и
выдаёт ему `ALL PRIVILEGES` отдельно на каждую фактически существующую
несистемную базу. Глобальные административные права на `*.*` не выдаются.

В PostgreSQL роль `DB_USER` получает `LOGIN`, владеет обязательной базой
`demo` и схемой `public`, но остаётся без `SUPERUSER`, `CREATEDB`,
`CREATEROLE`, `REPLICATION` и `BYPASSRLS`. Таблица `demo_users` создаётся от
имени этой роли.

## Проверки

Проверка каждой СУБД отдельно:

```bash
make check-mysql-access
make check-postgres-access
```

MySQL-проверка требует `demo.demo_users`, все пять обязательных email,
проверяет temporary read/write и пробный откатываемый `INSERT` в `demo_users`.
Она также проверяет доступ ко всем существующим пользовательским базам и
`world.city`/`sakila.actor` только при наличии соответствующего sample.

PostgreSQL-проверка подключается как `DB_USER` по TCP к работающему серверу,
проверяет владение базой и `demo_users`, все пять обязательных email, создаёт
временную таблицу, записывает и читает строку, выполняет откатываемый `INSERT`
в `demo_users` и подтверждает отсутствие `SUPERUSER`.

Для полного стенда:

```bash
make check
```

Команда проверяет Compose-конфигурацию и фактический доступ `DB_USER` к обеим
СУБД.

## Остановка и очистка данных

Остановить все сервисы без удаления bind-mounted данных:

```bash
make down
```

Удаление данных всегда требует явного `CONFIRM=1`:

```bash
make clean-mysql CONFIRM=1
make clean-postgres CONFIRM=1
make clean-all CONFIRM=1
```

Первые две команды удаляют только каталог соответствующей СУБД. `clean-all`
удаляет только `data/mysql` и `data/postgres`. `.docker.env`, конфигурация,
init-файлы, optional samples и backup сохраняются. Перед удалением проверяется,
что data-каталог находится внутри проекта; пустой каталог возвращается
текущему UID/GID.

Чистая инициализация с последующей проверкой:

```bash
make reinit-mysql CONFIRM=1
make reinit-postgres CONFIRM=1
make reinit-all CONFIRM=1
```

Одиночные команды запускают только выбранную СУБД без Adminer. `reinit-all`
запускает обе СУБД без Adminer и выполняет общую проверку.

## Основные команды

| Команда | Назначение |
|---|---|
| `make init` | Создать `.docker.env`, data/init/samples-каталоги и проверить скрипты |
| `make pull` | Скачать три образа |
| `make config` | Проверить итоговую Compose-конфигурацию |
| `make status` | Показать MySQL, PostgreSQL и профильный Adminer |
| `make logs` | Смотреть общие логи |
| `make log postgres` | Смотреть лог выбранного сервиса (`SERVICE=postgres` также поддерживается) |
| `make in postgres` | Открыть shell выбранного контейнера (`SERVICE=postgres` также поддерживается) |
| `make wait-mysql` | Дождаться MySQL |
| `make wait-postgres` | Дождаться PostgreSQL |
| `make mysql-grants` | Повторно применить MySQL grants |
| `make mysql-import FILE=...` | Импортировать MySQL dump, применить grants и проверить доступ |
| `make dump` / `make restore` | Создать / восстановить backup MySQL `demo` |

## Структура данных и Git

Данные СУБД разделены:

```text
data/
├── mysql/
└── postgres/
```

Контейнеры могут присвоить файлам числовые UID/GID своих системных
пользователей. Не редактируйте содержимое data-каталогов вручную.

Для официального образа PostgreSQL 18 host-каталог `data/postgres` подключён к
`/var/lib/postgresql`; фактический versioned data directory образ создаёт
внутри этого bind mount.

В Git не должны попадать:

```text
.docker.env
.env
data/
backup/
.tmp/
samples/mysql/*.sql
```

Обязательные init-скрипты и оба шаблона `.example` остаются отслеживаемыми.

---

Автор: **Александр Юрченко**

Лицензия: MIT
