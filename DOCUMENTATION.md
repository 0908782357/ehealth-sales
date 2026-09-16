# eHealth Sales – Website & Admin-Portal Dokumentation

Stand: 2026-09-13 · Diese Dokumentation beschreibt den aktuellen Build der öffentlichen Website und des Admin-Portals.

## Überblick

| | |
|---|---|
| **Stack** | Statisches HTML/CSS/Vanilla-JS, kein Build-Framework, kein Bundler |
| **Backend** | Supabase (Postgres + Auth + Storage), Zugriff über `@supabase/supabase-js@2` (CDN) |
| **E-Mail** | Resend, per PHP-Relay (`send-email.php`) |
| **Hosting** | Strato, Deployment per SFTP über GitHub Actions |
| **Repo** | `github.com/0908782357/ehealth-sales` |

Es gibt **keinen zentralen Build-Schritt** für Website und Portal – jede HTML-Datei ist eigenständig und wird 1:1 deployed. Einzige Ausnahme ist das `compass/`-Tool (siehe unten), das über ein Shell-Skript zu einer einzelnen Datei zusammengebaut wird.

---

## 1. Öffentliche Website (Root-Verzeichnis)

| Datei | Zweck |
|---|---|
| `index.html` (4.961 Zeilen) | Haupt-Website als Single-Page-App. Alle "Seiten" sind `<div id="page-...">`-Blöcke, die per JS (`showPage()`) ein-/ausgeblendet werden – kein echtes Routing, kein Reload. |
| `landingpage.html` | Eigenständige Produkt-Landingpage, lädt ein Produkt per `?id=`-Parameter aus `products` |
| `loesung-public.html` | Eigenständige Lösungs-Detailseite, ebenfalls `?id=`-basiert |
| `finder-whitelabel.html` | Marketing-Seite, die den Produktfinder als White-Label-Produkt an Partner verkauft; verlinkt zum Bestellen auf `admin/shop.html` |
| `config.js` | Ein Einzeiler: `window.RESEND_API_KEY = '...'` (nicht in git, siehe Sicherheitshinweise) |
| `send-email.php` | Minimaler CORS-beschränkter PHP-Relay: nimmt `{to, subject, html}` per POST entgegen, leitet an die Resend-API weiter (nicht in git) |

### Struktur von `index.html`

Die Seite gliedert sich in folgende Bereiche (per Kommentar-Marker `PAGE: ...` und `id="page-..."`):

```
STARTSEITE → LEISTUNGEN → ÜBER UNS → KONTAKT → IMPRESSUM → DATENSCHUTZ →
PARTNER → PRODUKTFINDER → LÖSUNGEN → DETAIL (Shop) → FOOTER → JS (ab Zeile ~2552)
```

### Der Produktfinder (Kernstück der Website)

Mehrstufiger Wizard in `PAGE: PRODUKTFINDER` (~Zeile 1953–2410):

1. **Themenauswahl** – SVG-Donut-Chart mit 6 Segmenten (`selectTopic()`): Cybersecurity, Telematik-Infrastruktur, IT-Infrastruktur, Modern Work, Prozessdigitalisierung, Telemedizin
2. **Assessment** – `startAssessment()` → `renderAssessmentQuestion()` → `answerAssessment()` → `showAssessmentResult()` → Radar-Chart (`renderResultSpider()`) aus 12 Fragen, empfiehlt ein Thema
3. **Berufsgruppen-Auswahl** – `selectBG()`, `renderBerufsgruppen()`
4. **Filterung/Ergebnisse** – `filterLoesungen()`, `applyFilters()`, `renderLoesungen()`, `renderTopicFilterStrip()`
5. **TI-Finanzierungsrechner** (eingebettet) – `calcKH377Wiz()`, `calcRehaZuschlag()`, `renderWizStaffelTable()` – Förderrechner nach SGB V §§371–382 je Berufsgruppe
6. **Anfrage-/Bestell-Flow** – `wizToStep3()`, `wizSubmit()`, `wiz2Submit()`, `openOrderModal()`, `submitOrder()`

**Genutzte Supabase-Tabellen:** `anfragen`, `shop_items`, `orders`, `partners`, `partner_finder_config`, `products`, `bundles`, `bundle_items`, `bundle_berufsgruppen`, `berufsgruppen`, `bg_topic_requirements`

### Weitere öffentliche Seiten

