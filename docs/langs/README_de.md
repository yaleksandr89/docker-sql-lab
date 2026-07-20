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
| `make up-no-ui` | Startet | Startet | Stoppt |
| `make up-mysql` | Startet | Startet nicht | Startet nicht |
| `make up-postgres` | Startet nicht | Startet | Startet nicht |

Einzel-DBMS-Befehle stoppen das andere laufende DBMS nicht; Adminer wird separat verwaltet.

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

## Zugangsdaten im Überblick

| Zweck | Benutzer | Passwort |
|---|---|---|
| Gemeinsamer Lernbenutzer | `DB_USER` | `DB_PASSWORD` |
| MySQL-Administrator | `root` | `MYSQL_ROOT_PASSWORD` |
| PostgreSQL-Superuser | `POSTGRES_SUPERUSER` | `POSTGRES_SUPERUSER_PASSWORD` |

`POSTGRES_SUPERUSER` und `DB_USER` müssen verschiedene Rollen sein. Verwenden Sie den gemeinsamen Lernbenutzer für Übungen und ersetzen Sie Beispielpasswörter vor einer Veröffentlichung.

## Datenbanken und wichtige Prüfungen

Beide DBMS erstellen die obligatorische Datenbank `demo` mit einer entsprechenden `demo_users`-Tabelle. Optionale Samples sind Chinook und Sakila für MySQL sowie Pagila und Chinook für PostgreSQL. Ihre Vorbereitung importiert nichts in bereits initialisierte Daten.

Diese statischen Prüfungen benötigen keine laufenden Datenbanken:

```bash
make check-env
make config
make test-storage-paths
```

Nach dem Start beider DBMS prüft `make check` den `DB_USER`-Zugriff; `make test-sql-imports` testet die öffentlichen trusted import targets. Die Detailseiten beschreiben alle Befehle, Einschränkungen und die sichere Reihenfolge.

Die Data-, Init- und Sample-Verzeichnisse von MySQL und PostgreSQL bleiben getrennt und werden über `.docker.env` konfiguriert. Der Managed-path-Validator lehnt Orte außerhalb von `data/` oder `samples/`, Symlink-Komponenten, Überschneidungen und reservierte Verzeichnisse ab. Ein vollständig fehlendes Sample wird übersprungen; unvollständige Dateien oder eine unerwartete Sample-Datenbank werden ohne automatische Reparatur abgelehnt.

Die Vorbereitung lädt festgelegte Upstream-Dateien, prüft ihre Integrität und behält sie lokal; Herkunft und Lizenzen stehen in `THIRD_PARTY_NOTICES.md`. Runtime-Prüfungen validieren außerdem die obligatorischen `demo`-Zeilen, Lese-/Schreibzugriff des Lernbenutzers und installierte Samples.

## Sicherheit und Lebenszyklus

- `BIND_ADDRESS=127.0.0.1` veröffentlicht Dienste nur auf loopback.
- `BIND_ADDRESS=0.0.0.0` veröffentlicht sie auf allen Schnittstellen;
  konfigurieren Sie Firewall, starke credentials und Netzvertrauen bewusst.
- Offizielle Entrypoints führen init nur für ein leeres data directory aus.
- `make mysql-import` und `make postgres-import` akzeptieren nur
  vertrauenswürdiges SQL. Sie erzeugen keine isolierte Umgebung (`sandbox`): partielle Ausführung ohne
  vollständigen automatic rollback ist möglich. Erstellen Sie vorher ein Backup.
- `make dump` und `make restore` decken nur MySQL `demo` ab; ein
  integriertes PostgreSQL-backup target fehlt.
- Alle `clean-*`- und `reinit-*`-Targets sind destruktiv und verlangen die
  exakte Bestätigung `CONFIRM=1`.

## Dokumentation

- [Erste Schritte](de/getting-started.md)
- [Datenbanken und Samples](de/databases.md)
- [Prüfungen und Betrieb](de/operations.md)
- [Diagnose und Fehlerbehebung](de/troubleshooting.md)

## Lizenzen und Hinweise zu Drittanbietern

Docker SQL Lab steht unter der MIT License:
[LICENSE.md](../../LICENSE.md). Optionale Samples behalten ihre
upstream-Lizenzen; Quellen, festgelegte Revisionen, Integritätswerte und Texte
stehen in [THIRD_PARTY_NOTICES.md](../../THIRD_PARTY_NOTICES.md).

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
