#!/usr/bin/env bash
set -Eeuo pipefail

required_variables=(POSTGRES_DB DB_USER DB_PASSWORD)
for variable_name in "${required_variables[@]}"; do
    if [[ -z "${!variable_name:-}" ]]; then
        echo "ERROR: environment variable ${variable_name} is required" >&2
        exit 1
    fi
done

psql_arguments=(
    --username="${DB_USER}"
    --dbname="${POSTGRES_DB}"
    --set=ON_ERROR_STOP=1
    --no-psqlrc
)

# The official entrypoint's temporary server may listen only on its Unix
# socket. Runtime checks opt into TCP by setting POSTGRES_CHECK_HOST.
if [[ -n "${POSTGRES_CHECK_HOST:-}" ]]; then
    psql_arguments+=(--host="${POSTGRES_CHECK_HOST}")
fi

psql_training() {
    PGPASSWORD="${DB_PASSWORD}" psql "${psql_arguments[@]}" "$@"
}

is_superuser=$(psql_training --tuples-only --no-align \
    --command="SELECT rolsuper FROM pg_catalog.pg_roles WHERE rolname = current_user;")
if [[ "${is_superuser}" != "f" ]]; then
    echo "ERROR: PostgreSQL training role unexpectedly has superuser privileges" >&2
    exit 1
fi

database_is_owned=$(psql_training --tuples-only --no-align \
    --command="SELECT pg_get_userbyid(datdba) = current_user FROM pg_catalog.pg_database WHERE datname = current_database();")
table_is_owned=$(psql_training --tuples-only --no-align \
    --command="SELECT pg_get_userbyid(relowner) = current_user FROM pg_catalog.pg_class WHERE oid = 'public.demo_users'::regclass;")
if [[ "${database_is_owned}" != "t" || "${table_is_owned}" != "t" ]]; then
    echo "ERROR: PostgreSQL demo database or demo_users table is not owned by DB_USER" >&2
    exit 1
fi

required_seed_count=$(psql_training --tuples-only --no-align --command="
    SELECT COUNT(DISTINCT email)
    FROM public.demo_users
    WHERE email IN (
        'alice@example.com',
        'bob@example.com',
        'carol@example.com',
        'dave@example.com',
        'eve@example.com'
    );
")
if [[ "${required_seed_count}" != "5" ]]; then
    echo "ERROR: public.demo_users does not contain all five required seed emails" >&2
    exit 1
fi

psql_training <<'SQL'
CREATE TEMPORARY TABLE __sql_lab_access_check
(
    id integer PRIMARY KEY,
    value varchar(32) NOT NULL
);

INSERT INTO __sql_lab_access_check (id, value) VALUES (1, 'ok');
SELECT value FROM __sql_lab_access_check WHERE id = 1;

BEGIN;
INSERT INTO public.demo_users (name, email)
VALUES (
    'SQL Lab access check',
    'sql-lab-check-' || md5(random()::text || clock_timestamp()::text) || '@example.invalid'
)
RETURNING email;
ROLLBACK;
SQL

echo "Verified PostgreSQL demo ownership, all five seed emails and temporary read/write access."
echo "Verified PostgreSQL user-row INSERT access and that the training role is not a superuser."
echo "All PostgreSQL training-user access checks passed."
