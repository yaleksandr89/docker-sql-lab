<p align="center">
  <img
    src="../assets/docker-sql-lab-cover.png"
    alt="Docker SQL Lab — environnement local MySQL et PostgreSQL"
    width="100%"
  >
</p>

# Docker SQL Lab

## Choisissez une langue

| Русский | English | Español | 中文 | Français | Deutsch |
| --- | --- | --- | --- | --- | --- |
| [Русский](../../README.md) | [English](README_en.md) | [Español](README_es.md) | [中文](README_zh.md) | **Sélectionné** | [Deutsch](README_de.md) |

Un environnement Docker Compose local pour pratiquer SQL, découvrir et
comparer MySQL et PostgreSQL. Lancez chaque SGBD séparément ou les deux
ensemble. La petite base `demo` est créée automatiquement ; les datasets
optionnels Sakila, Pagila et Chinook offrent des données prêtes à interroger.
Activez Adminer uniquement au besoin.

## Stack et versions épinglées

- MySQL 9.7.1 LTS
- PostgreSQL 18.4
- Adminer 5.4.2 Docker Official Image
- Docker Compose v2
- GNU Make et Bash pour les commandes et scripts d'initialisation

Les valeurs par défaut épinglées sont définies dans
[`.docker.env.example`](../../.docker.env.example) ; `make init` crée à partir
de ce fichier le `.docker.env` local. Les services sont définis dans
[`docker-compose.yml`](../../docker-compose.yml).

<details>
<summary>⚠️ Important : environnement de formation</summary>

Ce projet n'est pas un template prêt pour la production. Un usage externe
nécessite des choix dédiés pour les identifiants, l'exposition réseau, le
stockage, les sauvegardes et l'exploitation.

</details>

## Fonctionnalités principales

- MySQL et PostgreSQL fonctionnent séparément ou ensemble.
- Chaque SGBD possède une base `demo` obligatoire avec les mêmes seed rows.
- MySQL propose Sakila et Chinook en option ; PostgreSQL, Pagila et Chinook.
- Adminer est une interface optionnelle et indépendante pour les deux SGBD.
- Données, init et samples ont des bind mounts distincts pour chaque SGBD.
- Contrôles, imports SQL de confiance et actions destructives sont regroupés
  dans le [`Makefile`](../../Makefile).

## Prérequis

1. Docker Engine ou Docker Desktop avec `docker compose` v2.
2. GNU Make, Bash et les utilitaires Unix CLI de base utilisés par les scripts.

Environnements conseillés : Linux ; macOS avec Docker Desktop ; Windows avec
Docker Desktop et WSL2. Exécutez les commandes depuis la racine du dépôt. La
branche par défaut du projet est `master`.

## Démarrage rapide

```bash
make init
make up
```

`make init` crée le `.docker.env` local depuis
[`.docker.env.example`](../../.docker.env.example), valide les chemins gérés et
crée les répertoires de travail. Au premier démarrage, les entrypoints officiels
initialisent les deux SGBD. Sans samples optionnels, MySQL et PostgreSQL restent
opérationnels avec `demo` et ses seed rows.

`make up` lance MySQL, PostgreSQL et Adminer ; `make up-no-ui` lance les deux
SGBD sans Adminer. Par défaut, Adminer répond sur `http://127.0.0.1:8081`.

Modes, connexions et identifiants :
[Prise en main](fr/getting-started.md).

### Besoin de données d'entraînement prêtes à l'emploi ?

Les samples sont optionnels : `demo` est toujours créée ; Sakila et Chinook sont proposés pour MySQL, Pagila et Chinook pour PostgreSQL.

**Premier démarrage avec data vide**

```bash
make init
make samples-mysql
make samples-postgres
make up
```

Préparez les samples avant la première initialisation ; les entrypoints les chargeront avec `demo`.

> **Attention :** si un répertoire data a été initialisé sans samples, leur ajout exige un backup et une réinitialisation destructive confirmée.

<details>
<summary>📦 Le laboratoire a déjà démarré : ajouter ou réutiliser les samples</summary>

**Déjà initialisé sans samples.** `make up` n'applique pas les nouveaux fichiers init/sample. Sauvegardez les données importantes, puis choisissez l'option adaptée :

- MySQL : `make samples-mysql`, puis `make reinit-mysql CONFIRM=1`.
- PostgreSQL : `make samples-postgres`, puis `make reinit-postgres CONFIRM=1`.
- Les deux SGBD : `make samples-mysql`, `make samples-postgres`, puis `make reinit-all CONFIRM=1`.

