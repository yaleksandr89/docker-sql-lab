# Bases et samples

[← Retour au README](../README_fr.md)

## Langue

| Русский | English | Español | 中文 | Français | Deutsch |
| --- | --- | --- | --- | --- | --- |
| [Русский](../ru/databases.md) | [English](../en/databases.md) | [Español](../es/databases.md) | [中文](../zh/databases.md) | **Sélectionné** | [Deutsch](../de/databases.md) |

## Section

| Prise en main | Bases et samples | Contrôles et opérations | Diagnostic et dépannage |
| --- | --- | --- | --- |
| [Prise en main](getting-started.md) | **Sélectionné** | [Contrôles et opérations](operations.md) | [Diagnostic et dépannage](troubleshooting.md) |

<a id="section-demo"></a>
## Bases `demo` obligatoires

Les deux SGBD initialisent `demo` :

- MySQL : `demo.demo_users`
- PostgreSQL : `demo.public.demo_users`

Les tables ont les champs équivalents `id`, `name`, `email` et `created_at`,
avec Alice, Bob, Carol, Dave et Eve. Les contrôles acceptent des lignes
supplémentaires. `make check-env` impose `MYSQL_DATABASE=demo` et
`POSTGRES_DATABASE=demo`.

<a id="section-optional-samples"></a>
## Samples optionnels

| SGBD | Bases optionnelles | Préparation |
|---|---|---|
| MySQL | `chinook`, `sakila` | `make samples-mysql` |
| PostgreSQL | `pagila`, `chinook` | `make samples-postgres` |

<a id="section-sample-preparation"></a>
## Préparation des samples

La préparation demande `curl` et `git` ; les samples MySQL exigent aussi `unzip` et `sha256sum`.

La préparation télécharge et vérifie des fichiers upstream épinglés, sans
démarrer les conteneurs ni importer dans une base déjà initialisée. Les
téléchargements temporaires restent locaux, ne sont pas commités et sont
placés sous `MYSQL_SAMPLES_DIR` ou `POSTGRES_SAMPLES_DIR`. Provenance,
intégrité et licences figurent dans
[`THIRD_PARTY_NOTICES.md`](../../../THIRD_PARTY_NOTICES.md).

Consultez [Initialisation et cycle de vie](#section-initialization) pour le
moment de la préparation et la réinitialisation d’un SGBD existant.

Un sample totalement absent est ignoré et n’empêche pas la création de `demo`.
Un ensemble incomplet ou une base inattendue est refusé, sans réparation ni
suppression automatique.

<a id="section-storage-layout"></a>
## Organisation du stockage

```text
data/
├── mysql/
└── postgres/

initdb/
├── mysql/
└── postgres/
```

| SGBD | Data | Init | Samples optionnels |
|---|---|---|---|
| MySQL | `MYSQL_DATA_DIR` (`./data/mysql`) | `MYSQL_INITDB_DIR` (`./initdb/mysql`) | `MYSQL_SAMPLES_DIR` (`./samples/mysql`) |
| PostgreSQL | `POSTGRES_DATA_DIR` (`./data/postgres`) | `POSTGRES_INITDB_DIR` (`./initdb/postgres`) | `POSTGRES_SAMPLES_DIR` (`./samples/postgres`) |

Les chemins data et samples se configurent dans `.docker.env` sous contrôle
des managed paths. Les règles des répertoires init sont décrites dans
[Initialisation et cycle de vie](#section-initialization). Ne modifiez pas
manuellement les fichiers de `data/` : ils peuvent appartenir à des UID/GID
numériques du conteneur.

<a id="section-initialization"></a>
## Initialisation et cycle de vie

> **Important :** Les entrypoints officiels MySQL et PostgreSQL n’exécutent
> init que si le data directory est vide. Ajouter des fichiers après
> l’initialisation ne modifie pas une base existante. `make down` conserve les
> données, tandis qu’une réinitialisation confirmée supprime les données
> actuelles du SGBD choisi et recrée les bases depuis les scripts init actuels.
> Sauvegardez uniquement les données personnelles à conserver ; un lab ponctuel sans changement précieux ne l’exige pas.

Pour une première initialisation avec samples, préparez-les avant le premier
démarrage :

```bash
make samples-mysql
make up-mysql

make samples-postgres
make up-postgres
```

Pour un SGBD déjà initialisé, conservez les données personnelles si nécessaire,
puis utilisez uniquement sa réinitialisation confirmée correspondante :

```bash
make samples-mysql
make reinit-mysql CONFIRM=1

make samples-postgres
make reinit-postgres CONFIRM=1
```

<a id="section-training-access"></a>
## Accès pédagogique et ownership

MySQL crée `DB_USER` et lui accorde l’accès à toutes les bases non
système trouvées pendant init. PostgreSQL crée un `DB_USER` distinct, sans
superuser/createdb/createrole, et le rend propriétaire de `demo`, du schéma
`public` et des objets sample. Les credentials administratifs restent
séparés : `MYSQL_ROOT_PASSWORD`, `POSTGRES_SUPERUSER` et
`POSTGRES_SUPERUSER_PASSWORD`. Ne modifiez pas manuellement les fichiers de
`data/` appartenant aux conteneurs.

[Retour au README](../README_fr.md)
