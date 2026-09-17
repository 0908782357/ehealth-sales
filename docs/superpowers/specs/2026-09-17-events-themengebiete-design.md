# Events & Themengebiete — Design-Dokument
**Datum:** 2026-09-17  
**Ansatz:** B — Themengebiete-Fundament + Events-System; Topic-Tagging für products/bundles/kunden/VC inkrementell in Folge-Sessions  
**Status:** Genehmigt ✓

---

## Zusammenfassung

Aufbau eines zentralen Themengebiet-Systems als verbindende Schicht zwischen Produkten, Wissen, Events und Produktfinder. In dieser ersten Phase: Admin-Verwaltung der Themengebiete + vollständiges Events-System (Portal + öffentliche Alliance-Site).

---

## 1. Datenbankschema

### 1.1 `themengebiete`
Zentrale Topic-Tabelle, verwaltet durch Admins. Wird in allen zukünftigen Content-Typen referenziert.

```sql
CREATE TABLE themengebiete (
  id          uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name        text NOT NULL,
  slug        text NOT NULL UNIQUE,
  farbe       text NOT NULL DEFAULT '#1C74B8',
  beschreibung text,
  sortierung  int NOT NULL DEFAULT 0,
  aktiv       boolean NOT NULL DEFAULT true,
  created_at  timestamptz DEFAULT now()
);
```

### 1.2 `events`
Events werden von Partnern erstellt und können öffentlich auf der Alliance-Site beworben werden.

```sql
CREATE TABLE events (
  id               uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  titel            text NOT NULL,
  kurzbeschreibung text NOT NULL,
  beschreibung     text,
  datum            date NOT NULL,
  uhrzeit_start    time NOT NULL,
  dauer_min        int NOT NULL DEFAULT 60,
  format           text NOT NULL DEFAULT 'webinar',
  -- webinar | roundtable | workshop | vortrag
  max_teilnehmer   int,
  -- null = unbegrenzt
  teilnahme_link   text,
  -- Zoom/Teams-URL, nur für angemeldete Mitglieder sichtbar
  partner_id       uuid NOT NULL REFERENCES partners(id) ON DELETE CASCADE,
  status           text NOT NULL DEFAULT 'entwurf',
  -- entwurf | geplant | abgeschlossen | abgesagt
  oeffentlich      boolean NOT NULL DEFAULT false,
  -- Partner setzt selbst, Admin kann übersteuern
  created_at       timestamptz DEFAULT now()
);

CREATE INDEX idx_events_datum ON events(datum);
CREATE INDEX idx_events_partner_id ON events(partner_id);
CREATE INDEX idx_events_status ON events(status);
```

### 1.3 `event_themen` (Junction, Many-to-Many)
```sql
CREATE TABLE event_themen (
  event_id  uuid NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  thema_id  uuid NOT NULL REFERENCES themengebiete(id) ON DELETE CASCADE,
  PRIMARY KEY (event_id, thema_id)
);
```

### 1.4 `event_anmeldungen`
```sql
CREATE TABLE event_anmeldungen (
  id            uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  event_id      uuid NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  user_id       uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  status        text NOT NULL DEFAULT 'angemeldet',
  -- angemeldet | storniert | warteliste
  angemeldet_am timestamptz DEFAULT now(),
  UNIQUE(event_id, user_id)
);

CREATE INDEX idx_event_anmeldungen_event_id ON event_anmeldungen(event_id);
CREATE INDEX idx_event_anmeldungen_user_id ON event_anmeldungen(user_id);
```

### 1.5 RLS-Policies

**themengebiete:**
- Anon: SELECT (für Alliance-Site)
- Authenticated Admin: INSERT, UPDATE, DELETE

**events:**
- Anon: SELECT WHERE oeffentlich=true AND status='geplant' AND datum >= CURRENT_DATE
- Authenticated (Partner): SELECT/INSERT/UPDATE/DELETE WHERE partner_id = eigene partner_id
- Authenticated (Admin): SELECT/INSERT/UPDATE/DELETE alle

**event_themen:**
- Folgt den Rechten des verknüpften Events

**event_anmeldungen:**
- Authenticated User: SELECT/INSERT/UPDATE WHERE user_id = eigene user_id
- Authenticated (Partner): SELECT WHERE event.partner_id = eigene partner_id
- Authenticated (Admin): alle

---

## 2. Admin-Portal — Neue Seiten

### 2.1 `admin/themengebiete.html`
Verwaltungsseite nach dem Muster von `berufsgruppen.html`.

**Funktionen:**
- Tabelle: Name, Slug, Farbpunkt (CSS), Sortierung, Aktiv-Toggle, Bearbeiten, Löschen
- Modal: Name (Slug wird auto-generiert, überschreibbar), Farbe (Color-Picker), Beschreibung, Sortierung
- Slug-Generierung: Lowercase, Umlaute ersetzt (ä→ae, ö→oe, ü→ue), Leerzeichen → Bindestrich
- Aktiv/Inaktiv-Toggle inline ohne Modal
- Löschen nur wenn keine Events/Produkte mehr referenzieren (sonst Hinweis)

**Zugriff:** Nur Admin-Rolle

---

### 2.2 `admin/events.html`
Hauptverwaltungsseite für Events.

