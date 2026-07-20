# Prise en main

[← Retour au README](../README_fr.md)

## Langue

| Русский | English | Español | 中文 | Français | Deutsch |
| --- | --- | --- | --- | --- | --- |
| [Русский](../ru/getting-started.md) | [English](../en/getting-started.md) | [Español](../es/getting-started.md) | [中文](../zh/getting-started.md) | **Sélectionné** | [Deutsch](../de/getting-started.md) |

## Section

| Prise en main | Bases et samples | Contrôles et opérations | Diagnostic et dépannage |
| --- | --- | --- | --- |
| **Sélectionné** | [Bases et samples](databases.md) | [Contrôles et opérations](operations.md) | [Diagnostic et dépannage](troubleshooting.md) |

<a id="section-requirements"></a>
## Prérequis

- Docker Engine ou Docker Desktop avec la commande `docker compose` v2.
- GNU Make, Bash et les outils Unix utilisés par les scripts (`awk`, `sed`,
  `grep`, `find`, `realpath` et `stat`).
- Pour les samples optionnels : `curl` et `git` ; MySQL demande aussi `unzip`
  et `sha256sum`.

Exécutez les commandes depuis la racine du dépôt. La branche par défaut du
projet est `master`.

<a id="section-quick-start"></a>
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

<a id="section-startup-modes"></a>
## Modes de démarrage

| Commande | MySQL | PostgreSQL | Adminer |
|---|---|---|---|
| `make up` | Démarre | Démarre | Démarre |
| `make up-no-ui` | Démarre | Démarre | Arrête |
| `make up-mysql` | Démarre | Ne démarre pas | Ne démarre pas |
| `make up-postgres` | Ne démarre pas | Démarre | Ne démarre pas |

Les commandes d’un SGBD n’arrêtent pas l’autre déjà actif ; Adminer se gère séparément.

<details>
<summary>Tableau complet des modes de démarrage</summary>

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

</details>

<a id="section-connections"></a>
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

<a id="section-credentials"></a>
## Identifiants

`.docker.env` est créé depuis [`.docker.env.example`](../../../.docker.env.example) et ignoré par Git. Gardez
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

<a id="section-network-exposure"></a>
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

[LICENSE.md](../../../LICENSE.md) · [THIRD_PARTY_NOTICES.md](../../../THIRD_PARTY_NOTICES.md)

[Retour au README](../README_fr.md)
