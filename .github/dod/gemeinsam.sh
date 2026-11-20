#!/usr/bin/env bash
# Gemeinsame Hilfsfunktionen für die DoD-Prüfungen.
# Benötigt: GITHUB_TOKEN, GITHUB_REPOSITORY (z. B. "benutzer/microcloud").
# Optional: GITHUB_API_URL (Standard: https://api.github.com), GITHUB_STEP_SUMMARY.

API="${GITHUB_API_URL:-https://api.github.com}"
SUMMARY="${GITHUB_STEP_SUMMARY:-/dev/null}"
FEHLER=0

# GitHub-API lesend abfragen (gibt JSON aus, Exit-Code ≠ 0 bei HTTP-Fehler)
api() {
  curl -fsS \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "${API}/$1"
}

# Überschrift und Tabellenkopf für den Steckbrief
steckbrief_start() {
  { echo "## $1"; echo; echo "| Prüfpunkt | Ergebnis |"; echo "|---|---|"; } >> "$SUMMARY"
}

# ok "Prüfpunkt" "Detail"
ok() {
  echo "✅ $1${2:+ – $2}"
  echo "| $1 | ✅ ${2:-erfüllt} |" >> "$SUMMARY"
}

# fehlt "Prüfpunkt" "Fehlermeldung für Annotation und Steckbrief"
fehlt() {
  echo "::error title=$1::$2"
  echo "| $1 | ❌ $2 |" >> "$SUMMARY"
  FEHLER=1
}

# Ergebnis in den Steckbrief schreiben und mit passendem Exit-Code enden
ende() {
  if [ "$FEHLER" -eq 0 ]; then
    { echo; echo "**Ergebnis: ✅ erfüllt**"; } >> "$SUMMARY"
  else
    { echo; echo "**Ergebnis: ❌ noch nicht erfüllt** – siehe Meldungen oben."; } >> "$SUMMARY"
  fi
  exit "$FEHLER"
}
