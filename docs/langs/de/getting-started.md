# Erste Schritte

[← Zurück zur README](../README_de.md)

## Sprache

| Русский | English | Español | 中文 | Français | Deutsch |
| --- | --- | --- | --- | --- | --- |
| [Русский](../ru/getting-started.md) | [English](../en/getting-started.md) | [Español](../es/getting-started.md) | [中文](../zh/getting-started.md) | [Français](../fr/getting-started.md) | **Ausgewählt** |

## Abschnitt

| Erste Schritte | Datenbanken und Samples | Prüfungen und Betrieb | Diagnose und Fehlerbehebung |
| --- | --- | --- | --- |
| **Ausgewählt** | [Datenbanken und Samples](databases.md) | [Prüfungen und Betrieb](operations.md) | [Diagnose und Fehlerbehebung](troubleshooting.md) |

<a id="section-requirements"></a>
## Voraussetzungen

- Docker Engine oder Docker Desktop mit Docker Compose v2.
- GNU Make, Bash und grundlegende Unix-Kommandozeilenwerkzeuge.
- Empfohlene Umgebungen: Linux; macOS mit Docker Desktop; oder Windows mit
  Docker Desktop und WSL2.

Führen Sie Befehle im Repository-Stamm aus. Der Standardbranch des Projekts ist
`master`.

<a id="section-quick-start"></a>
## Schnellstart

`make init` erstellt eine lokale `.docker.env` aus
[`.docker.env.example`](../../../.docker.env.example), prüft die verwalteten
Speicherpfade und legt die Arbeitsverzeichnisse an. Starten Sie danach das
vollständige Lab:

```bash
make init
make up
```

`make up` startet MySQL, PostgreSQL und Adminer. Mit der Standardkonfiguration
ist Adminer unter `http://127.0.0.1:8081` erreichbar.

Mit `make up-no-ui` starten Sie beide DBMS ohne Adminer. Die obligatorische
`demo`-Datenbank wird bei der ersten Initialisierung immer erstellt;
Beispieldatensätze sind optional. Um sie bei der ersten Initialisierung zu
laden, bereiten Sie sie vor dem ersten `make up` vor. Bei bereits
initialisierten Datenverzeichnissen erstellen Sie ein Backup vor einer
bestätigten Neuinitialisierung nur, wenn eigene Daten erhalten bleiben sollen. Das genaue Verfahren steht
unter [Initialisierung und Lebenszyklus](databases.md#section-initialization).

```bash
make status
make logs
make down
```

`make down` entfernt Container und Netzwerk, behält aber bind-mounted Daten.

<a id="section-startup-modes"></a>
## Startmodi

| Befehl | MySQL | PostgreSQL | Adminer |
|---|---|---|---|
| `make up` | Startet | Startet | Startet |
| `make up-no-ui` | Startet | Startet | Stoppt |
| `make up-mysql` | Startet | Startet nicht | Startet nicht |
| `make up-postgres` | Startet nicht | Startet | Startet nicht |

Einzel-DBMS-Befehle stoppen das andere laufende DBMS nicht; Adminer wird separat verwaltet.

<details>
<summary>📋 Vollständige Tabelle der Startmodi</summary>

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

</details>

<a id="section-connections"></a>
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

<a id="section-credentials"></a>
## Zugangsdaten

`.docker.env` wird aus [`.docker.env.example`](../../../.docker.env.example) erstellt und von Git ignoriert.
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

<a id="section-network-exposure"></a>
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

[Zurück zur README](../README_de.md)
