# Questionnaire de sécurité (homologation)

Ce document décrit le principe d'un **questionnaire de sécurité** : un échange
structuré pour vérifier, ensemble, que les bonnes pratiques sont en place chez
vous.

> **Statut : intention.** Le contenu précis reste à co-construire avec les
> éditeurs. Le §4 propose un **brouillon** de questions types.

---

## 1. L'objectif

Établir une **base de confiance partagée**, dans une logique d'**homologation**.

Ce que c'est :

- un **état des lieux déclaratif**, accompagné par l'équipe ;
- un outil de **mise en conformité progressive** et de dialogue.

Ce que ce **n'est pas** :

- un audit intrusif ou un test d'intrusion ;
- un outil de sanction.

## 2. Ce que ça pourrait couvrir

| Thème | Exemples de points vérifiés |
|---|---|
| **Jetons / secrets** | Où sont stockés les jetons ? Rotation ? Accès restreint ? |
| **Sécurisation des accès** | Filtrage IP et/ou DPoP en place ? IP maîtrisées ? |
| **Traçabilité** | Identifiant d'agent transmis ? Durée de conservation des logs ? |
| **Accès internes** | Qui, chez vous, accède aux jetons et à l'espace éditeur ? |
| **Cycle de vie** | Procédure en cas de fuite ? Révocation ? Contact sécurité ? |
| **Conformité** | RGPD, minimisation des données, information des usagers |

## 3. Articulation avec les autres chantiers

Le questionnaire ne crée pas d'obligations isolées : il **formalise** ce que
portent déjà les chantiers **sécurité** (IP / DPoP) et **traçabilité** (agent
final), plus la gestion des accès depuis l'espace éditeur.

## 4. Questionnaire d'exemple (brouillon)

> À titre indicatif, pour fixer les idées. Le format final (échelles, pièces
> justificatives) se décidera ensemble.

**Jetons / secrets**

- Où stockez-vous vos jetons API ? *(coffre de secrets / variables
  d'environnement / base de données / autre)*
- Un humain peut-il lire un jeton en clair ? *(oui / non)*
- Faites-vous tourner vos jetons ? À quelle fréquence ? *(texte)*

**Sécurisation des accès**

- Quelle protection est en place ? *(filtrage IP / DPoP / les deux / aucune)*
- Vos IP de sortie sont-elles stables et maîtrisées ? *(oui / partiellement /
  non)*

**Traçabilité**

- Transmettez-vous un identifiant d'agent final à chaque appel ? *(oui / en
  cours / non)*
- Combien de temps conservez-vous vos propres logs d'appels ? *(durée)*

**Accès internes**

- Qui, chez vous, accède aux jetons et à l'espace éditeur ? *(rôles)*
- Les accès sont-ils retirés au départ d'un collaborateur ? *(oui / non)*

**Cycle de vie / incident**

- Avez-vous une procédure documentée en cas de fuite de jeton ? *(oui / non)*
- Avez-vous un contact sécurité dédié ? *(e-mail)*
- Savez-vous révoquer rapidement une délégation ou un jeton ? *(oui / non)*

**Conformité**

- Informez-vous les usagers finaux de l'usage de leurs données ? *(oui / non)*
- Appliquez-vous la minimisation (ne traiter que le strict nécessaire) ?
  *(oui / non)*

## 5. Modalités envisagées

```text
À l'entrée                          Puis périodiquement
état des lieux à l'intégration  -->  revue régulière pour maintenir
                                     le niveau dans le temps
```

- **Déclaratif** : vous déclarez vos pratiques.
- **Accompagné** : l'équipe vous aide à vous mettre à niveau si besoin.

---

Le contenu définitif du questionnaire sera défini **avec vous**.
