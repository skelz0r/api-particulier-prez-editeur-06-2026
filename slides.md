---
title: Sécuriser & simplifier les accès
tags: presentation, api-particulier
slideOptions:
  theme: white
  transition: none
  backgroundTransition: none
  slideNumber: true
  width: 1280
  height: 720
---

<style>
  .reveal { font-size: 32px; }
  .reveal .slides { text-align: left; }
  .reveal .slides section { height: 100%; }
  .reveal h1, .reveal h2, .reveal h3 { color: #000091; text-transform: none; letter-spacing: 0; font-weight: 700; }
  .reveal h1 { font-size: 1.8em; }
  .reveal h2 { font-size: 1.3em; border-bottom: 3px solid #000091; padding-bottom: .2em; margin-bottom: .6em; }
  .reveal h3 { font-size: 1.05em; }
  .reveal strong { color: #000091; }
  .reveal p, .reveal li { line-height: 1.4; }
  .reveal li { margin: .3em 0; }
  .reveal pre { width: 100%; box-shadow: none; margin: .6em 0; }
  .reveal pre code { font-size: 0.62em; line-height: 1.45; padding: 16px 20px; background: #f5f6fb; color: #161616; border: 1px solid #ddd; border-left: 4px solid #000091; border-radius: 4px; max-height: none; }
  .reveal table { font-size: 0.74em; margin: .4em 0; width: 100%; }
  .reveal th { background: #f0f0ff; color: #000091; }
  .reveal td, .reveal th { padding: .35em .7em; border: 1px solid #ddd; }
  .reveal small { color: #666; }
  .reveal a { color: #000091; }
  .reveal section > p:first-of-type { margin-top: 0; }
  .reveal section.section-divider { text-align: center; }
  .reveal section.section-divider h2 { color: #fff; border: none; font-size: 2.2em; margin-bottom: .3em; }
  .reveal section.section-divider p { color: #f5f5fe; font-size: 1.1em; }
</style>

# Sécuriser & simplifier les accès

### API Particulier : présentation éditeurs

<small>Délégation · Espace éditeur · Sécurisation · Traçabilité</small>

Note: Objectif du jour : partager la trajectoire et recueillir votre avis,
notamment IP vs DPoP. Un sondage vous sera envoyé après la présentation.

---

## Au programme

1. Contexte & objectifs
2. Délégation : jeton éditeur & OAuth2
3. Sécurisation des accès : IP / DPoP
4. Tracking de l'agent final
5. Questionnaire de sécurité (homologation)
6. Nouvel espace éditeur
7. Attestations PDF vérifiables

**→ puis échanges — un sondage vous sera envoyé après**

Note: 7 sujets, 2 fils rouges : sécuriser ET simplifier. Tout est opt-in et
progressif. Comptez ~30 min, puis échanges.

---

## Contexte : le constat

API Particulier est massivement consommée **via les éditeurs**.

```text
1 éditeur  →  des dizaines/centaines de
              collectivités (mairies, CCAS)
```

Quatre angles morts aujourd'hui :

- Lien habilitation ↔ éditeur **implicite**
- Jetons **rejouables**, parfois sans expiration
- Espace éditeur **minimal**
- **Aucune** traçabilité de l'agent final

Note: Les éditeurs sont le point de levier. Ces 4 angles morts justifient
exactement les 4 chantiers qui suivent.

---

## Contexte : deux objectifs

```text
SÉCURISER                    SIMPLIFIER
un jeton fuité  ≠            relation éditeur ↔
utilisable ailleurs         administration : claire
```

**En bref :** on resserre la sécurité *et* on allège vos procédures.

Note: Deux fils complémentaires, pas un arbitrage. Sécuriser ne doit pas
complexifier : on simplifie en parallèle (jeton éditeur).

---

## Contexte : comment on avance

- **Progressivité :** mode log d'abord, *enforcement* ensuite
- **Accompagnement :** contact + setup initial par l'équipe
- **Non-régression :** l'existant continue de fonctionner
- **Opt-in :** le contraignant est proposé, pas imposé

<small>Détails (PDF) : [00-contexte-objectifs.pdf](00-contexte-objectifs.pdf)</small>

Note: Message à faire passer : rien n'est activé en silence. On démarre en mode
log, l'existant continue de tourner. C'est accompagné, pas imposé.

---

## Délégation
<!-- .slide: class="section-divider" data-background-color="#000091" -->

Lier l'habilitation à l'éditeur, et simplifier l'intégration.

Note: Cœur du sujet : créer un lien formel éditeur ↔ habilitation, et au
passage simplifier vos intégrations.

---

## Délégation : le principe

```text
Administration  →  délègue  →  Éditeur
(habilitation)               (fait les appels)
```

Aujourd'hui **implicite** → demain **formel + transparent**.

L'administration doit **savoir** à qui ses accès sont délégués.

Deux déclinaisons : **jeton éditeur** (en dev) · **OAuth2** (vision).

<small>Détails (PDF) : [01a-delegation-intro.pdf](01a-delegation-intro.pdf)</small>

Note: Aujourd'hui le lien est deviné via les formulaires. On veut le rendre
explicite, et transparent pour la collectivité.

---

## Délégation : le jeton éditeur

La mécanique, en 3 points :

- **1 jeton, 0 droit** : les droits viennent de la délégation, pas du jeton
- **Désignez le client** : `recipient` (SIRET) et/ou `delegation_id`
- **`delegation_id` seul suffit** ; le SIRET devient alors inutile

```http
GET /v3/dss/quotient_familial/identite
      ?recipient=21560124000018       # SIRET de la collectivité
      &delegation_id=6f3c8d9a         # lève l'ambiguïté
Host: particulier.api.gouv.fr
Authorization: Bearer $JETON_EDITEUR  # 1 jeton pour tous vos clients
```

Note: Le message clé : 1 jeton au lieu de 300. Le recipient désigne le client ;
le delegation_id seul suffit (le SIRET devient optionnel).

---

## Délégation : récupérer ses délégations

Une **API dédiée au jeton éditeur** pour lister vos `id` de délégation :

```http
GET /editeur/api/v1/delegations
Authorization: Bearer $JETON_EDITEUR
```

```json
{ "data": [
  { "id": "6f3c8d9a", "siret": "21560124000018",
    "intitule": "Restauration scolaire",
    "scopes": ["dss_quotient_familial"], "statut": "active" }
]}
```

Récupérez l'`id` ici → réutilisez-le en `delegation_id`.

<small>Détails (PDF) : [01b-jeton-editeur.pdf](01b-jeton-editeur.pdf)</small>

Note: Vous êtes autonomes : une API pour lister vos délégations et leurs id.
Plus besoin de nous demander qui vous avez le droit de servir.

---

## OAuth2 : pourquoi c'est intéressant

Aujourd'hui la délégation passe par une **procédure manuelle**.

Avec OAuth2, **tout se configure dans le logiciel** :

- La collectivité clique « **Connecter API Particulier** » dans **votre** produit
- Elle **consent** explicitement (compte ProConnect)
- La **délégation se crée automatiquement**, sans ticket ni délai

Côté éditeur : **effort d'implémentation conséquent** (flow OAuth2). Deux
formes à l'étude (surcouche du jeton éditeur, ou jetons OAuth2 à expiration).

**Vision, non implémenté** : on recueille votre intérêt.

Note: Bénéfice = onboarding self-service. Mais c'est un vrai chantier côté
éditeur, et deux designs possibles. À ce stade c'est une piste : on jauge
votre intérêt.

---

## OAuth2 : démo

<iframe src="https://www.loom.com/embed/1c050660e244444683b2ba6f22769d54" frameborder="0" allowfullscreen style="width: 72%; height: 430px;"></iframe>

[Voir la démo sur Loom](https://www.loom.com/share/1c050660e244444683b2ba6f22769d54)

<small>Détails (PDF) : [01c-oauth2.pdf](01c-oauth2.pdf)</small>

Note: Lancer le Loom. Montre la création d'une délégation en quelques clics
depuis le logiciel. Court (~1 min).

---

## Sécurisation
<!-- .slide: class="section-divider" data-background-color="#000091" -->

Qu'un jeton fuité soit inutilisable ailleurs.

Note: Le sujet sur lequel on veut vraiment votre retour (IP vs DPoP). Objectif :
lier le jeton à son appelant légitime.

---

## Sécurisation : le problème

Le jeton est un **bearer** : un porteur. Volé, il marche **partout**.

```text
Jeton fuité (git, log, copie d'écran)
  →  utilisable depuis n'importe où
  →  accès accordé   (problème)
```

**Objectif :** lier le jeton à son **appelant légitime**.
À terme, **au moins un** des deux mécanismes suivants.

Note: Poser le risque concret : un jeton bearer qui fuite marche depuis
n'importe où. D'où le besoin de le lier à l'appelant.

---

## Sécurisation · Option A : filtrage IP

On déclare les **IP autorisées**.

```text
IP autorisée  →  OK
autre IP      →  refusé (403)
```

- **Aucune config technique** côté éditeur (fournir ses IP)
- Pour les éditeurs à **IP stables** (la majorité)
- Limite : inapplicable sans IP de sortie stable (cloud serverless)

Note: La voie simple : zéro code, vous nous fournissez vos IP. On a déjà
identifié les éditeurs à IP stables.

---

## Sécurisation · Option B : DPoP

Une **signature par requête** (RFC 9449) : le bearer seul ne suffit plus.

```http
GET /v3/dss/quotient_familial/identite
Authorization: Bearer $JETON
DPoP: eyJ0eXAiOiJkcG9wK2p3dCIsImFsZyI6...   # preuve signée
```

- Clé **privée** chez vous · clé **publique** déposée chez nous
- On **vérifie** la signature (méthode + URL + instant), aucun déchiffrement
- Jeton volé **sans la clé privée → inutilisable**
- Coût : **un peu de code** (signer chaque appel)

Note: Pour ceux sans IP stable. On vérifie, on ne déchiffre rien. Le coût est
récurrent (signer chaque appel), d'où la réserve aux éditeurs outillés.

---

## Sécurisation : IP, DPoP, ou les deux ?

| | Filtrage IP | DPoP |
|---|:---:|:---:|
| Config éditeur | **Aucune** | **Un peu de code** |
| Cible | IP stables | Cloud / sans IP stable |
| Jeton fuité | bloqué hors IP | bloqué **partout** |

Déploiement **log → enforcement**, accompagné puis self-service.

<small>Détails (PDF) : [03-securisation-acces-ip-dpop.pdf](03-securisation-acces-ip-dpop.pdf)</small>

Note: Complémentaires (ceinture + bretelles). Le choix dépend de votre infra :
c'est précisément la question qu'on posera dans le sondage à venir.

---

## Traçabilité & conformité
<!-- .slide: class="section-divider" data-background-color="#000091" -->

Tracer l'agent final, formaliser les bonnes pratiques.

Note: Deux briques : tracer l'agent final (en cas de contrôle), et
l'homologation (bonnes pratiques de sécurité).

---

## Tracking : le besoin

Aujourd'hui on sait *qu'un éditeur* a appelé, pas **quel agent**.

But : un **identifiant unique de l'agent final** par appel.

```text
identifiant agent  →  haché  →  stocké en logs
contrôle : valeur connue  →  re-hachée  →  comparée
```

**On ne déchiffre rien** : on compare des empreintes.

Note: On veut pouvoir remonter à un usage précis en cas de contrôle, sans
stocker d'identité en clair (uniquement des hash).

---

## Tracking : ce que ça implique

- Effort éditeur **faible** : un identifiant par appel
- Identifiant **stable et unique**, pas forcément nominatif
- Confidentialité : **rien en clair** chez nous (que des hash)
- **Notre** spec (header **temporaire**) : extension possible, rien de figé

<small>Détails (PDF) : [04-tracking-agent-final.pdf](04-tracking-agent-final.pdf)</small>

Note: Effort faible (un id par appel). C'est notre décision, pas une contrainte
externe ; le header est provisoire, on l'affine avec vous.

---

## Homologation : questionnaire de sécurité

Vérifier les **bonnes pratiques** côté éditeur. Logique de **confiance**.

- Jetons / secrets · sécurisation des accès · traçabilité · accès
- **Déclaratif et accompagné**, pas un audit-sanction
- **À co-construire** avec vous

<small>Détails (PDF) : [05-questionnaire-securite-homologation.pdf](05-questionnaire-securite-homologation.pdf)</small>

Note: Pas un audit-sanction : un état des lieux déclaratif et accompagné. Le
contenu se co-construit avec vous.

---

## Pour vous aider : clients & SDK officiels

Inutile de tout réécrire : des **clients officiels open source**.

- Référence **Ruby** et **Node** (Python, PHP, Java à venir)
- Gèrent l'**auth**, le **jeton éditeur** (`recipient`, `delegation_id`), à terme **DPoP**
- Basés sur une **spec normative** (contrat HTTP unique)

```ruby
client = ApiParticulier.new(token: ENV["JETON_EDITEUR"])
client.quotient_familial(recipient: "21560124000018",
                         delegation_id: "6f3c8d9a")
```

Note: On fournit des clients officiels (Ruby, Node) pour ne pas tout
réimplémenter, jeton éditeur inclus et bientôt DPoP.

---

## On veut votre avis

Un **sondage vous sera envoyé** après la présentation :

- **IP vs DPoP vs les deux** : préférence & faisabilité
- Intérêt **jeton éditeur** / **OAuth2**
- Priorités sur le **nouvel espace éditeur**
- Volontaires pour un **pilote en mode log**

Note: Le sondage oriente nos priorités. Insister sur IP vs DPoP et le
volontariat pour un pilote en mode log.

---

## Espace éditeur
<!-- .slide: class="section-divider" data-background-color="#000091" -->

Le cockpit où vous pilotez tout.

Note: La rubrique qui matérialise tous les autres chantiers : délégations,
sécurité, jetons, logs, membres.

---

## Espace éditeur : le cockpit

D'un simple listing à un **cockpit complet** :

| Profil | Sécurité (IP / DPoP) | Habilitations |
|:------:|:--------------------:|:-------------:|
| **Jetons éditeurs** | **Logs d'accès** | **Membres** |

C'est ici qu'on **pilote tous les autres chantiers**.

Note: On passe d'un simple listing à 6 rubriques. Insister : c'est le liant de
toute la présentation.

---

## Espace éditeur : aperçu

<img src="espace-editeur.png" alt="Espace éditeur" style="max-height: 540px; border: 1px solid #ddd; box-shadow: 0 2px 8px rgba(0,0,0,.15);">

<small>Démo interactive : [mockup-espace-editeur.html](mockup-espace-editeur.html)</small>

Note: C'est une maquette (données fictives Promucad), pas encore le produit
final. Ouvrir le lien interactif si le temps le permet.

---

## Espace éditeur : ouverture progressive

```text
Étape 1 : ACCOMPAGNÉ   →   Étape 2 : SELF-SERVICE
opérations sensibles       configuration en autonomie
via l'équipe               (IP, clé DPoP, délégations)
```

On enrichit l'espace **au fil des chantiers**, pas tout d'un coup.

<small>Détails (PDF) : [02-espace-editeur.pdf](02-espace-editeur.pdf)</small>

Note: Au début, les opérations sensibles (IP, clé DPoP) passent par l'équipe.
On ouvre le self-service progressivement.

---

## Attestations PDF vérifiables
<!-- .slide: class="section-divider" data-background-color="#000091" -->

Prouver l'authenticité d'une donnée, sans logiciel.

Note: En cours de développement sur plusieurs endpoints (ex. quotient familial).

---

## Attestations PDF : le cas d'usage

Un appel API pourra produire une **attestation officielle** contrôlable
par n'importe quel agent — sans logiciel, juste un navigateur.

Cas d'usage type :

1. L'agent récupère le QF → obtient en même temps le PDF mis en forme
2. Il joint le PDF au dossier (ou archive simplement le lien de vérification)
3. Un autre agent contrôle l'authenticité : QR code ou lien → page de
   vérification → compare le code affiché au code imprimé sur le PDF

Deux niveaux de preuve :

- **`proof-only`** : lien + code de vérification, valable **~5 ans**
- **`pdf`** : idem + lien de téléchargement du document mis en forme

<small>Détails (PDF) : [06-attestations-pdf.pdf](06-attestations-pdf.pdf)</small>

Note: Le lien de vérification est à lui seul le justificatif durable.
Le PDF n'est utile que si on veut le joindre ou l'imprimer.

---

## Attestations PDF : comment ça marche

Un en-tête suffit pour obtenir une **preuve officielle et contrôlable** :

```http
GET /v3/dss/quotient_familial/identite
X-Generate-Proof: pdf          # ou proof-only (lien sans PDF)
Authorization: Bearer <jeton>
```

La réponse (bloc `data` inchangé) ajoute :

- `links.attestation_pdf` → lien de téléchargement du PDF (expire en ~5 min)
- `meta.pdf_verification_link` + `meta.pdf_verification_code` → preuve
  contrôlable sur `particulier.api.gouv.fr` pendant **~5 ans**, sans logiciel

Le PDF embarque un **QR code** et le code de vérification ; la page de
contrôle n'expose qu'un sous-ensemble (pas d'identité complète).

<small>Détails (PDF) : [06-attestations-pdf.pdf](06-attestations-pdf.pdf)</small>

Note: proof-only = archiver le lien + code sans jamais télécharger le PDF.
Le lien de vérification est à lui seul le justificatif durable.

---

## Merci

Échanges et questions — **le sondage arrive par email**.

On revient vers chacun pour le **suivi individuel**.

Note: Inviter à se signaler comme pilote. Rappeler les prochaines étapes et
le calendrier.
