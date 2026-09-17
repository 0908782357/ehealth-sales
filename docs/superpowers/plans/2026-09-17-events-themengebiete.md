# Events & Themengebiete — Implementierungsplan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Zentrales Themengebiet-System als DB-Tabelle + vollständiges Events-System (Admin-Portal für Partner + öffentliche Alliance-Site mit Anmeldungsflow)

**Architecture:** Supabase als gemeinsames Backend; Admin-Portal liest/schreibt Events (RLS nach Rolle); Alliance-Site liest via Anon-Key nur öffentliche Events; Anmeldung erfordert Portal-Login. Keine Build-Pipeline — reines HTML/JS/CSS.

**Tech Stack:** Static HTML, Vanilla JS, Supabase JS SDK v2 (CDN), CSS Custom Properties. Kein Build-Step.

**Spec:** `docs/superpowers/specs/2026-09-17-events-themengebiete-design.md`

## Global Constraints

- Supabase URL: `https://focysklymhmcfwgxdtuk.supabase.co`
- Supabase Anon Key: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZvY3lza2x5bWhtY2Z3Z3hkdHVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc1NTY1NTUsImV4cCI6MjEwMzEzMjU1NX0.VxgHwrnFUd-_7Q3pZx0L-7xY5roBZ__rUnLc5W7lOgg`
- Supabase JS SDK: `<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>`
- API-Key darf NIEMALS in git-getrackten Dateien hardcoded stehen — Anon-Key ist öffentlich und darf in HTML, API-Key (service role) niemals
- Alle Admin-Seiten: `setupNavRole()` Pattern aus bestehenden Seiten übernehmen; Rolle aus `user_roles` Tabelle
- Slug-Generierung: lowercase, ä→ae, ö→oe, ü→ue, ß→ss, Leerzeichen→Bindestrich, Sonderzeichen entfernen
- Alliance-Site Design-System: CSS aus `ehealth Alliance/assets/css/styles.css`, Fonts Inter + Sora via Google Fonts
- Alliance-Site Supabase-Init: identisch (gleicher Anon-Key), kein Auth-Check nötig für public reads
- Alle neuen Admin-Seiten: `esc()` Hilfsfunktion für HTML-Escaping immer definieren
- Bestehende Seiten nicht umstrukturieren — nur Nav-Einträge ergänzen

---

## Dateiübersicht

| Datei | Aktion | Verantwortlichkeit |
|---|---|---|
| `admin/sql/migration_events.sql` | Erstellen | 4 Tabellen + Indizes + RLS |
| `admin/themengebiete.html` | Erstellen | Admin-CRUD für Themengebiete |
| `admin/events.html` | Erstellen | Event-Management (Admin + Partner) + Mitglieder-Anmeldung |
| `admin/index.html` | Modifizieren | `?event=<id>` nach Login weiterleiten statt immer `dashboard.html` |
| `admin/*.html` (alle 15) | Modifizieren | Nav-Einträge für Themengebiete + Events ergänzen |
| `ehealth Alliance/events.html` | Erstellen | Öffentliche Events-Seite |
| `ehealth Alliance/index.html` | Modifizieren | Nav-Eintrag + optionaler 3-Card-Preview-Block |
| `ehealth Alliance/partner.html` | Modifizieren | Nav-Eintrag Events |
| `ehealth Alliance/datenschutz.html` | Modifizieren | Nav-Eintrag Events |
| `ehealth Alliance/impressum.html` | Modifizieren | Nav-Eintrag Events |

---

## Task 1: SQL-Migration

**Files:**
- Create: `admin/sql/migration_events.sql`

**Interfaces:**
- Produces: Tabellen `themengebiete`, `events`, `event_themen`, `event_anmeldungen` in Supabase

- [ ] **Step 1: Migration-Datei erstellen**

Erstelle `admin/sql/migration_events.sql` mit folgendem Inhalt:

```sql
-- Migration: Themengebiete + Events
-- Ausführen im Supabase SQL Editor

-- ─── Themengebiete ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS themengebiete (
  id           uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name         text NOT NULL,
  slug         text NOT NULL UNIQUE,
  farbe        text NOT NULL DEFAULT '#1C74B8',
  beschreibung text,
  sortierung   int NOT NULL DEFAULT 0,
  aktiv        boolean NOT NULL DEFAULT true,
  created_at   timestamptz DEFAULT now()
);

-- Starter-Daten (später über Admin-UI verwaltbar)
INSERT INTO themengebiete (name, slug, farbe, sortierung) VALUES
  ('Telematikinfrastruktur', 'ti',         '#0F4C81', 10),
  ('ePA & Digitale Akten',  'epa',         '#12A594', 20),
  ('KI im Gesundheitswesen','ki',          '#7C3AED', 30),
  ('Cybersecurity',         'security',    '#DC2626', 40),
  ('Abrechnung & Finanzierung', 'abrechnung', '#D97706', 50),
  ('IT-Infrastruktur',      'it',          '#475569', 60),
  ('Telemedizin',           'telemedizin', '#0891B2', 70),
  ('Regulatory & Zulassung','regulatory',  '#16A34A', 80)
ON CONFLICT (slug) DO NOTHING;

-- ─── Events ───────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS events (
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
  teilnahme_link   text,
  partner_id       uuid REFERENCES partners(id) ON DELETE SET NULL,
  status           text NOT NULL DEFAULT 'entwurf',
  -- entwurf | geplant | abgeschlossen | abgesagt
  oeffentlich      boolean NOT NULL DEFAULT false,
  created_at       timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_events_datum       ON events(datum);
CREATE INDEX IF NOT EXISTS idx_events_partner_id  ON events(partner_id);
CREATE INDEX IF NOT EXISTS idx_events_status      ON events(status);
CREATE INDEX IF NOT EXISTS idx_events_oeffentlich ON events(oeffentlich);

-- ─── Event-Themen (Junction) ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS event_themen (
  event_id  uuid NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  thema_id  uuid NOT NULL REFERENCES themengebiete(id) ON DELETE CASCADE,
  PRIMARY KEY (event_id, thema_id)
);

-- ─── Event-Anmeldungen ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS event_anmeldungen (
  id            uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  event_id      uuid NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  user_id       uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  status        text NOT NULL DEFAULT 'angemeldet',
  -- angemeldet | storniert | warteliste
  angemeldet_am timestamptz DEFAULT now(),
  UNIQUE(event_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_event_anm_event_id ON event_anmeldungen(event_id);
CREATE INDEX IF NOT EXISTS idx_event_anm_user_id  ON event_anmeldungen(user_id);

-- ─── RLS ──────────────────────────────────────────────────────────────────────
ALTER TABLE themengebiete    ENABLE ROW LEVEL SECURITY;
ALTER TABLE events           ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_themen     ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_anmeldungen ENABLE ROW LEVEL SECURITY;

-- themengebiete: jeder liest, nur Admins schreiben
CREATE POLICY "themengebiete_read_all"
  ON themengebiete FOR SELECT USING (true);

CREATE POLICY "themengebiete_admin_write"
  ON themengebiete FOR ALL
  USING (
    EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
  );

-- events: anon liest nur öffentliche+geplante+zukünftige
CREATE POLICY "events_public_read"
  ON events FOR SELECT
  USING (oeffentlich = true AND status = 'geplant' AND datum >= CURRENT_DATE);

-- events: eingeloggte User lesen alle öffentlichen (auch vergangene für Meine Anmeldungen)
CREATE POLICY "events_auth_read"
  ON events FOR SELECT
  TO authenticated
  USING (true);

-- events: Partner verwalten eigene
CREATE POLICY "events_partner_write"
  ON events FOR ALL
  TO authenticated
  USING (
    partner_id IN (
      SELECT id FROM partners WHERE user_id = auth.uid()
    )
    OR EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
  );

-- event_themen: folgt events-Rechten
CREATE POLICY "event_themen_read"
  ON event_themen FOR SELECT USING (true);

CREATE POLICY "event_themen_write"
  ON event_themen FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM events e
      WHERE e.id = event_themen.event_id
      AND (
        e.partner_id IN (SELECT id FROM partners WHERE user_id = auth.uid())
        OR EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
      )
    )
  );

-- event_anmeldungen: User sieht eigene
CREATE POLICY "event_anm_user_read"
  ON event_anmeldungen FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM events e
      WHERE e.id = event_anmeldungen.event_id
      AND e.partner_id IN (SELECT id FROM partners WHERE user_id = auth.uid())
    )
    OR EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "event_anm_user_write"
  ON event_anmeldungen FOR ALL
  TO authenticated
  USING (user_id = auth.uid());
```

- [ ] **Step 2: Migration in Supabase ausführen**

SQL-Editor in Supabase Dashboard öffnen → Inhalt der Datei einfügen → ausführen. Überprüfen dass 4 Tabellen angelegt wurden.

- [ ] **Step 3: Commit**

```bash
git add admin/sql/migration_events.sql
git commit -m "feat: add events + themengebiete SQL migration"
```

---

## Task 2: `admin/themengebiete.html`

**Files:**
- Create: `admin/themengebiete.html`

**Interfaces:**
- Consumes: Tabelle `themengebiete` (Task 1)
- Produces: `allThemengebiete` Array (für andere Admin-Seiten als Vorlage)

- [ ] **Step 1: HTML-Gerüst erstellen**

Kopiere das Grundgerüst von `admin/berufsgruppen.html` (Header, Nav-Sidebar, CSS-Variablen, Supabase-Init, Auth-Check). Passe Titel auf "Themengebiete" an.

Nav-Sidebar: Füge unter "Administration" einen neuen Sub-Link hinzu:
```html
<a class="nav-link nav-sub active" href="themengebiete.html">Themengebiete</a>
```
(Auf allen anderen Seiten ist `active` nicht gesetzt.)

- [ ] **Step 2: Tabellen-HTML schreiben**

```html
<div class="page-header">
  <div>
    <h1>Themengebiete</h1>
    <p class="page-sub">Zentrale Themen-Tags für Produkte, Events und Wissensdatenbank.</p>
  </div>
  <button class="btn btn-primary" onclick="openModal()">+ Themengebiet anlegen</button>
</div>

<div class="table-wrap">
  <table class="data-table">
    <thead>
      <tr>
        <th style="width:32px;"></th>
        <th>Name</th>
        <th>Slug</th>
        <th style="width:80px">Sort.</th>
        <th style="width:80px;text-align:center;">Aktiv</th>
        <th style="width:110px">Aktionen</th>
      </tr>
    </thead>
    <tbody id="tg-tbody">
      <tr><td colspan="6" class="empty">Lade Themengebiete…</td></tr>
    </tbody>
  </table>
</div>
```

- [ ] **Step 3: Modal-HTML schreiben**

```html
<div class="modal-bg" id="modal-bg">
  <div class="modal">
    <h2 id="modal-title">Themengebiet anlegen</h2>
    <div class="form-grid">
      <div class="form-group">
        <label>Name *</label>
        <input type="text" id="f-name" placeholder="z.B. Telematikinfrastruktur"
               oninput="autoSlug()">
      </div>
      <div class="form-group">
        <label>Slug * <small style="font-weight:400;color:var(--gray-400)">(URL-safe, eindeutig)</small></label>
        <input type="text" id="f-slug" placeholder="z.B. ti">
      </div>
      <div class="form-group">
        <label>Farbe (Badge)</label>
        <div style="display:flex;gap:8px;align-items:center;">
          <input type="color" id="f-farbe" value="#1C74B8"
                 style="width:44px;height:36px;border:1.5px solid var(--gray-200);border-radius:8px;cursor:pointer;padding:2px;">
          <input type="text" id="f-farbe-hex" value="#1C74B8"
                 style="flex:1;" placeholder="#1C74B8"
                 oninput="syncColorFromHex()">
        </div>
      </div>
      <div class="form-group">
        <label>Sortierung</label>
        <input type="number" id="f-sort" value="0" min="0" step="10">
      </div>
      <div class="form-group form-full">
        <label>Beschreibung</label>
        <textarea id="f-beschreibung" placeholder="Optionaler Tooltip-Text…"
                  style="min-height:70px;"></textarea>
      </div>
    </div>
    <div class="msg" id="modal-msg"></div>
    <div class="modal-actions">
      <button class="btn btn-secondary" onclick="closeModal()">Abbrechen</button>
      <button class="btn btn-primary" onclick="saveThema()">Speichern</button>
    </div>
  </div>
</div>
```

- [ ] **Step 4: JavaScript schreiben**

```javascript
const SUPA_URL = 'https://focysklymhmcfwgxdtuk.supabase.co';
const SUPA_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZvY3lza2x5bWhtY2Z3Z3hkdHVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc1NTY1NTUsImV4cCI6MjEwMzEzMjU1NX0.VxgHwrnFUd-_7Q3pZx0L-7xY5roBZ__rUnLc5W7lOgg';
const sb = supabase.createClient(SUPA_URL, SUPA_KEY);

function esc(s) { return String(s ?? '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }

function makeSlug(s) {
  return s.toLowerCase()
    .replace(/ä/g,'ae').replace(/ö/g,'oe').replace(/ü/g,'ue').replace(/ß/g,'ss')
    .replace(/[^a-z0-9]+/g,'-').replace(/^-+|-+$/g,'');
}

function autoSlug() {
  const slugEl = document.getElementById('f-slug');
  if (!slugEl.dataset.manual) slugEl.value = makeSlug(document.getElementById('f-name').value);
}

function syncColorFromHex() {
  const hex = document.getElementById('f-farbe-hex').value.trim();
  if (/^#[0-9a-fA-F]{6}$/.test(hex)) document.getElementById('f-farbe').value = hex;
}

let allThemen = [];
let editId = null;

async function init() {
  const { data: { session } } = await sb.auth.getSession();
  if (!session) { window.location.href = 'index.html'; return; }
  const { data: ur } = await sb.from('user_roles').select('role').eq('user_id', session.user.id).maybeSingle();
  if (ur?.role !== 'admin') { window.location.href = 'dashboard.html'; return; }
  await loadThemen();
}

async function loadThemen() {
  const { data } = await sb.from('themengebiete').select('*').order('sortierung').order('name');
  allThemen = data || [];
  renderTable();
}

function renderTable() {
  const tbody = document.getElementById('tg-tbody');
  if (!allThemen.length) {
    tbody.innerHTML = '<tr><td colspan="6" class="empty">Keine Themengebiete vorhanden.</td></tr>';
    return;
  }
  tbody.innerHTML = allThemen.map(t => `
    <tr>
      <td><span style="display:inline-block;width:18px;height:18px;border-radius:50%;background:${esc(t.farbe)};"></span></td>
      <td><strong>${esc(t.name)}</strong>${t.beschreibung ? `<br><small style="color:var(--gray-400)">${esc(t.beschreibung)}</small>` : ''}</td>
      <td><code style="font-size:0.78rem;color:var(--gray-500);">${esc(t.slug)}</code></td>
      <td>${t.sortierung}</td>
      <td style="text-align:center;">
        <input type="checkbox" ${t.aktiv ? 'checked' : ''} onchange="toggleAktiv('${t.id}', this.checked)"
               style="width:16px;height:16px;accent-color:var(--navy);cursor:pointer;">
      </td>
      <td>
        <button class="btn btn-sm btn-secondary" onclick="openEdit('${t.id}')">Bearbeiten</button>
        <button class="btn btn-sm" style="color:#ef4444;background:none;border:1.5px solid #fca5a5;" onclick="deleteThema('${t.id}')">Löschen</button>
      </td>
    </tr>`).join('');
}

function openModal() {
  editId = null;
  document.getElementById('modal-title').textContent = 'Themengebiet anlegen';
  document.getElementById('f-name').value = '';
  document.getElementById('f-slug').value = '';
  delete document.getElementById('f-slug').dataset.manual;
  document.getElementById('f-farbe').value = '#1C74B8';
  document.getElementById('f-farbe-hex').value = '#1C74B8';
  document.getElementById('f-sort').value = (Math.max(0, ...allThemen.map(t => t.sortierung)) + 10);
  document.getElementById('f-beschreibung').value = '';
  document.getElementById('modal-msg').className = 'msg';
  document.getElementById('modal-bg').classList.add('open');
}

function openEdit(id) {
  const t = allThemen.find(x => x.id === id);
  if (!t) return;
  editId = id;
  document.getElementById('modal-title').textContent = 'Themengebiet bearbeiten';
  document.getElementById('f-name').value = t.name;
  const slugEl = document.getElementById('f-slug');
  slugEl.value = t.slug;
  slugEl.dataset.manual = '1';
  document.getElementById('f-farbe').value = t.farbe;
  document.getElementById('f-farbe-hex').value = t.farbe;
  document.getElementById('f-sort').value = t.sortierung;
  document.getElementById('f-beschreibung').value = t.beschreibung || '';
  document.getElementById('modal-msg').className = 'msg';
  document.getElementById('modal-bg').classList.add('open');
}

function closeModal() { document.getElementById('modal-bg').classList.remove('open'); }

document.getElementById('f-slug').addEventListener('input', () => {
  document.getElementById('f-slug').dataset.manual = '1';
});

document.getElementById('f-farbe').addEventListener('input', e => {
  document.getElementById('f-farbe-hex').value = e.target.value;
});

async function saveThema() {
  const msg = document.getElementById('modal-msg');
  const name = document.getElementById('f-name').value.trim();
  const slug = document.getElementById('f-slug').value.trim();
  const farbe = document.getElementById('f-farbe-hex').value.trim() || document.getElementById('f-farbe').value;
  const sortierung = parseInt(document.getElementById('f-sort').value, 10) || 0;
  const beschreibung = document.getElementById('f-beschreibung').value.trim() || null;

  if (!name) { msg.textContent = 'Name ist Pflichtfeld.'; msg.className = 'msg error'; return; }
  if (!slug) { msg.textContent = 'Slug ist Pflichtfeld.'; msg.className = 'msg error'; return; }

  const payload = { name, slug, farbe, sortierung, beschreibung };
  let error;
  if (editId) {
    ({ error } = await sb.from('themengebiete').update(payload).eq('id', editId));
  } else {
    ({ error } = await sb.from('themengebiete').insert(payload));
  }

  if (error) { msg.textContent = error.message; msg.className = 'msg error'; return; }
  closeModal();
  await loadThemen();
}

async function toggleAktiv(id, aktiv) {
  await sb.from('themengebiete').update({ aktiv }).eq('id', id);
}

async function deleteThema(id) {
  const t = allThemen.find(x => x.id === id);
  if (!confirm(`Themengebiet "${t?.name}" wirklich löschen? Verknüpfungen mit Events werden ebenfalls entfernt.`)) return;
  const { error } = await sb.from('themengebiete').delete().eq('id', id);
  if (error) { alert(error.message); return; }
  await loadThemen();
}

init();
```

- [ ] **Step 5: In Browser öffnen und prüfen**

  - Tabelle lädt Starter-Daten aus DB
  - Neues Thema anlegen → erscheint in Tabelle
  - Slug wird automatisch generiert, kann manuell überschrieben werden
  - Farb-Picker und Hex-Input synchronisieren sich
  - Aktiv-Toggle funktioniert ohne Reload
  - Löschen zeigt Bestätigung

- [ ] **Step 6: Commit**

```bash
git add admin/themengebiete.html
git commit -m "feat: add themengebiete admin page (CRUD)"
```

---

## Task 3: Nav-Update in allen Admin-Seiten

**Files:**
- Modify: `admin/dashboard.html`, `admin/users.html`, `admin/products.html`, `admin/partners.html`, `admin/finder-config.html`, `admin/shop.html`, `admin/orders.html`, `admin/knowledge.html`, `admin/profile.html`, `admin/anfragen.html`, `admin/kunden.html`, `admin/loesung.html`, `admin/rechner.html`

**Interfaces:**
- Consumes: nichts
- Produces: "Themengebiete" + "Events" Links in allen Admin-Seiten sichtbar

- [ ] **Step 1: In jeder Admin-Seite Nav-Einträge ergänzen**

**Schritt A — Themengebiete:** In jeder Datei den `<a class="nav-link nav-sub" href="berufsgruppen.html">Berufsgruppen</a>` Eintrag suchen und direkt darunter einfügen:

```html
<a class="nav-link nav-sub" href="themengebiete.html">Themengebiete</a>
```

**Schritt B — Events:** Nach dem `<a class="nav-link" href="kunden.html">` Block (oder einem anderen sinnvollen Platz in der Hauptnavigation, nach Kunden und vor Shop) einfügen:

```html
<a class="nav-link" href="events.html">
  <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.8">
    <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
    <line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/>
    <line x1="3" y1="10" x2="21" y2="10"/>
  </svg>
  Events
</a>
```

Die aktive Seite erhält zusätzlich die Klasse `active` auf dem jeweiligen Link — für `themengebiete.html` ist das bereits in Task 2 gemacht, für `events.html` wird es in Task 4 gesetzt.

- [ ] **Step 2: Prüfen**

Zwei Admin-Seiten (z.B. `dashboard.html` und `anfragen.html`) im Browser öffnen und sicherstellen dass beide neuen Links sichtbar sind und auf die richtigen Seiten zeigen.

- [ ] **Step 3: Commit**

```bash
git add admin/dashboard.html admin/users.html admin/products.html admin/partners.html \
        admin/finder-config.html admin/shop.html admin/orders.html admin/knowledge.html \
        admin/profile.html admin/anfragen.html admin/kunden.html admin/loesung.html \
        admin/rechner.html
git commit -m "feat: add Themengebiete + Events nav links to all admin pages"
```

---

## Task 4: `admin/events.html`

**Files:**
- Create: `admin/events.html`

**Interfaces:**
- Consumes: `themengebiete`, `events`, `event_themen`, `event_anmeldungen`, `partners`, `user_roles` (Tasks 1–3)
- Produces: vollständige Event-Verwaltung; `?event=<id>` URL-Parameter-Handling für post-login Redirect (Task 5)

- [ ] **Step 1: Grundgerüst + CSS schreiben**

Kopiere HTML-Gerüst (Head, Nav-Sidebar, Auth-Check) aus einer bestehenden Admin-Seite. Setze `active` nur auf den Events-Nav-Link. Ergänze folgende CSS-Klassen:

```css
.status-badge { display:inline-block; padding:2px 10px; border-radius:20px; font-size:0.72rem; font-weight:700; text-transform:uppercase; letter-spacing:.04em; }
.status-entwurf    { background:#f3f4f6; color:#6b7280; }
.status-geplant    { background:#dcfce7; color:#166534; }
.status-abgeschlossen { background:#e0f2fe; color:#075985; }
.status-abgesagt   { background:#fee2e2; color:#991b1b; }

.format-badge { display:inline-block; padding:2px 8px; border-radius:6px; font-size:0.72rem; font-weight:600; background:var(--gray-100); color:var(--gray-600); }

.thema-chip { display:inline-block; padding:2px 9px; border-radius:20px; font-size:0.72rem; font-weight:600; color:#fff; margin:1px 2px; }

.event-tabs { display:flex; gap:4px; margin-bottom:20px; border-bottom:2px solid var(--gray-200); padding-bottom:0; }
.event-tab { padding:8px 16px; border:none; background:none; cursor:pointer; font-size:0.87rem; font-weight:600; color:var(--gray-400); border-bottom:2px solid transparent; margin-bottom:-2px; }
.event-tab.active { color:var(--navy); border-bottom-color:var(--navy); }

.teilnehmer-row { background:var(--gray-50); }
.teilnehmer-table { width:100%; border-collapse:collapse; font-size:0.8rem; }
.teilnehmer-table td { padding:6px 12px; border-top:1px solid var(--gray-100); }
```

- [ ] **Step 2: Haupt-HTML-Struktur schreiben**

```html
<div class="page-header">
  <div><h1>Events</h1></div>
  <button class="btn btn-primary" id="btn-new-event" onclick="openEventModal()">+ Neues Event</button>
</div>

<div class="event-tabs">
  <button class="event-tab active" onclick="switchTab(0)" id="tab-0">Alle Events</button>
  <button class="event-tab" onclick="switchTab(1)" id="tab-1">Meine Anmeldungen</button>
</div>

<!-- Tab 0: Event-Liste -->
<div id="tab-content-0">
  <div style="display:flex;gap:10px;margin-bottom:16px;flex-wrap:wrap;">
    <select id="filter-status" onchange="renderEventList()" style="padding:7px 11px;border:1.5px solid var(--gray-200);border-radius:8px;font-size:0.82rem;font-family:inherit;">
      <option value="">Alle Status</option>
      <option value="entwurf">Entwurf</option>
      <option value="geplant">Geplant</option>
      <option value="abgeschlossen">Abgeschlossen</option>
      <option value="abgesagt">Abgesagt</option>
    </select>
    <select id="filter-thema" onchange="renderEventList()" style="padding:7px 11px;border:1.5px solid var(--gray-200);border-radius:8px;font-size:0.82rem;font-family:inherit;">
      <option value="">Alle Themen</option>
    </select>
  </div>
  <div class="table-wrap">
    <table class="data-table" id="events-table">
      <thead><tr>
        <th>Datum</th><th>Titel</th><th>Format</th><th>Themen</th>
        <th id="th-partner" style="display:none;">Partner</th>
        <th>Teilnehmer</th><th>Status</th><th>Öffentlich</th><th style="width:110px;">Aktionen</th>
      </tr></thead>
      <tbody id="events-tbody">
        <tr><td colspan="9" class="empty">Lade Events…</td></tr>
      </tbody>
    </table>
  </div>
</div>

<!-- Tab 1: Meine Anmeldungen -->
<div id="tab-content-1" style="display:none;">
  <div id="meine-anmeldungen-list"><p class="empty">Lade Anmeldungen…</p></div>
</div>
```

- [ ] **Step 3: Event-Modal HTML schreiben**

```html
<div class="modal-bg" id="event-modal-bg">
  <div class="modal" style="max-width:640px;">
    <h2 id="event-modal-title">Neues Event</h2>

    <!-- Modal-Tabs -->
    <div style="display:flex;gap:4px;margin-bottom:20px;border-bottom:1.5px solid var(--gray-200);padding-bottom:0;">
      <button type="button" class="event-tab active" id="mtab-0" onclick="switchModalTab(0)">Grunddaten</button>
      <button type="button" class="event-tab" id="mtab-1" onclick="switchModalTab(1)">Termin & Format</button>
      <button type="button" class="event-tab" id="mtab-2" onclick="switchModalTab(2)">Themen & Sichtbarkeit</button>
    </div>

    <!-- Tab 0: Grunddaten -->
    <div id="mtab-content-0" class="form-grid">
      <div class="form-group form-full">
        <label>Titel *</label>
        <input type="text" id="ev-titel" placeholder="z.B. ePA-Workshop für Arztpraxen">
      </div>
      <div class="form-group form-full">
        <label>Kurzbeschreibung * <small style="font-weight:400;color:var(--gray-400)">(erscheint auf der Alliance-Site)</small></label>
        <textarea id="ev-kurz" style="min-height:70px;" placeholder="1–2 Sätze, max. 200 Zeichen…"></textarea>
      </div>
      <div class="form-group form-full">
        <label>Ausführliche Beschreibung</label>
        <textarea id="ev-beschreibung" style="min-height:100px;" placeholder="Agenda, Zielgruppe, Referenten…"></textarea>
      </div>
    </div>

    <!-- Tab 1: Termin & Format -->
    <div id="mtab-content-1" class="form-grid" style="display:none;">
      <div class="form-group">
        <label>Datum *</label>
        <input type="date" id="ev-datum">
      </div>
      <div class="form-group">
        <label>Uhrzeit (Start) *</label>
        <input type="time" id="ev-uhrzeit" value="10:00">
      </div>
      <div class="form-group">
        <label>Dauer (Minuten)</label>
        <input type="number" id="ev-dauer" value="60" min="15" step="15">
      </div>
      <div class="form-group">
        <label>Format</label>
        <select id="ev-format">
          <option value="webinar">Webinar</option>
          <option value="roundtable">Roundtable</option>
          <option value="workshop">Workshop</option>
          <option value="vortrag">Vortrag</option>
        </select>
      </div>
      <div class="form-group">
        <label>Max. Teilnehmer <small style="font-weight:400;color:var(--gray-400)">(leer = unbegrenzt)</small></label>
        <input type="number" id="ev-max" min="1" placeholder="z.B. 50">
      </div>
      <div class="form-group form-full">
        <label>Teilnahme-Link <small style="font-weight:400;color:var(--gray-400)">(Zoom/Teams — nur für angemeldete Mitglieder)</small></label>
        <input type="url" id="ev-link" placeholder="https://zoom.us/j/...">
      </div>
    </div>

    <!-- Tab 2: Themen & Sichtbarkeit -->
    <div id="mtab-content-2" class="form-grid" style="display:none;">
      <div class="form-group form-full">
        <label>Themengebiete</label>
        <div id="ev-themen-chips" style="display:flex;flex-wrap:wrap;gap:6px;padding:8px 0;"></div>
      </div>
      <div class="form-group">
        <label>Status</label>
        <select id="ev-status">
          <option value="entwurf">Entwurf</option>
          <option value="geplant">Geplant</option>
          <option value="abgeschlossen">Abgeschlossen</option>
          <option value="abgesagt">Abgesagt</option>
        </select>
      </div>
      <div class="form-group">
        <label>Öffentlich auf Alliance-Site</label>
        <div style="display:flex;align-items:center;gap:10px;padding-top:6px;">
          <input type="checkbox" id="ev-oeffentlich" style="width:18px;height:18px;accent-color:var(--navy);cursor:pointer;">
          <label for="ev-oeffentlich" style="cursor:pointer;font-size:0.87rem;">Auf eHealth Alliance Website anzeigen</label>
        </div>
      </div>
    </div>

    <div class="msg" id="event-modal-msg"></div>
    <div class="modal-actions">
      <button class="btn btn-secondary" onclick="closeEventModal()">Abbrechen</button>
      <button class="btn btn-primary" onclick="saveEvent()">Speichern</button>
    </div>
  </div>
</div>
```

- [ ] **Step 4: JavaScript — State und Init schreiben**

```javascript
const SUPA_URL = 'https://focysklymhmcfwgxdtuk.supabase.co';
const SUPA_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZvY3lza2x5bWhtY2Z3Z3hkdHVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc1NTY1NTUsImV4cCI6MjEwMzEzMjU1NX0.VxgHwrnFUd-_7Q3pZx0L-7xY5roBZ__rUnLc5W7lOgg';
const sb = supabase.createClient(SUPA_URL, SUPA_KEY);

function esc(s) { return String(s ?? '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }

let userRole = 'partner';
let currentUserId = null;
let currentPartnerId = null;
let allEvents = [];
let allThemen = [];
let allAnmeldungen = [];
let editEventId = null;
let evSelectedThemen = [];
let activeTab = 0;

async function init() {
  const { data: { session } } = await sb.auth.getSession();
  if (!session) { window.location.href = 'index.html'; return; }
  currentUserId = session.user.id;

  const [roleRes, partnerRes] = await Promise.all([
    sb.from('user_roles').select('role').eq('user_id', session.user.id).maybeSingle(),
    sb.from('partners').select('id').eq('user_id', session.user.id).maybeSingle()
  ]);
  userRole = roleRes.data?.role || 'partner';
  currentPartnerId = partnerRes.data?.id || null;

  // Admins sehen Partner-Spalte
  if (userRole === 'admin') {
    document.getElementById('th-partner').style.display = '';
  }
  // Mitglieder ohne Partner-Zugang: "Neues Event" ausblenden
  if (userRole !== 'admin' && !currentPartnerId) {
    document.getElementById('btn-new-event').style.display = 'none';
  }

  // ?event= Parameter prüfen (Redirect nach Login)
  const params = new URLSearchParams(window.location.search);
  const eventParam = params.get('event');

  await Promise.all([loadThemen(), loadEvents(), loadMeineAnmeldungen()]);

  if (eventParam) {
    // Direkt zur Anmeldungs-Ansicht scrollen / Tab wechseln
    switchTab(1);
    scrollToEvent(eventParam);
  }

  populateThemaFilter();
}
```

- [ ] **Step 5: JavaScript — Lade- und Render-Funktionen schreiben**

```javascript
async function loadThemen() {
  const { data } = await sb.from('themengebiete').select('*').eq('aktiv', true).order('sortierung');
  allThemen = data || [];
}

async function loadEvents() {
  let query = sb.from('events')
    .select(`*, event_themen(thema_id), event_anmeldungen(id, status)`)
    .order('datum', { ascending: false });

  if (userRole !== 'admin' && currentPartnerId) {
    query = query.eq('partner_id', currentPartnerId);
  }

  const { data } = await query;
  allEvents = data || [];
  renderEventList();
}

async function loadMeineAnmeldungen() {
  const { data } = await sb.from('event_anmeldungen')
    .select(`*, events(id, titel, datum, uhrzeit_start, format, teilnahme_link, status)`)
    .eq('user_id', currentUserId)
    .neq('status', 'storniert')
    .order('angemeldet_am', { ascending: false });
  allAnmeldungen = data || [];
  renderMeineAnmeldungen();
}

function populateThemaFilter() {
  const sel = document.getElementById('filter-thema');
  sel.innerHTML = '<option value="">Alle Themen</option>'
    + allThemen.map(t => `<option value="${t.id}">${esc(t.name)}</option>`).join('');
}

function themaChip(themaId, small = false) {
  const t = allThemen.find(x => x.id === themaId);
  if (!t) return '';
  return `<span class="thema-chip" style="background:${esc(t.farbe)};font-size:${small ? '0.68rem' : '0.72rem'}">${esc(t.name)}</span>`;
}

const FORMAT_LABEL = { webinar:'Webinar', roundtable:'Roundtable', workshop:'Workshop', vortrag:'Vortrag' };
const STATUS_LABEL  = { entwurf:'Entwurf', geplant:'Geplant', abgeschlossen:'Abgeschlossen', abgesagt:'Abgesagt' };

function renderEventList() {
  const statusFilter = document.getElementById('filter-status').value;
  const themaFilter  = document.getElementById('filter-thema').value;

  let events = allEvents;
  if (statusFilter) events = events.filter(e => e.status === statusFilter);
  if (themaFilter)  events = events.filter(e => e.event_themen?.some(et => et.thema_id === themaFilter));

  const tbody = document.getElementById('events-tbody');
  if (!events.length) {
    tbody.innerHTML = `<tr><td colspan="9" class="empty">Keine Events gefunden.</td></tr>`;
    return;
  }

  tbody.innerHTML = events.map(e => {
    const anmCount = e.event_anmeldungen?.filter(a => a.status === 'angemeldet').length ?? 0;
    const themenHtml = (e.event_themen || []).map(et => themaChip(et.thema_id, true)).join('');
    return `<tr>
      <td style="white-space:nowrap;">${e.datum ? new Date(e.datum).toLocaleDateString('de-DE') : '–'}<br>
        <small style="color:var(--gray-400);">${e.uhrzeit_start?.slice(0,5) || ''}</small></td>
      <td><strong>${esc(e.titel)}</strong></td>
      <td><span class="format-badge">${FORMAT_LABEL[e.format] || e.format}</span></td>
      <td>${themenHtml || '–'}</td>
      ${userRole === 'admin' ? `<td><small>${esc(e.partner_id || '–')}</small></td>` : ''}
      <td>${anmCount}${e.max_teilnehmer ? ' / ' + e.max_teilnehmer : ''}</td>
      <td><span class="status-badge status-${e.status}">${STATUS_LABEL[e.status] || e.status}</span></td>
      <td style="text-align:center;">
        <input type="checkbox" ${e.oeffentlich ? 'checked' : ''} onchange="toggleOeffentlich('${e.id}', this.checked)"
               style="width:15px;height:15px;accent-color:var(--navy);cursor:pointer;">
      </td>
      <td>
        <button class="btn btn-sm btn-secondary" onclick="openEventEdit('${e.id}')">Bearbeiten</button>
        <button class="btn btn-sm" style="color:#ef4444;background:none;border:1.5px solid #fca5a5;"
                onclick="deleteEvent('${e.id}')">Löschen</button>
      </td>
    </tr>`;
  }).join('');
}

function renderMeineAnmeldungen() {
  const container = document.getElementById('meine-anmeldungen-list');
  if (!allAnmeldungen.length) {
    container.innerHTML = '<p class="empty" style="padding:20px 0;">Du hast dich noch für keine Events angemeldet.</p>';
    return;
  }
  container.innerHTML = allAnmeldungen.map(a => {
    const e = a.events;
    const datum = e?.datum ? new Date(e.datum).toLocaleDateString('de-DE') : '–';
    return `<div style="border:1.5px solid var(--gray-200);border-radius:12px;padding:16px 20px;margin-bottom:12px;">
      <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:12px;">
        <div>
          <div style="font-weight:700;font-size:0.95rem;color:var(--navy);">${esc(e?.titel || '')}</div>
          <div style="color:var(--gray-500);font-size:0.82rem;margin-top:4px;">
            ${datum} · ${e?.uhrzeit_start?.slice(0,5) || ''} · <span class="format-badge">${FORMAT_LABEL[e?.format] || ''}</span>
          </div>
          ${a.status === 'angemeldet' && e?.teilnahme_link
            ? `<a href="${esc(e.teilnahme_link)}" target="_blank" rel="noopener"
                  style="display:inline-block;margin-top:8px;padding:5px 14px;background:var(--navy);color:#fff;border-radius:8px;font-size:0.82rem;text-decoration:none;">
                 Zum Event →
               </a>`
            : a.status === 'warteliste'
              ? '<span style="font-size:0.78rem;color:#d97706;font-weight:600;margin-top:6px;display:block;">⏳ Du bist auf der Warteliste</span>'
              : ''}
        </div>
        <button class="btn btn-sm" style="color:#ef4444;background:none;border:1.5px solid #fca5a5;flex-shrink:0;"
                onclick="storniereAnmeldung('${a.id}', '${esc(e?.titel || '')}')">Stornieren</button>
      </div>
    </div>`;
  }).join('');
}
```

- [ ] **Step 6: JavaScript — Modal-Logik + Save schreiben**

```javascript
function switchTab(idx) {
  activeTab = idx;
  [0,1].forEach(i => {
    document.getElementById(`tab-${i}`).classList.toggle('active', i === idx);
    document.getElementById(`tab-content-${i}`).style.display = i === idx ? '' : 'none';
  });
}

function switchModalTab(idx) {
  [0,1,2].forEach(i => {
    document.getElementById(`mtab-${i}`).classList.toggle('active', i === idx);
    document.getElementById(`mtab-content-${i}`).style.display = i === idx ? '' : 'none';
  });
}

function renderEvThemenChips() {
  const container = document.getElementById('ev-themen-chips');
  container.innerHTML = allThemen.map(t => {
    const sel = evSelectedThemen.includes(t.id);
    return `<button type="button" class="thema-chip" onclick="toggleEvThema('${t.id}')"
      style="background:${sel ? esc(t.farbe) : 'var(--gray-100)'};color:${sel ? '#fff' : 'var(--gray-600)'};
             cursor:pointer;border:1.5px solid ${sel ? esc(t.farbe) : 'var(--gray-200)'};padding:4px 12px;border-radius:20px;font-size:0.8rem;font-weight:600;">
      ${esc(t.name)}
    </button>`;
  }).join('');
}

function toggleEvThema(id) {
  const idx = evSelectedThemen.indexOf(id);
  if (idx >= 0) evSelectedThemen.splice(idx, 1); else evSelectedThemen.push(id);
  renderEvThemenChips();
}

function openEventModal(partnerId) {
  editEventId = null;
  evSelectedThemen = [];
  document.getElementById('event-modal-title').textContent = 'Neues Event';
  document.getElementById('ev-titel').value = '';
  document.getElementById('ev-kurz').value = '';
  document.getElementById('ev-beschreibung').value = '';
  document.getElementById('ev-datum').value = '';
  document.getElementById('ev-uhrzeit').value = '10:00';
  document.getElementById('ev-dauer').value = '60';
  document.getElementById('ev-format').value = 'webinar';
  document.getElementById('ev-max').value = '';
  document.getElementById('ev-link').value = '';
  document.getElementById('ev-status').value = 'entwurf';
  document.getElementById('ev-oeffentlich').checked = false;
  document.getElementById('event-modal-msg').className = 'msg';
  switchModalTab(0);
  renderEvThemenChips();
  document.getElementById('event-modal-bg').classList.add('open');
}

function openEventEdit(id) {
  const e = allEvents.find(x => x.id === id);
  if (!e) return;
  editEventId = id;
  evSelectedThemen = (e.event_themen || []).map(et => et.thema_id);
  document.getElementById('event-modal-title').textContent = 'Event bearbeiten';
  document.getElementById('ev-titel').value = e.titel || '';
  document.getElementById('ev-kurz').value = e.kurzbeschreibung || '';
  document.getElementById('ev-beschreibung').value = e.beschreibung || '';
  document.getElementById('ev-datum').value = e.datum || '';
  document.getElementById('ev-uhrzeit').value = e.uhrzeit_start?.slice(0,5) || '10:00';
  document.getElementById('ev-dauer').value = e.dauer_min || 60;
  document.getElementById('ev-format').value = e.format || 'webinar';
  document.getElementById('ev-max').value = e.max_teilnehmer || '';
  document.getElementById('ev-link').value = e.teilnahme_link || '';
  document.getElementById('ev-status').value = e.status || 'entwurf';
  document.getElementById('ev-oeffentlich').checked = !!e.oeffentlich;
  document.getElementById('event-modal-msg').className = 'msg';
  switchModalTab(0);
  renderEvThemenChips();
  document.getElementById('event-modal-bg').classList.add('open');
}

function closeEventModal() { document.getElementById('event-modal-bg').classList.remove('open'); }

async function saveEvent() {
  const msg = document.getElementById('event-modal-msg');
  const titel = document.getElementById('ev-titel').value.trim();
  const kurz  = document.getElementById('ev-kurz').value.trim();
  const datum  = document.getElementById('ev-datum').value;
  const uhrzeit = document.getElementById('ev-uhrzeit').value;
  if (!titel) { msg.textContent = 'Titel ist Pflichtfeld.'; msg.className = 'msg error'; switchModalTab(0); return; }
  if (!kurz)  { msg.textContent = 'Kurzbeschreibung ist Pflichtfeld.'; msg.className = 'msg error'; switchModalTab(0); return; }
  if (!datum) { msg.textContent = 'Datum ist Pflichtfeld.'; msg.className = 'msg error'; switchModalTab(1); return; }

  const payload = {
    titel, kurzbeschreibung: kurz,
    beschreibung: document.getElementById('ev-beschreibung').value.trim() || null,
    datum, uhrzeit_start: uhrzeit,
    dauer_min: parseInt(document.getElementById('ev-dauer').value, 10) || 60,
    format: document.getElementById('ev-format').value,
    max_teilnehmer: parseInt(document.getElementById('ev-max').value, 10) || null,
    teilnahme_link: document.getElementById('ev-link').value.trim() || null,
    status: document.getElementById('ev-status').value,
    oeffentlich: document.getElementById('ev-oeffentlich').checked,
    partner_id: currentPartnerId,
  };

  let eventId = editEventId;
  let error;

  if (editEventId) {
    ({ error } = await sb.from('events').update(payload).eq('id', editEventId));
  } else {
    const res = await sb.from('events').insert(payload).select('id').single();
    error = res.error;
    eventId = res.data?.id;
  }

  if (error) { msg.textContent = error.message; msg.className = 'msg error'; return; }

  // Themen-Verknüpfungen aktualisieren
  await sb.from('event_themen').delete().eq('event_id', eventId);
  if (evSelectedThemen.length) {
    await sb.from('event_themen').insert(evSelectedThemen.map(tid => ({ event_id: eventId, thema_id: tid })));
  }

  closeEventModal();
  await loadEvents();
}

async function toggleOeffentlich(id, oeffentlich) {
  await sb.from('events').update({ oeffentlich }).eq('id', id);
  const ev = allEvents.find(e => e.id === id);
  if (ev) ev.oeffentlich = oeffentlich;
}

async function deleteEvent(id) {
  const e = allEvents.find(x => x.id === id);
  if (!confirm(`Event "${e?.titel}" wirklich löschen? Alle Anmeldungen werden ebenfalls gelöscht.`)) return;
  const { error } = await sb.from('events').delete().eq('id', id);
  if (error) { alert(error.message); return; }
  await loadEvents();
}

async function storniereAnmeldung(anmId, titel) {
  if (!confirm(`Anmeldung für "${titel}" stornieren?`)) return;
  await sb.from('event_anmeldungen').update({ status: 'storniert' }).eq('id', anmId);
  await loadMeineAnmeldungen();
}

function scrollToEvent(eventId) {
  // Öffentliche Events-Liste im Tab 1 nach eventId durchsuchen
  const e = allEvents.find(x => x.id === eventId);
  if (!e) return;
  // Zeige Event-Details als kleines Popup / Scroll direkt in "Meine Anmeldungen"
  // Prüfe ob User schon angemeldet
  const anm = allAnmeldungen.find(a => a.event_id === eventId || a.events?.id === eventId);
  if (!anm) {
    // Zeige Anmelde-Bestätigungs-Dialog
    if (confirm(`Möchtest du dich für "${e.titel}" anmelden?`)) {
      anmeldenFuerEvent(eventId, e.titel, e.max_teilnehmer, e.event_anmeldungen?.filter(a => a.status === 'angemeldet').length ?? 0);
    }
  }
}

async function anmeldenFuerEvent(eventId, titel, maxTn, aktuelleAnzahl) {
  const status = maxTn && aktuelleAnzahl >= maxTn ? 'warteliste' : 'angemeldet';
  const { error } = await sb.from('event_anmeldungen').insert({
    event_id: eventId, user_id: currentUserId, status
  });
  if (error) { alert(error.message); return; }
  await Promise.all([loadEvents(), loadMeineAnmeldungen()]);
  if (status === 'warteliste') {
    alert(`Du wurdest auf die Warteliste für "${titel}" gesetzt.`);
  } else {
    alert(`Erfolgreich für "${titel}" angemeldet!`);
  }
}

init();
```

- [ ] **Step 7: In Browser prüfen**

  - Events-Liste lädt (leer ist ok — noch keine Events)
  - Neues Event anlegen: alle 3 Modal-Tabs navigierbar
  - Themen-Chips wählbar (toggle Farbe)
  - Öffentlich-Toggle ohne Modal
  - Tab "Meine Anmeldungen" zeigt leeren Zustand sauber
  - Admin sieht Partner-Spalte, Partner-User nicht

- [ ] **Step 8: Commit**

```bash
git add admin/events.html
git commit -m "feat: add events admin page (CRUD + Anmeldung + Themen)"
```

---

## Task 5: Login-Redirect für `?event=<id>`

**Files:**
- Modify: `admin/index.html`

**Interfaces:**
- Consumes: `?event=<id>` URL-Parameter
- Produces: Nach Login weiterleitung zu `events.html?event=<id>` statt `dashboard.html`

- [ ] **Step 1: index.html lesen und Redirect-Logik anpassen**

In `admin/index.html` alle Stellen suchen wo `window.location.href = 'dashboard.html'` steht (ca. 4 Stellen). Jede ersetzen durch:

```javascript
// Vorher:
window.location.href = 'dashboard.html';

// Nachher (Hilfsfunktion einmalig definieren, dann überall aufrufen):
function redirectAfterLogin() {
  const params = new URLSearchParams(window.location.search);
  const eventId = params.get('event');
  window.location.href = eventId ? `events.html?event=${eventId}` : 'dashboard.html';
}
// Alle window.location.href = 'dashboard.html' ersetzen durch: redirectAfterLogin();
```

- [ ] **Step 2: Prüfen**

URL `admin/index.html?event=test-id` aufrufen → nach Login landet man auf `events.html?event=test-id`.

- [ ] **Step 3: Commit**

```bash
git add admin/index.html
git commit -m "feat: preserve ?event= param through login redirect"
```

---

## Task 6: `ehealth Alliance/events.html`

**Files:**
- Create: `ehealth Alliance/events.html`

**Interfaces:**
- Consumes: `themengebiete`, `events`, `event_themen` (nur öffentlich+geplant+zukünftig) via Anon-Key
- Produces: öffentliche Events-Seite mit Filter + "Jetzt anmelden"-Button

- [ ] **Step 1: HTML-Grundgerüst mit Alliance-Design erstellen**

Kopiere Header + Nav + Footer aus `ehealth Alliance/partner.html`. Ersetze `aria-current="page"` auf den neuen Events-Nav-Link. Binde `assets/css/styles.css` ein. Lade Supabase SDK:

```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
```

Kein Auth-Check — diese Seite ist vollständig öffentlich.

- [ ] **Step 2: Hero + Filter + Card-Grid HTML schreiben**

```html
<main id="main">

  <section class="hero" style="padding:60px 0 40px;">
    <div class="container hero__inner" style="grid-template-columns:1fr;">
      <div>
        <span class="badge">Online-Events & Webinare</span>
        <h1>Wissen teilen. Netzwerk stärken.</h1>
        <p class="hero__lead">
          Unsere Partner gestalten regelmäßige Online-Events zu den Themen der digitalen
          Gesundheitsversorgung — für Mitglieder der eHealth Alliance.
        </p>
        <p style="font-size:0.9rem;color:var(--muted);">
          Zur Anmeldung ist eine Mitgliedschaft im
          <a href="https://www.ehealth-sales.de/admin/index.html" style="color:var(--brand-500);">Mitglieder-Portal</a>
          erforderlich.
        </p>
      </div>
    </div>
  </section>

  <section class="section">
    <div class="container">

      <!-- Filter -->
      <div id="filter-bar" style="display:flex;gap:10px;flex-wrap:wrap;margin-bottom:28px;align-items:center;">
        <span style="font-size:0.82rem;font-weight:600;color:var(--muted);">Thema:</span>
        <button class="filter-chip active" data-thema="" onclick="setThemaFilter(this, '')">Alle</button>
      </div>

      <!-- Event-Cards -->
      <div id="events-grid" style="display:grid;grid-template-columns:repeat(auto-fill,minmax(320px,1fr));gap:20px;">
        <p style="color:var(--muted);">Lade Events…</p>
      </div>

    </div>
  </section>

</main>
```

- [ ] **Step 3: CSS für Filter-Chips und Event-Cards ergänzen (inline `<style>`):**

```css
.filter-chip {
  padding: 5px 14px; border-radius: 20px; border: 1.5px solid var(--line-strong);
  background: transparent; color: var(--ink-soft); cursor: pointer;
  font-size: 0.8rem; font-weight: 600; font-family: inherit; transition: all 0.15s;
}
.filter-chip.active, .filter-chip:hover {
  background: var(--brand-500); border-color: var(--brand-500); color: #fff;
}

.event-card {
  border: 1.5px solid var(--line); border-radius: 14px; padding: 22px;
  display: flex; flex-direction: column; gap: 12px;
  background: var(--bg); transition: box-shadow 0.15s;
}
.event-card:hover { box-shadow: 0 4px 16px rgba(15,76,129,.10); }

.event-card__meta { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }
.event-card__date { font-size: 0.8rem; font-weight: 700; color: var(--brand-600); }
.event-card__format { padding: 2px 8px; border-radius: 6px; font-size: 0.72rem;
  font-weight: 600; background: var(--bg-soft); color: var(--muted); }
.event-card__title { font-family: 'Sora', sans-serif; font-size: 1.05rem;
  font-weight: 700; color: var(--ink); line-height: 1.35; }
.event-card__desc { font-size: 0.85rem; color: var(--ink-soft); line-height: 1.5; }
.event-card__themen { display: flex; flex-wrap: wrap; gap: 5px; }
.thema-pill { padding: 2px 10px; border-radius: 20px; font-size: 0.72rem;
  font-weight: 600; color: #fff; }
.event-card__footer { margin-top: auto; display: flex; justify-content: space-between;
  align-items: center; }
.event-card__partner { font-size: 0.78rem; color: var(--muted); }
```

- [ ] **Step 4: JavaScript schreiben**

```javascript
const SUPA_URL = 'https://focysklymhmcfwgxdtuk.supabase.co';
const SUPA_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZvY3lza2x5bWhtY2Z3Z3hkdHVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc1NTY1NTUsImV4cCI6MjEwMzEzMjU1NX0.VxgHwrnFUd-_7Q3pZx0L-7xY5roBZ__rUnLc5W7lOgg';
const sb = supabase.createClient(SUPA_URL, SUPA_KEY);

function esc(s) { return String(s ?? '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }

const FORMAT_LABEL = { webinar:'Webinar', roundtable:'Roundtable', workshop:'Workshop', vortrag:'Vortrag' };

let allEvents = [];
let allThemen = [];
let activeThema = '';

async function init() {
  const [evRes, thRes] = await Promise.all([
    sb.from('events')
      .select('*, event_themen(thema_id), partners(id, firma)')
      .eq('oeffentlich', true)
      .eq('status', 'geplant')
      .gte('datum', new Date().toISOString().slice(0,10))
      .order('datum', { ascending: true }),
    sb.from('themengebiete').select('*').eq('aktiv', true).order('sortierung')
  ]);

  allEvents = evRes.data || [];
  allThemen  = thRes.data || [];

  buildThemaFilter();
  renderCards();
}

function buildThemaFilter() {
  const bar = document.getElementById('filter-bar');
  // Nur Themen anzeigen die in den geladenen Events vorkommen
  const usedThemaIds = new Set(allEvents.flatMap(e => (e.event_themen || []).map(et => et.thema_id)));
  allThemen.filter(t => usedThemaIds.has(t.id)).forEach(t => {
    const btn = document.createElement('button');
    btn.className = 'filter-chip';
    btn.dataset.thema = t.id;
    btn.style.setProperty('--chip-color', t.farbe);
    btn.textContent = t.name;
    btn.onclick = () => setThemaFilter(btn, t.id);
    bar.appendChild(btn);
  });
}

function setThemaFilter(el, themaId) {
  activeThema = themaId;
  document.querySelectorAll('.filter-chip').forEach(c => c.classList.remove('active'));
  el.classList.add('active');
  renderCards();
}

function renderCards() {
  const grid = document.getElementById('events-grid');
  let events = allEvents;
  if (activeThema) events = events.filter(e => e.event_themen?.some(et => et.thema_id === activeThema));

  if (!events.length) {
    grid.innerHTML = `<p style="color:var(--muted);grid-column:1/-1;">
      Aktuell sind keine Events zu diesem Thema geplant. Schau bald wieder vorbei.
    </p>`;
    return;
  }

  grid.innerHTML = events.map(e => {
    const datum = e.datum ? new Date(e.datum + 'T' + e.uhrzeit_start).toLocaleDateString('de-DE', { weekday:'short', day:'numeric', month:'long', year:'numeric' }) : '';
    const uhrzeit = e.uhrzeit_start?.slice(0,5) || '';
    const themenHtml = (e.event_themen || []).map(et => {
      const t = allThemen.find(x => x.id === et.thema_id);
      return t ? `<span class="thema-pill" style="background:${esc(t.farbe)}">${esc(t.name)}</span>` : '';
    }).join('');
    const portalUrl = `https://www.ehealth-sales.de/admin/index.html?event=${e.id}`;
    return `<div class="event-card">
      <div class="event-card__meta">
        <span class="event-card__date">${datum}, ${uhrzeit} Uhr</span>
        <span class="event-card__format">${FORMAT_LABEL[e.format] || e.format}</span>
        ${e.max_teilnehmer ? `<span style="font-size:0.72rem;color:var(--muted);">max. ${e.max_teilnehmer} TN</span>` : ''}
      </div>
      <div class="event-card__title">${esc(e.titel)}</div>
      <div class="event-card__desc">${esc(e.kurzbeschreibung)}</div>
      <div class="event-card__themen">${themenHtml}</div>
      <div class="event-card__footer">
        <span class="event-card__partner">${esc(e.partners?.firma || '')}</span>
        <a href="${esc(portalUrl)}" class="btn btn--primary" style="font-size:0.83rem;padding:8px 18px;">
          Jetzt anmelden →
        </a>
      </div>
    </div>`;
  }).join('');
}

init();
```

- [ ] **Step 5: In Browser prüfen**

  Datei im Browser öffnen (über lokalen Server oder direkt):
  - Hero-Bereich sichtbar
  - Filter-Chips erscheinen nach Laden (leer wenn keine Events vorhanden — ok)
  - "Jetzt anmelden"-Button zeigt auf korrekten Portal-Link mit event_id
  - Design ist konsistent mit `partner.html` (Farben, Schrift, Nav)

- [ ] **Step 6: Commit**

```bash
git add "ehealth Alliance/events.html"
git commit -m "feat: add public events page on Alliance site"
```

---

## Task 7: Alliance-Site Nav + Index-Preview

**Files:**
- Modify: `ehealth Alliance/index.html`, `ehealth Alliance/partner.html`, `ehealth Alliance/datenschutz.html`, `ehealth Alliance/impressum.html`

**Interfaces:**
- Consumes: `events.html` (Task 6)
- Produces: "Events" in Alliance-Nav; optionaler 3-Card-Preview auf Homepage

- [ ] **Step 1: Nav-Eintrag in allen 4 Alliance-Seiten ergänzen**

In jeder Datei in der `<ul class="nav__list">` direkt nach dem `<li><a href="partner.html">Partner</a></li>` Eintrag einfügen:

```html
<li><a href="events.html">Events</a></li>
```

Auf `events.html` selbst: `aria-current="page"` ergänzen.

- [ ] **Step 2: Preview-Block auf `index.html` ergänzen**

In `index.html` nach dem letzten `</section>` vor dem `<section class="cta-band">` einfügen:

```html
<section class="section section--soft" id="events-preview">
  <div class="container">
    <div class="section-head">
      <h2>Nächste Events</h2>
      <p>Online-Austausch zu den Themen der digitalen Gesundheitsversorgung — nur für Mitglieder.</p>
    </div>
    <div id="preview-events-grid" style="display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:16px;margin-bottom:24px;">
      <p style="color:var(--muted);">Lade Events…</p>
    </div>
    <div style="text-align:center;">
      <a href="events.html" class="btn btn--ghost">Alle Events ansehen →</a>
    </div>
  </div>
</section>
```

Und das JS für den Preview-Block am Ende von `index.html` vor `</body>`:

```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script>
(async () => {
  const sb = supabase.createClient(
    'https://focysklymhmcfwgxdtuk.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZvY3lza2x5bWhtY2Z3Z3hkdHVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc1NTY1NTUsImV4cCI6MjEwMzEzMjU1NX0.VxgHwrnFUd-_7Q3pZx0L-7xY5roBZ__rUnLc5W7lOgg'
  );
  function esc(s) { return String(s ?? '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
  const { data: events } = await sb.from('events')
    .select('id, titel, datum, uhrzeit_start, format, kurzbeschreibung')
    .eq('oeffentlich', true).eq('status', 'geplant')
    .gte('datum', new Date().toISOString().slice(0,10))
    .order('datum', { ascending: true }).limit(3);

  const FORMAT = { webinar:'Webinar', roundtable:'Roundtable', workshop:'Workshop', vortrag:'Vortrag' };
  const grid = document.getElementById('preview-events-grid');
  if (!events?.length) {
    grid.innerHTML = '<p style="color:var(--muted);">Aktuell sind keine Events geplant.</p>';
    return;
  }
  grid.innerHTML = events.map(e => {
    const d = new Date(e.datum + 'T' + e.uhrzeit_start).toLocaleDateString('de-DE',{day:'numeric',month:'long'});
    return `<a href="events.html" style="text-decoration:none;">
      <div style="border:1.5px solid var(--line);border-radius:12px;padding:18px;background:var(--bg);transition:box-shadow .15s;" onmouseover="this.style.boxShadow='0 4px 16px rgba(15,76,129,.10)'" onmouseout="this.style.boxShadow=''">
        <div style="font-size:0.78rem;font-weight:700;color:var(--brand-500);margin-bottom:6px;">${esc(d)} · ${FORMAT[e.format]||e.format}</div>
        <div style="font-family:'Sora',sans-serif;font-weight:700;font-size:0.95rem;color:var(--ink);margin-bottom:8px;">${esc(e.titel)}</div>
        <div style="font-size:0.83rem;color:var(--ink-soft);line-height:1.45;">${esc(e.kurzbeschreibung)}</div>
      </div></a>`;
  }).join('');
})();
</script>
```

- [ ] **Step 3: Alliance-Seiten im Browser prüfen**

  - `index.html`: "Events" im Nav, Preview-Section sichtbar (Platzhalter wenn keine Events)
  - `partner.html`: "Events" im Nav sichtbar
  - `events.html`: `aria-current="page"` auf Events-Link

- [ ] **Step 4: Commit**

```bash
git add "ehealth Alliance/index.html" "ehealth Alliance/partner.html" \
        "ehealth Alliance/datenschutz.html" "ehealth Alliance/impressum.html"
git commit -m "feat: add Events nav + homepage preview to Alliance site"
```

---

## Self-Review Checkliste

- [x] **Spec-Abdeckung:** Alle 4 DB-Tabellen ✓ | RLS ✓ | themengebiete.html ✓ | events.html Admin ✓ | Alliance events.html ✓ | Anmeldungsflow ✓ | Nav-Updates ✓ | Login-Redirect ✓
- [x] **Keine Platzhalter:** Alle Code-Blöcke vollständig
- [x] **Typ-Konsistenz:** `evSelectedThemen`, `allThemen`, `allEvents` konsistent durch Tasks 4–6
- [x] **Partner-Spalte:** `th-partner` mit `style="display:none"` und JS-Toggle für Admin korrekt
- [x] **?event= Param:** Task 5 (index.html) + Task 4 (`scrollToEvent`) greifen konsistent auf `eventId` zu
- [x] **Anon-Key:** Nur in öffentlichen Seiten und Admin-Seiten (beides erlaubt) — nie in git-ignorierten oder sensitiven Stellen
