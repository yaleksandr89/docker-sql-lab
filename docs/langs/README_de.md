<p align="center">
  <img
    src="../assets/docker-sql-lab-cover.png"
    alt="Docker SQL Lab — lokale MySQL- und PostgreSQL-Umgebung"
    width="100%"
  >
</p>

# Docker SQL Lab

## Sprache auswählen

| Русский | English | Español | 中文 | Français | Deutsch |
| --- | --- | --- | --- | --- | --- |
| [Русский](../../README.md) | [English](README_en.md) | [Español](README_es.md) | [中文](README_zh.md) | [Français](README_fr.md) | **Ausgewählt** |

Eine lokale Docker-Compose-Umgebung zum Lernen und Vergleichen von MySQL und
PostgreSQL. Beide DBMS lassen sich einzeln oder gemeinsam ausführen; Adminer
wird nur bei Bedarf als Browseroberfläche zugeschaltet.

## Stack und festgelegte Versionen

- MySQL 9.7.1 LTS
- PostgreSQL 18.4
- Adminer 5.4.2 Docker Official Image
- Docker Compose v2
- GNU Make und Bash für Projektbefehle und Initialisierungsskripte

Die Image-Versionen sind in `.docker.env` festgelegt. Verwenden Sie das Lab
nicht ungeprüft als Produktionsvorlage; Zugangsdaten, Netzwerkfreigabe,
Speicherung, Backups und Betrieb benötigen eine eigene Bewertung.

## Hauptfunktionen

- Unabhängige MySQL- und PostgreSQL-Dienste, die auch gemeinsam laufen.
- Optionaler Adminer für beide DBMS, ohne Bindung an einen bestimmten Dienst.
- Obligatorische `demo`-Datenbank in jedem DBMS mit denselben fünf Beispieldatensätzen.
- Optionale Samples: Sakila und Chinook für MySQL, Pagila und Chinook für PostgreSQL.
- Getrennte bind-mounted Verzeichnisse für data, init und samples je DBMS.
- Gemeinsame Lern-Zugangsdaten und getrennte Administrator-Zugangsdaten.
- Statische Konfigurationsprüfungen, Schutz der managed storage paths,
  Runtime-Zugriffsprüfungen und Smoke-Test für vertrauenswürdige SQL-Imports.
- Explizite Bestätigung für destruktive Bereinigung und Neuinitialisierung.

## Voraussetzungen

- Docker Engine oder Docker Desktop mit dem Befehl `docker compose` v2.
- GNU Make, Bash und die von den Skripten verwendeten Unix-Werkzeuge (`awk`,
  `sed`, `grep`, `find`, `realpath` und `stat`).
- Für optionale Samples: `curl` und `git`; für MySQL zusätzlich `unzip` und
  `sha256sum`.

Führen Sie Befehle im Repository-Stamm aus. Der Standardbranch des Projekts ist
`master`.

## Schnellstart

Erstellen Sie `.docker.env` aus dem versionierten Beispiel, prüfen Sie die
Pfade, legen Sie Arbeitsverzeichnisse an und starten Sie das vollständige Lab:

```bash
make init
make up
```

`make up` startet MySQL, PostgreSQL und Adminer. Mit der Standardkonfiguration
ist Adminer unter `http://127.0.0.1:8081` erreichbar.

```bash
make status
make logs
make down
```

`make down` entfernt Container und Netzwerk, behält aber bind-mounted Daten.

## Startmodi

| Befehl | MySQL | PostgreSQL | Adminer |
|---|---|---|---|
| `make up` | Startet | Startet | Startet |
| `make up-no-ui` | Startet oder lässt laufen | Startet oder lässt laufen | Stoppt, falls aktiv |
| `make up-mysql` | Startet | Startet nicht automatisch | Startet nicht automatisch |
| `make up-mysql-ui` | Startet | Startet nicht automatisch | Startet |
| `make up-postgres` | Startet nicht automatisch | Startet | Startet nicht automatisch |
| `make up-postgres-ui` | Startet nicht automatisch | Startet | Startet |
| `make up-ui` | Ändert nichts | Ändert nichts | Startet |
| `make down-ui` | Ändert nichts | Ändert nichts | Stoppt |

Einzel-DBMS-Befehle stoppen ein bereits laufendes anderes DBMS nicht. Adminer
lässt sich separat starten und stoppen und ist nicht nur an MySQL gebunden.

## Verbindungen

### Adminer

Im Compose-Netzwerk bietet Adminer zwei vordefinierte Server an:

```text
MySQL (mysql)
PostgreSQL (postgres)
```

