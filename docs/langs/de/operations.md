# Prüfungen und Betrieb

[← Zurück zur README](../README_de.md)

## Sprache

| Русский | English | Español | 中文 | Français | Deutsch |
| --- | --- | --- | --- | --- | --- |
| [Русский](../ru/operations.md) | [English](../en/operations.md) | [Español](../es/operations.md) | [中文](../zh/operations.md) | [Français](../fr/operations.md) | **Ausgewählt** |

## Abschnitt

| Erste Schritte | Datenbanken und Samples | Prüfungen und Betrieb | Diagnose und Fehlerbehebung |
| --- | --- | --- | --- |
| [Erste Schritte](getting-started.md) | [Datenbanken und Samples](databases.md) | **Ausgewählt** | [Diagnose und Fehlerbehebung](troubleshooting.md) |

<a id="section-make-targets"></a>
## Öffentliche Make targets

Öffentliche Targets und ihre Implementierung stehen im [`Makefile`](../../../Makefile).

Wichtige Targets sind `make init`, `make up`, `make down`, `make check`,
`make test-storage-paths`, `make test-sql-imports`, `make mysql-import`
und `make postgres-import`. Vertrauenswürdiges SQL ist keine isolierte Umgebung (`sandbox`), kann
partiell ausgeführt werden und erhält keine Garantie für automatic rollback;
erstellen Sie vor wichtigen Imports ein Backup. Integrierte backup targets
decken nur MySQL `demo` ab, nicht PostgreSQL. `clean-*` und `reinit-*`
sind destruktiv und erfordern exakt `CONFIRM=1`.

<details>
<summary>📋 Vollständige Referenz der öffentlichen Make targets</summary>

`make help` zeigt die kompakte Liste.

| Befehl | Zweck |
|---|---|
| `make init` | `.docker.env` erstellen, managed paths prüfen, Verzeichnisse anlegen |
| `make check-env` | Env-Werte, Rollen, Datenbanknamen und Pfade prüfen |
| `make pull` | Die drei festgelegten Images laden |
| `make config` | Erweiterte Compose-Konfiguration validieren |
| `make up`, `make up-no-ui` | Beide DBMS mit oder ohne Adminer starten |
| `make up-mysql`, `make up-mysql-ui` | MySQL, optional mit Adminer, starten |
| `make up-postgres`, `make up-postgres-ui` | PostgreSQL, optional mit Adminer, starten |
| `make up-ui`, `make down-ui` | Nur Adminer starten oder stoppen |
| `make down` | Lab stoppen, ohne bind-mounted Daten zu löschen |
| `make status`, `make logs` | Status anzeigen oder alle Logs verfolgen |
| `make log SERVICE=postgres` | Einen Dienst verfolgen; auch `make log postgres` |
| `make in SERVICE=postgres` | Dienst-Shell öffnen; auch `make in postgres` |
| `make mysql`, `make mysql-user` | MySQL als Admin oder `DB_USER` öffnen |
| `make postgres`, `make postgres-user` | PostgreSQL als Superuser oder `DB_USER` öffnen |
| `make samples-mysql`, `make samples-postgres` | Geprüfte Samples vorbereiten |
| `make check-mysql-access`, `make check-postgres-access` | Ein laufendes DBMS prüfen |
| `make check` | Compose und `DB_USER`-Zugriff auf beide DBMS prüfen |
| `make test-storage-paths` | Managed paths ohne Docker runtime testen |
| `make test-sql-imports` | Smoke-Test beider öffentlicher SQL-Imports |
| `make mysql-import FILE=... DATABASE=...` | Plain SQL als `DB_USER` in MySQL importieren |
| `make postgres-import FILE=... DATABASE=...` | Plain SQL als `DB_USER` in PostgreSQL importieren |
| `make dump`, `make restore` | MySQL-`demo` sichern oder wiederherstellen |
| `make clean-{mysql,postgres,all} CONFIRM=1` | Ausgewählte data directories löschen |
| `make reinit-{mysql,postgres,all} CONFIRM=1` | Datenbanken löschen, neu erstellen und prüfen |

