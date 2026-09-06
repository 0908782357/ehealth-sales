# eHealth Alliance Compass — Analyse des Webservice (`Compass.zip`)

Analysiertes Artefakt: `Compass.zip` (58 MB) → Projekt `Compass-cgi`, 208 Dateien, ~25.500 Zeilen
Frontend-Code. Interner Projektname im Code: **healthcheck360**.

> Bezeichner, die wörtlich aus dem analysierten Archiv stammen — der Ordnername
> `Compass-cgi` und die SES-Identity `cgicompass.com` — sind bewusst nicht umbenannt.
> Sie beschreiben den vorgefundenen Stand; eine Umbenennung würde die Analyse falsch machen.

---

## 1. Was der Service macht

eHealth Alliance Compass ist eine **Compliance-Assessment-Plattform**. Berater:innen legen Mandanten an,
arbeiten mit ihnen einen Fragenkatalog ab (Themen: Cloud, AI, Security, ESG, Test Automation),
und das System berechnet daraus eine gewichtete Reifegrad-Auswertung inklusive
Handlungsempfehlungen, Benchmark-Vergleich und PDF-Report. Die erläuternden Fließtexte
des Reports werden per OpenAI GPT-4o generiert.

Drei Nutzungsmodi:

| Modus | Zugang | Zweck |
|---|---|---|
| **Standard-Assessment** | Login (Cognito) | Klassisches Reifegrad-Assessment, Anforderungen 0–3 bzw. ja/nein gewichtet |
| **Two-Dimensional Assessment** | Login | Risiko-Assessment mit x-/y-Achse (Ausmaß, Umfang, Eintrittswahrscheinlichkeit) → Risikomatrix |
| **Public Assessment** | öffentlich, ohne Login (API-Key) | Self-Service-Kurzassessment für Interessenten, Ergebnis per Mail |

Dazu ein **Office Assessment / Quiz** (10 Multiple-Choice-Fragen über eHealth Alliance), das per SES
eine Ergebnismail verschickt — offensichtlich für einen Messe-/Office-Event gebaut.

---

## 2. Architektur

**Reines AWS-Amplify-Projekt (Gen 1), Serverless, kein eigener Applikationsserver.**

```
React 18 SPA (Vite 4)                     ← src/
  MUI 5 + Emotion · react-router-dom 6
  recharts (Radar/Charts) · @react-pdf/renderer (Report)
  react-speech-recognition (Diktat für Anmerkungen)
        │  aws-amplify 5 (API / Auth / Storage)
        ▼
AWS AppSync (GraphQL)  ←→  DynamoDB (11 @model-Tabellen)
  Auth: Cognito User Pool + Identity Pool, zusätzlich API-Key für Public Assessments
        │
        ├── Lambda ComputeEvaluation          Auswertung Standard + GPT-4o-Texte
        ├── Lambda ComputeTwoDimEvaluation    Auswertung Risikomatrix
        ├── Lambda CreatePublicEvaluation     Auswertung öffentliches Assessment
        ├── Lambda CreateNewAssessmentVersion Versionierung eines Fragenkatalogs
        ├── Lambda ChangeAssessmentStatus     Statuswechsel Evaluation
        ├── Lambda EvaluationRequestHandler   API-Gateway-Einstiegspunkt
        ├── Lambda SendQuizMailFunction       Ergebnismail via SES (cgicompass.com)
        ├── Lambda AdminQueries               Cognito-Benutzerverwaltung
        └── Lambda PreAuthentication          Login-Hook
        │
S3 (Amplify Storage)   Profilbilder, Modul-Bilder
SSM Parameter Store    OpenAI API Key (verschlüsselt)
Amplify Hosting        Auslieferung der SPA
```

### Datenmodell (`amplify/backend/api/healthcheck360/schema.graphql`)

