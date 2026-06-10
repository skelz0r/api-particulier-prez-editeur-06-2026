# Sécuriser les accès : IP et DPoP

Ce document explique pourquoi et comment lier votre jeton à votre
infrastructure, pour qu'un jeton qui fuite reste **inutilisable ailleurs**.

---

## 1. Le problème

Le jeton API est un **bearer token** : un porteur. Quiconque le détient peut
l'utiliser **depuis n'importe où**. Un jeton qui fuite (dépôt Git public, log,
copie d'écran, poste compromis) est exploitable tel quel par un tiers.

```text
  Votre jeton  --- fuite --->  Tiers malveillant
                                     |
                                     v
                       appel accepté depuis n'importe où
```

Le but n'est pas de « filtrer des IP » pour le plaisir, mais de **lier le jeton
à son appelant légitime**. Deux mécanismes y répondent, **complémentaires** : à
terme, on demandera **au moins l'un des deux**.

## 2. Option A : filtrage IP

Vous déclarez les **adresses IP** depuis lesquelles vos appels partent. Un appel
venant d'une autre IP est refusé (`403`, code d'erreur dédié).

```text
appel depuis IP autorisée   --->  [ API ]  --->  200 OK
appel depuis une autre IP   --->  [ API ]  --->  403 refusé
```

```http
GET /v3/dss/quotient_familial/identite HTTP/1.1
Host: particulier.api.gouv.fr
Authorization: Bearer <votre_jeton>
```

(L'appel est identique à d'habitude : le contrôle se fait sur l'IP source.)

**En pratique :**

- **Aucune configuration technique** de votre côté : vous nous communiquez vos
  IP de sortie (ou les déclarez dans l'espace éditeur).
- Idéal pour les éditeurs à **IP de sortie stables**, soit la grande majorité.
- Le mécanisme accepte les IP unitaires et les plages **CIDR** (`51.158.66.0/24`).

**Limite :** inapplicable si vous n'avez pas d'IP de sortie stable (cloud
serverless, conteneurs sans NAT fixe). Dans ce cas, voir DPoP.

## 3. Option B : DPoP

DPoP (**standard RFC 9449**) ajoute à chaque requête une **signature** qui
prouve que c'est bien vous. Le jeton seul ne suffit plus.

### Le principe

```text
Vous            : générez une paire de clés
                  clé privée (gardée secrète) + clé publique (déposée chez nous)

À chaque appel  : vous SIGNEZ une note décrivant l'appel
                  (méthode + URL + instant + valeur unique)

Nous            : vérifions la signature avec votre clé publique
                  -> aucun déchiffrement, juste un contrôle
```

Un jeton volé **sans la clé privée** devient inutile : le voleur a la carte,
mais pas la main qui signe.

### Ce que contient la preuve

La preuve est un **petit JWT** (`typ: dpop+jwt`) placé dans l'en-tête `DPoP`. Il
embarque votre **clé publique** (au format JWK) et signe les champs suivants :

| Champ | Rôle |
|---|---|
| `htm` | Méthode HTTP : la preuve ne vaut que pour ce verbe |
| `htu` | URL appelée : pas de rejeu sur une autre route |
| `iat` | Instant de signature : rejet si trop ancien (fenêtre ~60s) |
| `jti` | Identifiant unique : mémorisé quelques secondes, anti-rejeu |
| `ath` | Empreinte du jeton : lie la preuve à ce bearer précis |

### Ce qu'on vérifie en face

1. La signature correspond à la clé publique, dont l'**empreinte** (`jkt`,
   thumbprint RFC 7638) est **épinglée** chez nous.
2. `htm` / `htu` correspondent à la requête réelle.
3. `iat` est récent (fenêtre de tolérance ~60s).
4. `jti` n'a jamais été vu (anti-rejeu).
5. `ath` correspond au jeton présenté.

On épingle **l'empreinte de la clé**, jamais la clé privée : nous confier la clé
publique ne donne aucun pouvoir d'usurpation.

### En requête

```http
GET /v3/dss/quotient_familial/identite HTTP/1.1
Host: particulier.api.gouv.fr
Authorization: Bearer <votre_jeton>
DPoP: eyJ0eXAiOiJkcG9wK2p3dCIsImFsZyI6...
```

L'en-tête `DPoP` change **à chaque appel** (nouvel `iat`, nouveau `jti`).

**En pratique :**

- Clé **privée** chez vous, jamais partagée ; clé **publique** déposée une fois.
- Coût : **un peu de code** (signer chaque requête). Réservé aux éditeurs qui
  ont une équipe technique.
- Cible : les éditeurs **sans IP stable** (cloud, SaaS multi-régions).
- Un appel sans preuve valide est refusé (`403`, code d'erreur dédié).

## 4. IP, DPoP, ou les deux ?

| | Filtrage IP | DPoP |
|---|---|---|
| Ce que ça prouve | L'appel vient d'un réseau autorisé | L'appel est signé par le bon détenteur de clé |
| Config technique éditeur | **Aucune** | **Un peu de code** |
| Cible | IP stables | Cloud / sans IP stable |
| Résiste à un jeton fuité | Oui, sauf depuis une IP autorisée | Oui, même depuis n'importe où |
| Anti-rejeu | Implicite (réseau) | Explicite (`jti`) |

Les deux sont **complémentaires** : ceinture + bretelles. Le choix dépend de
votre infrastructure.

## 5. En complément : durée de vie des jetons

Indépendamment d'IP/DPoP, **raccourcir la durée de vie des jetons** réduit la
fenêtre d'exploitation d'un jeton volé. Priorité : corriger les jetons qui
n'expirent pas. C'est applicable à tous et se combine avec les deux options.

## 6. Alternative documentée : mTLS

Même objectif (prouver la possession d'une clé, pas une IP), mais l'effort est
surtout **infra/ops** : le certificat client est vérifié au reverse proxy, et on
épingle son empreinte. Côté client, c'est de la **configuration** (ex.
`curl --cert`), pas de la signature par requête.

Non retenu par défaut ici : on veut piloter la protection **côté applicatif**, et
mTLS déplace la logique vers le proxy et ajoute un cycle de vie de certificats.
À garder en tête si vous visez **zéro code client**.

## 7. Comment ça se déploie

```text
1. Paramétrage          2. Mode log               3. Enforcement
   (par l'équipe)          on observe,                on applique :
                           on ne bloque pas           les appels non
                                                      conformes sont refusés
```

- **Mode log d'abord** : rien n'est bloqué, vous ajustez votre client en voyant
  les éventuels écarts.
- **Enforcement ensuite** : on bascule, coordonné avec vous.
- Nous avons **déjà identifié** les éditeurs à IP stables : setup initial à
  partir des appels observés, puis suivi individuel.

---

## FAQ

**Je n'ai pas d'IP fixe, que faire ?**
DPoP est fait pour ça : la protection ne dépend plus de l'IP.

**DPoP m'oblige-t-il à vous confier un secret ?**
Non. Vous déposez une **clé publique** ; la clé privée ne quitte jamais votre
infrastructure. On vérifie, on ne déchiffre rien.

**Si ma clé est compromise ?**
On retire l'empreinte épinglée (`jkt`) ; les preuves signées avec cette clé ne
passent plus. Vous redéposez une nouvelle clé publique.

**Puis-je tester sans risque de blocage ?**
Oui. Tout démarre en mode log ; on bascule en enforcement seulement avec vous.

**Le jeton éditeur dispense-t-il de tout ça ?**
Non, mais il aide : avec un jeton éditeur, c'est **une seule infrastructure**
(la vôtre) à protéger, au lieu de N habilitations.
