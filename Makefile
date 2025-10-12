###############################################################################
# 🧠 Makefile — MySQL Trainer
# Версия: стабильная, гарантированный порядок init
###############################################################################

SHELL = bash
.PHONY: init init-setup pull build config up down reset restart in log mysql sh dump restore

# -----------------------------------------------------------------------------
# 🏗️  Основные переменные
# -----------------------------------------------------------------------------
PROJECT_DIR := $(PWD)
ENV_FILE_EXAMPLE := .docker.env.example
ENV_FILE := .docker.env

# Подключаем переменные из .docker.env, если файл уже существует
-include $(ENV_FILE)

# Команда для docker-compose
COMPOSE_COMMAND := docker-compose -p $(COMPOSE_PROJECT_NAME) --env-file $(ENV_FILE)

# Контейнеры по умолчанию
LOCAL_CONTAINERS := mysql adminer

# -----------------------------------------------------------------------------
# ⚙️  Инициализация окружения
# -----------------------------------------------------------------------------

# Главная цель — init
# Гарантирует, что .docker.env существует перед выполнением setup
init: $(ENV_FILE) init-setup

# Если .docker.env отсутствует, создаём его из примера
$(ENV_FILE): $(ENV_FILE_EXAMPLE)
	@cp $(ENV_FILE_EXAMPLE) $(ENV_FILE)
	@echo "✅ Создан файл $(ENV_FILE) из примера"

# Проверяем директории и конфиги
init-setup:
	@echo "🔧 Проверяем переменные и создаем директории..."
	@DATA_DIR="$(MYSQL_DATA_DIR)"; \
	CONF_FILE="$(MYSQL_CONF_FILE)"; \
	INIT_DIR="$(INITDB_DIR)"; \
	for DIR in "$$DATA_DIR" "$$(dirname "$$CONF_FILE")" "$$INIT_DIR"; do \
		if [ -n "$$DIR" ] && [ ! -d "$$DIR" ]; then \
			mkdir -p "$$DIR"; \
			echo "📁 Создана директория: $$DIR"; \
		fi; \
	done; \
	if [ -f "$$CONF_FILE" ]; then \
		echo "✅ Конфиг найден: $$CONF_FILE"; \
	else \
		echo "⚠️  Не найден конфиг $$CONF_FILE — проверь, что он на месте (conf/my.cnf)"; \
	fi

# -----------------------------------------------------------------------------
# 🐳 Docker Compose управление
# -----------------------------------------------------------------------------

pull:
	@echo "⬇️  Скачиваем образы..."
	docker pull mysql:$(MYSQL_VERSION)
	docker pull adminer:$(ADMINER_VERSION)
	@echo "✅ Образы успешно скачаны."

build:
	@echo "🛠️  Собираем образы..."
	$(COMPOSE_COMMAND) build --no-cache

config:
	@echo "🧩 Проверяем конфигурацию..."
	$(COMPOSE_COMMAND) config

up:
	@echo "🚀 Запускаем контейнеры..."
	$(COMPOSE_COMMAND) up -d

down:
	@echo "🛑 Останавливаем контейнеры..."
	$(COMPOSE_COMMAND) down

reset: down up

restart:
	@echo "♻️  Перезапуск контейнеров..."
	$(COMPOSE_COMMAND) restart

# -----------------------------------------------------------------------------
# 🧭 Доступ внутрь контейнеров
# -----------------------------------------------------------------------------

ifeq (in,$(firstword $(MAKECMDGOALS)))
  CONTAINER := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(CONTAINER):;@: )
endif

in:
	@test -n "$(CONTAINER)" || (echo "❗ Не указан контейнер. Пример: make in mysql" && exit 1)
	$(COMPOSE_COMMAND) exec $(CONTAINER) bash

# Быстрые ярлыки
mysql:
	$(COMPOSE_COMMAND) exec mysql mysql -uroot -p$(MYSQL_ROOT_PASSWORD)

sh:
	$(COMPOSE_COMMAND) exec mysql bash

# -----------------------------------------------------------------------------
# 💾 Бэкап и восстановление
# -----------------------------------------------------------------------------

dump:
	@mkdir -p backup
	@echo "💾 Делаем бэкап БД $(MYSQL_DATABASE)..."
	$(COMPOSE_COMMAND) exec -T mysql mysqldump -uroot -p$(MYSQL_ROOT_PASSWORD) --databases $(MYSQL_DATABASE) > backup/$(MYSQL_DATABASE).sql
	@echo "✅ Бэкап сохранён в backup/$(MYSQL_DATABASE).sql"

restore:
	@test -f backup/$(MYSQL_DATABASE).sql || (echo "❗ Нет backup/$(MYSQL_DATABASE).sql" && exit 1)
	@echo "♻️  Восстанавливаем БД из backup/$(MYSQL_DATABASE).sql..."
	$(COMPOSE_COMMAND) exec -T mysql mysql -uroot -p$(MYSQL_ROOT_PASSWORD) < backup/$(MYSQL_DATABASE).sql
	@echo "✅ Восстановление завершено"

# -----------------------------------------------------------------------------
# 📜 Просмотр логов
# -----------------------------------------------------------------------------

ifeq (log,$(firstword $(MAKECMDGOALS)))
  CONTAINER := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(CONTAINER):;@: )
endif

log:
	@test -n "$(CONTAINER)" || (echo "❗ Не указан контейнер. Пример: make log mysql" && exit 1)
	@echo "📜 Просмотр логов контейнера $(CONTAINER)..."
	$(COMPOSE_COMMAND) logs -f $(CONTAINER)

###############################################################################
# ✅ Конец Makefile
###############################################################################
