SHELL = bash
.PHONY: init pull build config up down reset restart in log mysql sh dump restore

PROJECT_DIR := $(PWD)
ENV_FILE_EXAMPLE := .docker.env.example
ENV_FILE := .docker.env

-include $(ENV_FILE)

COMPOSE_COMMAND := docker-compose -p $(COMPOSE_PROJECT_NAME) --env-file $(ENV_FILE)

# Контейнеры по умолчанию
LOCAL_CONTAINERS := mysql adminer

init:
	@if [ ! -f "$(ENV_FILE)" ]; then \
		cp $(ENV_FILE_EXAMPLE) $(ENV_FILE); \
		echo "Создан файл $(ENV_FILE) из примера"; \
	else \
		echo "Файл $(ENV_FILE) уже существует"; \
	fi
	@echo "Проверяем переменные и создаем директории..."
	@DATA_DIR=$$(grep '^MYSQL_DATA_DIR=' $(ENV_FILE) | cut -d '=' -f2); \
	CONF_FILE=$$(grep '^MYSQL_CONF_FILE=' $(ENV_FILE) | cut -d '=' -f2); \
	INIT_DIR=$$(grep '^INITDB_DIR=' $(ENV_FILE) | cut -d '=' -f2); \
	for DIR in "$$DATA_DIR" "$$(dirname "$$CONF_FILE")" "$$INIT_DIR"; do \
		if [ -n "$$DIR" ] && [ ! -d "$$DIR" ]; then \
			mkdir -p "$$DIR"; \
			echo "Создана директория: $$DIR"; \
		fi; \
	done
	@if [ ! -f "$$CONF_FILE" ]; then \
		echo "⚠️  Не найден конфиг $$CONF_FILE — проверь, что он на месте (conf/my.cnf)"; \
	fi

pull:
	@echo "Скачиваем образы..."
	docker pull mysql:$(MYSQL_VERSION)
	docker pull adminer:$(ADMINER_VERSION)
	@echo "Готово."

build:
	$(COMPOSE_COMMAND) build --no-cache

config:
	$(COMPOSE_COMMAND) config

up:
	$(COMPOSE_COMMAND) up -d

down:
	$(COMPOSE_COMMAND) down

reset: down up

restart:
	$(COMPOSE_COMMAND) restart

# Вход внутрь контейнера
ifeq (in,$(firstword $(MAKECMDGOALS)))
  CONTAINER := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(CONTAINER):;@: )
endif

in:
	@test -n "$(CONTAINER)" || (echo "Не указан контейнер. Пример: make in mysql" && exit 1)
	$(COMPOSE_COMMAND) exec $(CONTAINER) bash

# Быстрые ярлыки
mysql:
	$(COMPOSE_COMMAND) exec mysql mysql -uroot -p$(MYSQL_ROOT_PASSWORD)

sh:
	$(COMPOSE_COMMAND) exec mysql bash

# Бекап и восстановление простой БД (пример)
dump:
	@mkdir -p backup
	$(COMPOSE_COMMAND) exec -T mysql mysqldump -uroot -p$(MYSQL_ROOT_PASSWORD) --databases $(MYSQL_DATABASE) > backup/$(MYSQL_DATABASE).sql
	@echo "Бекап в backup/$(MYSQL_DATABASE).sql"

restore:
	@test -f backup/$(MYSQL_DATABASE).sql || (echo "Нет backup/$(MYSQL_DATABASE).sql" && exit 1)
	$(COMPOSE_COMMAND) exec -T mysql mysql -uroot -p$(MYSQL_ROOT_PASSWORD) < backup/$(MYSQL_DATABASE).sql
	@echo "Восстановление завершено"

# Логи
ifeq (log,$(firstword $(MAKECMDGOALS)))
  CONTAINER := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(CONTAINER):;@: )
endif

log:
	@test -n "$(CONTAINER)" || (echo "Не указан контейнер. Пример: make log mysql" && exit 1)
	$(COMPOSE_COMMAND) logs -f $(CONTAINER)
