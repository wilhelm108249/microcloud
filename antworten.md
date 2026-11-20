##Teil A:  Aufbau der Workflow Datei##

1: Bei welchen Ereignissen (Events) startet der Workflow? Nenne alle drei.
Antwort: push, pull_request, workflow_dispatch

2: Auf welchem Runner (Betriebssystem) läuft der Job? Wer stellt diesen Rechner bereit?
Antwort: Ubuntu-Latest (Frischer Ubuntu-Rechner mit Docker + Compose)

3: Wie heißt der Job, und wie viele Steps hat er?
Antwort: Name= Compose-Stack testen (Port 8085) und Steps: 9

4: Welcher Step nutzt eine fertige Action (uses:), welche führen eigene Befehle aus (run:)?
Antwort: Step 1 Nutzt "uses: actions/checkout@v7" ; Step 2 bis Step 9 nutzen alle "run:"

5: Welche Rechte hat der Workflow (permissions)? Warum ist es sinnvoll, sie so knapp zu halten?
Antwort: Der Workflow hat nur leserechte. (Zeile im Code 30/31). Sinnvoll, da dann nicht ungewollte Aktionen
durchgeführt werden können oder Dateiänderungen vorgenommen werden können.

6: Der Job hat die Bedingung if: ${{ !github.event.repository.is_template }}. 
   Was bewirkt sie in der Vorlage und was in deinem Repo?
   Antwort: Die Bedingung ist, dass das Event-Repository keine Vorlage (Template) ist. 
   Es darf also nicht der Haken bei Template repository gesetzt sein. 

## Teil B Was wird geprüft? ##

7: Ordne zu: Welcher Step würde zuerst fehlschlagen, wenn …

... in der compose.yml ein Tabulator statt Leerzeichen steht?
  Antwort: Step3, da Docker Compose & Yaml verbieten Tabulatoren und Docker compose config bricht hier ab.
  
... der Ordner html/ nie committet wurde?
  Antwort: Step 7. Da wird die Bedingung "if [! -f html/index.html]" gegeben und ein diff ausgeführt.

... ports: - "8085:8080" eingetragen ist?
  Antwort: Step 6. Container hat Port 80 und nicht 8080, da schlägt der Curl befehl Fehl.

...die compose.yml versehentlich in einem Unterordner liegt?
  Antwort: Step 2. Nur das Hauptverzeichnis wird nach der compose.yml durchsucht und keine Unterordner.
  Erkennt man daran, das nur die Dateinamen angegeben wurden im Schleiffenkopf. Ansonten würde da stehen 
  z.b /html/compose.yml usw.

8: Step 7 vergleicht mit diff, ob der Server genau deine html/index.html ausliefert.
Warum reicht es nicht, nur zu prüfen, ob Port 8085 antwortet? Denke an Phase 5 … 
Antwort: Es wird verglichen, ob die html Seite die angezeigt wird auch die gleiche Datei ist die auf dem
Server liegt. Gibt es unterschiede wird das als Fehler angezeigt.

9: Die Steps 8–10 haben if: always() bzw. if: failure(). 
Wozu dient Step 10 Aufräumen, obwohl der Runner nach dem Lauf ohnehin gelöscht wird?
Damit auch die restlichen Volumes auch gelöscht werden, da sonst die Daten auf der Test Maschine 
bestehen bleiben würden.

## Teil C: Einordnen##

10: Ist das, was dieser Workflow tut, Continuous Integration, Continuous Delivery
oder Continuous Deployment? Begründe.
Antwort: Es ist CI (Continuous Integration), da wir eine Automatisierte Überprüfung bei jeder Änderung
haben und eine Isolierte Test Umgebung auf einem Test-Runner läuft, die gelöscht wird nach jeden run.

11: Nenne zwei Vorteile, die die TechNova GmbH durch diesen automatischen Test hat, im Vergleich dazu, 
dass jeder Admin „mal kurz mit curl testet“.
Antwort: Kein menschlicher Faktor, Zeit sparen. Wenn der Test vom Admin gemacht wird kann auch
mal ein Use-Case vergessen werden zu testen. Dadurch würde man den Fehler evtl viel später merken.

