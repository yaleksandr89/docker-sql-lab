#!/usr/bin/env bash
set -Eeuo pipefail

: "${MYSQL_ROOT_PASSWORD:?environment variable MYSQL_ROOT_PASSWORD is required}"

samples_dir=/opt/mysql-samples
world_file="${samples_dir}/010_world.sql"
sakila_schema_file="${samples_dir}/020_sakila_schema.sql"
sakila_data_file="${samples_dir}/021_sakila_data.sql"

mysql_root() {
    MYSQL_PWD="${MYSQL_ROOT_PASSWORD}" mysql \
        --protocol=socket \
        --user=root \
        "$@"
}

if [[ ! -d "${samples_dir}" ]]; then
    echo "Optional MySQL samples directory is not mounted; skipping World and Sakila."
    exit 0
fi

if [[ -f "${world_file}" ]]; then
    echo "Loading optional MySQL sample: World..."
    mysql_root < "${world_file}"
    echo "Loaded optional MySQL sample: World."
else
    echo "Optional MySQL sample World is not present; skipping it."
fi

if [[ -f "${sakila_schema_file}" && ! -f "${sakila_data_file}" ]]; then
    echo "ERROR: Sakila schema is present but Sakila data is missing" >&2
    exit 1
fi

if [[ ! -f "${sakila_schema_file}" && -f "${sakila_data_file}" ]]; then
    echo "ERROR: Sakila data is present but Sakila schema is missing" >&2
    exit 1
fi

if [[ -f "${sakila_schema_file}" ]]; then
    echo "Loading optional MySQL sample: Sakila schema..."
    mysql_root < "${sakila_schema_file}"
    echo "Loading optional MySQL sample: Sakila data..."
    mysql_root < "${sakila_data_file}"
    echo "Loaded optional MySQL sample: Sakila."
else
    echo "Optional MySQL sample Sakila is not present; skipping it."
fi

echo "Optional MySQL sample loading completed."
