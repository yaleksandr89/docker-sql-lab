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
| `make up-no-ui` | Démarre | Démarre | Arrête |
| `make up-mysql` | Démarre | Ne démarre pas | Ne démarre pas |
| `make up-postgres` | Ne démarre pas | Démarre | Ne démarre pas |

Les commandes d’un SGBD n’arrêtent pas l’autre déjà actif ; Adminer se gère séparément.

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

## Identifiants en bref

| Usage | Utilisateur | Mot de passe |
|---|---|---|
| Utilisateur pédagogique commun | `DB_USER` | `DB_PASSWORD` |
| Administrateur MySQL | `root` | `MYSQL_ROOT_PASSWORD` |
| Superutilisateur PostgreSQL | `POSTGRES_SUPERUSER` | `POSTGRES_SUPERUSER_PASSWORD` |

`POSTGRES_SUPERUSER` et `DB_USER` doivent être des rôles distincts. Utilisez l’utilisateur pédagogique commun pour les exercices et remplacez les mots de passe d’exemple avant toute publication.

## Bases et contrôles essentiels

Les deux SGBD créent la base obligatoire `demo` avec une table `demo_users` équivalente. Les samples optionnels sont Chinook et Sakila pour MySQL, Pagila et Chinook pour PostgreSQL. Leur préparation ne les importe pas dans des données déjà initialisées.

Ces contrôles statiques ne demandent aucun SGBD actif :

```bash
make check-env
make config
make test-storage-paths
```

Après le démarrage des deux SGBD, `make check` vérifie l’accès de `DB_USER` et `make test-sql-imports` exerce les targets publics d’import de confiance. Les pages détaillées couvrent commandes, limites et ordre opératoire sûr.

Les répertoires data, init et samples de MySQL et PostgreSQL restent séparés et se configurent via `.docker.env`. Le validateur de managed paths refuse toute sortie de `data/` ou `samples/`, composant symlink, chevauchement ou répertoire réservé. Un sample totalement absent est ignoré ; un ensemble partiel ou une base inattendue est refusé sans réparation automatique.

La préparation télécharge des fichiers upstream épinglés, vérifie leur intégrité et les conserve localement ; provenance et licences figurent dans `THIRD_PARTY_NOTICES.md`. Les contrôles runtime vérifient aussi les lignes obligatoires de `demo`, l’accès lecture/écriture pédagogique et les samples installés.

## Sécurité et cycle de vie

- `BIND_ADDRESS=127.0.0.1` ne publie les services que sur loopback.
- `BIND_ADDRESS=0.0.0.0` les publie sur toutes les interfaces ; configurez
  volontairement firewall, credentials robustes et confiance réseau.
- Les entrypoints officiels n’exécutent init que pour un data directory vide.
- `make mysql-import` et `make postgres-import` n’acceptent que du SQL de
  confiance. Ils ne créent pas de sandbox : une exécution partielle est
  possible sans rollback automatique complet. Faites un backup auparavant.
- `make dump` et `make restore` couvrent uniquement MySQL `demo` ; aucun
  target de backup PostgreSQL n’est intégré.
- Tous les targets `clean-*` et `reinit-*` sont destructifs et exigent
  exactement `CONFIRM=1`.

## Documentation

- [Bien démarrer](fr/getting-started.md)
- [Bases et samples](fr/databases.md)
- [Contrôles et opérations](fr/operations.md)
- [Diagnostic et dépannage](fr/troubleshooting.md)

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
