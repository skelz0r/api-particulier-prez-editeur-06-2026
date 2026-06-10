# La délégation

Ce document explique la notion de **délégation** : ce qu'elle est, ce qu'elle
change pour vous (éditeur) et pour les collectivités que vous équipez, et les
deux façons dont nous comptons la mettre en œuvre.

---

## 1. Le contexte

Sur API Particulier, une **collectivité** (mairie, CCAS, département) est
**titulaire** d'une habilitation : c'est elle qui a le droit de consulter des
données (quotient familial, composition familiale, etc.) pour mener une
démarche.

Mais en pratique, ce n'est presque jamais la collectivité qui appelle l'API
directement : c'est **son éditeur de logiciel**. Vous réalisez les appels
techniques **pour le compte** de vos collectivités clientes.

Ce schéma fonctionne, mais il a un angle mort : **rien ne relie formellement
une habilitation à l'éditeur qui l'exploite**.

```text
   Collectivité                          Éditeur
 (titulaire de                        (réalise les
 l'habilitation)                     appels techniques)
        |                                    |
        |   "j'utilise le logiciel X"        |
        +----------------- ? ----------------+
               lien deviné, jamais formalisé
```

Aujourd'hui, ce lien se **devine** via les formulaires éditeurs (qui permettent
de mentionner le contact technique du prestataire), mais il n'existe nulle part
de façon explicite.

## 2. Ce qu'on veut changer

L'objectif : rendre ce lien **explicite et transparent**.

```text
AVANT                          APRÈS
lien implicite        ----->   Collectivité --autorise--> Éditeur
(deviné)                       délégation formelle, visible et révocable
```

Concrètement :

| Pour... | Bénéfice |
|---|---|
| **la collectivité** | Elle sait à qui ses accès sont délégués, et peut l'encadrer |
| **vous, l'éditeur** | Une relation formalisée, des jetons en moins à gérer |
| **nous** | Un destinataire (`recipient`) cohérent par construction |

## 3. Deux déclinaisons techniques

La délégation se matérialise de deux façons, présentées chacune dans son
document :

| Mécanisme | Idée | Effort éditeur | Statut |
|---|---|---|---|
| **Jeton éditeur** | Un jeton unique, sans droits, résolu par le SIRET | Moyen | En développement |
| **OAuth2** | La collectivité crée la délégation depuis votre logiciel | Élevé | Vision |

Les deux peuvent se combiner : le jeton éditeur règle la **mécanique d'appel** ;
OAuth2 vise à **simplifier l'onboarding** (deux formes sont à l'étude, voir le
document OAuth2). OAuth2 demande un **effort d'intégration plus important**.

## 4. Vocabulaire

| Terme | Sens |
|---|---|
| **Habilitation** | Le droit d'accès, porté par la collectivité (issu de DataPass) |
| **Délégation** | Le lien entre une habilitation et un éditeur |
| **`recipient`** | Le SIRET de la collectivité pour laquelle vous appelez |

---

Ces mécanismes sont **optionnels** : ils sont proposés, jamais imposés. Le
fonctionnement actuel (un jeton par habilitation) reste valable.
