# Sicherheitsrichtlinie

## Sprache wählen

| Русский | English | Español | 中文 | Français | Deutsch |
|---|---|---|---|---|---|
| [Русский](https://github.com/yaleksandr89/docker-sql-lab/blob/master/.github/SECURITY.md) | [English](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/en/SECURITY.md) | [Español](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/es/SECURITY.md) | [中文](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/zh/SECURITY.md) | [Français](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/fr/SECURITY.md) | **Deutsch** |

## Unterstützte Versionen

Sicherheitskorrekturen werden für den aktuellen Stand von `master` und die zuletzt veröffentlichte Version geprüft. Ältere Versionen können andere Netzwerkeinstellungen haben; vor einem Upgrade die Datenkompatibilität prüfen.

| Version | Unterstützt |
|---|---|
| `master` | Ja |
| Zuletzt veröffentlichte Version | Ja |

## Sicherheitsgrenzen des Labors

Dies ist ein lokales MySQL-, PostgreSQL- und Adminer-Lernlabor für synthetische Daten, kein Produktionsbetrieb. Ports werden standardmäßig auf `127.0.0.1` veröffentlicht; eine Änderung von `BIND_ADDRESS` kann Dienste extern zugänglich machen. Nur vertrauenswürdige Netze und getrennte administrative und Lern-Zugangsdaten (`DB_USER`) verwenden. Beispielpasswörter sind nur für lokales Lernen gedacht. Der Import vertrauenswürdigen Plain SQL ist keine Sandbox und kann teilweise ausgeführt werden; `clean-*` und `reinit-*` löschen mit ausdrücklichem `CONFIRM=1` absichtlich Daten.

Zu Sicherheitsproblemen zählen insbesondere:

- unbeabsichtigte Freigabe von Diensten oder Umgehung der Trennung von Lern- und Administratorrechten;
- Umgehung von Prüfungen für Speicherpfade, symbolische Links oder Bestätigung destruktiver Operationen;
- unsichere Verarbeitung von Parametern, Datenbanknamen oder Pfaden bei Importen und Make-Befehlen;
- unbeabsichtigtes Löschen, Überschreiben oder Offenlegen von Daten, Passwörtern oder lokaler Konfiguration;
- Umgehung der Herkunfts- oder Integritätsprüfungen der Samples oder Sicherheitsprobleme mit Images, Adminer-Plugins oder CI.

Gewöhnliche Fehler über [GitHub Issues](https://github.com/yaleksandr89/docker-sql-lab/issues), Fragen und Ideen über [GitHub Discussions](https://github.com/yaleksandr89/docker-sql-lab/discussions) melden. Liegt das Problem in einer Upstream-Komponente, deren genaue Version und Auswirkung auf das Labor angeben; Fehler der Komponente selbst auch nach den Regeln ihrer Maintainer melden.

## Eine Schwachstelle melden

Bevorzugt GitHub Private Vulnerability Reporting nutzen: **Security and quality → Report a vulnerability** öffnen. Ist dies nicht verfügbar, in GitHub Discussions um einen privaten Kommunikationskanal bitten, ohne technische Schwachstellendetails zu veröffentlichen.

Vor koordinierter Offenlegung keine Passwörter, Tokens, lokalen oder Produktionskonfigurationen, echten Daten, vollständigen Logs, funktionsfähigen Exploits oder sensiblen Details veröffentlichen. Nur synthetische Daten oder bereinigte Ausschnitte verwenden.

## Inhalt des Berichts

- Betroffener Release, Branch oder Commit sowie relevante Versionen von MySQL, PostgreSQL, Adminer, Docker und Compose.
- Startmodus (MySQL, PostgreSQL, beide, mit oder ohne Adminer), betroffener Make-Befehl und erwartete Zugriffsgrenze.
- Minimale Reproduktionsschritte, erwartetes und tatsächliches Verhalten.
- Bereinigte Anfrage-, Antwort- oder Log-Ausschnitte und eine mögliche Korrektur, falls bekannt.

## Bearbeitung des Berichts

Berichte werden nach Verfügbarkeit geprüft; kein festes SLA wird versprochen. Die Offenlegung mit dem Maintainer abstimmen. Nach Bestätigung werden Korrekturen und Informationen zu betroffenen Versionen im Rahmen koordinierter Offenlegung veröffentlicht. Es wird kein Prämienprogramm für Schwachstellen angegeben.