```
Module (= Assessment)
  └── Category (= Modul/Themenblock, n:m über modules:[ID])
        └── Question   index, content, title, source, package(Basic|Premium),
                       requirements: JSON, threshold (nur Two-Dim)
              └── requirements[uuid] = { id, text, weight,
                                         discreteOptions, discreteSolutions,
                                         solution, solution1..3 }

Customer (Mandant)  ── Answer ──> Question
                       Answer = { rating 0..100, responsibleRole, answerText,
                                  requirementAnswers: { reqId: {fulfilled, disabled} } }

Evaluation ── EvaluationModuleData (pro Kategorie: content + generatedText)

PublicAssessment ── PublicAssessmentAnswers
OfficeAssessmentData (Quiz-Teilnehmer)
```

Auffällig: **Namensinversion**. Im GraphQL-Schema heißt der Container `Module` und der
Themenblock `Category`; im UI ist ein `Module` das *Assessment* und eine `Category` das
*Modul*. Der Kommentar `#Assessment` / `#Modul` im Schema bestätigt das.

### Autorisierung

- Cognito-Gruppen mit Precedence: `Admin` (1), `Contributor` (2), dann fachliche Gruppen
  (`ESG`, `AI`, `Security`, `M365`, `QualityAssurance`, `DataPlatform`, `GTO`, `Corporate` …),
  zuletzt `User` (14).
- Feldbasierte Ownership: `Category`/`Question`/`Module` tragen `ownerGroup` — eine
  Fachgruppe darf nur ihre eigenen Fragen ändern (`groupsField: "ownerGroup"`).
- `Customer.ownerList` beschränkt Lesen/Löschen auf zugeordnete Berater.
- `PublicAssessment` ist per API-Key öffentlich lesbar (`allow: public, operations: [get]`),
  `PublicAssessmentAnswers` öffentlich nur `create` — sauber gewählt.

### Bewertungslogik (der fachliche Kern)

Pro Frage, in `StandardAssessment.jsx:calculatePercentage()`:

```
rating = Σ(weight · fulfilled/3)  /  Σ(weight)   · 100      // über alle nicht deaktivierten
                                                            // Anforderungen; bei
                                                            // discreteOptions=false: 0 oder weight
```

Pro Kategorie, in `ComputeEvaluation/src/index.mjs`:

```
totalRating          = Σ rating der Fragen
maxRating            = Anzahl Fragen · 100
totalRatingInPercent = totalRating / maxRating
recommendations      = solution jeder nicht deaktivierten Anforderung mit fulfilled ≤ 1
completelyAnswered   = alle Fragen der Kategorie beantwortet
```

Anschließend zwei GPT-4o-Aufrufe: ein Gesamttext über alle Kategorieergebnisse und je
Kategorie ein Text über die offenen Handlungsempfehlungen.

---

## 3. Befunde

**Blocker für den Originalbetrieb**

1. **`src/aws-exports.js` fehlt** — per `.gitignore` ausgeschlossen. Ohne diese Datei
   startet die SPA nicht; sie enthält User-Pool-ID, AppSync-Endpoint und API-Key.
2. **Kein Backend im Archiv.** `amplify/#current-cloud-backend`, `amplify-meta.json` und
   `team-provider-info.json` fehlen ebenfalls. Ein `amplify pull` gegen die echte
   AWS-Umgebung wäre nötig — d. h. AWS-Credentials für das Konto `654654302313`.
3. **Kein Fragenbestand.** Die ~580 produktiven Assessment-Fragen liegen in DynamoDB,
   nicht im Repository. Im Archiv finden sich nur zwei Fragensätze (siehe Abschnitt 4).
4. Auf dieser Maschine ist weder Node.js noch Python installiert — `npm install` /
   `vite dev` / `amplify mock` sind ohnehin nicht ausführbar.

**Qualität / Wartbarkeit**

- Sehr große Komponenten: `EditQuestions.jsx` 1.676 Zeilen, `DisplayEvaluation.jsx` 1.672,
  `PublicAssessments.jsx` 1.401. Keine Tests im Archiv, `README.md` ist leer.
