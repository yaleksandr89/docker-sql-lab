# Contrôles et opérations

[← Retour au README](../README_fr.md)

## Langue

| Русский | English | Español | 中文 | Français | Deutsch |
| --- | --- | --- | --- | --- | --- |
| [Русский](../ru/operations.md) | [English](../en/operations.md) | [Español](../es/operations.md) | [中文](../zh/operations.md) | **Sélectionné** | [Deutsch](../de/operations.md) |

## Section

| Prise en main | Bases et samples | Contrôles et opérations | Diagnostic et dépannage |
| --- | --- | --- | --- |
| [Prise en main](getting-started.md) | [Bases et samples](databases.md) | **Sélectionné** | [Diagnostic et dépannage](troubleshooting.md) |

<a id="section-make-targets"></a>
## Targets Make publics

Les targets publics et leur implémentation figurent dans le [`Makefile`](../../../Makefile).

Targets essentiels : `make init`, `make up`, `make down`, `make check`,
`make test-storage-paths`, `make test-sql-imports`, `make mysql-import` et
`make postgres-import`. Le SQL de confiance n’est pas un sandbox, peut être
exécuté partiellement et n’offre aucun rollback automatique garanti ; faites
un backup avant tout import important. Les backups intégrés couvrent seulement
MySQL `demo`, pas PostgreSQL. `clean-*` et `reinit-*` sont destructifs et
exigent `CONFIRM=1` exact.

<details>
<summary>Référence complète des targets Make publics</summary>

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

</details>

<a id="section-validation"></a>
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

<a id="section-storage-path-safety"></a>
## Sécurité des storage paths

`make check-env` exécute `scripts/validate-storage-paths.sh`. Les data
paths doivent rester strictement sous `data/`, les sample paths sous
`samples/` ; symlinks, chemins égaux, imbriqués, chevauchants ou réservés
sont refusés. `make test-storage-paths` teste ces règles sans Docker runtime.

<a id="section-sql-imports"></a>
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

<a id="section-backup"></a>
## Sauvegarde

Les targets intégrés couvrent uniquement la base MySQL `demo` configurée :

```bash
make dump
make restore
```

`make dump` écrit `backup/demo.sql` ; `make restore` le lit et réapplique les
grants pédagogiques MySQL. Utilisez une procédure distincte pour PostgreSQL.

<a id="section-clean-reinitialize"></a>
## Nettoyage et réinitialisation

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

[LICENSE.md](../../../LICENSE.md) · [THIRD_PARTY_NOTICES.md](../../../THIRD_PARTY_NOTICES.md)

[Retour au README](../README_fr.md)
