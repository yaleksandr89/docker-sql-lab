#!/usr/bin/env bash
set -Eeuo pipefail

: "${MYSQL_ROOT_PASSWORD:?environment variable MYSQL_ROOT_PASSWORD is required}"

samples_dir=/opt/mysql-samples
chinook_file="${samples_dir}/010_chinook.sql"
sakila_schema_file="${samples_dir}/020_sakila_schema.sql"
sakila_data_file="${samples_dir}/021_sakila_data.sql"

mysql_root() {
    MYSQL_PWD="${MYSQL_ROOT_PASSWORD}" mysql \
        --protocol=socket \
        --user=root \
        --batch \
        --skip-column-names \
        "$@"
}

if [[ ! -d "${samples_dir}" ]]; then
    echo "Optional MySQL samples directory is not mounted; skipping Chinook and Sakila."
    exit 0
fi

chinook_is_complete() {
    local key_table_count key_tables_have_data join_has_data

    key_table_count=$(mysql_root --execute="
        SELECT COUNT(*)
        FROM information_schema.tables
        WHERE table_schema = 'chinook'
          AND table_type = 'BASE TABLE'
          AND BINARY table_name IN ('Artist', 'Album', 'Track', 'Customer', 'Invoice');
    ")
    [[ "${key_table_count}" == "5" ]] || return 1

    key_tables_have_data=$(mysql_root --execute="
        SELECT EXISTS (SELECT 1 FROM chinook.Artist)
           AND EXISTS (SELECT 1 FROM chinook.Album)
           AND EXISTS (SELECT 1 FROM chinook.Track)
           AND EXISTS (SELECT 1 FROM chinook.Customer)
           AND EXISTS (SELECT 1 FROM chinook.Invoice);
    ")
    [[ "${key_tables_have_data}" == "1" ]] || return 1

    join_has_data=$(mysql_root --execute="
        SELECT EXISTS (
            SELECT 1
            FROM chinook.Artist AS artist
            JOIN chinook.Album AS album ON album.ArtistId = artist.ArtistId
            JOIN chinook.Track AS track ON track.AlbumId = album.AlbumId
        );
    ")
    [[ "${join_has_data}" == "1" ]]
}

chinook_file_has_database_setup() {
    awk '
        BEGIN { in_comment = 0; found = 0 }
        { upper = toupper($0) }
        /^[[:space:]]*\/\*/ { in_comment = 1 }
        !in_comment && upper ~ /^[[:space:]]*((DROP|CREATE)[[:space:]]+DATABASE|USE[[:space:]])/ { found = 1 }
        /\*\// { in_comment = 0 }
        END { exit(found ? 0 : 1) }
    ' "${chinook_file}"
}

if [[ -f "${chinook_file}" ]]; then
    if chinook_file_has_database_setup; then
        echo "ERROR: prepared Chinook MySQL SQL contains forbidden database-level statements" >&2
        exit 1
    fi

    chinook_exists=$(mysql_root --execute="
        SELECT COUNT(*)
        FROM information_schema.schemata
        WHERE schema_name = 'chinook';
    ")

    if [[ "${chinook_exists}" == "1" ]]; then
        if chinook_is_complete; then
            echo "Optional MySQL sample Chinook is already complete; skipping reload."
        else
            echo "ERROR: database chinook already exists but is incomplete or unexpected" >&2
            echo "Recreate MySQL explicitly with: make reinit-mysql CONFIRM=1" >&2
            exit 1
        fi
    else
        echo "Creating optional MySQL database chinook..."
        mysql_root --execute='CREATE DATABASE `chinook` CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;'
        echo "Loading optional MySQL sample: Chinook..."
        mysql_root --database=chinook < "${chinook_file}"
        if ! chinook_is_complete; then
            echo "ERROR: Chinook load finished but required tables, data, or join verification failed" >&2
            exit 1
        fi
        echo "Loaded and verified optional MySQL sample Chinook."
    fi
else
    echo "Optional MySQL sample Chinook is not present; skipping it."
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
