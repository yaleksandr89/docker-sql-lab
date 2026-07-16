#!/usr/bin/env bash
set -Eeuo pipefail

required_variables=(POSTGRES_USER POSTGRES_DB DB_USER DB_PASSWORD)
for variable_name in "${required_variables[@]}"; do
    if [[ -z "${!variable_name:-}" ]]; then
        echo "ERROR: environment variable ${variable_name} is required" >&2
        exit 1
    fi
done

if [[ "${DB_USER}" == "${POSTGRES_USER}" ]]; then
    echo "ERROR: DB_USER must differ from the PostgreSQL administrative user" >&2
    exit 1
fi

psql \
    --username="${POSTGRES_USER}" \
    --dbname="${POSTGRES_DB}" \
    --set=ON_ERROR_STOP=1 \
    --set=db_user="${DB_USER}" \
    --set=db_name="${POSTGRES_DB}" <<'SQL'
\getenv db_password DB_PASSWORD

SELECT format(
    'CREATE ROLE %I WITH LOGIN PASSWORD %L NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS',
    :'db_user',
    :'db_password'
)
WHERE NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = :'db_user')
\gexec

SELECT format(
    'ALTER ROLE %I WITH LOGIN PASSWORD %L NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS',
    :'db_user',
    :'db_password'
)
\gexec

SELECT format('ALTER DATABASE %I OWNER TO %I', :'db_name', :'db_user')
\gexec

SELECT format('ALTER SCHEMA public OWNER TO %I', :'db_user')
\gexec
SQL

echo "PostgreSQL training role ${DB_USER} configured as owner of ${POSTGRES_DB}."
