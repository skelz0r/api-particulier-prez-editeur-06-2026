# OAuth2 (vision)

Ce document décrit une piste pour l'avenir : permettre à une collectivité de
**créer la délégation elle-même**, en quelques clics, depuis votre logiciel,
grâce à un flow OAuth2 standard.

> **Statut : non implémenté, piste ouverte.** Nous présentons cette orientation
> pour recueillir votre intérêt et la prioriser si elle vous semble utile.

---

## 1. Le problème aujourd'hui

Créer une délégation passe par une **procédure manuelle** : formulaires,
échanges, délais. Pour vous comme pour la collectivité, c'est de la friction à
chaque onboarding d'un nouveau client.

## 2. L'idée : la délégation en self-service

Avec OAuth2, la collectivité **autorise elle-même** votre logiciel à appeler
l'API pour son compte. Tout se passe **dans votre produit**, sans ticket.

```text
[ Votre logiciel ]                          [ API Particulier ]
       |                                            |
   1.  | "Connecter API Particulier"  ------------> |
       |                                            |
   2.  |        la collectivité s'authentifie       |
       |        (ProConnect) et consent             |
       |                                            |
   3.  | <------------ code d'autorisation --------- |
   4.  | ------------- échange code -> jeton ------> |
       | <------------ jeton ------------------------ |
       |                                            |
   5.  |  délégation active : vous appelez          |
       |  pour le compte de la collectivité         |
```

C'est le **flow OAuth2 classique** (autorisation par l'usager). Point clé :
**aucun secret n'est partagé** entre vous et la collectivité, c'est elle qui
autorise.

## 3. Ce que ça apporte

| Bénéfice | Détail |
|---|---|
| **Onboarding immédiat** | Un nouveau client est opérationnel en quelques clics |
| **Consentement explicite** | La collectivité autorise et voit ce qu'elle autorise |
| **Traçabilité** | La délégation naît d'un acte volontaire et daté |
| **Moins de paperasse** | Plus de formulaire manuel pour démarrer |

## 4. Deux formes possibles (à arbitrer)

OAuth2 ne remplace pas le jeton éditeur. Il peut prendre **deux formes**, encore
à arbitrer :

- **Option A : surcouche du jeton éditeur.** OAuth2 sert uniquement à créer et
  autoriser la délégation ; derrière, vous appelez toujours avec la mécanique du
  jeton éditeur (`recipient` / `delegation_id`). But : **simplifier
  l'intégration**.
- **Option B : jetons OAuth2 dédiés.** OAuth2 émet des **bearer tokens** ayant
  les mêmes caractéristiques que les jetons « uniques » (un par habilitation /
  délégation), mais **avec expiration** (jetons courte durée + renouvellement),
  contrairement aux jetons actuels qui n'expirent pas toujours.

## 5. À quel coût pour vous ?

OAuth2 demande d'**implémenter le flow OAuth2** dans votre logiciel :
redirection, consentement, échange du code contre un jeton, puis gestion et
renouvellement des jetons. C'est un **développement conséquent**, plus lourd que
le jeton éditeur.

En contrepartie, vous gagnez un **onboarding self-service** : une fois le flow
en place, chaque nouveau client se connecte seul, sans intervention.

---

Démo (Loom) : https://www.loom.com/share/1c050660e244444683b2ba6f22769d54
