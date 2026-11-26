# Contribuer

## Choisir la langue

| Русский | English | Español | 中文 | Français | Deutsch |
|---|---|---|---|---|---|
| [Русский](https://github.com/yaleksandr89/docker-sql-lab/blob/master/.github/CONTRIBUTING.md) | [English](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/en/CONTRIBUTING.md) | [Español](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/es/CONTRIBUTING.md) | [中文](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/zh/CONTRIBUTING.md) | **Français** | [Deutsch](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/de/CONTRIBUTING.md) |

## Avant de commencer

Signalez les bugs reproductibles dans [GitHub Issues](https://github.com/yaleksandr89/docker-sql-lab/issues) ; posez vos questions et partagez vos idées dans [GitHub Discussions](https://github.com/yaleksandr89/docker-sql-lab/discussions). Convenez au préalable des changements importants avec le propriétaire. Ne publiez ni mots de passe, ni données réelles, ni détails de vulnérabilités.

Vulnérabilités : [politique de sécurité](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/fr/SECURITY.md).

## Limites des modifications

Préservez les commandes Make publiques, la séparation des SGBD, `demo` obligatoire, les samples optionnels et les droits de `DB_USER`. Convenez à l’avance des changements d’images, schémas, privilèges, réseau, imports et opérations destructrices. Ne versionnez pas les fichiers SQL tiers téléchargés ni les fichiers `.docker.env` locaux.

## Contrôles

Travaillez dans une copie jetable avec des données synthétiques, un nom de projet Compose et des ports uniques. Vérifiez les chemins de stockage réels et l’identité de la base avant les commandes runtime.

```bash
make check-env
make config
make test-storage-paths
```

Pour les changements d’init, d’images, d’imports ou d’Adminer, exécutez les contrôles adaptés dans un laboratoire isolé. `clean-*` et `reinit-*` suppriment les données ; ne les utilisez pas dans un laboratoire de travail.

[Premiers pas](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/fr/guides/getting-started.md) · [Guide des opérations](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/fr/guides/operations.md).

## Pull Request

Créez une branche thématique depuis `master` et un commit signé et cohérent. Utilisez Conventional Commits avec une description en russe, par exemple `docs: уточнить порядок запуска`. Décrivez le changement, ses effets sur les données et la sécurité, les contrôles réellement exécutés et la documentation modifiée. Synchronisez les six langues ; les trois workflows CI doivent réussir avant la fusion.

[Site de l’auteur](https://yaleksandr89.github.io/)
