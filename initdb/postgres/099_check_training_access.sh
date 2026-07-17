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
    --set=ON_ERROR_STOP=1
    --no-psqlrc
)

# The official entrypoint's temporary server may listen only on its Unix
# socket. Runtime checks opt into TCP by setting POSTGRES_CHECK_HOST.
if [[ -n "${POSTGRES_CHECK_HOST:-}" ]]; then
    psql_arguments+=(--host="${POSTGRES_CHECK_HOST}")
fi

psql_training() {
    local database_name=${1}
    shift
    PGPASSWORD="${DB_PASSWORD}" psql \
        "${psql_arguments[@]}" \
        --dbname="${database_name}" \
        "$@"
}

has_administrative_attributes=$(psql_training "${POSTGRES_DB}" --tuples-only --no-align \
    --command="
        SELECT rolsuper OR rolcreatedb OR rolcreaterole OR rolreplication OR rolbypassrls
        FROM pg_catalog.pg_roles
        WHERE rolname = current_user;
    ")
if [[ "${has_administrative_attributes}" != "f" ]]; then
    echo "ERROR: PostgreSQL training role unexpectedly has administrative attributes" >&2
    exit 1
fi

database_is_owned=$(psql_training "${POSTGRES_DB}" --tuples-only --no-align \
    --command="SELECT pg_get_userbyid(datdba) = current_user FROM pg_catalog.pg_database WHERE datname = current_database();")
table_is_owned=$(psql_training "${POSTGRES_DB}" --tuples-only --no-align \
    --command="SELECT pg_get_userbyid(relowner) = current_user FROM pg_catalog.pg_class WHERE oid = 'public.demo_users'::regclass;")
if [[ "${database_is_owned}" != "t" || "${table_is_owned}" != "t" ]]; then
    echo "ERROR: PostgreSQL demo database or demo_users table is not owned by DB_USER" >&2
    exit 1
fi

required_seed_count=$(psql_training "${POSTGRES_DB}" --tuples-only --no-align --command="
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

psql_training "${POSTGRES_DB}" <<'SQL'
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
echo "Verified PostgreSQL user-row INSERT access and absence of administrative role attributes."

pagila_exists=$(psql_training "${POSTGRES_DB}" --tuples-only --no-align \
    --command="SELECT EXISTS (SELECT FROM pg_catalog.pg_database WHERE datname = 'pagila');")
if [[ "${pagila_exists}" == "t" ]]; then
    pagila_database_is_owned=$(psql_training "${POSTGRES_DB}" --tuples-only --no-align \
        --command="SELECT pg_get_userbyid(datdba) = current_user FROM pg_catalog.pg_database WHERE datname = 'pagila';")
    if [[ "${pagila_database_is_owned}" != "t" ]]; then
        echo "ERROR: PostgreSQL database pagila is not owned by DB_USER" >&2
        exit 1
    fi

    pagila_key_table_count=$(psql_training pagila --tuples-only --no-align --command="
        SELECT COUNT(*)
        FROM pg_catalog.pg_class AS class
        JOIN pg_catalog.pg_namespace AS namespace ON namespace.oid = class.relnamespace
        WHERE namespace.nspname = 'public'
          AND class.relkind IN ('r', 'p')
          AND class.relname IN ('actor', 'film', 'customer', 'rental');
    ")
    if [[ "${pagila_key_table_count}" != "4" ]]; then
        echo "ERROR: Pagila does not contain all required tables: actor, film, customer, rental" >&2
        exit 1
    fi

    pagila_key_tables_owned=$(psql_training pagila --tuples-only --no-align --command="
        SELECT COUNT(*) = 4 AND bool_and(pg_get_userbyid(class.relowner) = current_user)
        FROM pg_catalog.pg_class AS class
        JOIN pg_catalog.pg_namespace AS namespace ON namespace.oid = class.relnamespace
        WHERE namespace.nspname = 'public'
          AND class.relkind IN ('r', 'p')
          AND class.relname IN ('actor', 'film', 'customer', 'rental');
    ")
    if [[ "${pagila_key_tables_owned}" != "t" ]]; then
        echo "ERROR: one or more required Pagila tables are not owned by DB_USER" >&2
        exit 1
    fi

    pagila_key_tables_have_data=$(psql_training pagila --tuples-only --no-align --command="
        SELECT EXISTS (SELECT FROM public.actor)
           AND EXISTS (SELECT FROM public.film)
           AND EXISTS (SELECT FROM public.customer)
           AND EXISTS (SELECT FROM public.rental);
    ")
    if [[ "${pagila_key_tables_have_data}" != "t" ]]; then
        echo "ERROR: one or more required Pagila tables contain no data" >&2
        exit 1
    fi

    pagila_read_probe=$(psql_training pagila --tuples-only --no-align --command="
        SELECT actor.actor_id || ':' || film.film_id
        FROM public.actor AS actor
        JOIN public.film_actor AS film_actor USING (actor_id)
        JOIN public.film AS film USING (film_id)
        WHERE film.title IS NOT NULL
        ORDER BY actor.actor_id, film.film_id
        LIMIT 1;
    ")
    if [[ -z "${pagila_read_probe}" ]]; then
        echo "ERROR: Pagila join read probe returned no rows" >&2
        exit 1
    fi

    psql_training pagila <<'SQL'
CREATE TEMPORARY TABLE __sql_lab_pagila_access_check
(
    id integer PRIMARY KEY,
    value varchar(32) NOT NULL
);

INSERT INTO __sql_lab_pagila_access_check (id, value) VALUES (1, 'ok');
SELECT value FROM __sql_lab_pagila_access_check WHERE id = 1;
DROP TABLE __sql_lab_pagila_access_check;

BEGIN;
INSERT INTO public.actor (actor_id, first_name, last_name)
VALUES (-2147483648, 'SQL LAB', 'ACCESS CHECK')
RETURNING actor_id;
ROLLBACK;
SQL

    echo "Verified Pagila ownership, required populated tables, join read and reversible write access."
else
    echo "Optional PostgreSQL sample Pagila is not installed; skipped."
fi

chinook_exists=$(psql_training "${POSTGRES_DB}" --tuples-only --no-align \
    --command="SELECT EXISTS (SELECT FROM pg_catalog.pg_database WHERE datname = 'chinook');")
if [[ "${chinook_exists}" == "t" ]]; then
    chinook_database_is_owned=$(psql_training "${POSTGRES_DB}" --tuples-only --no-align \
        --command="SELECT pg_get_userbyid(datdba) = current_user FROM pg_catalog.pg_database WHERE datname = 'chinook';")
    if [[ "${chinook_database_is_owned}" != "t" ]]; then
        echo "ERROR: PostgreSQL database chinook is not owned by DB_USER" >&2
        exit 1
    fi

    chinook_key_table_count=$(psql_training chinook --tuples-only --no-align --command="
        SELECT COUNT(*)
        FROM pg_catalog.pg_class AS class
        JOIN pg_catalog.pg_namespace AS namespace ON namespace.oid = class.relnamespace
        WHERE namespace.nspname = 'public'
          AND class.relkind IN ('r', 'p')
          AND class.relname IN ('artist', 'album', 'track', 'customer', 'invoice');
    ")
    if [[ "${chinook_key_table_count}" != "5" ]]; then
        echo "ERROR: Chinook does not contain all required tables: artist, album, track, customer, invoice" >&2
        exit 1
    fi

    chinook_public_objects_owned=$(psql_training chinook --tuples-only --no-align --command="
        SELECT
            pg_catalog.pg_get_userbyid(namespace.nspowner) = current_user
            AND NOT EXISTS (
                SELECT
                FROM pg_catalog.pg_class AS class
                JOIN pg_catalog.pg_namespace AS object_namespace ON object_namespace.oid = class.relnamespace
                WHERE object_namespace.nspname = 'public'
                  AND class.relkind IN ('r', 'p', 'S', 'v', 'm', 'f')
                  AND pg_catalog.pg_get_userbyid(class.relowner) <> current_user
            )
            AND NOT EXISTS (
                SELECT
                FROM pg_catalog.pg_proc AS procedure
                JOIN pg_catalog.pg_namespace AS object_namespace ON object_namespace.oid = procedure.pronamespace
                WHERE object_namespace.nspname = 'public'
                  AND pg_catalog.pg_get_userbyid(procedure.proowner) <> current_user
            )
            AND NOT EXISTS (
                SELECT
                FROM pg_catalog.pg_type AS type
                JOIN pg_catalog.pg_namespace AS object_namespace ON object_namespace.oid = type.typnamespace
                WHERE object_namespace.nspname = 'public'
                  AND type.typtype IN ('c', 'd', 'e')
                  AND pg_catalog.pg_get_userbyid(type.typowner) <> current_user
            )
        FROM pg_catalog.pg_namespace AS namespace
        WHERE namespace.nspname = 'public';
    ")
    if [[ "${chinook_public_objects_owned}" != "t" ]]; then
        echo "ERROR: Chinook public schema or one or more objects are not owned by DB_USER" >&2
        exit 1
    fi

    chinook_key_tables_have_data=$(psql_training chinook --tuples-only --no-align --command="
        SELECT EXISTS (SELECT FROM public.artist)
           AND EXISTS (SELECT FROM public.album)
           AND EXISTS (SELECT FROM public.track)
           AND EXISTS (SELECT FROM public.customer)
           AND EXISTS (SELECT FROM public.invoice);
    ")
    if [[ "${chinook_key_tables_have_data}" != "t" ]]; then
        echo "ERROR: one or more required Chinook tables contain no data" >&2
        exit 1
    fi

    chinook_read_probe=$(psql_training chinook --tuples-only --no-align --command="
        SELECT artist.artist_id || ':' || album.album_id || ':' || track.track_id
        FROM public.artist AS artist
        JOIN public.album AS album USING (artist_id)
        JOIN public.track AS track USING (album_id)
        ORDER BY artist.artist_id, album.album_id, track.track_id
        LIMIT 1;
    ")
    if [[ -z "${chinook_read_probe}" ]]; then
        echo "ERROR: Chinook artist-album-track join returned no rows" >&2
        exit 1
    fi

    psql_training chinook <<'SQL'
CREATE TEMPORARY TABLE __sql_lab_chinook_access_check
(
    id integer PRIMARY KEY,
    value varchar(32) NOT NULL
);

INSERT INTO __sql_lab_chinook_access_check (id, value) VALUES (1, 'ok');
SELECT value FROM __sql_lab_chinook_access_check WHERE id = 1;
DROP TABLE __sql_lab_chinook_access_check;

BEGIN;
INSERT INTO public.artist (artist_id, name)
VALUES (-2147483648, 'SQL Lab access check')
RETURNING artist_id;
ROLLBACK;
SQL

    echo "Verified Chinook ownership, required populated tables, join read and reversible write access."
else
    echo "Optional PostgreSQL sample Chinook is not installed; skipped."
fi

echo "All PostgreSQL training-user access checks passed."