> **Attention :** `reinit-*` supprime les données sélectionnées et exige exactement `CONFIRM=1`.

**Samples déjà installés.** Utilisez `make up` ou le `make up-*` choisi : aucun nouveau download ni reinit ; les bases persistent dans le stockage bind-mounted.

</details>

Détails : [Bases et samples](fr/databases.md).

## Modes de démarrage

| Commande | MySQL | PostgreSQL | Adminer |
|---|---|---|---|
| `make up` | Lance | Lance | Lance |
| `make up-no-ui` | Lance | Lance | Arrête |
| `make up-mysql` | Lance | Ne lance pas | Ne lance pas |
| `make up-postgres` | Ne lance pas | Lance | Ne lance pas |

Une commande mono-SGBD n'arrête pas l'autre ; Adminer se gère séparément. La
liste complète figure dans le [`Makefile`](../../Makefile).

## Connexions et bases disponibles

Dans le réseau Compose, Adminer utilise `mysql` et `postgres`. Les clients de
l'hôte utilisent `127.0.0.1` et `MYSQL_PORT` ou `POSTGRES_PORT`. Pour les
exercices, utilisez `DB_USER` et `DB_PASSWORD`.

| SGBD | Toujours disponible | Après initialisation des samples |
|---|---|---|
| MySQL | `demo` | `sakila`, `chinook` |
| PostgreSQL | `demo` | `pagila`, `chinook` |

Les bases optionnelles n'existent qu'après leur initialisation effective.
Détails : [démarrage et connexions](fr/getting-started.md) ·
[bases et samples](fr/databases.md).

## Identifiants en bref

| Usage | Utilisateur | Mot de passe |
|---|---|---|
| Utilisateur de formation commun | `DB_USER` | `DB_PASSWORD` |
| Administrateur MySQL | `root` | `MYSQL_ROOT_PASSWORD` |
| Superuser PostgreSQL | `POSTGRES_SUPERUSER` | `POSTGRES_SUPERUSER_PASSWORD` |

`POSTGRES_SUPERUSER` et `DB_USER` doivent être distincts. Utilisez le compte de
formation et remplacez les mots de passe d'exemple avant toute publication.

## Bases et contrôles essentiels

Les deux `demo` contiennent une table `demo_users` équivalente de cinq lignes.
Ces contrôles ne nécessitent aucun SGBD lancé :

```bash
make check-env
make config
make test-storage-paths
```

Après démarrage, `make check` vérifie `demo` et l'accès de `DB_USER` ;
`make test-sql-imports` teste les imports publics de confiance. Ordre et
limites : [Contrôles et opérations](fr/operations.md).

## Sécurité et cycle de vie

- `BIND_ADDRESS=127.0.0.1` publie uniquement sur loopback.
- `BIND_ADDRESS=0.0.0.0` expose toutes les interfaces ; configurez d'abord
  firewall, identifiants robustes et réseau de confiance.
- Les entrypoints officiels exécutent init uniquement sur des données vides.
- `make mysql-import` et `make postgres-import` n'acceptent que du SQL de
  confiance. Ce n'est pas un sandbox : une exécution partielle sans rollback
  automatique complet reste possible.
  Avant un import important, vérifiez le fichier SQL et créez un backup adapté.
- `make dump` et `make restore` couvrent seulement `demo` MySQL ; aucun target
  de backup PostgreSQL n'est intégré.
- Tout `clean-*` et `reinit-*` est destructif et exige exactement `CONFIRM=1`.

Séquences sûres : [Contrôles et opérations](fr/operations.md). En cas d'échec,
collectez d'abord le diagnostic :
[Diagnostic et dépannage](fr/troubleshooting.md).

## Licences des données d'entraînement

Les datasets optionnels conservent les licences et notices de leurs projets
upstream. Provenance, révisions épinglées, intégrité et textes figurent dans
[`THIRD_PARTY_NOTICES.md`](../../THIRD_PARTY_NOTICES.md).

<p align="center">
  <a href="https://yaleksandr89.github.io/" title="yaleksandr89.github.io">
    <img
      src="../assets/ya-logo-dark-50px.png"
      alt="YA"
      width="32"
    >
  </a>
  <br>
  <a href="https://yaleksandr89.github.io/">yaleksandr89.github.io</a>
</p>
