# Tracking de l'agent final

Ce document explique comment chaque appel pourra porter un **identifiant de
l'agent final** (la personne qui consulte la donnée), tout en restant
respectueux de la vie privée.

> **Spec temporaire.** Le mécanisme (nom du header, format, durées) est encore
> provisoire et sera précisé. Ce document en pose les principes.

---

## 1. À quoi ça sert

Aujourd'hui, nos logs savent qu'un **éditeur** a appelé, mais pas **quel agent**
(l'agent de mairie, de CCAS) était derrière l'appel.

L'objectif : pouvoir, **en cas de contrôle**, remonter jusqu'à l'usage
individuel d'une donnée, sans pour autant stocker d'identité en clair.

## 2. Comment ça marche

Vous transmettez, à chaque appel, un identifiant de l'agent final, dans un
en-tête dédié :

```http
GET /v3/dss/quotient_familial/identite HTTP/1.1
Host: particulier.api.gouv.fr
Authorization: Bearer <votre_jeton>
X-Agent-Id: agent-4831
```

> Nom d'en-tête **illustratif** : il sera figé avec vous.

De notre côté, le traitement est volontairement à sens unique :

```text
X-Agent-Id: agent-4831
      |
      v
   hachage (sens unique)
      |
      v
   empreinte stockée dans les logs   (jamais l'identifiant en clair)
```

- on **hache** l'identifiant et on stocke seulement l'empreinte ;
- on **ne conserve rien en clair** ;
- nous **ne pouvons pas** retrouver l'agent par nous-mêmes.

## 3. Le contrôle (service de vérification)

L'empreinte seule ne se « décode » pas. Pour rapprocher un appel d'un agent, il
faut une **valeur connue** à re-hacher :

```text
valeur connue  -->  même hachage  -->  empreinte
                                          |
                                          v
                                comparaison avec les logs
                                (concordance = c'est bien cet appel)
```

En pratique, on exposera un **service de vérification** : à partir d'une valeur
connue (fournie par vous ou l'administration lors d'un contrôle), il recalcule
l'empreinte et la compare à nos logs. À aucun moment nous ne manipulons la
donnée en clair.

## 4. Vie privée & RGPD

- **Minimisation** : nous ne stockons que des **empreintes**, jamais
  l'identifiant en clair.
- **Pseudonymat** : l'identifiant transmis doit être une **référence opaque**
  (pas une donnée nominative directe).
- **Responsabilité** : la correspondance « identifiant ↔ agent réel » reste
  **chez vous**. C'est vous qui pouvez fournir la valeur connue lors d'un
  contrôle.
- **Finalité limitée** : la donnée sert au **contrôle a posteriori**, pas à
  autre chose.

## 5. Rétention

Les empreintes vivent dans nos **logs d'accès** et suivent leur durée de
conservation. La durée exacte sera précisée dans la spec définitive.

## 6. Périmètre & statut

C'est **notre** politique : nous la définissons et la faisons évoluer. On
commence par les endpoints qui en ont besoin, avec une **extension possible**
ensuite. Rien n'est figé.

---

## FAQ

**L'identifiant doit-il être nominatif ?**
Non. Il doit être **stable et unique** par agent (pour qu'un même agent donne
toujours la même empreinte), mais une **référence opaque** suffit.

**Stockez-vous des données personnelles ?**
Non : uniquement des **empreintes** (hash), jamais l'identifiant en clair.

**Qui peut faire le rapprochement ?**
Le rapprochement nécessite la **valeur connue**, que vous (ou l'administration)
détenez. Nous, seuls, ne pouvons pas remonter à l'agent.

**Que se passe-t-il si je n'envoie pas l'en-tête ?**
Tant que le dispositif n'est pas exigé sur un endpoint, l'appel fonctionne. Le
déploiement sera progressif et coordonné.
