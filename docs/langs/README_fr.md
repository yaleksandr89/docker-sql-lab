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

Environnement local fondé sur Docker Compose pour apprendre et comparer MySQL
et PostgreSQL. Chaque SGBD peut fonctionner seul, les deux peuvent fonctionner
ensemble et Adminer ne s’ajoute que lorsqu’une interface web est utile.

## Stack et versions épinglées

- MySQL 9.7.1 LTS
- PostgreSQL 18.4
- Adminer 5.4.2 Docker Official Image
- Docker Compose v2
- GNU Make et Bash pour les commandes et scripts d’initialisation

Les versions d’images sont épinglées dans `.docker.env`. N’utilisez pas ce
laboratoire comme modèle de production sans réévaluer les identifiants,
l’exposition réseau, le stockage, les sauvegardes et l’exploitation.

## Fonctionnalités principales

- Services MySQL et PostgreSQL indépendants, utilisables aussi simultanément.
- Adminer optionnel, commun aux deux SGBD et sans dépendance à l’un d’eux.
- Base `demo` obligatoire dans chaque SGBD avec les mêmes cinq utilisateurs.
- Samples optionnels : Sakila et Chinook pour MySQL, Pagila et Chinook pour PostgreSQL.
- Répertoires bind-mounted data, init et samples séparés par SGBD.
- Identifiants pédagogiques communs et identifiants administratifs distincts.
- Contrôles statiques, protection des managed storage paths, contrôles runtime
  et smoke-test des imports SQL de confiance.
- Confirmation explicite des opérations destructives de nettoyage et réinitialisation.

## Prérequis

- Docker Engine ou Docker Desktop avec la commande `docker compose` v2.
- GNU Make, Bash et les outils Unix utilisés par les scripts (`awk`, `sed`,
  `grep`, `find`, `realpath` et `stat`).
- Pour les samples optionnels : `curl` et `git` ; MySQL demande aussi `unzip`
  et `sha256sum`.

Exécutez les commandes depuis la racine du dépôt. La branche par défaut du
projet est `master`.

## Démarrage rapide

Créez `.docker.env` depuis l’exemple suivi par Git, validez les chemins, créez
les répertoires de travail et démarrez le laboratoire complet :

```bash
make init
make up
```

`make up` démarre MySQL, PostgreSQL et Adminer. Avec la configuration par
défaut, Adminer est disponible sur `http://127.0.0.1:8081`.

```bash
make status
make logs
make down
```

`make down` supprime les conteneurs et le réseau, mais conserve les données
bind-mounted.

## Modes de démarrage

| Commande | MySQL | PostgreSQL | Adminer |
|---|---|---|---|
| `make up` | Démarre | Démarre | Démarre |
| `make up-no-ui` | Démarre ou laisse actif | Démarre ou laisse actif | Arrête s’il est actif |
| `make up-mysql` | Démarre | Ne démarre pas automatiquement | Ne démarre pas automatiquement |
| `make up-mysql-ui` | Démarre | Ne démarre pas automatiquement | Démarre |
| `make up-postgres` | Ne démarre pas automatiquement | Démarre | Ne démarre pas automatiquement |
| `make up-postgres-ui` | Ne démarre pas automatiquement | Démarre | Démarre |
| `make up-ui` | Ne change rien | Ne change rien | Démarre |
| `make down-ui` | Ne change rien | Ne change rien | Arrête |

Les commandes dédiées à un SGBD n’arrêtent pas l’autre s’il fonctionne déjà.
Adminer se démarre et s’arrête séparément et n’est pas lié uniquement à MySQL.

## Connexions

### Adminer

Dans le réseau Compose, Adminer propose deux serveurs prédéfinis :

```text
MySQL (mysql)
PostgreSQL (postgres)
```

Choisissez un serveur, puis saisissez `DB_USER`, `DB_PASSWORD` et une base telle
que `demo`. `mysql` et `postgres` sont des noms internes au réseau Compose, pas
des noms d’hôte pour les clients desktop.

