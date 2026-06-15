# Attestations PDF vérifiables — Guide API

Ce guide explique comment obtenir, depuis les endpoints API Particulier,
une **attestation PDF officielle et vérifiable** (exemple : quotient
familial CAF), et comment un tiers peut en contrôler l'authenticité.

---

## 1. À quoi ça sert

Sur un appel API, en plus des données JSON habituelles, vous pouvez
demander **une preuve d'attestation** :

- un **lien de vérification** + un **code** que n'importe quel agent
  peut contrôler en ligne, et
- (optionnellement) un **lien de téléchargement du PDF** mis en forme,
  prêt à joindre à un dossier.

Cas d'usage type : un agent récupère le quotient familial d'un usager,
joint l'attestation au dossier, et un autre agent vérifie plus tard
qu'elle n'a pas été falsifiée — sans logiciel particulier, juste un
navigateur.

---

## 2. Demander une attestation : l'en-tête `X-Generate-Proof`

Par défaut, les endpoints renvoient les données nues. Pour obtenir une
preuve, ajoutez l'en-tête **`X-Generate-Proof`** à votre requête
(authentifiée, comme d'habitude) :

| Valeur de l'en-tête | Ce que vous recevez |
|---------------------|---------------------|
| *(absent)* | Données nues. Comportement inchangé. |
| `proof-only` | Données + **lien et code de vérification** (`meta`). Pas de PDF. |
| `pdf` | Comme `proof-only` + un **lien de téléchargement du PDF** (`links`). |

```http
GET /v3/dss/quotient_familial/identite HTTP/1.1
Host: particulier.api.gouv.fr
Authorization: Bearer <votre_jeton>
X-Generate-Proof: pdf
```

**Pourquoi deux modes ?**

- `proof-only` suffit si vous voulez seulement **archiver la preuve**
  (lien + code) dans votre dossier métier, sans jamais télécharger de
  PDF. Le lien de vérification reste valable plusieurs années : il est
  à lui seul votre justificatif.
- `pdf` quand vous avez besoin du document mis en forme (à imprimer,
  joindre, transmettre).

Vous pouvez donc **ne pas télécharger le PDF** si vous n'en avez pas
besoin — et le PDF n'est généré que lorsque vous suivez réellement le
lien.

---

## 3. La réponse

Le bloc `data` est **identique** à l'appel standard. Les nouveautés
apparaissent dans `links` et `meta`.

| Emplacement | Clé | Présent en | Contenu |
|-------------|-----|-----------|---------|
| `links` | `attestation_pdf` | mode `pdf` | Lien de téléchargement du PDF |
| `meta` | `pdf_link_expires_in` | mode `pdf` | Expiration du lien ci-dessus (timestamp Unix, secondes) |
| `meta` | `pdf_verification_link` | `proof-only` et `pdf` | Lien de la page de vérification |
| `meta` | `pdf_verification_code` | `proof-only` et `pdf` | Code de vérification visuel (10 caractères) |

### Avant / après — payload

**Avant** — `GET /v3/dss/quotient_familial/identite` (sans en-tête) :

```json
{
  "data": {
    "quotient_familial": {
      "fournisseur": "CNAF",
      "valeur": 2550,
      "annee": 2024,
      "mois": 2,
      "annee_calcul": 2024,
      "mois_calcul": 3
    },
    "allocataires": [
      {
        "nom_naissance": "DUPONT",
        "nom_usage": null,
        "prenoms": "JEAN-PIERRE THOMAS",
        "date_naissance": "1962-08-24",
        "sexe": "M"
      }
    ],
    "enfants": [],
    "adresse": {
      "destinataire": "Monsieur JEAN-PIERRE DUPONT",
      "numero_libelle_voie": "1 RUE DE LA GARE",
      "code_postal_ville": "75002 PARIS",
      "pays": "FRANCE"
    }
  },
  "links": {},
  "meta": {}
}
```

**Après** — même appel avec `X-Generate-Proof: pdf` (le bloc `data` est
inchangé) :

```json
{
  "data": { "...": "identique à l'appel standard" },
  "links": {
    "attestation_pdf": "https://particulier.api.gouv.fr/attestations/8f3ac2e1-4d77-4b0a-9b1e-2c5f0a7e9d12.pdf"
  },
  "meta": {
    "pdf_verification_link": "https://particulier.api.gouv.fr/attestations/verification/AgADk9QxR1pZ3m8nT0oqLp2vWc7yB4fH",
    "pdf_verification_code": "AB12-X9K3-TZ",
    "pdf_link_expires_in": 1781015700
  }
}
```

Avec `X-Generate-Proof: proof-only`, `links` reste `{}` et `meta` ne
contient que `pdf_verification_link` + `pdf_verification_code`.

---

## 4. Télécharger le PDF

Suivez le lien `links.attestation_pdf` : il renvoie directement le PDF.

- **Pas d'authentification requise** sur ce lien : il porte sa propre
  autorisation. Ne le diffusez qu'aux personnes habilitées à voir le
  document.
- **Durée courte** : le lien expire à `pdf_link_expires_in` (environ
  **5 minutes** après l'appel). Passé ce délai, il renvoie
  **`410 Gone`** — relancez simplement l'appel API authentifié pour en
  obtenir un nouveau.
- **Téléchargeable plusieurs fois** tant que le lien est valide.

---

## 5. Vérifier une attestation

Le PDF embarque un **QR code** et un **code de vérification** imprimé
en clair. Pour contrôler un document reçu :

1. Scannez le QR code (appareil photo / navigateur, aucune application
   dédiée), ou ouvrez `pdf_verification_link`.
2. Vous arrivez sur la page de vérification
   `https://particulier.api.gouv.fr/attestations/verification/:id`.
3. La page affiche les **données authentifiées** et un **code de
   vérification**.
4. Comparez le code affiché à l'écran avec celui imprimé sur le PDF :
   - **identiques** → document authentique ;
   - **différents** → document falsifié.

La page indique aussi si l'attestation est **périmée** (au-delà de sa
durée de validité) ou **invalide**.

> Vérifiez toujours que l'adresse affichée est bien
> `particulier.api.gouv.fr` avant de faire confiance au résultat.

---

## 6. PDF complet vs page de vérification (sous-ensemble)

Deux niveaux d'information, volontairement différents.

**Le PDF affiche l'ensemble des informations** de l'attestation, comme
la réponse JSON : identité complète (nom, prénoms, **date de naissance
complète**), adresse, valeur du quotient familial et période, etc. Il
porte en plus :

- le **QR code** et le **code de vérification** (pied de page) ;
- à titre de **traçabilité de provenance**, le **SIRET** de votre
  structure et l'**identifiant d'habilitation** sous lequel l'appel a
  été effectué — pour savoir, si un document circule, d'où il vient.

**La page de vérification n'affiche qu'un sous-ensemble** volontairement
réduit : suffisant pour comparer visuellement avec le PDF, mais
insuffisant pour reconstituer une identité. Elle ne montre que :

- les **3 premières lettres** du nom de naissance (ex. `DUP` pour
  `DUPONT`) ;
- le **mois et l'année** de naissance, **sans le jour** (ex. `1962-08`) ;
- quelques **informations non nominatives** de la payload (ex. valeur du
  quotient familial, mois et année de référence) ;
- le **code de vérification**.

Concrètement, lors d'un contrôle, vous comparez `DUP` à `DUPONT`,
`1962-08` à `1962-08-24`, et la valeur du QF à l'identique : la
concordance confirme l'authenticité, sans que le lien de vérification
n'ait jamais exposé l'identité complète.

---

## 7. Durées de validité

| Élément | Validité | Remarque |
|---------|----------|----------|
| Lien de téléchargement du PDF (`attestation_pdf`) | ~5 minutes | Au-delà : `410 Gone`, relancez l'appel |
| Lien + code de vérification | ~5 ans | Reste contrôlable pendant toute la durée d'archivage |

La durée de vérification (5 ans par défaut) couvre les besoins
d'archivage et de contrôle a posteriori. Elle peut être ajustée selon
le type de document.

---

## 8. FAQ

**Dois-je télécharger le PDF pour avoir une preuve ?**
Non. Avec `proof-only`, archivez `pdf_verification_link` +
`pdf_verification_code` ; ils suffisent à prouver l'authenticité de la
donnée pendant des années.

**Le lien de vérification expose-t-il l'identité complète ?**
Non — seulement un sous-ensemble (3 premières lettres du nom, mois et
année de naissance, données non nominatives). Le PDF, lui, contient tout.
Voir §6.

**Que se passe-t-il si j'appelle deux fois ?**
Chaque appel produit une nouvelle preuve. Le lien de téléchargement est
propre à chaque appel et expire en quelques minutes.

**Le lien de téléchargement a expiré.**
Rappelez l'endpoint avec `X-Generate-Proof: pdf` : vous obtenez un
nouveau lien. La preuve de vérification, elle, ne change pas de nature
et reste valable.
