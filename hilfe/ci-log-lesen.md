# Ein CI-Log lesen: Warum ist es rot?

[⬅️ Zurück zum Projektauftrag](../README.md)

## Wo finde ich die Ergebnisse?

| Ort | Was du siehst |
|---|---|
| **DoD-Abzeichen** oben im README | Fünf Abzeichen, eins pro automatisch geprüftem DoD-Punkt: `passing` = erfüllt, `failing` oder `no status` = noch nicht erfüllt. Klick aufs Abzeichen → letzter Lauf → **Summary** zeigt, was fehlt. Achtung: bis zu 5 Minuten Verzögerung (Browser-Cache), neu laden mit Strg+F5 |
| Startseite des Repos, neben dem letzten Commit | ✅ / ❌ / 🟡 (läuft) für diesen Commit |
| Tab **Actions** | Liste aller Läufe mit Commit-Nachricht, Branch und Ergebnis |
| **Pull Request** → Bereich *Checks* | Ergebnis für den geplanten Merge |

## Einen roten Lauf untersuchen, Schritt für Schritt

1. Tab **Actions** → den roten Lauf anklicken.
2. Auf der Übersichtsseite (**Summary**) stehen ganz unten die **Annotations**, also die rot markierten Fehlermeldungen. Die Microcloud-CI schreibt dort in Klartext, was nicht stimmt. **Hier zuerst lesen!**
3. Darunter steht der **Steckbrief** mit Branch, Commit, Port, Webserver und Ergebnis.
4. Für Details links auf den Job **Compose-Stack testen (Port 8085)** klicken. Jeder Step ist aufklappbar:
   - ✅ grüner Haken = Step erfolgreich
   - ❌ rotes X = **hier** ist es passiert, aufklappen und von unten nach oben lesen
   - ⊘ durchgestrichen = übersprungen, weil ein Step davor fehlgeschlagen ist

   Der **erste rote** Step ist der aussagekräftige. Grüne Steps davor heißen nicht, dass dort alles stimmt: Jeder Step prüft nur seinen Teil. Beispiel: Step 6 ist schon grün, wenn *irgendeine* Seite antwortet, auch die Standardseite des Webservers. Ob es **deine** Seite ist, prüft erst Step 7.
5. Bei Fehlern zeigt Step **9 · Container-Logs** die Ausgabe der Container, z. B. Fehlermeldungen des Webservers.

## Den Fehler beheben

1. Fehler **lokal** nachstellen (`sudo docker compose up -d`, `curl …`).
2. Korrigieren, lokal testen.
3. `git add` → `git commit` → `git push`. Ein neuer Lauf startet automatisch.

Einen Lauf ohne neuen Commit wiederholen: Lauf öffnen → **Re-run jobs**. Oder links den Workflow *DoD 2 · Microcloud-CI* wählen → **Run workflow** (das ist der Auslöser `workflow_dispatch`).

> Ein roter Lauf ist **kein Misserfolg**, sondern genau das, wofür CI da ist: Der Fehler wurde gefunden, **bevor** er im Betrieb Schaden anrichtet.