- `catch { }` ohne Fehlerobjekt im `ComputeEvaluation`-Handler verschluckt die Ursache;
  im Fehlerfall wird die Evaluation nur auf `ERROR` gesetzt, ohne Log.
- In `ComputeEvaluation` referenziert die Recommendation-Schleife `solutionKeys[x.fulfilled]`,
  obwohl die Laufvariable `e` heißt — bei `discreteSolutions: true` läuft das in einen
  ReferenceError und damit über den `catch` in den ERROR-Status.
- `document.onkeydown` wird in `StandardAssessment.jsx` global überschrieben (Ctrl+S-Handler)
  statt über einen React-Effekt registriert — überschreibt fremde Handler.
- Sprachumschaltung DE/EN ist als Prop durch den kompletten Komponentenbaum gereicht
  (`language={language}` in jeder Route) statt über Context/i18n-Bibliothek.

**Datenschutz / Sicherheit**

- Public Assessments erheben Name, Mail, Telefon, Organisation plus Marketing-Einwilligung
  (`consentMarketingMails`) — DSGVO-relevant, Löschkonzept nicht im Code erkennbar.
  Der auskommentierte Typ `PublicAssessmentEvaluation` enthält den Hinweis
  „should be automatically deleted after e.g. 7 days" — offenbar nie umgesetzt.
- Assessment-Antworten von Kunden gehen als Prompt an die OpenAI-API. Für Kundendaten in
  einem Compliance-Werkzeug sollte das vertraglich und im Datenschutzhinweis abgedeckt sein.
- Der OpenAI-Key liegt korrekt verschlüsselt im SSM Parameter Store, nicht im Code.

---

## 4. Fragenbestand im Archiv

| Quelle | Umfang | Inhalt |
|---|---|---|
| `src/pages/management/InputData.jsx` | 11 Fragen | **Test-Automation-Assessment**: je Frage ein Bereich (*Area*), die Frage selbst und eine Handlungsempfehlung (*Suggestions for Improvement*). Import-Seed für `EditQuestions.jsx` (dort auskommentiert). |
| `src/pages/officeAssessment/assessmentData.jsx` | 10 Fragen | **eHealth Alliance Compass Quiz**: Multiple Choice mit vier Optionen, korrekter Antwort und Auflösungstext. |

Beide sind in der lokalen Instanz als Content hinterlegt.

---

## 5. Lokale Bereitstellung

Da das Original ohne AWS-Backend nicht startet, liegt daneben eine **eigenständige lokale
Instanz** (`index.html`): dieselbe Domäne, dieselbe Bewertungsformel, dieselbe Optik,
ohne Cloud-Abhängigkeit. Details in `README.md`.

Übernommen wurden:

- Datenmodell Module → Category → Question → Requirements (weight, discreteOptions, solution)
- Bewertungsformel je Frage (`calculatePercentage`) und je Kategorie (`ComputeEvaluation`)
- Ableitung der Handlungsempfehlungen (`fulfilled ≤ 1` → `solution`)
- Skala „Nicht erfüllt / Kaum erfüllt / Weitgehend erfüllt / Erfüllt" (`discreteDescriptions`)
- „Nicht relevant"-Schalter (`disabled`), Ansprechperson, Anmerkungen, Quelle
- DE/EN-Umschaltung, eHealth Alliance-Farbpalette und -Gradienten aus `helpers/enums.jsx`, Original-SVGs

Ersetzt wurden:

| Original | Lokal |
|---|---|
| AppSync + DynamoDB | `localStorage` |
| Cognito-Login | entfällt (Single-User) |
| GPT-4o-Fließtext | deterministisch erzeugte Zusammenfassung nach demselben Prompt-Aufbau |
| recharts RadarChart | handgezeichnetes Inline-SVG |
| `@react-pdf/renderer` | Druckansicht (`window.print()`) + JSON-Export |
