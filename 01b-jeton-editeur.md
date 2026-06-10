# Le jeton éditeur

Ce document explique comment un **jeton éditeur** vous permet d'appeler
API Particulier pour toutes vos collectivités avec **un seul jeton**, comment
l'API retrouve la bonne habilitation, comment piloter vos délégations, et
comment se comportent quota et révocation.

---

## 1. À quoi ça sert

Historiquement, le modèle est **1 habilitation = 1 jeton**. Un éditeur qui sert
300 collectivités doit créer, stocker, faire tourner et sécuriser **300
jetons**. C'est lourd et risqué.

Le jeton éditeur change la donne : **un seul jeton, permanent, sans droits
propres**. Les droits ne sont plus portés par le jeton, mais par la
**délégation** que chaque collectivité vous accorde.

```text
AVANT                                APRÈS
collectivité A -> jeton A            collectivité A ┐
collectivité B -> jeton B            collectivité B ┤
collectivité C -> jeton C    ===>    collectivité C ┼-> 1 jeton éditeur
   ...             ...                    ...        ┘   + destinataire par appel
collectivité Z -> jeton Z            collectivité Z ┘
```

## 2. Obtenir un jeton éditeur

Le jeton éditeur vous est **fourni par l'équipe** : une fois les délégations
activées pour votre compte, un jeton est généré côté back-office et mis à
disposition dans l'espace éditeur.

Techniquement, c'est un **JWT** (avec date d'émission et d'expiration). Il ne
contient **aucun scope** : les scopes sont résolus dynamiquement via la
délégation, à chaque appel.

## 3. Comment l'API retrouve la bonne habilitation

À chaque appel, vous présentez le **jeton éditeur** et indiquez **pour qui**
vous appelez. L'API résout alors la délégation correspondante et applique ses
droits.

```text
jeton éditeur  +  destinataire (recipient et/ou delegation_id)
        |
        v
  résolution de la délégation active
        |
        v
  scopes, IP autorisées, limites de l'habilitation  -->  réponse
```

Pour désigner le destinataire, vous fournissez **au moins l'un** de ces deux
paramètres :

- **`delegation_id`** : désigne **directement** une délégation (donc
  l'habilitation et son SIRET). Il **suffit à lui seul**.
- **`recipient`** (SIRET de la collectivité) : suffit s'il n'existe **qu'une**
  délégation active pour ce SIRET ; sinon, ajoutez le `delegation_id`.

Le SIRET n'est donc **pas toujours nécessaire** : avec un `delegation_id`, il
devient inutile.

## 4. Exemples d'appel

Avec le SIRET (cas courant) :

```http
GET /v3/dss/quotient_familial/identite?recipient=21560124000018&delegation_id=6f3c8d9a HTTP/1.1
Host: particulier.api.gouv.fr
Authorization: Bearer <votre_jeton_editeur>
```

Avec le seul `delegation_id` (le `recipient` est alors inutile) :

```http
GET /v3/dss/quotient_familial/identite?delegation_id=6f3c8d9a HTTP/1.1
Host: particulier.api.gouv.fr
Authorization: Bearer <votre_jeton_editeur>
```

Le bloc `data` de la réponse est **identique** à un appel classique : seul le
mode d'authentification change.

### Réponses selon le cas

| Situation | Réponse |
|---|---|
| Ni `recipient` ni `delegation_id` | `422` (on ne sait pas pour qui) |
| `delegation_id` valide et actif | succès |
| `recipient` seul, une seule délégation | succès |
| `recipient` seul, plusieurs délégations | `422` (ambiguïté, code dédié) |
| `recipient` / `delegation_id` ne correspond à aucune délégation active | `403` |

## 5. Piloter ses délégations (API dédiée)

Une **API réservée au jeton éditeur** liste vos délégations, **en autonomie**.
C'est là que vous récupérez les `id` à réutiliser comme `delegation_id`.

```http
GET /editeur/api/v1/delegations?page=1&per_page=50 HTTP/1.1
Host: particulier.api.gouv.fr
Authorization: Bearer <votre_jeton_editeur>
```

Elle est **paginée** : `page` (défaut 1) et `per_page` (défaut 50, **max 100**).

```json
{
  "data": [
    {
      "id": "6f3c8d9a",
      "authorization_request_id": 48231,
      "siret": "21560124000018",
      "intitule": "Restauration scolaire",
      "scopes": ["dss_quotient_familial"],
      "statut": "active",
      "created_at": "2026-03-12T10:00:00Z"
    }
  ],
  "meta": { "page": 1, "per_page": 50, "total": 1, "total_pages": 1 }
}
```

| Champ | Sens |
|---|---|
| `id` | Identifiant de la délégation, à passer en `delegation_id` |
| `authorization_request_id` | Le numéro DataPass de l'habilitation |
| `siret` | SIRET de la collectivité |
| `intitule` / `scopes` | Intitulé et périmètre de l'habilitation |
| `statut` | `active` ou `revoked` |

## 6. Quota (rate limiting)

Le quota d'appels est appliqué **au niveau de l'habilitation résolue**, pas du
jeton. Conséquences :

- un jeton éditeur et un jeton classique pointant vers la **même** habilitation
  **partagent** le compteur ;
- pour un même jeton éditeur, **chaque délégation a son propre compteur** ;
- la limite se pilote au niveau de l'habilitation (réglages de sécurité).

Autrement dit, passer au jeton éditeur **ne change pas** vos quotas par
collectivité.

## 7. Révocation

Une délégation peut être **révoquée** (par la collectivité ou par nous). Elle
passe alors en `statut: revoked` et les appels la concernant sont refusés.

> La révocation d'une délégation **ne casse pas votre jeton** : le jeton éditeur
> reste valable pour toutes vos autres délégations.

## 8. Pour qui ?

| Profil | Adapté ? | Pourquoi |
|---|---|---|
| **SaaS centralisé** | Oui, cas idéal | Une seule infra sert toutes les collectivités |
| **On-premise** | Peu adapté | Le logiciel est installé chez chaque collectivité (N infras) |

C'est **opt-in** : si le jeton éditeur ne convient pas à votre architecture, le
mode « un jeton par habilitation » reste possible.

---

## FAQ

**Comment j'obtiens mon jeton éditeur ?**
Par l'équipe, une fois les délégations activées pour votre compte. Il apparaît
ensuite dans l'espace éditeur.

**Dois-je toujours envoyer le SIRET (`recipient`) ?**
Non. Un `delegation_id` identifie déjà la délégation : le `recipient` devient
inutile.

**Comment lister beaucoup de délégations ?**
Via la pagination (`page` / `per_page`, max 100 par page) ; le bloc `meta`
indique `total` et `total_pages`.

**Le jeton éditeur expire-t-il ?**
C'est un JWT avec une expiration. Vous n'avez pas à le faire tourner à chaque
nouveau client ; sa rotation se gère côté équipe / espace éditeur.

**Dois-je migrer mes jetons existants d'un coup ?**
Non. La transition est progressive ; vos jetons actuels continuent de
fonctionner.
