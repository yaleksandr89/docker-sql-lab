# Diagnose und Fehlerbehebung

[← Zurück zur README](../README_de.md)

## Sprache

| Русский | English | Español | 中文 | Français | Deutsch |
| --- | --- | --- | --- | --- | --- |
| [Русский](../ru/troubleshooting.md) | [English](../en/troubleshooting.md) | [Español](../es/troubleshooting.md) | [中文](../zh/troubleshooting.md) | [Français](../fr/troubleshooting.md) | **Ausgewählt** |

## Abschnitt

| Erste Schritte | Datenbanken und Samples | Prüfungen und Betrieb | Diagnose und Fehlerbehebung |
| --- | --- | --- | --- |
| [Erste Schritte](getting-started.md) | [Datenbanken und Samples](databases.md) | [Prüfungen und Betrieb](operations.md) | **Ausgewählt** |

Sammeln Sie zuerst Diagnosedaten und korrigieren Sie dann die konkrete
Ursache. Falls eine Neuinitialisierung nötig bleibt, erstellen Sie ein Backup
und verwenden `reinit-... CONFIRM=1` nur als bewussten letzten Schritt.

Verbindliche Details zu Lebenszyklus und Betrieb: [Datenbanken](databases.md#section-initialization) · [Betrieb](operations.md#section-clean-reinitialize).

<a id="section-configuration"></a>
## Konfiguration oder Pfadvalidierung schlägt fehl

Führen Sie `make check-env` aus. Data paths müssen strikt unter `data/` und
Samples unter `samples/` liegen; symlinks, Überschneidungen und reservierte
Verzeichnisse sind unzulässig. Korrigieren Sie `.docker.env` und führen Sie
`make config` aus.

<a id="section-readiness"></a>
## Ein Dienst wird nicht bereit

```bash
make status
make log SERVICE=mysql
make log SERVICE=postgres
```

Prüfen Sie Docker, Port, `.docker.env` und Logs, bevor Sie Daten ändern.

<a id="section-init-samples"></a>
## Init-Änderungen oder Samples erscheinen nicht

Bei bereits initialisierten Daten ist das erwartet. Prüfen Sie Pfade und
Vorbereitung, sichern Sie wichtige Daten und verwenden Sie
`reinit-... CONFIRM=1` nur als bewussten letzten Schritt.

<a id="section-sample-integrity"></a>
## Sample ist unvollständig oder hat einen unerwarteten Besitzer

Der Loader überschreibt oder repariert unerwartete Datenbanken nicht. Führen
Sie `make samples-mysql` oder `make samples-postgres` erneut aus und prüfen Sie
den Fehler; sichern Sie Daten vor einer Neuinitialisierung.

<a id="section-connections-troubleshooting"></a>
## Ein Client kann keine Verbindung herstellen

Host-Clients verwenden veröffentlichte Adresse und `MYSQL_PORT` oder
`POSTGRES_PORT`; Adminer verwendet `mysql` oder `postgres` im Compose-Netz.
Prüfen Sie `BIND_ADDRESS`, Firewall, Datenbankauswahl und `DB_USER`-Zugangsdaten.

[LICENSE.md](../../../LICENSE.md) · [THIRD_PARTY_NOTICES.md](../../../THIRD_PARTY_NOTICES.md)

[Zurück zur README](../README_de.md)