### Clients sur l’hôte

| SGBD | Hôte par défaut | Variable de port | Utilisateur | Base par défaut |
|---|---|---|---|---|
| MySQL | `127.0.0.1` | `MYSQL_PORT` | `DB_USER` | `demo` |
| PostgreSQL | `127.0.0.1` | `POSTGRES_PORT` | `DB_USER` | `demo` |

DataGrip, DBeaver, PhpStorm et les CLI de l’hôte utilisent l’adresse et le port
publiés. Si `BIND_ADDRESS` change, utilisez l’adresse joignable de l’interface.

### CLI dans les conteneurs

Les mots de passe passent par l’environnement du conteneur et non par
l’historique du shell :

```bash
make mysql          # administrateur MySQL, base demo
make mysql-user     # DB_USER, base demo
make postgres       # superutilisateur PostgreSQL, base demo
make postgres-user  # DB_USER, base demo
```

## Identifiants

`.docker.env` est créé depuis `.docker.env.example` et ignoré par Git. Gardez
les mots de passe dans ce fichier ; ne les codez pas en dur dans Compose, SQL
ou une configuration client versionnée.

| Usage | Utilisateur | Mot de passe |
|---|---|---|
| Utilisateur pédagogique commun | `DB_USER` | `DB_PASSWORD` |
| Administrateur MySQL | `root` | `MYSQL_ROOT_PASSWORD` |
| Administrateur/superutilisateur PostgreSQL | `POSTGRES_SUPERUSER` | `POSTGRES_SUPERUSER_PASSWORD` |

`POSTGRES_SUPERUSER` et `DB_USER` doivent être deux rôles différents. Utilisez
le compte pédagogique pour les exercices courants. Remplacez les mots de passe
d’exemple avant tout partage ou toute publication de service.

## Ports et `BIND_ADDRESS`

| Service | Variable | Valeur d’exemple |
|---|---|---|
| MySQL | `MYSQL_PORT` | `3306` |
| PostgreSQL | `POSTGRES_PORT` | `5432` |
| Adminer | `ADMINER_PORT` | `8081` |

Par défaut, les trois services ne sont publiés que sur loopback :

```env
BIND_ADDRESS=127.0.0.1
```

`127.0.0.1` est la valeur locale par défaut. `BIND_ADDRESS=0.0.0.0` publie les
ports sur toutes les interfaces. Pour un LAN ou VPN, préférez l’adresse d’une
interface précise. Ce changement doit être volontaire et tenir compte du
firewall, de la robustesse des mots de passe et de la confiance accordée au réseau.

## Bases pédagogiques

### Bases `demo` obligatoires

Les deux SGBD initialisent `demo` :

- MySQL : `demo.demo_users`
- PostgreSQL : `demo.public.demo_users`

Les tables ont les champs équivalents `id`, `name`, `email` et `created_at`,
avec Alice, Bob, Carol, Dave et Eve. Les contrôles acceptent des lignes
supplémentaires. `make check-env` impose `MYSQL_DATABASE=demo` et
`POSTGRES_DATABASE=demo`.

### Samples optionnels

| SGBD | Bases optionnelles | Préparation |
|---|---|---|
| MySQL | Chinook, Sakila | `make samples-mysql` |
| PostgreSQL | Pagila, Chinook | `make samples-postgres` |

La préparation télécharge et vérifie des fichiers upstream épinglés, sans
démarrer les conteneurs ni importer dans une base déjà initialisée. Les
téléchargements temporaires restent locaux, ne sont pas commités et sont
placés sous `MYSQL_SAMPLES_DIR` ou `POSTGRES_SAMPLES_DIR`. Provenance,
intégrité et licences figurent dans
[THIRD_PARTY_NOTICES.md](../../THIRD_PARTY_NOTICES.md).

Pour un répertoire data vide :

```bash
make samples-mysql
make up-mysql

make samples-postgres
make up-postgres
```

