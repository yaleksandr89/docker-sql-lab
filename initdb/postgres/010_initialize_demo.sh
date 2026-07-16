#!/usr/bin/env bash
set -Eeuo pipefail

required_variables=(POSTGRES_USER POSTGRES_DB DB_USER)
for variable_name in "${required_variables[@]}"; do
    if [[ -z "${!variable_name:-}" ]]; then
        echo "ERROR: environment variable ${variable_name} is required" >&2
        exit 1
    fi
done

psql \
    --username="${POSTGRES_USER}" \
    --dbname="${POSTGRES_DB}" \
    --set=ON_ERROR_STOP=1 \
    --set=db_user="${DB_USER}" <<'SQL'
SET ROLE :"db_user";

CREATE TABLE IF NOT EXISTS public.demo_users
(
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name varchar(100) NOT NULL,
    email varchar(150) NOT NULL UNIQUE,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO public.demo_users (name, email, created_at)
VALUES ('Alice', 'alice@example.com', '2025-01-10 09:00:00+03'),
       ('Bob', 'bob@example.com', '2025-01-11 10:15:00+03'),
       ('Carol', 'carol@example.com', '2025-01-12 11:30:00+03'),
       ('Dave', 'dave@example.com', '2025-01-13 12:45:00+03'),
       ('Eve', 'eve@example.com', '2025-01-14 14:00:00+03')
ON CONFLICT (email) DO UPDATE
SET name = EXCLUDED.name,
    created_at = EXCLUDED.created_at;
SQL

echo "PostgreSQL demo table and rows initialized as ${DB_USER}."
