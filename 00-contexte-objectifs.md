# 0. Contexte & objectifs

## 1. Pourquoi ce chantier

API Particulier est massivement consommée **via des éditeurs** : un éditeur
équipe des dizaines, voire des centaines de collectivités et de CCAS. Cette
concentration est un atout (un seul interlocuteur technique pour beaucoup
d'usagers), mais elle crée des angles morts qu'on veut corriger.

Deux objectifs complémentaires :

1. **Sécuriser les accès.** Le jeton API est un *bearer token* : quiconque le
   détient l'utilise depuis n'importe où. Un jeton qui fuite est exploitable
   tel quel. On veut **lier chaque accès à son appelant légitime**.
2. **Simplifier et clarifier la relation éditeur / administration.** Le lien
   entre une habilitation (portée par l'administration) et l'éditeur qui
   l'exploite est aujourd'hui implicite. On veut le rendre **explicite et
   transparent**.

## 2. Le constat de départ

| Aujourd'hui | Conséquence |
|---|---|
| Lien habilitation / éditeur **implicite** (deviné via les formulaires) | Pas de transparence pour l'usager |
| Jetons **bearer**, parfois sans expiration | Un jeton fuité marche partout, indéfiniment |
| Espace éditeur **minimal** (simple listing) | Aucun pilotage en autonomie |
| **Aucune** trace de l'agent final | Impossible de remonter à un usage précis |

## 3. Les chantiers présentés

| Chantier | Ce que ça apporte | Effort éditeur |
|---|---|---|
| **Délégation** (jeton éditeur, OAuth2) | 1 lien clair éditeur / habilitation, moins de jetons | Moyen à élevé, opt-in |
| **Nouvel espace éditeur** | Un cockpit pour tout piloter | Nul (c'est un service) |
| **Sécurisation IP / DPoP** | Un jeton fuité devient inutilisable ailleurs | Nul (IP) à moyen (DPoP) |
| **Tracking de l'agent final** | Traçabilité fine en cas de contrôle | Faible (un identifiant par appel) |
| **Homologation sécurité** | Confiance mutuelle, conformité | Déclaratif |

## 4. Comment on avance

- **Progressivité** : d'abord en mode observation (log), puis en application
  (enforcement). Rien n'est activé en silence.
- **Accompagnement** : chaque éditeur est contacté ; le setup initial est
  réalisé par l'équipe.
- **Non-régression** : jetons et intégrations existants continuent de
  fonctionner pendant la transition.
- **Opt-in** : les mécanismes contraignants (jeton éditeur, OAuth2) sont
  proposés, pas imposés.

## 5. Ce qu'on attend de cette présentation

- Partager la **trajectoire** et le **calendrier** des chantiers.
- Recueillir votre **avis** sur les options de sécurisation
  (**IP vs DPoP vs les deux**), via le sondage de feedback.
- Identifier des **éditeurs volontaires** pour les premiers pilotes (mode log).

## 6. À retenir

- Deux fils : **sécuriser** et **simplifier**.
- Tout est **progressif, accompagné, non cassant**.
- On veut votre **retour avant d'enforcer**.
