#!/usr/bin/env bash
# DoD 1 · Repo
#   - Repository ist öffentlich und aus der Vorlage erzeugt
#   - compose.yml und html/index.html sind committet
#   - Laufzeitdaten (kuma-data/) sind NICHT committet
# Läuft im ausgecheckten Repository (Arbeitsverzeichnis = Repo-Wurzel).
set -uo pipefail
source "$(dirname "$0")/gemeinsam.sh"

steckbrief_start "DoD 1 · Repo"

if ! REPO_JSON=$(api "repos/${GITHUB_REPOSITORY}"); then
  fehlt "GitHub-API" "Die Repository-Daten konnten nicht abgefragt werden."
  ende
fi

if [ "$(jq -r '.private' <<<"$REPO_JSON")" = "false" ]; then
  ok "Repository öffentlich"
else
  fehlt "Repository ist privat" "Stelle dein Repo auf Public (Settings → General → Danger Zone → Change visibility). Nur öffentliche Repos testen kostenlos."
fi

VORLAGE=$(jq -r '.template_repository.full_name // empty' <<<"$REPO_JSON")
if [ -n "$VORLAGE" ]; then
  ok "Aus der Vorlage erzeugt" "$VORLAGE"
else
  fehlt "Nicht aus der Vorlage erzeugt" "Dein Repo wurde nicht über „Use this template“ angelegt (z. B. Fork oder leeres Repo). Lege es neu aus der Vorlage an."
fi

COMPOSE=""
for f in compose.yaml compose.yml docker-compose.yaml docker-compose.yml; do
  if git ls-files --error-unmatch "$f" > /dev/null 2>&1; then COMPOSE="$f"; break; fi
done
if [ -n "$COMPOSE" ]; then
  ok "Compose-Datei committet" "$COMPOSE"
else
  fehlt "Keine Compose-Datei" "Im Hauptordner deines Repos ist keine compose.yml committet (Phase 2)."
fi

if [ -n "$(git ls-files html/index.html)" ]; then
  ok "html/index.html committet"
else
  fehlt "html/index.html fehlt" "Der Ordner html mit deiner index.html ist nicht committet (Phase 2)."
fi

# kuma-data/ in jedem Unterordner suchen (nicht nur im Hauptordner)
KUMA=$(git ls-files | grep -E '(^|/)kuma-data/' | head -n 1)
if [ -z "$KUMA" ]; then
  ok "Keine Laufzeitdaten (kuma-data/) im Repo"
else
  KUMA_ORDNER="${KUMA%%kuma-data/*}kuma-data"
  fehlt "Laufzeitdaten im Repo" "kuma-data/ ist committet ($KUMA). Entferne den Ordner aus Git: git rm -r --cached $KUMA_ORDNER, dann committen und pushen."
fi

ende
