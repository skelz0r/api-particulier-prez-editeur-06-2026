#!/usr/bin/env bash
#
# publish.sh - un seul binaire pour publier la présentation éditeurs.
#
# 1. génère un PDF par document de référence (style DSFR bleu Marianne #000091) ;
# 2. publie slides + PDF + maquette + svg sur
#    https://assets.delmai.re/prez-editeurs/.
#
# Les sources .md ne sont pas modifiées (pré-traitement sur copie temporaire).
# Prérequis : pandoc, weasyprint, upload-assets.
#
set -euo pipefail
cd "$(dirname "$0")"

for bin in pandoc weasyprint upload-assets; do
  command -v "$bin" >/dev/null 2>&1 || { echo "Erreur : $bin introuvable." >&2; exit 1; }
done

DOCS=(
  00-contexte-objectifs
  01a-delegation-intro
  01b-jeton-editeur
  01c-oauth2
  02-espace-editeur
  03-securisation-acces-ip-dpop
  04-tracking-agent-final
  05-questionnaire-securite-homologation
  06-attestations-pdf
)

# --- 1. PDF -----------------------------------------------------------------
echo "==> Génération des PDF"
CSS="$(mktemp)"
cat > "$CSS" <<'EOF'
@page { size: A4; margin: 1.5cm; }
body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif; font-size: 9.5pt; line-height: 1.45; color: #333; word-wrap: break-word; overflow-wrap: break-word; }
h1 { font-size: 17pt; color: #000074; border-bottom: 3px solid #000091; padding-bottom: 8px; margin-top: 18px; }
h2 { font-size: 12.5pt; color: #000091; margin-top: 18px; border-bottom: 1px solid #cacafb; padding-bottom: 4px; }
h3 { font-size: 10.5pt; color: #000074; margin-top: 12px; }
blockquote { background: #f5f5fe; border-left: 4px solid #000091; padding: 8px 14px; margin: 14px 0; font-size: 9pt; }
blockquote strong { color: #000091; }
table { width: 100%; border-collapse: collapse; margin: 12px 0; font-size: 9pt; table-layout: fixed; word-wrap: break-word; }
th { background: #000091; color: white; padding: 6px 8px; text-align: left; font-weight: 600; word-wrap: break-word; }
td { padding: 5px 8px; border-bottom: 1px solid #e2e8f0; word-wrap: break-word; overflow-wrap: break-word; vertical-align: top; }
tr:nth-child(even) { background: #f5f5fe; }
strong { color: #000074; }
code { background: #eeeefb; padding: 2px 4px; border-radius: 3px; font-family: "SFMono-Regular", "SF Mono", Menlo, Consolas, "Liberation Mono", monospace; font-size: 8.5pt; word-break: break-all; overflow-wrap: anywhere; }
pre { background: #f5f5fe; padding: 10px 12px; border-radius: 4px; border-left: 4px solid #000091; font-size: 8pt; white-space: pre-wrap; word-wrap: break-word; overflow-wrap: break-word; }
pre code { background: transparent; padding: 0; font-family: "SFMono-Regular", "SF Mono", Menlo, Consolas, "Liberation Mono", monospace; font-size: 8pt; word-break: normal; }
hr { border: none; border-top: 1px solid #cacafb; margin: 18px 0; }
p { margin: 6px 0; }
ul, ol { margin: 8px 0; padding-left: 22px; }
li { margin: 5px 0; word-wrap: break-word; overflow-wrap: break-word; }
li p { margin: 4px 0; }
li p:first-child { margin-top: 0; }
li p:last-child { margin-bottom: 0; }
a { color: #000091; }
img { max-width: 100%; height: auto; display: block; margin: 10px 0; }
EOF

for d in "${DOCS[@]}"; do
  tmp="$(mktemp).md"
  cp "$d.md" "$tmp"
  python3 - "$tmp" <<'PY'
import re, sys
p = sys.argv[1]
lines = open(p, encoding='utf-8').readlines()
out = []
for line in lines:
    if re.match(r'^([0-9]+\.|[-*+])\s', line) and out:
        prev = out[-1]
        if not (re.match(r'^([0-9]+\.|[-*+])\s', prev) or re.match(r'^\s{2,}', prev) or prev.strip() == ''):
            out.append('\n')
    out.append(line)
open(p, 'w', encoding='utf-8').writelines(out)
PY
  pandoc -f gfm "$tmp" -o "$tmp.html" --standalone --css="$CSS" --embed-resources --resource-path=.
  weasyprint "$tmp.html" "$d.pdf" 2>/dev/null
  rm -f "$tmp" "$tmp.html"
  echo "    $d.pdf"
done
rm -f "$CSS"

# --- 2. Upload --------------------------------------------------------------
echo "==> Upload vers assets.delmai.re/prez-editeurs/"
upload-assets -d prez-editeurs \
  slides.html interne.html slides.md espace-editeur.png mockup-espace-editeur.html \
  sondage-feedback.md README.md \
  "${DOCS[@]/%/.md}" "${DOCS[@]/%/.pdf}"