Wählen Sie einen Server und melden Sie sich mit `DB_USER`, `DB_PASSWORD` und
einer Datenbank wie `demo` an. `mysql` und `postgres` sind interne
Compose-Dienstnamen, keine Hostnamen für Desktop-Clients.

### Clients auf dem Host

| DBMS | Standardhost | Portvariable | Benutzer | Standarddatenbank |
|---|---|---|---|---|
| MySQL | `127.0.0.1` | `MYSQL_PORT` | `DB_USER` | `demo` |
| PostgreSQL | `127.0.0.1` | `POSTGRES_PORT` | `DB_USER` | `demo` |

DataGrip, DBeaver, PhpStorm und Host-CLI-Werkzeuge nutzen veröffentlichte
Adresse und Port. Nach einer Änderung von `BIND_ADDRESS` verwenden Sie bei
Bedarf die erreichbare Adresse dieser Schnittstelle.

### CLI in den Containern

Passwörter werden über die Containerumgebung übergeben und nicht in die
Shell-History geschrieben:

```bash
make mysql          # MySQL-Administrator, Datenbank demo
make mysql-user     # DB_USER, Datenbank demo
make postgres       # PostgreSQL-Superuser, Datenbank demo
make postgres-user  # DB_USER, Datenbank demo
```

## Zugangsdaten

`.docker.env` wird aus `.docker.env.example` erstellt und von Git ignoriert.
Bewahren Sie Passwörter dort auf; codieren Sie sie nicht in versioniertem
Compose, SQL oder Client-Konfigurationen.

| Zweck | Benutzer | Passwort |
|---|---|---|
| Gemeinsamer Lernbenutzer | `DB_USER` | `DB_PASSWORD` |
| MySQL-Administrator | `root` | `MYSQL_ROOT_PASSWORD` |
| PostgreSQL-Administrator/Superuser | `POSTGRES_SUPERUSER` | `POSTGRES_SUPERUSER_PASSWORD` |

`POSTGRES_SUPERUSER` und `DB_USER` müssen verschiedene Rollen sein. Verwenden
Sie den Lernbenutzer für normale Übungen. Ersetzen Sie Beispielpasswörter,
bevor Dienste geteilt oder außerhalb des lokalen Rechners veröffentlicht werden.

## Ports und `BIND_ADDRESS`

| Dienst | Portvariable | Beispielwert |
|---|---|---|
| MySQL | `MYSQL_PORT` | `3306` |
| PostgreSQL | `POSTGRES_PORT` | `5432` |
| Adminer | `ADMINER_PORT` | `8081` |

Standardmäßig werden alle drei Dienste nur an loopback gebunden:

```env
BIND_ADDRESS=127.0.0.1
```

`127.0.0.1` ist der lokale Standard. `BIND_ADDRESS=0.0.0.0` veröffentlicht die
Ports auf allen Netzwerkschnittstellen. Für LAN oder VPN ist die Adresse einer
bestimmten Schnittstelle vorzuziehen. Ändern Sie die Bindung bewusst und
beachten Sie Firewall, Passwortstärke und Vertrauenswürdigkeit des Netzes.

## Lerndatenbanken

### Obligatorische `demo`-Datenbanken

Beide DBMS initialisieren `demo`:

- MySQL: `demo.demo_users`
- PostgreSQL: `demo.public.demo_users`

Die Tabellen besitzen entsprechende Felder `id`, `name`, `email` und
`created_at` sowie Alice, Bob, Carol, Dave und Eve. Zusätzliche Zeilen sind
zulässig. `make check-env` verlangt `MYSQL_DATABASE=demo` und
`POSTGRES_DATABASE=demo`.

### Optionale Samples

| DBMS | Optionale Datenbanken | Vorbereitung |
|---|---|---|
| MySQL | Chinook, Sakila | `make samples-mysql` |
| PostgreSQL | Pagila, Chinook | `make samples-postgres` |

Die Vorbereitung lädt festgelegte upstream-Dateien herunter und prüft sie,
startet aber keine Container und importiert nichts in bereits initialisierte
Datenbanken. Temporäre Downloads bleiben lokal, werden nicht committed und
liegen unter `MYSQL_SAMPLES_DIR` beziehungsweise `POSTGRES_SAMPLES_DIR`.
Herkunft, Integritätswerte und Lizenzen stehen in
[THIRD_PARTY_NOTICES.md](../../THIRD_PARTY_NOTICES.md).

Bei leerem data directory:

```bash
make samples-mysql
make up-mysql

make samples-postgres
make up-postgres
```

