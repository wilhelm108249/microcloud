# Typische Fehler und Lösungen

[⬅️ Zurück zum Projektauftrag](../README.md)

## Git und GitHub

| Meldung / Symptom | Ursache | Lösung |
|---|---|---|
| `git@github.com: Permission denied (publickey).` | GitHub kennt deinen öffentlichen Schlüssel nicht, oder du hast den falschen hochgeladen. | `cat ~/.ssh/id_ed25519.pub` erneut bei GitHub → *SSH and GPG keys* eintragen. Mit `ssh -T git@github.com` testen. |
| `ssh: connect to host github.com port 22: Connection timed out` | Port 22 ist durch eine Firewall gesperrt. | SSH über Port 443, siehe [01 – SSH-Schlüssel](../anleitung/01-ssh-key.md#falls-port-22-gesperrt-ist). |
| `Please tell me who you are` beim Commit | `user.name` / `user.email` fehlen. | `git config --global user.name …` und `user.email …` setzen. |
| `fatal: not a git repository` | Du bist nicht im Repo-Ordner. | `cd ~/microcloud` |
| `remote: Support for password authentication was removed` | Du hast mit `https://…` geklont, GitHub akzeptiert dort kein Passwort. | Auf SSH umstellen: `git remote set-url origin git@github.com:USER/microcloud.git` |
| `! [rejected] main -> main (fetch first)` | Auf GitHub gibt es Commits, die du lokal nicht hast (z. B. nach einem Merge im Browser). | Erst `git pull`, dann `git push`. |
| `There is no tracking information for the current branch` / `has no upstream branch` | Neuer Branch, der noch nie gepusht wurde. | `git push -u origin dev` |
| Editor (vim) öffnet sich bei `git pull` oder `git commit` | Git möchte eine Nachricht (z. B. für einen Merge-Commit). | Nachricht übernehmen und speichern: in vim `Esc`, dann `:wq` + `Enter`. |
| `kuma-data/` taucht in `git status` auf | `.gitignore` fehlt oder wurde verändert. | `.gitignore` prüfen, dort muss `kuma-data/` stehen. |
| Pull Request zeigt *„There isn't anything to compare“* | `dev` enthält keine neuen Commits gegenüber `main`, oder die Richtung ist vertauscht. | `base: main` ← `compare: dev` prüfen. Wurde auf `dev` gepusht? |

## Docker und Compose

| Meldung / Symptom | Ursache | Lösung |
|---|---|---|
| `Bind for 0.0.0.0:8085 failed: port is already allocated` | Ein anderer Container belegt den Port, oft der alte Stack. | `sudo docker ps` → alten Container stoppen (`sudo docker rm -f NAME`) bzw. im alten Ordner `sudo docker compose down` |
| `Conflict. The container name "/technova-web" is already in use` | Ein Container mit demselben `container_name` existiert noch (z. B. aus `~/microcloud-alt`). | `sudo docker rm -f technova-web`, dann erneut `sudo docker compose up -d` |
| `yaml: line X: found character that cannot start any token` | Tabulator in der YAML-Datei | Nur Leerzeichen verwenden (2 pro Ebene). |
| `curl` liefert *403 Forbidden* | Im Web-Ordner des Containers liegt keine `index.html`. | Volume-Pfad prüfen (nginx: `/usr/share/nginx/html`, Apache: Doku des `httpd`-Images). |
| `curl` liefert lokal *403 Forbidden*, obwohl der Volume-Pfad stimmt | Der Webserver im Container darf deine Dateien nicht lesen (Dateirechte auf dem LXC). | `chmod -R a+rX html`, dann erneut `curl` |
| Apache zeigt *„It works!“* | Volume hängt am falschen Ordner, Apache zeigt seine Standardseite. | siehe [05 – dev-Branch](../anleitung/05-dev-branch-apache.md#schritt-4-recherche--wo-erwartet-apache-die-webseiten) |

## Die CI

| Fehlgeschlagener Step | Bedeutung |
|---|---|
| 2 · Compose-Datei suchen | Keine `compose.yml` im Hauptordner des Repos. Committet und gepusht? |
| 3 · YAML-Syntax prüfen | Die Datei ist kein gültiges Compose-YAML (Einrückung, Tabs, Doppelpunkte). |
| 4 · Port 8085 prüfen | Kein Dienst veröffentlicht den **Host**-Port 8085. |
| 6 · Erreichbarkeit | Der Container läuft, aber hinter Port 8085 antwortet niemand. Stimmt der **Container**-Port? Schritt 4 prüft nur den **Host**-Port links vom Doppelpunkt, deshalb ist z. B. `"8085:8085"` in Schritt 4 noch grün. Rechts muss der Port stehen, auf dem der Webserver **im Container** lauscht (steht in der Doku des Images). |
| 7 · Inhalt prüfen | Der Server antwortet, liefert aber nicht deine `html/index.html`. Stimmt der Volume-Pfad? Schritt 6 ist in diesem Fall trotzdem grün: Ohne deine Seite liefert jeder Webserver seine **Standardseite mit HTTP 200** aus. Erst Schritt 7 vergleicht den Inhalt. |

| Symptom | Ursache | Lösung |
|---|---|---|
| Rot in Schritt 2 **direkt nach dem Erstellen** des Repos (Lauf 1) | Normal: Dein Repo enthält bis jetzt nur die Vorlage, noch keine `compose.yml`. | Weiter mit [Phase 2](../anleitung/02-repo-anlegen-und-stack-einspielen.md), Stack einspielen und pushen. |
| Rot in Schritt 4 **nach dem ersten Push deines Stacks** (Lauf 2) | Normal: Dein Stack aus Modul 4 veröffentlicht noch Port 8080 statt 8085. | Weiter mit [Phase 3](../anleitung/03-port-anpassen-erster-gruener-build.md), Port anpassen. |
| Variable in `compose.yml` (z. B. `${WEB_PORT}`), CI rot in Schritt 3 oder 4 | Die CI kennt nur, was im Repo liegt. Eine `.env` auf dem LXC ist nicht committet (und gehört oft auch nicht hinein). | Standardwert angeben: `"${WEB_PORT:-8085}:…"` |
| Abzeichen zeigt einen **alten Stand** | Der Browser speichert das Abzeichen-Bild bis zu 5 Minuten zwischen. | Seite mit Strg+F5 neu laden. Der Tab **Actions** zeigt immer den aktuellen Stand. |

## Die DoD-Abzeichen: rot oder grau – was fehlt?

Klick auf das Abzeichen, öffne den letzten Lauf und lies unter **Summary** den Steckbrief. Dort steht genau, welcher Prüfpunkt fehlt.

| Abzeichen | Typische Ursache | Lösung |
|---|---|---|
| **DoD 1 · Repo** rot | Repo privat, kein Repo aus der Vorlage (z. B. Fork), `compose.yml` oder `html/index.html` nicht committet, oder `kuma-data/` committet | Steckbrief lesen. Bei `kuma-data/`: `git rm -r --cached kuma-data`, committen, pushen |
| **DoD 2 · Microcloud-CI** rot | Der Test auf `main` schlägt fehl (Port, Container-Port, Volume-Pfad) | siehe Tabelle „Die CI“ oben |
| **DoD 3 · Branch dev** grau | Es gibt noch keinen Branch `dev` auf GitHub | `git switch -c dev`, ändern, committen, `git push -u origin dev` |
| **DoD 3 · Branch dev** rot | `dev` ist gepusht, enthält aber noch keine eigene Änderung | Auf `dev` die Umstellung committen und pushen |
| **DoD 4 · Apache auf main** rot | Auf `main` läuft noch nginx, weil die Umstellung erst auf `dev` liegt | Pull Request `dev → main` nach grünem Test mergen (Phase 6) |
| **DoD 3 · Branch dev** rot, obwohl gepusht | Auf `dev` liegen nur Commits ohne Dateiänderung (z. B. `git commit --allow-empty`) | Die Umstellung wirklich in `compose.yml` committen und pushen |
| **DoD 5 · Pull Request** rot | Noch kein PR von `dev` nach `main` gemergt, **oder** er wurde gemergt, bevor der Test grün war, **oder** nach dem grünen Lauf wurde noch ein Commit auf `dev` gepusht und sofort gemergt (der Test muss für den **letzten** Commit grün sein) | Auf `dev` korrigieren, neuen PR stellen, erst nach grünem Check für den letzten Commit mergen |
| **DoD 5** meldet *„Kein Lauf … gefunden“* | Der Jobname in `microcloud-ci.yml` wurde verändert. DoD 5 erkennt den Test am Namen `Compose-Stack testen (Port 8085)`. | Jobnamen zurücksetzen, auf `dev` pushen, neuen PR stellen |

Mehr dazu: [CI-Log lesen](ci-log-lesen.md)
