# Diagnostic et dépannage

[← Retour au README](../README_fr.md)

[Русский](../ru/troubleshooting.md) | [English](../en/troubleshooting.md) | [Español](../es/troubleshooting.md) | [中文](../zh/troubleshooting.md) | **Français — Sélectionné** | [Deutsch](../de/troubleshooting.md)

**Pages dans cette langue:** [Prise en main](getting-started.md) · [Bases et samples](databases.md) · [Contrôles et opérations](operations.md) · **Diagnostic et dépannage**

Collectez d’abord le diagnostic, puis corrigez la cause précise. Si une
réinitialisation reste nécessaire, effectuez un backup et n’utilisez
`reinit-... CONFIRM=1` qu’en dernier recours volontaire.

Détails canoniques du cycle de vie et des opérations : [bases](databases.md#section-initialization) · [opérations](operations.md#section-clean-reinitialize).

<a id="section-configuration"></a>
## Échec de configuration ou de validation des chemins

Lancez `make check-env`. Les data paths doivent rester strictement sous
`data/` et les samples sous `samples/` ; aucun symlink, chevauchement ou
répertoire réservé n’est admis. Corrigez `.docker.env` puis lancez `make config`.

<a id="section-readiness"></a>
## Un service n’est pas prêt

```bash
make status
make log SERVICE=mysql
make log SERVICE=postgres
```

Vérifiez Docker, le port, `.docker.env` et les logs avant de toucher aux données.

<a id="section-init-samples"></a>
## Les changements init ou les samples n’apparaissent pas

C’est normal si data est déjà initialisé. Vérifiez chemins et préparation,
sauvegardez les données importantes et n’utilisez `reinit-... CONFIRM=1` qu’en
dernier recours volontaire.

<a id="section-sample-integrity"></a>
## Sample incomplet ou propriétaire inattendu

Le loader ne remplace ni ne répare une base inattendue. Relancez
`make samples-mysql` ou `make samples-postgres` et inspectez l’erreur ;
préservez les données avant toute réinitialisation.

<a id="section-connections-troubleshooting"></a>
## Un client ne se connecte pas

Les clients hôtes utilisent l’adresse publiée et `MYSQL_PORT` ou
`POSTGRES_PORT` ; Adminer utilise `mysql` ou `postgres` dans Compose. Vérifiez
`BIND_ADDRESS`, firewall, base sélectionnée et identifiants `DB_USER`.

[LICENSE.md](../../../LICENSE.md) · [THIRD_PARTY_NOTICES.md](../../../THIRD_PARTY_NOTICES.md)

[Retour au README](../README_fr.md)