Die offiziellen Entrypoints verarbeiten init nur bei leerem data directory.
Um Samples einer bestehenden Instanz hinzuzufügen, erstellen Sie ein Backup
und initialisieren bewusst nur das betroffene DBMS neu:

```bash
make samples-mysql
make reinit-mysql CONFIRM=1

make samples-postgres
make reinit-postgres CONFIRM=1
```

Ein vollständig fehlendes Sample wird übersprungen und verhindert `demo`
nicht. Unvollständige Samples oder unerwartete Datenbanken werden ohne
automatische Reparatur oder Löschung abgelehnt.

## Öffentliche Make targets

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
import workflow, kein Sandbox und kein Sicherheitsnachweis für fremdes SQL.

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
- `DATABASE` wählt die erste Verbindung, erzeugt aber keine Sandbox.
- Qualified names, Client-/Session-Befehle und tatsächliche grants können
  andere erreichbare Objekte betreffen.
- Partielle Ausführung ist möglich; automatischer Rollback wird nicht zugesagt.
- Erstellen Sie vor wichtigen Imports ein Backup.
- gzip, Archive und PostgreSQL-custom-format backups werden nicht verarbeitet.

## Lebenszyklus von data und init

```text
data/
├── mysql/
└── postgres/

initdb/
├── mysql/
└── postgres/
```

| DBMS | Data | Init | Optionale Samples |
|---|---|---|---|
| MySQL | `MYSQL_DATA_DIR` (`./data/mysql`) | `MYSQL_INITDB_DIR` (`./initdb/mysql`) | `MYSQL_SAMPLES_DIR` (`./samples/mysql`) |
| PostgreSQL | `POSTGRES_DATA_DIR` (`./data/postgres`) | `POSTGRES_INITDB_DIR` (`./initdb/postgres`) | `POSTGRES_SAMPLES_DIR` (`./samples/postgres`) |

Data- und Sample-Pfade sind über `.docker.env` konfigurierbar und werden als
managed paths validiert. Entrypoints führen init nur bei leerem data directory
aus; geänderte init-Dateien migrieren keine bestehende Datenbank. `make down`
löscht keine bind mounts. Bearbeiten Sie Dateien in `data/` nicht manuell; sie
können numerischen Container-UID/GID gehören.

## Backup, Bereinigung und Neuinitialisierung

Die eingebauten Targets decken nur die konfigurierte MySQL-Datenbank `demo` ab:

```bash
make dump
make restore
```

`make dump` schreibt `backup/demo.sql`; `make restore` liest die Datei und
wendet die MySQL-Lern-grants erneut an. Verwenden Sie für PostgreSQL ein eigenes
Backup-Verfahren.

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

## Diagnose und Fehlerbehebung

### Konfiguration oder Pfadvalidierung schlägt fehl

Führen Sie `make check-env` aus. Data paths müssen strikt unter `data/` und
Samples unter `samples/` liegen; symlinks, Überschneidungen und reservierte
Verzeichnisse sind unzulässig. Korrigieren Sie `.docker.env` und führen Sie
`make config` aus.

### Ein Dienst wird nicht bereit

```bash
make status
make log SERVICE=mysql
make log SERVICE=postgres
```

Prüfen Sie Docker, Port, `.docker.env` und Logs, bevor Sie Daten ändern.

### Init-Änderungen oder Samples erscheinen nicht

Bei bereits initialisierten Daten ist das erwartet. Prüfen Sie Pfade und
Vorbereitung, sichern Sie wichtige Daten und verwenden Sie
`reinit-... CONFIRM=1` nur als bewussten letzten Schritt.

### Sample ist unvollständig oder hat einen unerwarteten Besitzer

Der Loader überschreibt oder repariert unerwartete Datenbanken nicht. Führen
Sie `make samples-mysql` oder `make samples-postgres` erneut aus und prüfen Sie
den Fehler; sichern Sie Daten vor einer Neuinitialisierung.

### Ein Client kann keine Verbindung herstellen

Host-Clients verwenden veröffentlichte Adresse und `MYSQL_PORT` oder
`POSTGRES_PORT`; Adminer verwendet `mysql` oder `postgres` im Compose-Netz.
Prüfen Sie `BIND_ADDRESS`, Firewall, Datenbankauswahl und `DB_USER`-Zugangsdaten.

## Lizenzen und Hinweise zu Drittanbietern

Docker SQL Lab steht unter der MIT License:
[LICENSE.md](../../LICENSE.md). Optionale Samples behalten ihre
upstream-Lizenzen; Quellen, festgelegte Revisionen, Integritätswerte und Texte
stehen in [THIRD_PARTY_NOTICES.md](../../THIRD_PARTY_NOTICES.md).