**Rollenverhalten:**
- Admin: sieht alle Events aller Partner; kann Status und `oeffentlich` übersteuern
- Partner: sieht nur eigene Events; kann `oeffentlich` selbst setzen

**Layout:**
- Header-Toolbar: "Neues Event" Button, Filter (Status, Themengebiet, Zeitraum)
- Tabelle: Datum, Titel, Format-Badge, Themen-Chips, Partner (nur für Admin), Status-Badge, Teilnehmer (X/max), Öffentlich-Icon, Bearbeiten, Löschen

**Event-Modal — Tabs:**
- Tab 1 "Grunddaten": Titel, Kurzbeschreibung, Beschreibung (Textarea)
- Tab 2 "Termin & Format": Datum, Uhrzeit, Dauer (Min), Format (Dropdown), Max. Teilnehmer
- Tab 3 "Themen & Sichtbarkeit": Themengebiete (Multi-Select Chips aus DB), Teilnahme-Link, Öffentlich-Toggle, Status

**Teilnehmer-Ansicht:**
- Pro Event-Zeile: aufklappbare Teilnehmerliste (Name, E-Mail, Anmeldestatus, Datum)
- Warteliste automatisch wenn max_teilnehmer erreicht

**Anmeldungs-Tab für eingeloggte Mitglieder (kein Partner/Admin):**
- Tab "Kommende Events": listet alle öffentlichen + geplanten Events mit Anmelden/Stornieren-Button
- Tab "Meine Anmeldungen": eigene gebuchte Events, nach Anmeldung Teilnahme-Link sichtbar

---

## 3. Alliance-Site — `events.html`

Neue öffentliche Seite im Design-System der Alliance-Site (Blau/Teal, Inter/Sora).

**Datenquelle:** Supabase Anon-Key (read-only), nur `oeffentlich=true AND status='geplant' AND datum >= heute`

**Aufbau:**
- Hero-Bereich: "Unsere Events" mit Kurzbeschreibung des Austauschformats
- Filterleiste: Themengebiet-Chips (dynamisch geladen), Format-Filter-Dropdown
- Event-Cards: Datum + Uhrzeit, Titel, Kurzbeschreibung, Format-Badge (farbkodiert), Themen-Chips, Name des veranstaltenden Partners, "Jetzt anmelden →"-Button
- Leerzustand: "Keine Events geplant" Hinweis mit Link zum Mitglieder-Portal
- Alliance-Nav: neuer Punkt "Events"

**"Jetzt anmelden"-Button:**
- Ziel: `https://www.ehealth-sales.de/admin/index.html?event=<event_id>`
- Nicht eingeloggte Nutzer: landen auf Login → nach Login Weiterleitung zurück zum Event
- Eingeloggte Mitglieder: sehen sofort Event-Detail mit Anmeldebutton

---

## 4. Anmeldungsflow im Portal

1. Nutzer klickt "Jetzt anmelden" auf Alliance-Site
2. Weiterleitung auf Portal-Login mit `?event=<id>` als Query-Parameter
3. Nach Login: Portal liest `event_id` aus URL, zeigt Event-Detailansicht
4. Nutzer klickt "Anmelden": INSERT in `event_anmeldungen`
   - Wenn `max_teilnehmer` erreicht → Status `warteliste`
   - Sonst → Status `angemeldet`
5. Teilnahme-Link wird im Portal sichtbar (nur status=angemeldet)
6. Optional: E-Mail-Bestätigung via `send-email.php` an Nutzer
7. Optional: Benachrichtigung an Partner bei neuer Anmeldung

---

## 5. Navigation & Integration

**Admin-Portal:**
- Neuer Nav-Eintrag "Events" in allen bestehenden Admin-Seiten (`admin/*.html`)
- Neuer Nav-Eintrag "Themengebiete" unter "Administration" (wie Berufsgruppen)

**Alliance-Site (`ehealth Alliance/`):**
- Neuer Nav-Punkt "Events" → `events.html`
- Bestehende `index.html`: optionaler "Nächste Events"-Vorschau-Block (3 Cards, Link → events.html)

---

## 6. SQL-Migration

Neue Datei: `admin/sql/migration_events.sql`  
Enthält alle 4 CREATE TABLE-Statements + Indizes + RLS-Policies.

---

## 7. Implementierungs-Reihenfolge (für writing-plans)

1. SQL-Migration schreiben + in Supabase ausführen
2. `admin/themengebiete.html` bauen
3. Nav-Update: Themengebiete-Link in alle Admin-Seiten
4. `admin/events.html` bauen (Admin + Partner-Ansicht + Mitglieder-Anmeldungs-Tab)
5. `event_id`-Query-Parameter-Handling in Portal-Login/Index
6. `ehealth Alliance/events.html` bauen
7. Alliance-Site Nav updaten + optionaler Preview-Block auf index.html

---

## 8. Nicht in diesem Scope (Folge-Sessions)

- Topic-Tagging für Products, Bundles, Kunden, Verkaufschancen
- E-Mail-Benachrichtigungen (Anmeldebestätigung, Partner-Notification)
- Kalender-Export (ICS-Download)
- Aufzeichnungs-Links nach dem Event
