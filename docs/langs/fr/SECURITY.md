# Politique de sécurité

## Choisir la langue

| Русский | English | Español | 中文 | Français | Deutsch |
|---|---|---|---|---|---|
| [Русский](https://github.com/yaleksandr89/docker-sql-lab/blob/master/.github/SECURITY.md) | [English](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/en/SECURITY.md) | [Español](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/es/SECURITY.md) | [中文](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/zh/SECURITY.md) | **Français** | [Deutsch](https://github.com/yaleksandr89/docker-sql-lab/blob/master/docs/langs/de/SECURITY.md) |

## Versions prises en charge

Les correctifs de sécurité sont envisagés pour l’état actuel de `master` et la dernière version publiée. Les anciennes versions peuvent avoir une configuration réseau différente ; vérifiez la compatibilité des données avant toute mise à niveau.

| Version | Prise en charge |
|---|---|
| `master` | Oui |
| Dernière version publiée | Oui |

## Périmètre de sécurité du laboratoire

Ce laboratoire local MySQL, PostgreSQL et Adminer utilise des données synthétiques ; ce n’est pas un déploiement de production. Les ports sont publiés sur `127.0.0.1` par défaut ; modifier `BIND_ADDRESS` peut exposer les services à l’extérieur. Utilisez des réseaux de confiance et des identifiants distincts pour l’administration et l’apprentissage (`DB_USER`). Les mots de passe d’exemple sont réservés à l’apprentissage local. L’import de SQL brut de confiance n’est pas un sandbox et peut s’exécuter partiellement ; `clean-*` et `reinit-*` suppriment volontairement des données avec `CONFIRM=1` explicite.

Les problèmes de sécurité comprennent notamment :

- exposition imprévue de services ou contournement de la séparation entre privilèges d’apprentissage et d’administration ;
- contournement des contrôles de chemins de stockage, liens symboliques ou confirmation d’opérations destructrices ;
- traitement non sûr de paramètres, noms de bases ou chemins lors des imports et commandes Make ;
- suppression, écrasement ou divulgation imprévus de données, mots de passe ou configuration locale ;
- contournement des contrôles de provenance ou d’intégrité des échantillons, ou problèmes d’images, plugins Adminer ou CI affectant la sécurité.

Signalez les bugs ordinaires via [GitHub Issues](https://github.com/yaleksandr89/docker-sql-lab/issues), les questions et idées via [GitHub Discussions](https://github.com/yaleksandr89/docker-sql-lab/discussions). Si le problème concerne un composant amont, précisez sa version exacte et son impact sur le laboratoire ; signalez également les défauts du composant à ses mainteneurs selon leurs règles.

## Signaler une vulnérabilité

Privilégiez GitHub Private Vulnerability Reporting : ouvrez **Security and quality → Report a vulnerability**. Si cette option est indisponible, demandez un canal privé dans GitHub Discussions sans publier de détails techniques de la vulnérabilité.

Ne publiez pas de mots de passe, jetons, configurations locales ou de production, données réelles, logs complets, exploits fonctionnels ou détails sensibles avant la divulgation coordonnée. Utilisez uniquement des données synthétiques ou des extraits nettoyés.

## Contenu du rapport

- Release, branch ou commit concerné et versions de MySQL, PostgreSQL, Adminer, Docker et Compose si pertinentes.
- Mode de lancement (MySQL, PostgreSQL, les deux, avec ou sans Adminer), commande Make concernée et limite d’accès attendue.
- Étapes minimales de reproduction, comportement attendu et réel.
- Extraits nettoyés de requêtes, réponses ou logs et correctif possible s’il est connu.

## Traitement du rapport

Les rapports sont examinés selon les disponibilités ; aucun SLA fixe n’est promis. Coordonnez la divulgation avec le mainteneur. Après confirmation, les correctifs et les informations sur les versions affectées sont publiés dans le cadre d’une divulgation coordonnée. Aucun programme de récompense des vulnérabilités n’est annoncé.
