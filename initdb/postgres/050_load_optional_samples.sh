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
pagila_schema_file="${samples_dir}/010_pagila_schema.sql"
pagila_data_file="${samples_dir}/020_pagila_data.sql"
chinook_file="${samples_dir}/030_chinook.sql"
pagila_database=pagila
chinook_database=chinook

admin_psql() {
    psql \
        --username="${POSTGRES_USER}" \
        --set=ON_ERROR_STOP=1 \
        --no-psqlrc \
        "$@"
}

training_psql() {
    local database_name=${1}
    shift
    PGPASSWORD="${DB_PASSWORD}" psql \
        --username="${DB_USER}" \
        --dbname="${database_name}" \
        --set=ON_ERROR_STOP=1 \
        --no-psqlrc \
        "$@"
}

database_exists() {
    local database_name=${1}
    admin_psql \
        --dbname="${POSTGRES_DB}" \
        --tuples-only \
        --no-align \
        --set=database_name="${database_name}" <<'SQL'
SELECT EXISTS (
    SELECT FROM pg_catalog.pg_database WHERE datname = :'database_name'
);
SQL
}

database_owner() {
    local database_name=${1}
    admin_psql \
        --dbname="${POSTGRES_DB}" \
        --tuples-only \
        --no-align \
        --set=database_name="${database_name}" <<'SQL'
SELECT pg_catalog.pg_get_userbyid(datdba)
FROM pg_catalog.pg_database
WHERE datname = :'database_name';
SQL
}