- `landingpage.html` / `loesung-public.html`: dünne, reine Lese-Seiten (`renderPage()`), laden ein Produkt per `?id=`
- `finder-whitelabel.html`: lädt live Preise für das Finder-Produkt (`products`, gefiltert auf `ilike('produkt','%finder%')`, `published=true`, `partner_id is null`); **enthält Supabase-URL/Key hardcoded** statt aus `config.js` zu lesen (Inkonsistenz, siehe Hinweise unten)

---

## 2. Admin-Portal (`admin/`)

Jede Seite ist ein eigenständiges HTML-Dokument mit eigenem `<script>`-Block, aber wiederkehrendem Muster: `init()`-Bootstrap, `logout()`, `toggleNavGroup()` (Sidebar), `setupNavRole()` (rollenbasierte Nav-Sichtbarkeit – pro Datei dupliziert, kein gemeinsames Modul).

| Seite | Zweck | Tabellen | Rollen-Logik |
|---|---|---|---|
| `index.html` | Login (Passwort, OTP, Erstpasswort, Profil-Claim) | `user_profiles`, `user_roles` | Kein Rollen-Gate (Einstiegspunkt) |
| `dashboard.html` | Startseite nach Login, KPIs | `partners`, `products`, `user_roles` | `admin` vs. `customer` → unterschiedliche KPI-Kacheln |
| `users.html` | Nutzerverwaltung (CRUD, Einladungen) | `partners`, `user_profiles`, `user_roles` | faktisch admin-only (Nav-Gate) |
| `products.html` | **Größte Admin-Seite** (1.743 Zeilen, ~65 Funktionen): Produkt-CRUD, Bundle-Management, Preis-Wizard, Bild-Upload | `products`, `bundles`, `bundle_items`, `bundle_berufsgruppen`, `berufsgruppen`, `partners`, `user_profiles` | `userRole`-Checks schränken Bearbeiten/Veröffentlichen ein |
| `partners.html` | Kundenverwaltung, Embed-Code, Status (aktiv/test/gesperrt) | `partners`, `products`, `user_roles` | hart auf `admin` gesetzt |
| `finder-config.html` | Produktfinder-Konfiguration je Partner (Farben, Themen, URL) | `partner_finder_config`, `partners`, `user_roles` | Admin kann jeden Partner wählen, Partner nur sich selbst |
| `shop.html` | Zweitgrößte Seite (1.406 Zeilen): Warenkorb, Bestell-Flow inkl. Bundle-BOM-Modal, Artikel-CRUD | `shop_items`, `bundles`, `bundle_items`, `orders`, `order_items`, `partners`, `products` | `userRole` trennt Shop-Admin (Artikelverwaltung) von Kunde (Kauf) |
| `orders.html` | Bestellverwaltung inkl. aufklappbarer Bundle-Extras | `orders`, `order_items`, `access_tokens`, `partners`, `user_profiles` | nur Nav-Gate |
| `knowledge.html` | Community/Wissensdatenbank, Forum, Board | `knowledge_articles`, `board_posts`, `forum_channels`, `forum_posts`, `forum_threads`, `partners`, `user_profiles` | `userRole` gated Erstellen/Löschen, Lesen offen |
| `berufsgruppen.html` | Berufsgruppen-CRUD inkl. TI-Finanzierungs-Staffeln | `berufsgruppen`, `bg_topic_requirements`, `user_roles` | `userRole` gated Bearbeitung |
| `rechner.html` | TI-Finanzierungsrechner (Admin-Ansicht) | `berufsgruppen`, `bg_topic_requirements`, `user_roles` | `admin` schaltet ein erweitertes Panel frei |
| `profile.html` | Mein Konto (Passwort, Logo, Profil) | `partners`, `user_profiles`, `user_roles` | `admin`/`customer` steuert editierbare Felder |
| `loesung.html` | Admin-seitiges Pendant zu `loesung-public.html` | `products` | keine |

### Datenbank-Schema

