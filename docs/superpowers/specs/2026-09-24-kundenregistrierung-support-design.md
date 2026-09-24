# Kundenregistrierung & Supportsystem – Design-Spec

## Ziel

Endkunden können sich über die eHealth Alliance Website registrieren. Admins prüfen und genehmigen die Registrierung im Anfragecenter. Nach Freischaltung hat der Endkunde Zugang zum Portal (Tickets, Shop, Events, Community). Support-Tickets landen in einer neuen Supportverwaltung, wo Admins sie priorisieren und Partnern zuweisen können.

## Architektur

Drei aufeinander aufbauende Phasen, die sequenziell implementiert werden:

1. **Registrierungsflow** – öffentliches Formular → Anfragecenter → Genehmigung → Kontoanlage
2. **Kundenportal** – eingeschränkte Portalansicht mit Ticket-Erstellung
3. **Supportverwaltung** – Admin/Partner-Seite für Ticketverwaltung und Zuweisung

## Tech-Stack

- Statisches HTML/JS, Supabase JS SDK v2 via CDN (kein Build-Step)
- Supabase Edge Functions (Deno) für server-seitige Admin-Operationen
- E-Mails über `send-email.php` + Resend API (API-Key nur in gitignorierten Dateien)
- RLS auf allen neuen Tabellen

---

## Phase 1: Registrierungsflow

### 1.1 Öffentliche Registrierungsseite

**Datei:** `ehealth Alliance/registrieren.html`

**Formularfelder:**
- Vorname, Nachname (text, Pflicht)
- E-Mail (email, Pflicht, Uniqueness-Check gegen `registrierungen.email`)
- Firma / Praxis (text, Pflicht)
- Berufsgruppe (Dropdown, Pflicht — lädt aus `berufsgruppen` Tabelle, `aktiv = true`)
- Produkt (Dropdown, Pflicht — lädt aus `products` wo `published = true`, zeigt `produkt`-Feld)
- Anliegen (textarea, Pflicht, max. 500 Zeichen mit Zähler)

**Submit-Verhalten:**
1. Insert in `registrierungen` (status = 'ausstehend')
2. E-Mail an Endkunden: höfliche Bestätigung ("Wir haben Ihre Registrierungsanfrage erhalten und prüfen diese in Kürze.")
3. E-Mail an Admin (marco.alexandre@healoscope.de): "Neue Registrierungsanfrage von [Name], [Firma]"
4. Erfolgsseite / Meldung: "Vielen Dank! Sie erhalten eine E-Mail sobald Ihr Zugang freigeschaltet wurde."

**Verlinkung:** Nav-Link "Registrieren" in `ehealth Alliance/index.html` und ggf. weiteren Alliance-Seiten ergänzen.

### 1.2 Datenbanktabelle `registrierungen`

```sql
CREATE TABLE IF NOT EXISTS public.registrierungen (
  id               uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  vorname          text NOT NULL,
  nachname         text NOT NULL,
  email            text NOT NULL,
  firma            text NOT NULL,
  berufsgruppe_id  uuid REFERENCES public.berufsgruppen(id) ON DELETE SET NULL,
  produkt_id       uuid REFERENCES public.products(id) ON DELETE SET NULL,
  anliegen         text,
  status           text NOT NULL DEFAULT 'ausstehend',
  -- ausstehend | genehmigt | abgelehnt
  ablehnungsgrund  text,
  erstellt_am      timestamptz DEFAULT now()
);

-- RLS: jeder kann inserieren (öffentliches Formular), nur Admins lesen/updaten
ALTER TABLE public.registrierungen ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Öffentlich: registrieren"
  ON public.registrierungen FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Admin: alle Registrierungen verwalten"
  ON public.registrierungen FOR ALL
  USING (EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin'));
```

### 1.3 Anfragecenter – Registrierungen-Tab

**Datei:** `admin/anfragen.html` (erweitert)

- Zweiter Tab "Registrierungen" neben bestehendem "Anfragen"-Tab
- Tab-Badge zeigt Anzahl ausstehender Registrierungen
- Karten-Design identisch zu Anfragen-Karten:
  - Kopf: Name, Firma, E-Mail, Datum
  - Body: Berufsgruppe, Produkt, Anliegen
  - Status-Badge: "⏳ Ausstehend" / "✓ Genehmigt" / "✗ Abgelehnt"
  - Buttons (nur bei ausstehend): **Genehmigen** (grün), **Ablehnen** (rot)
- Genehmigte/abgelehnte Einträge bleiben als Protokoll sichtbar (ausgegraut)

### 1.4 Genehmigungs-Edge-Function

**Datei:** `supabase/functions/admin-approve-registration/index.ts`

**Input:** `{ registrierungId: string }`