public_objects_owned_by_training_role() {
    local database_name=${1}
    local public_objects_owned

    public_objects_owned=$(admin_psql \
        --dbname="${database_name}" \
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

create_training_database() {
    local database_name=${1}
    admin_psql \
        --dbname="${POSTGRES_DB}" \
        --set=database_name="${database_name}" \
        --set=db_user="${DB_USER}" <<'SQL'
SELECT format('CREATE DATABASE %I OWNER %I', :'database_name', :'db_user')
WHERE NOT EXISTS (
    SELECT FROM pg_catalog.pg_database WHERE datname = :'database_name'
)
\gexec
SQL
}

pagila_is_complete() {
    local key_table_count key_tables_have_data

    [[ "$(database_owner "${pagila_database}")" == "${DB_USER}" ]] || return 1

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

    public_objects_owned_by_training_role "${pagila_database}"
}

chinook_is_complete() {
    local key_table_count key_tables_have_data join_has_data

    [[ "$(database_owner "${chinook_database}")" == "${DB_USER}" ]] || return 1

    key_table_count=$(admin_psql \
        --dbname="${chinook_database}" \
        --tuples-only \
        --no-align \
        --command="
            SELECT COUNT(*)
            FROM pg_catalog.pg_class AS class
            JOIN pg_catalog.pg_namespace AS namespace ON namespace.oid = class.relnamespace
            WHERE namespace.nspname = 'public'
              AND class.relkind IN ('r', 'p')
              AND class.relname IN ('artist', 'album', 'track', 'customer', 'invoice');
        ")
    [[ "${key_table_count}" == "5" ]] || return 1

    key_tables_have_data=$(admin_psql \
        --dbname="${chinook_database}" \
        --tuples-only \
        --no-align \
        --command="
            SELECT EXISTS (SELECT FROM public.artist)
               AND EXISTS (SELECT FROM public.album)
               AND EXISTS (SELECT FROM public.track)
               AND EXISTS (SELECT FROM public.customer)
               AND EXISTS (SELECT FROM public.invoice);
        ")
    [[ "${key_tables_have_data}" == "t" ]] || return 1

    join_has_data=$(admin_psql \
        --dbname="${chinook_database}" \
        --tuples-only \
        --no-align \
        --command="
            SELECT EXISTS (
                SELECT
                FROM public.artist AS artist
                JOIN public.album AS album USING (artist_id)
                JOIN public.track AS track USING (album_id)
            );
        ")
    [[ "${join_has_data}" == "t" ]] || return 1

    public_objects_owned_by_training_role "${chinook_database}"
}

chinook_file_has_database_setup() {
    awk '
        BEGIN { in_comment = 0; found = 0 }
        { upper = toupper($0) }
        /^[[:space:]]*\/\*/ { in_comment = 1 }
        !in_comment && (upper ~ /^[[:space:]]*(DROP|CREATE)[[:space:]]+DATABASE/ || upper ~ /^[[:space:]]*\\(C|CONNECT)([[:space:]]|$)/) { found = 1 }
        /\*\// { in_comment = 0 }
        END { exit(found ? 0 : 1) }
    ' "${chinook_file}"
}

load_pagila() {
    if [[ ! -f "${pagila_schema_file}" && ! -f "${pagila_data_file}" ]]; then
        echo "Optional PostgreSQL sample Pagila is not present; skipping it."
        return
    fi

    if [[ -f "${pagila_schema_file}" && ! -f "${pagila_data_file}" ]]; then
        echo "ERROR: Pagila schema is present but Pagila data is missing; prepare the complete pair with make samples-postgres" >&2
        exit 1
    fi

    if [[ ! -f "${pagila_schema_file}" && -f "${pagila_data_file}" ]]; then
        echo "ERROR: Pagila data is present but Pagila schema is missing; prepare the complete pair with make samples-postgres" >&2
        exit 1
    fi

    if [[ "$(database_exists "${pagila_database}")" == "t" ]]; then
        if pagila_is_complete; then
            echo "Optional PostgreSQL sample Pagila is already complete and owned by ${DB_USER}; skipping reload."
            return
        fi

        echo "ERROR: database pagila already exists but is incomplete or has unexpected ownership" >&2
        echo "Recreate PostgreSQL explicitly with: make reinit-postgres CONFIRM=1" >&2
        exit 1
    fi

    owner_statement_count=$(grep -Fc 'OWNER TO postgres;' "${pagila_schema_file}" || true)
    if [[ "${owner_statement_count}" == "0" ]]; then
        echo "ERROR: Pagila schema has an unexpected ownership format" >&2
        exit 1
    fi
    if grep 'OWNER TO ' "${pagila_schema_file}" | grep -Fv 'OWNER TO postgres;' >/dev/null; then
        echo "ERROR: Pagila schema contains an unsupported owner other than postgres" >&2
        exit 1
    fi

    create_training_database "${pagila_database}"

    echo "Loading optional PostgreSQL sample: Pagila schema as ${DB_USER}..."
    sed 's/OWNER TO postgres;/OWNER TO :"db_user";/g' "${pagila_schema_file}" | \
        training_psql "${pagila_database}" --set=db_user="${DB_USER}"

    echo "Loading optional PostgreSQL sample: Pagila data as ${DB_USER}..."
    training_psql "${pagila_database}" < "${pagila_data_file}"

    if ! pagila_is_complete; then
        echo "ERROR: Pagila load finished but required tables, data, or DB_USER ownership verification failed" >&2
        exit 1
    fi

    echo "Loaded and verified optional PostgreSQL sample Pagila as ${DB_USER}."
}

load_chinook() {
    if [[ ! -f "${chinook_file}" ]]; then
        echo "Optional PostgreSQL sample Chinook is not present; skipping it."
        return
    fi

    if chinook_file_has_database_setup; then
        echo "ERROR: prepared Chinook PostgreSQL SQL contains forbidden database-level statements" >&2
        exit 1
    fi

    if [[ "$(database_exists "${chinook_database}")" == "t" ]]; then
        if chinook_is_complete; then
            echo "Optional PostgreSQL sample Chinook is already complete and owned by ${DB_USER}; skipping reload."
            return
        fi

        echo "ERROR: database chinook already exists but is incomplete or has unexpected ownership" >&2
        echo "Recreate PostgreSQL explicitly with: make reinit-postgres CONFIRM=1" >&2
        exit 1
    fi

    create_training_database "${chinook_database}"
    admin_psql \
        --dbname="${chinook_database}" \
        --set=db_user="${DB_USER}" <<'SQL'
SELECT format('ALTER SCHEMA public OWNER TO %I', :'db_user')
\gexec
SQL

    echo "Loading optional PostgreSQL sample: Chinook as ${DB_USER}..."
    training_psql "${chinook_database}" < "${chinook_file}"

    if ! chinook_is_complete; then
        echo "ERROR: Chinook load finished but required tables, data, join, or DB_USER ownership verification failed" >&2
        exit 1
    fi

    echo "Loaded and verified optional PostgreSQL sample Chinook as ${DB_USER}."
}

load_pagila
load_chinook
echo "Optional PostgreSQL sample loading completed."