- **`admin/setup.sql`** (Master-Schema, 27,9 KB): `user_roles` (Enum admin/partner/customer), `partners`, `products`, `knowledge_articles`, `user_profiles`, `shop_items`, `orders`, `access_tokens`, `partner_finder_config`, `berufsgruppen`, Funktion `public.is_admin`
- **`admin/sql/bundle_migration.sql`**: Bundle-System – `bundle_items`, `bundle_berufsgruppen`, `order_items`, RLS-Policies dafür
- **`sql/` (Projekt-Root)** – inkrementelle Migrationen:
  - `add_bg_topic_requirements.sql` – Tabelle für Berufsgruppen↔Themen-Förderanforderungen
  - `add_bundle_themen.sql` – Themen-Spalte auf `bundles`
  - `add_has_rechner.sql` – Flag "hat Rechner" auf `berufsgruppen`
  - `add_rechner_config.sql` – Rechner-Konfigurationsspalten
  - `ti_finanzierung_import.sql` – Seed-Daten TI-Finanzierungsvereinbarungen (§§371–382 SGB V, Stand September 2026)

**Hinweis:** Rollen-Prüfung erfolgt aktuell **clientseitig, pro Seite**, nicht über ein gemeinsames Modul. Die eigentliche Durchsetzung sollte über Supabase Row-Level-Security-Policies laufen (in `bundle_migration.sql` sichtbar) – die vollständigen RLS-Policies aller Tabellen wurden hier nicht geprüft (dafür wäre Zugriff auf das Supabase-Dashboard nötig) und sollten separat verifiziert werden.

---

## 3. Compass-Tool (`compass/`)

Ein eigenständiges, separat gebrandetes Mikro-Tool: **"eHS Compass"** – ein Token-gated Quiz/Assessment (vermutlich für Messen/Events), unabhängig vom Haupt-Produktfinder.

- `compass/build.sh`: baut `index.html` aus `src/part_head.html` + `src/_input.js` + `src/_quiz.js` + `src/_alliance.js` + `src/part_app.js` + `src/part_tail.html`, inlined alle Bilder als Base64 → eine portable Einzeldatei
- `compass/index.html`: gegatete Version, fragt Zugangscode ab (`submitToken()`) vor Anzeige des Inhalts
- `compass/app.html`: lokale/ungegatete Entwicklungsversion
- `compass/ANALYSE.md`: Wettbewerbs-/Recherchedokument zu einem größeren externen Referenzprodukt ("Compass.zip"/"healthcheck360", AWS-Amplify/React-SaaS) – Hintergrundrecherche, kein Code dieses Verzeichnisses

---

## 4. Deployment (CI/CD)

**`.github/workflows/deploy.yml`** – Trigger: Push auf `main` oder `staging`.

- Push auf `main` → SFTP-Mirror (`lftp mirror -R --delete`) nach Strato, Zielverzeichnis aus `secrets.SFTP_TARGET_DIR` → **Produktion**
- Push auf `staging` → gleicher Mechanismus, `secrets.SFTP_STAGING_DIR` → **Staging**
- Ausgeschlossen vom Mirror: `.git/`, `.github/`, `.gitignore`, `.DS_Store`

**`.github/workflows/release.yml`** – Trigger: Tag `v*.*.*`, erstellt automatisch eine GitHub Release (reine Versionierungs-Konvenience, kein Deployment).

Lokale Entwicklung läuft über `.claude/launch.json` (Python-HTTP-Server auf Port 3334, nicht in git).

---

## 5. Sicherheitshinweise (zur Kenntnisnahme, keine Bewertung der Dringlichkeit)

- **Resend-API-Key** liegt im Klartext in `config.js` und `send-email.php` – beide Dateien sind `.gitignore`t (nicht im Repo), liegen aber unverschlüsselt auf dem Server/der Platte.
- **Supabase Anon-Key** ist bewusst in praktisch jeder Seite eingebettet (Standard-Pattern bei Supabase: öffentlicher Anon-Key + serverseitige RLS-Policies) – das ist an sich kein Problem, solange die RLS-Policies korrekt greifen.
- `finder-whitelabel.html` liest Supabase-URL/Key hardcoded statt aus `config.js` – Inkonsistenz, keine akute Schwachstelle.
- Rollenprüfung ist clientseitig dupliziert (kein gemeinsames Auth-Modul) – funktional, aber Wartungsrisiko bei künftigen Rollen-Änderungen.
- Der Git-Remote (`origin`) enthält einen Benutzernamen in der URL – bei externem Teilen dieses Dokuments oder des Repo-Links beachten.

---

## Offene Punkte / für spätere Vertiefung

- Supabase RLS-Policies aller Tabellen (nicht nur Bundle-System) sind nicht dokumentiert – Export aus dem Supabase-Dashboard empfohlen
- TI-Finanzierungsinfos direkt bei Produkten anzeigen (aus vorherigem Fortschritts-Stand übernommen, weiterhin offen)