**Ablauf:**
1. Caller-Check: nur Admins dürfen aufrufen
2. Registrierung laden (`id`, `email`, `vorname`, `nachname`, `firma`, `berufsgruppe_id`, `produkt_id`)
3. Auth-Account anlegen: `adminClient.auth.admin.createUser({ email, email_confirm: true })`
4. `user_profiles` INSERT: `{ email, vorname, nachname, firma, rolle: 'kunde', password_set: false }`
5. `user_roles` INSERT: `{ user_id: authUser.id, role: 'kunde' }`
6. `kunden` INSERT: `{ name: vorname + ' ' + nachname, firma, email, partner_id: null }` — kunden_id zurückgeben
7. Magic-Link senden: `adminClient.auth.admin.generateLink({ type: 'magiclink', email })` → URL an `send-email.php` übergeben; E-Mail-Text: "Ihr Zugang wurde freigeschaltet. Klicken Sie hier um Ihr Passwort zu setzen: [Link]"
8. `registrierungen` UPDATE: `{ status: 'genehmigt' }`
9. Antwort: `{ success: true, kundenId, userId }`

### 1.5 Ablehnungs-Flow (Frontend)

Kein Edge Function nötig — direkt vom Frontend:
1. Modal mit optionalem Ablehnungsgrund-Textfeld
2. `registrierungen` UPDATE: `{ status: 'abgelehnt', ablehnungsgrund }`
3. E-Mail an Endkunden über `send-email.php`: "Leider konnten wir Ihre Registrierungsanfrage nicht genehmigen. [Grund falls angegeben]"

---

## Phase 2: Kundenportal

### 2.1 Navigation (Rolle: Kunde)

Alle bestehenden Admin-Seiten blenden mit `setupNavRole()` folgende Einträge aus:
- Admin-Gruppe (Nutzerverwaltung, Registrierungen etc.)
- Produkte
- Partner / Kunden-Verwaltung
- Anfragecenter

Sichtbar für Kunden:
- Dashboard
- **Support** → `tickets.html` (neu)
- Shop
- Events
- Community

### 2.2 Neue Seite `admin/tickets.html` (Kunden-Ansicht)

**Für Endkunden:**
- Liste eigener Tickets (gefiltert nach `user_id = auth.uid()`)
- Spalten: Titel, Produkt, Status (Badge), Erstellt am
- Button "Neues Ticket" → Inline-Formular oder Modal:
  - Titel (text, Pflicht)
  - Beschreibung (textarea, Pflicht)
  - Produkt (Dropdown aus `products published=true`, Vorausfüllung aus `user_profiles.registrierungs_produkt` — gespeichert bei Genehmigung)
- Nach Erstellung: E-Mail an Endkunden ("Ihr Support-Ticket wurde erfolgreich erstellt. Wir melden uns bei Ihnen.")
- Interne Notizen NICHT sichtbar
- Status nur lesbar (kein Ändern)

**Für Partner (selbe Seite, andere Ansicht):**
- Liste aller ihnen zugewiesenen Tickets
- Kann Status ändern: In Bearbeitung / Gelöst
- Kann interne Notiz hinterlegen
- Kann Priorität setzen (niedrig/mittel/hoch/kritisch)
- Kundendaten sichtbar (Name, Firma, E-Mail)

**Für Admins:** Weiterleitung zu `support.html`

### 2.3 Datenbanktabelle `support_tickets`

```sql
CREATE TABLE IF NOT EXISTS public.support_tickets (
  id                   uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  titel                text NOT NULL,
  beschreibung         text NOT NULL,
  kunden_id            uuid REFERENCES public.kunden(id) ON DELETE SET NULL,
  user_id              uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  produkt_id           uuid REFERENCES public.products(id) ON DELETE SET NULL,
  prioritaet           text,
  -- NULL (neu/unbewertet) | niedrig | mittel | hoch | kritisch
  status               text NOT NULL DEFAULT 'offen',
  -- offen | in_bearbeitung | gelöst | geschlossen
  assigned_partner_id  uuid REFERENCES public.user_profiles(id) ON DELETE SET NULL,
  notiz_intern         text,
  created_at           timestamptz DEFAULT now(),
  updated_at           timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_tickets_user_id    ON support_tickets(user_id);
CREATE INDEX IF NOT EXISTS idx_tickets_kunden_id  ON support_tickets(kunden_id);
CREATE INDEX IF NOT EXISTS idx_tickets_partner_id ON support_tickets(assigned_partner_id);
CREATE INDEX IF NOT EXISTS idx_tickets_status     ON support_tickets(status);

-- RLS
ALTER TABLE public.support_tickets ENABLE ROW LEVEL SECURITY;

-- Endkunde sieht nur eigene Tickets
CREATE POLICY "Kunde: eigene Tickets lesen"
  ON support_tickets FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Endkunde kann neue Tickets anlegen
CREATE POLICY "Kunde: Ticket erstellen"
  ON support_tickets FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Partner sieht zugewiesene Tickets
CREATE POLICY "Partner: zugewiesene Tickets"
  ON support_tickets FOR ALL
  TO authenticated
  USING (
    assigned_partner_id IN (
      SELECT id FROM user_profiles WHERE user_id = auth.uid()
    )
    OR EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
  );

-- Admin: alles
CREATE POLICY "Admin: alle Tickets"
  ON support_tickets FOR ALL
  USING (EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin'));
```

