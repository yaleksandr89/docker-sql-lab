# 🧠 MySQL Trainer (Docker)

Локальный тренажёр для SQL-заданий.
Работает на MySQL **8.0.21**, с графическим интерфейсом **Adminer**.

---

## 🚀 Быстрый старт

```bash
make init        # создаст .docker.env и каталоги
make pull        # загрузит образы MySQL и Adminer
make up          # запустит контейнеры
```

После запуска открой браузер → [http://localhost:8081](http://localhost:8081)

**Adminer:**

| Параметр | Значение |
|-----------|-----------|
| Сервер | mysql |
| Пользователь | student |
| Пароль | student |
| БД | demo |

---

## ⚙️ Настройки окружения

- **MySQL:** 8.0.21
- **Adminer:** latest
- **Timezone:** Europe/Moscow
- **Encoding:** utf8mb4 / utf8mb4_0900_ai_ci
- **SQL Mode:** STRICT (ошибки при некорректных данных)
- **initdb/** — SQL-файлы выполняются один раз при создании тома
- **data/** — хранит данные MySQL (персистентность между перезапусками)

---

## 📁 Структура проекта

```
.
├── docker-compose.yml
├── Makefile
├── .docker.env.example
├── conf/
│   └── my.cnf
├── initdb/
│   └── 001_init.sql
├── data/           # создаётся автоматически
└── backup/         # создаётся при make dump
```

---

## 🛠 Команды Makefile

| Команда | Описание |
|----------|-----------|
| `make init` | Создать .docker.env и каталоги |
| `make pull` | Скачать Docker-образы |
| `make up` | Запустить контейнеры (MySQL + Adminer) |
| `make down` | Остановить контейнеры |
| `make reset` | Перезапустить с чистого состояния |
| `make in mysql` | Зайти внутрь MySQL-контейнера |
| `make log mysql` | Посмотреть логи MySQL |
| `make dump` | Сделать SQL-бэкап БД |
| `make restore` | Восстановить БД из бэкапа |

---

## 💡 Полезно знать

- `make init` теперь полностью автономен: создаёт `.docker.env`, проверяет каталоги и конфиг.
- При необходимости можно изменить версию MySQL прямо в `.docker.env` → `MYSQL_VERSION=8.0.21`.
- PhpStorm подключается к MySQL через `127.0.0.1:3306` (student/student).
- Для полного сброса БД просто удали папку `./data/mysql` и сделай `make up` снова.

---

Автор: **Александр Юрченко**  
Лицензия: MIT
