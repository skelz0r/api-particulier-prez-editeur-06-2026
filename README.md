# API Particulier : présentation éditeurs (juin 2026)

Support de la présentation faite aux **éditeurs de logiciels** consommant
**API Particulier**, autour de la **sécurisation** et de la **simplification**
des accès : délégation (jeton éditeur, OAuth2), espace éditeur, filtrage IP /
DPoP, tracking de l'agent final, homologation.

## En ligne

- **Slides** : https://assets.delmai.re/prez-editeurs/slides.html
- **Documents** (lecture + téléchargement) : https://assets.delmai.re/prez-editeurs/interne.html
- **Maquette de l'espace éditeur** : https://assets.delmai.re/prez-editeurs/mockup-espace-editeur.html

## Contenu

| Fichier | Rôle |
|---|---|
| `00`…`05`, `01a`/`01b`/`01c` `.md` | Documents de référence (un par sujet) |
| `slides.md` + `slides.html` | Slides reveal.js (le HTML charge le MD) |
| `interne.html` | Rend chaque doc + lien de téléchargement du MD |
| `mockup-espace-editeur.html` | Maquette DSFR interactive de l'espace éditeur |
| `espace-editeur.png` | Capture de la maquette (utilisée dans les slides) |
| `sondage-feedback.md` | Sondage de feedback (IP vs DPoP, SDK, pilotes) |
| `publish.sh` | Génère les PDF puis publie le tout |

Les PDF sont **générés à la volée** par `publish.sh` (non versionnés).

## Publier

```bash
./publish.sh
```

Prérequis : `pandoc`, `weasyprint`, et `upload-assets` (publication sur
l'asset host).

## Prévisualiser en local

```bash
python3 -m http.server
# puis http://localhost:8000/slides.html  (ou /interne.html)
```

Le `fetch` du Markdown est bloqué en `file://`, d'où le serveur HTTP.