Les entrypoints officiels ne traitent init que si le répertoire data est vide.
Pour ajouter des samples à une instance existante, sauvegardez puis
réinitialisez volontairement uniquement le SGBD concerné :

```bash
make samples-mysql
make reinit-mysql CONFIRM=1

make samples-postgres
make reinit-postgres CONFIRM=1
```

Un sample totalement absent est ignoré et n’empêche pas la création de `demo`.
Un ensemble incomplet ou une base inattendue est refusé, sans réparation ni
suppression automatique.

## Targets Make publics

`make help` affiche la liste concise.

| Commande | Rôle |
|---|---|
| `make init` | Créer `.docker.env`, valider les chemins et créer les répertoires |
| `make check-env` | Vérifier env, rôles, noms de bases et managed paths |
| `make pull` | Télécharger les trois images épinglées |
| `make config` | Valider la configuration Compose développée |
| `make up`, `make up-no-ui` | Démarrer les deux SGBD avec ou sans Adminer |
| `make up-mysql`, `make up-mysql-ui` | Démarrer MySQL, avec Adminer en option |
| `make up-postgres`, `make up-postgres-ui` | Démarrer PostgreSQL, avec Adminer en option |
| `make up-ui`, `make down-ui` | Démarrer ou arrêter seulement Adminer |
| `make down` | Arrêter sans supprimer les données bind-mounted |
| `make status`, `make logs` | Afficher l’état ou suivre tous les logs |
| `make log SERVICE=postgres` | Suivre un service ; `make log postgres` fonctionne aussi |
| `make in SERVICE=postgres` | Ouvrir un shell ; `make in postgres` fonctionne aussi |
| `make mysql`, `make mysql-user` | Ouvrir MySQL comme admin ou `DB_USER` |
| `make postgres`, `make postgres-user` | Ouvrir PostgreSQL comme superutilisateur ou `DB_USER` |
| `make samples-mysql`, `make samples-postgres` | Préparer les samples vérifiés |
| `make check-mysql-access`, `make check-postgres-access` | Contrôler un SGBD actif |
| `make check` | Valider Compose et l’accès `DB_USER` aux deux SGBD |
| `make test-storage-paths` | Tester les managed paths sans Docker runtime |
| `make test-sql-imports` | Smoke-test des deux imports SQL publics |
| `make mysql-import FILE=... DATABASE=...` | Importer du plain SQL dans MySQL comme `DB_USER` |
| `make postgres-import FILE=... DATABASE=...` | Importer du plain SQL dans PostgreSQL comme `DB_USER` |
| `make dump`, `make restore` | Sauvegarder ou restaurer `demo` dans MySQL |
| `make clean-{mysql,postgres,all} CONFIRM=1` | Supprimer les data directories choisis |
| `make reinit-{mysql,postgres,all} CONFIRM=1` | Supprimer, recréer et contrôler les bases |

## Contrôles

### Contrôles statiques et locaux

```bash
make check-env
make config
make test-storage-paths
```

`make check-env` crée `.docker.env` s’il manque, puis valide valeurs et chemins.
`make config` valide le modèle Compose développé. `make test-storage-paths` ne
demande pas de Docker runtime : il teste les sorties du projet, composants
symlink, chemins qui se chevauchent ou s’imbriquent et répertoires réservés.

### Contrôles runtime

```bash
make up-no-ui
make check
make test-sql-imports
make down
```

`make check` valide `demo` et l’accès réel de `DB_USER` aux deux SGBD, ainsi que
les samples installés. `make test-sql-imports` exige que les deux SGBD soient
actifs ; il appelle `mysql-import` et `postgres-import`, crée des tables
temporaires aux noms uniques dans `demo`, vérifie les marker rows comme
`DB_USER` puis ne supprime que ces tables. C’est un smoke-test du flux trusted
import, ni un sandbox ni une preuve de sécurité pour du SQL non fiable.

