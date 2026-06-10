# Sondage : Votre avis sur les chantiers de sécurisation

Ce sondage recueille l'avis des éditeurs API Particulier à l'issue de la
présentation. Objectif : orienter nos choix (notamment **filtrage IP vs DPoP**)
et identifier des **volontaires** pour les premiers pilotes.

> Format : markdown structuré, prêt à être porté dans un outil de sondage
> (Framaforms, Grist, Google Forms…). Le type de réponse attendu est indiqué
> entre crochets : `[Choix unique]`, `[Choix multiple]`, `[Échelle 1–5]`,
> `[Texte libre]`, `[Oui/Non]`.

---

## Section 1 : Identité (pour le suivi)

1. **Nom de l'éditeur / du produit.** `[Texte libre]`
2. **Contact (nom + e-mail) pour le suivi de ces chantiers.** `[Texte libre]`
3. **Votre modèle d'hébergement principal.** `[Choix unique]`
   - SaaS centralisé (une infra qui sert toutes les collectivités)
   - On-premise (logiciel installé chez chaque collectivité)
   - Mixte / hybride
   - Autre / ne sait pas

---

## Section 2 : Sécurisation des accès (IP / DPoP)

> Cœur du sondage. Voir le document « Sécurisation des accès : IP / DPoP ».

4. **Vos IP de sortie vers l'API sont-elles stables ?** `[Choix unique]`
   - Oui, une ou quelques IP fixes
   - Partiellement (plage connue mais variable)
   - Non (cloud serverless / IP dynamiques)
   - Ne sait pas
5. **Quelle option de sécurisation a votre préférence ?** `[Choix unique]`
   - Filtrage IP seul
   - DPoP seul
   - Les deux (IP + DPoP)
   - Aucune préférence / besoin d'échanger
6. **Faisabilité du filtrage IP chez vous** (fournir et maintenir une liste
   d'IP). `[Échelle 1–5]` _(1 = très difficile, 5 = très facile)_
7. **Faisabilité de DPoP chez vous** (signer chaque requête, gérer une paire de
   clés). `[Échelle 1–5]` _(1 = très difficile, 5 = très facile)_
8. **Principaux freins ou contraintes** que vous anticipez (techniques,
   organisationnels, calendrier). `[Texte libre]`
9. **Seriez-vous volontaire pour un pilote en « mode log »** (observation sans
   blocage) avant enforcement ? `[Oui/Non]`

---

## Section 3 : Délégation & jeton éditeur

> Voir les documents « Délégation : le jeton éditeur » et « Délégation : OAuth2 ».

10. **Intérêt pour le jeton éditeur** (1 jeton unique au lieu d'un par
    collectivité). `[Échelle 1–5]`
11. **Qu'est-ce qui vous freinerait à adopter le jeton éditeur ?**
    `[Choix multiple]`
    - Changement d'architecture trop lourd
    - Modèle on-premise (peu adapté)
    - Besoin de garder un jeton par client
    - Manque de visibilité sur le calendrier
    - Aucun frein particulier
    - Autre `[Texte libre]`
12. **Intérêt pour OAuth2** (la collectivité crée la délégation elle-même, en
    quelques clics). `[Échelle 1–5]`

---

## Section 4 : Nouvel espace éditeur

> Voir le document « Nouvel espace éditeur ».

13. **Classez les rubriques par priorité pour vous.**
    `[Classement / Choix multiple]`
    - Profil
    - Sécurité (IP, clé DPoP)
    - Habilitations (via délégation)
    - Jetons éditeurs
    - Logs d'accès
    - Gestion des membres
14. **Fonctionnalités manquantes** que vous aimeriez y voir. `[Texte libre]`
15. **Préférence de paramétrage IP/DPoP.** `[Choix unique]`
    - Self-service depuis l'espace éditeur
    - Via l'équipe (accompagné)
    - Peu importe

---

## Section 5 : Tracking de l'agent final

> Voir le document « Tracking de l'agent final ».

16. **Pouvez-vous fournir un identifiant d'agent final stable à chaque appel ?**
    `[Choix unique]`
    - Oui, déjà disponible
    - Oui, moyennant un développement
    - Difficilement
    - Non
17. **Contraintes ou questions** sur ce point (confidentialité, technique,
    calendrier). `[Texte libre]`

---

## Section 6 : Homologation & général

> Voir le document « Questionnaire de sécurité (homologation) ».

18. **Un questionnaire de sécurité périodique vous paraît-il acceptable ?**
    `[Échelle 1–5]` _(1 = trop contraignant, 5 = tout à fait)_
19. **Sur quels chantiers souhaitez-vous être contacté en priorité ?**
    `[Choix multiple]`
    - Délégation / jeton éditeur
    - OAuth2
    - Sécurisation IP / DPoP
    - Tracking de l'agent final
    - Homologation
20. **Remarques libres** sur la présentation ou ces chantiers. `[Texte libre]`

---

## Section 7 : Clients / SDK officiels

> En complément, nous mettons à disposition des **clients / SDK officiels**
> (référence Ruby et Node, autres langages à venir) pour intégrer l'API
> sans tout réécrire.

21. **Utiliseriez-vous un client / SDK officiel** pour intégrer l'API ?
    `[Échelle 1–5]`
22. **Quels langages vous intéressent ?** `[Choix multiple]`
    - Ruby
    - Node / JavaScript
    - Python
    - PHP
    - Java
    - Autre `[Texte libre]`

---

_Merci ! Vos réponses orientent directement nos priorités et notre calendrier._
