#!/usr/bin/env bash
set -Eeuo pipefail

required_variables=(POSTGRES_USER POSTGRES_DB DB_USER DB_PASSWORD)
for variable_name in "${required_variables[@]}"; do
    if [[ -z "${!variable_name:-}" ]]; then
        echo "ERROR: environment variable ${variable_name} is required" >&2
        exit 1
    fi
done

samples_dir=/opt/postgres-samples
schema_file="${samples_dir}/010_pagila_schema.sql"
data_file="${samples_dir}/020_pagila_data.sql"
pagila_database=pagila

if [[ ! -f "${schema_file}" && ! -f "${data_file}" ]]; then
    echo "Optional PostgreSQL sample Pagila is not present; skipping it."
    exit 0
fi

if [[ -f "${schema_file}" && ! -f "${data_file}" ]]; then
    echo "ERROR: Pagila schema is present but Pagila data is missing; prepare the complete pair with make samples-postgres" >&2
    exit 1
fi

if [[ ! -f "${schema_file}" && -f "${data_file}" ]]; then
    echo "ERROR: Pagila data is present but Pagila schema is missing; prepare the complete pair with make samples-postgres" >&2
    exit 1
fi

admin_psql() {
    psql \
        --username="${POSTGRES_USER}" \
        --set=ON_ERROR_STOP=1 \
        --no-psqlrc \
        "$@"
}

training_psql() {
    PGPASSWORD="${DB_PASSWORD}" psql \
        --username="${DB_USER}" \
        --dbname="${pagila_database}" \
        --set=ON_ERROR_STOP=1 \
        --no-psqlrc \
        "$@"
}

database_exists=$(admin_psql \
    --dbname="${POSTGRES_DB}" \
    --tuples-only \
    --no-align \
    --set=database_name="${pagila_database}" <<'SQL'
SELECT EXISTS (
    SELECT FROM pg_catalog.pg_database WHERE datname = :'database_name'
);
SQL
)

pagila_is_complete() {
    local database_owner key_table_count key_tables_have_data public_objects_owned

    database_owner=$(admin_psql \
        --dbname="${POSTGRES_DB}" \
        --tuples-only \
        --no-align \
        --set=database_name="${pagila_database}" <<'SQL'
SELECT pg_catalog.pg_get_userbyid(datdba)
FROM pg_catalog.pg_database
WHERE datname = :'database_name';
SQL
    )
    [[ "${database_owner}" == "${DB_USER}" ]] || return 1

    key_table_count=$(admin_psql \
        --dbname="${pagila_database}" \
        --tuples-only \
        --no-align \
        --command="
            SELECT COUNT(*)
            FROM pg_catalog.pg_class AS class
            JOIN pg_catalog.pg_namespace AS namespace ON namespace.oid = class.relnamespace
            WHERE namespace.nspname = 'public'
              AND class.relkind IN ('r', 'p')
              AND class.relname IN ('actor', 'film', 'customer', 'rental');
        ")
    [[ "${key_table_count}" == "4" ]] || return 1

    key_tables_have_data=$(admin_psql \
        --dbname="${pagila_database}" \
        --tuples-only \
        --no-align \
        --command="
            SELECT EXISTS (SELECT FROM public.actor)
               AND EXISTS (SELECT FROM public.film)
               AND EXISTS (SELECT FROM public.customer)
               AND EXISTS (SELECT FROM public.rental);
        ")
    [[ "${key_tables_have_data}" == "t" ]] || return 1

    public_objects_owned=$(admin_psql \
        --dbname="${pagila_database}" \
        --tuples-only \
        --no-align \
        --set=db_user="${DB_USER}" <<'SQL'
SELECT
    (SELECT namespace.nspowner = role.oid
     FROM pg_catalog.pg_namespace AS namespace
     CROSS JOIN pg_catalog.pg_roles AS role
     WHERE namespace.nspname = 'public' AND role.rolname = :'db_user')
    AND NOT EXISTS (
        SELECT
        FROM pg_catalog.pg_class AS class
        JOIN pg_catalog.pg_namespace AS namespace ON namespace.oid = class.relnamespace
        JOIN pg_catalog.pg_roles AS role ON role.rolname = :'db_user'
        WHERE namespace.nspname = 'public'
          AND class.relkind IN ('r', 'p', 'S', 'v', 'm', 'f')
          AND class.relowner <> role.oid
    )
    AND NOT EXISTS (
        SELECT
        FROM pg_catalog.pg_proc AS procedure
        JOIN pg_catalog.pg_namespace AS namespace ON namespace.oid = procedure.pronamespace
        JOIN pg_catalog.pg_roles AS role ON role.rolname = :'db_user'
        WHERE namespace.nspname = 'public'
          AND procedure.proowner <> role.oid
    )
    AND NOT EXISTS (
        SELECT
        FROM pg_catalog.pg_type AS type
        JOIN pg_catalog.pg_namespace AS namespace ON namespace.oid = type.typnamespace
        JOIN pg_catalog.pg_roles AS role ON role.rolname = :'db_user'
        WHERE namespace.nspname = 'public'
          AND type.typtype IN ('c', 'd', 'e')
          AND type.typowner <> role.oid
    );
SQL
    )
    [[ "${public_objects_owned}" == "t" ]]
}

if [[ "${database_exists}" == "t" ]]; then
    if pagila_is_complete; then
        echo "Optional PostgreSQL sample Pagila is already complete and owned by ${DB_USER}; skipping reload."
        exit 0
    fi

    echo "ERROR: database pagila already exists but is incomplete or has unexpected ownership" >&2
    echo "Recreate PostgreSQL explicitly with: make reinit-postgres CONFIRM=1" >&2
    exit 1
fi

owner_statement_count=$(grep -Fc 'OWNER TO postgres;' "${schema_file}" || true)
if [[ "${owner_statement_count}" == "0" ]]; then
    echo "ERROR: Pagila schema has an unexpected ownership format" >&2
    exit 1
fi
if grep 'OWNER TO ' "${schema_file}" | grep -Fv 'OWNER TO postgres;' >/dev/null; then
    echo "ERROR: Pagila schema contains an unsupported owner other than postgres" >&2
    exit 1
fi

admin_psql \
    --dbname="${POSTGRES_DB}" \
    --set=database_name="${pagila_database}" \
    --set=db_user="${DB_USER}" <<'SQL'
SELECT format('CREATE DATABASE %I OWNER %I', :'database_name', :'db_user')
WHERE NOT EXISTS (
    SELECT FROM pg_catalog.pg_database WHERE datname = :'database_name'
)
\gexec
SQL

echo "Loading optional PostgreSQL sample: Pagila schema as ${DB_USER}..."
sed 's/OWNER TO postgres;/OWNER TO :"db_user";/g' "${schema_file}" | \
    training_psql --set=db_user="${DB_USER}"

echo "Loading optional PostgreSQL sample: Pagila data as ${DB_USER}..."
training_psql < "${data_file}"

if ! pagila_is_complete; then
    echo "ERROR: Pagila load finished but required tables, data, or DB_USER ownership verification failed" >&2
    exit 1
fi

echo "Loaded and verified optional PostgreSQL sample Pagila as ${DB_USER}."