---

## Phase 3: Supportverwaltung (Admin)

### 3.1 Neue Seite `admin/support.html`

**Admin-Ansicht:**

**Filterleiste:**
- Suchfeld (Titel, Kundenname, Firma)
- Status-Filter (Alle / Offen / In Bearbeitung / Gelöst / Geschlossen)
- Prioritäts-Filter
- Partner-Filter (Dropdown: Alle / Nicht zugewiesen / [Partner-Namen])

**Tabelle:**
- Spalten: #, Titel, Kunde (Firma), Produkt, Status, Priorität, Partner, Erstellt am, Aktionen
- Zeilen-Klick öffnet Detail-Panel (Master-Detail analog zu kunden.html)

**Detail-Panel (Admin):**
- Ticket-Info: Titel, Beschreibung, Kunde-Link (→ kunden.html), Produkt
- Priorität setzen: Dropdown (Leer/Niedrig/Mittel/Hoch/Kritisch)
- Partner zuweisen: Dropdown aller Partner-User-Profiles; bei Änderung → E-Mail an Partner
- Status ändern: Dropdown
- Interne Notiz: Textarea (speichert in `notiz_intern`)
- Kundendaten (Name, Firma, E-Mail, Telefon)

**Bei Partner-Zuweisung:** E-Mail an Partner: "Ein Support-Ticket wurde Ihnen zugewiesen: [Titel], Kunde: [Name], [Firma]"
**Bei Statusänderung:** E-Mail an Endkunden (außer Admin-interne Statuswechsel wie geschlossen): "Der Status Ihres Tickets '[Titel]' wurde auf [Status] gesetzt."

### 3.2 Nav-Update

- Alle Admin-Seiten (13 Seiten): Nav-Eintrag "Support" hinzufügen
  - Admins: Link → `support.html`
  - Partner & Kunden: Link → `tickets.html`
  - Nav-Eintrag in `setupNavRole()` rollenabhängig setzen

---

## E-Mail-Übersicht

| Auslöser | Empfänger | Inhalt |
|---|---|---|
| Registrierung eingereicht | Endkunde | Bestätigung, Prüfung läuft |
| Registrierung eingereicht | Admin | Neue Registrierung: Name, Firma |
| Registrierung genehmigt | Endkunde | Freischaltung + Magic-Link zum Passwort setzen |
| Registrierung abgelehnt | Endkunde | Ablehnung + optionaler Grund |
| Ticket erstellt | Endkunde | Höfliche Bestätigung, Ticketnummer |
| Ticket Partner zugewiesen | Partner | Titel, Kundenname, Firma |
| Ticket-Status geändert | Endkunde | Neuer Status für Ticket [Titel] |

Alle E-Mails über `send-email.php` + Resend; API-Key ausschließlich in gitignorierten Dateien, nie in HTML-Dateien.

---

## Neue Dateien

| Datei | Typ | Zweck |
|---|---|---|
| `ehealth Alliance/registrieren.html` | Öffentlich | Registrierungsformular |
| `admin/tickets.html` | Portal | Ticketliste für Kunden + Partner |
| `admin/support.html` | Portal | Ticketverwaltung für Admin |
| `supabase/functions/admin-approve-registration/index.ts` | Edge Function | Genehmigung: Auth + Profile + Kunden |
| `admin/sql/migration_registrierungen_tickets.sql` | SQL | Neue Tabellen + RLS |

## Geänderte Dateien

| Datei | Änderung |
|---|---|
| `admin/anfragen.html` | Tab "Registrierungen" + Approve/Reject-Logik |
| `admin/dashboard.html` | Kunde-Nav: Support-Link |
| alle 13 Admin-Seiten | Nav-Eintrag "Support" |
| `ehealth Alliance/index.html` | Link zur Registrierungsseite |

---

## Implementierungsreihenfolge

1. SQL-Migration (Tabellen + RLS)
2. Registrierungsseite + E-Mails
3. Anfragecenter: Registrierungen-Tab + Ablehnen-Flow
4. Edge Function: admin-approve-registration
5. Nav-Update alle Seiten (Support-Link)
6. `admin/tickets.html` (Kunden- + Partner-Ansicht)
7. `admin/support.html` (Admin-Ansicht)
8. Dashboard: Kunde-Nav bereinigen

## Global Constraints

- Supabase-Projekt: `focysklymhmcfwgxdtuk.supabase.co`
- Supabase Anon-Key darf in HTML stehen; Resend API-Key (`re_Ag1Zo4P8_...`) NIEMALS in HTML oder git-getrackten Dateien
- Kein Build-Step; alle Libraries via CDN (cdnjs.cloudflare.com oder cdn.jsdelivr.net)
- Service-Role-Key nur in Edge Functions (auto-injected), nie in Frontend-Code
- RLS auf allen neuen Tabellen; Edge Functions prüfen Caller-Rolle via JWT
- Bestehende Patterns übernehmen: `setupNavRole()`, `_setHeaderUser()`, `showMsg()`, `esc()`