</details>

<a id="section-validation"></a>
## Prüfungen

### Statische und lokale Prüfungen

```bash
make check-env
make config
make test-storage-paths
```

`make check-env` erstellt bei Bedarf `.docker.env` und validiert Werte und
Pfade. `make config` prüft das erweiterte Compose-Modell.
`make test-storage-paths` benötigt keine Docker runtime und testet Pfade
außerhalb des Projekts, symlink-Komponenten, überlappende oder verschachtelte
Pfade sowie reserved directories.

### Runtime-Prüfungen

```bash
make up-no-ui
make check
make test-sql-imports
make down
```

`make check` prüft `demo` und den tatsächlichen `DB_USER`-Zugriff in beiden
DBMS sowie installierte Samples. `make test-sql-imports` benötigt beide
laufenden DBMS, ruft `mysql-import` und `postgres-import` auf, erstellt
eindeutig benannte temporäre Tabellen in `demo`, prüft marker rows als
`DB_USER` und löscht nur diese Tabellen. Dies ist ein Smoke-Test des trusted
import workflow, keine isolierte Umgebung (`sandbox`) und kein Sicherheitsnachweis für fremdes SQL.

<a id="section-storage-path-safety"></a>
## Sicherheit der storage paths

`make check-env` führt
[`scripts/validate-storage-paths.sh`](../../../scripts/validate-storage-paths.sh)
aus. Data
paths müssen strikt unter `data/`, sample paths unter `samples/` liegen;
Symlinks sowie gleiche, verschachtelte, überlappende oder reservierte Pfade
werden abgelehnt. `make test-storage-paths` testet dies ohne Docker runtime.

<a id="section-sql-imports"></a>
## Import vertrauenswürdiger SQL-Dateien

```bash
make mysql-import FILE=path/to/file.sql DATABASE=demo
make postgres-import FILE=path/to/file.sql DATABASE=demo
```

Für beide targets gilt:

- `FILE` und `DATABASE` sind erforderlich.
- Die lokale plain-SQL-Datei muss existieren, lesbar und nicht leer sein.
- Die Datenbank muss existieren; Systemdatenbanken sind verboten.
- Der Import läuft als `DB_USER`, erstellt keine Datenbank und vergibt keine grants.
- `DATABASE` wählt die erste Verbindung, erzeugt aber keine isolierte Umgebung (`sandbox`).
- Qualified names, Client-/Session-Befehle und tatsächliche grants können
  andere erreichbare Objekte betreffen.
- Partielle Ausführung ist möglich; automatischer Rollback wird nicht zugesagt.
- Erstellen Sie vor wichtigen Imports ein Backup.
- gzip, Archive und PostgreSQL-custom-format backups werden nicht verarbeitet.

<a id="section-backup"></a>
## Backup

Die eingebauten Targets decken nur die konfigurierte MySQL-Datenbank `demo` ab:

```bash
make dump
make restore
```

`make dump` schreibt `backup/demo.sql`; `make restore` liest die Datei und
wendet die MySQL-Lern-grants erneut an. Verwenden Sie für PostgreSQL ein eigenes
Backup-Verfahren.

<a id="section-clean-reinitialize"></a>
## Bereinigung und Neuinitialisierung

> **Warnung:** Alle `clean-*`- und `reinit-*`-Targets sind destruktiv und
> verlangen die exakte Bestätigung `CONFIRM=1`.

```bash
make clean-mysql CONFIRM=1
make clean-postgres CONFIRM=1
make clean-all CONFIRM=1

make reinit-mysql CONFIRM=1
make reinit-postgres CONFIRM=1
make reinit-all CONFIRM=1
```

Einzelne Targets löschen nur das gewählte DBMS-data directory; `all` löscht
beide. Konfiguration, init, Samples und Backups bleiben erhalten. Reinit
startet und prüft anschließend die gewählten DBMS; `reinit-all` startet beide
ohne Adminer.

[Zurück zur README](../README_de.md)
