# Mitwirken

## Sprache auswählen

| Русский | English | Español | 中文 | Français | Deutsch |
|---|---|---|---|---|---|
| [Русский](https://github.com/yaleksandr89/docker-sql-lab/blob/master/.github/CONTRIBUTING.md) | [English](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/en/CONTRIBUTING.md) | [Español](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/es/CONTRIBUTING.md) | [中文](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/zh/CONTRIBUTING.md) | [Français](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/fr/CONTRIBUTING.md) | **Deutsch** |

## Vor dem Start

Verwenden Sie GitHub Issues für reproduzierbare Fehler; besprechen Sie Fragen und Vorschläge zunächst mit dem Eigentümer. Veröffentlichen Sie keine Passwörter, echten Daten oder Schwachstellendetails.

## Änderungsgrenzen

Erhalten Sie öffentliche Make-Befehle, getrennte DBMS, die obligatorische `demo`, optionale Samples und `DB_USER`-Rechte. Stimmen Sie Änderungen an Images, Schemas, Rechten, Netzwerkzugriff, Importen und destruktiven Operationen vorher ab. Committen Sie keine heruntergeladenen Drittanbieter-SQL-Dateien oder lokalen `.docker.env`-Dateien.

## Prüfungen

Arbeiten Sie in einem temporären Checkout mit synthetischen Daten, eindeutigem Compose-Projektnamen und eigenen Ports. Prüfen Sie tatsächliche Speicherpfade und Datenbankidentität vor Runtime-Befehlen.

```bash
make check-env
make config
make test-storage-paths
```

Führen Sie bei Änderungen an Init, Images, Importen oder Adminer die relevanten Prüfungen in einem isolierten Lab aus. `clean-*` und `reinit-*` löschen Daten; verwenden Sie sie nicht in einem Arbeits-Lab.

[Erste Schritte](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/de/guides/getting-started.md) · [Betriebsleitfaden](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/de/guides/operations.md).

## Pull Request

Erstellen Sie einen Themenbranch von `master` und einen logisch zusammenhängenden signierten Commit. Verwenden Sie Conventional Commits mit russischer Beschreibung, etwa `docs: уточнить порядок запуска`. Beschreiben Sie Änderung, Daten- und Sicherheitsauswirkungen, tatsächlich ausgeführte Prüfungen und Dokumentationsänderungen. Synchronisieren Sie alle sechs Sprachen; alle drei CI-Workflows müssen vor dem Merge erfolgreich sein.
