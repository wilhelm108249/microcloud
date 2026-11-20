#!/usr/bin/env bash
# DoD 4 · Apache auf main
#   Der Service, der Host-Port 8085 veröffentlicht, wird gestartet.
#   Erfüllt, wenn der HTTP-Header "Server" Apache meldet.
#   (Ob die richtige Seite ausgeliefert wird, prüft DoD 2 · Microcloud-CI.)
# Läuft im ausgecheckten Repository, braucht Docker mit Compose.
set -uo pipefail
source "$(dirname "$0")/gemeinsam.sh"
ZIELPORT="${ZIELPORT:-8085}"

steckbrief_start "DoD 4 · Apache auf main"

if ! docker compose config --format json > konfiguration.json 2> fehler.txt; then
  cat fehler.txt
  fehlt "Kein lauffähiger Stack" "Auf main liegt keine gültige compose.yml. Erst DoD 1 und DoD 2 erfüllen."
  ende
fi

SERVICE=$(jq -r --arg p "$ZIELPORT" '
  .services | to_entries[]
  | select(any(.value.ports[]?; (.published | tostring) == $p))
  | .key' konfiguration.json | head -n 1)
if [ -z "$SERVICE" ]; then
  fehlt "Port $ZIELPORT fehlt" "Kein Service auf main veröffentlicht Port $ZIELPORT (siehe DoD 2)."
  ende
fi
IMAGE=$(jq -r --arg s "$SERVICE" '.services[$s].image // "(eigenes Build)"' konfiguration.json)
ok "Service mit Port $ZIELPORT" "$SERVICE ($IMAGE)"

docker compose up -d "$SERVICE" > /dev/null 2>&1
SERVER=""
for versuch in $(seq 1 30); do
  SERVER=$(curl -s -I "http://localhost:$ZIELPORT/" 2>/dev/null | grep -i '^server:' | cut -d' ' -f2- | tr -d '\r')
  [ -n "$SERVER" ] && break
  sleep 2
done
docker compose down -v > /dev/null 2>&1 || true

if [ -z "$SERVER" ]; then
  fehlt "Keine Antwort" "Auf Port $ZIELPORT antwortet kein Webserver (siehe DoD 2)."
elif grep -qi 'apache' <<<"$SERVER"; then
  ok "Webserver ist Apache" "$SERVER"
else
  fehlt "Noch kein Apache auf main" "Auf main läuft noch „$SERVER“. Stelle auf dem Branch dev auf Apache httpd um und übernimm die Änderung per Pull Request (Phase 5 und 6)."
fi

ende