## Imports SQL de confiance

```bash
make mysql-import FILE=path/to/file.sql DATABASE=demo
make postgres-import FILE=path/to/file.sql DATABASE=demo
```

Pour les deux targets :

- `FILE` et `DATABASE` sont obligatoires.
- Le fichier local plain SQL doit exister, être lisible et non vide.
- La base doit déjà exister ; les bases système sont interdites.
- L’import s’exécute comme `DB_USER`, sans créer de base ni accorder de grants.
- `DATABASE` choisit la connexion initiale, mais ne crée pas de sandbox.
- Les qualified names, commandes client/session et grants effectifs peuvent
  atteindre d’autres objets accessibles.
- Une exécution partielle est possible ; aucun rollback automatique n’est promis.
- Effectuez une sauvegarde avant un import important.
- gzip, archives et backups PostgreSQL custom-format ne sont pas pris en charge.

## Cycle de vie data/init

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
des managed paths. Les entrypoints exécutent init uniquement avec un data
directory vide ; modifier init ne migre pas une base existante. `make down` ne
supprime aucun bind mount. Ne modifiez pas manuellement les fichiers de
`data/` : ils peuvent appartenir à des UID/GID numériques du conteneur.

## Sauvegarde, nettoyage et réinitialisation

Les targets intégrés couvrent uniquement la base MySQL `demo` configurée :

```bash
make dump
make restore
```

`make dump` écrit `backup/demo.sql` ; `make restore` le lit et réapplique les
grants pédagogiques MySQL. Utilisez une procédure distincte pour PostgreSQL.

> **Attention :** tous les targets `clean-*` et `reinit-*` sont destructifs et
> exigent la confirmation exacte `CONFIRM=1`.

```bash
make clean-mysql CONFIRM=1
make clean-postgres CONFIRM=1
make clean-all CONFIRM=1

make reinit-mysql CONFIRM=1
make reinit-postgres CONFIRM=1
make reinit-all CONFIRM=1
```

Les commandes unitaires ne suppriment que les données du SGBD choisi ; `all`
supprime celles des deux. Configuration, init, samples et backups restent en
place. La réinitialisation redémarre et contrôle les SGBD choisis ;
`reinit-all` démarre les deux sans Adminer.

## Diagnostic et dépannage

### Échec de configuration ou de validation des chemins

Lancez `make check-env`. Les data paths doivent rester strictement sous
`data/` et les samples sous `samples/` ; aucun symlink, chevauchement ou
répertoire réservé n’est admis. Corrigez `.docker.env` puis lancez `make config`.

### Un service n’est pas prêt

```bash
make status
make log SERVICE=mysql
make log SERVICE=postgres
```

Vérifiez Docker, le port, `.docker.env` et les logs avant de toucher aux données.

### Les changements init ou les samples n’apparaissent pas

C’est normal si data est déjà initialisé. Vérifiez chemins et préparation,
sauvegardez les données importantes et n’utilisez `reinit-... CONFIRM=1` qu’en
dernier recours volontaire.

### Sample incomplet ou propriétaire inattendu

Le loader ne remplace ni ne répare une base inattendue. Relancez
`make samples-mysql` ou `make samples-postgres` et inspectez l’erreur ;
préservez les données avant toute réinitialisation.

### Un client ne se connecte pas

Les clients hôtes utilisent l’adresse publiée et `MYSQL_PORT` ou
`POSTGRES_PORT` ; Adminer utilise `mysql` ou `postgres` dans Compose. Vérifiez
`BIND_ADDRESS`, firewall, base sélectionnée et identifiants `DB_USER`.

## Licences et mentions de tiers

Docker SQL Lab est sous licence MIT : [LICENSE.md](../../LICENSE.md). Les
samples conservent leurs licences upstream ; sources, révisions épinglées,
intégrité et textes figurent dans
[THIRD_PARTY_NOTICES.md](../../THIRD_PARTY_NOTICES.md).

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
