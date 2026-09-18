# Themengebiete-Tagging — Systemweite Erweiterung

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Die `themengebiete`-Tabelle wird zur einzigen Quelle für Topic-Tags im Portal — Produkte, Bundles und Kunden erhalten Junction-Tabellen; Produktfinder und Lösungsseiten laden Filter und Badges dynamisch aus der DB.

**Architecture:** Junction-Tabellen analog zu `event_themen` (normalisiert, FK-Referenzintegrität). Produkte schreiben beim Speichern in beide Systeme: neue `product_themen`-Tabelle UND bestehende Boolean-Spalten (rückwärtskompatibel für Produktfinder-Filter). ASSESSMENT_TOPICS in index.html wird via neues `finder_pref_column`-Feld auf `themengebiete` dynamisiert.

**Tech Stack:** Supabase JS SDK v2 (CDN), Static HTML/JS SPA, kein Build-Step

**Spec:** docs/superpowers/specs/2026-09-18-themengebiete-tagging.md

## Global Constraints

- Supabase anon key (`eyJhbGci...`) darf in HTML-Dateien stehen — ist öffentlich
- Resend API key darf NIEMALS in git-tracked files stehen
- Kein Build-Step, kein npm — reines HTML/JS mit CDN
- `esc(s)` für alle user-generierten Inhalte verwenden (XSS-Schutz): `s => String(s??'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')`
- Chip-Multiselect-Pattern: delete-all + re-insert beim Speichern; State als `let xyzSelectedThemen = []`
- Bestehende RLS-Policies nicht brechen
- Alte `bundles.themen`-jsonb-Spalte: nicht droppen, nur nicht mehr beschreiben
- Products: beim Speichern in BEIDE Systeme schreiben — `product_themen` UND alte Boolean-Spalten auf `products`

---

## Datei-Übersicht

| Datei | Änderung |
|---|---|
| `admin/sql/migration_themengebiete_tagging.sql` | neu: 2 Themengebiete, 3 Junction-Tables, Bundle-Migration, finder_pref_column, RLS |
| `admin/products.html` | Produkt-Themen-Chips in Schritt 1; Bundle-b-thema-Checkboxen → Chips |
| `admin/kunden.html` | Interessen-Chips in Tab 1; VC-Tabelle zeigt vererbte Themen |
| `index.html` | ASSESSMENT_TOPICS dynamisch aus DB; Bundle-Filter nutzt bundle_themen |
| `loesung-public.html` | Themen-Badges aus product_themen im Hero-Bereich |

---

## Task 1: SQL-Migration

**Files:**
- Create: `admin/sql/migration_themengebiete_tagging.sql`

**Interfaces:**
- Produces: Tabellen `product_themen`, `bundle_themen`, `kunden_interessen`; Spalte `themengebiete.finder_pref_column`; 2 neue Themengebiete-Einträge

- [ ] **Schritt 1: Migration-Datei erstellen**

Erstelle `admin/sql/migration_themengebiete_tagging.sql` mit folgendem Inhalt (vollständig, nichts kürzen):

```sql
-- Migration: Themengebiete-Tagging systemweit
-- Ausführen im Supabase SQL Editor

-- ─── 1. Fehlende Themengebiete ergänzen ──────────────────────────────────────
INSERT INTO themengebiete (name, slug, farbe, sortierung) VALUES
  ('Modern Work',             'modernwork', '#6DC52D', 90),
  ('Prozess Digitalisierung', 'prozess',    '#ED8936', 100)
ON CONFLICT (slug) DO NOTHING;

-- ─── 2. finder_pref_column für index.html ASSESSMENT_TOPICS ──────────────────
-- Welche Spalte auf der products-Tabelle entspricht diesem Thema im Produktfinder?
ALTER TABLE themengebiete ADD COLUMN IF NOT EXISTS finder_pref_column text;

UPDATE themengebiete SET finder_pref_column = 'security'         WHERE slug = 'security';
UPDATE themengebiete SET finder_pref_column = 'ti'               WHERE slug = 'ti';
UPDATE themengebiete SET finder_pref_column = 'telemedizin'      WHERE slug = 'telemedizin';
UPDATE themengebiete SET finder_pref_column = 'it_infrastruktur' WHERE slug = 'it';
UPDATE themengebiete SET finder_pref_column = 'modern_work'      WHERE slug = 'modernwork';
UPDATE themengebiete SET finder_pref_column = 'prozess_digital'  WHERE slug = 'prozess';
-- epa, ki, abrechnung, regulatory haben noch keine pref_column (kommen später)

-- ─── 3. Junction-Tabellen ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS product_themen (
  product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  thema_id   uuid NOT NULL REFERENCES themengebiete(id) ON DELETE CASCADE,
  PRIMARY KEY (product_id, thema_id)
);

CREATE TABLE IF NOT EXISTS bundle_themen (
  bundle_id uuid NOT NULL REFERENCES bundles(id) ON DELETE CASCADE,
  thema_id  uuid NOT NULL REFERENCES themengebiete(id) ON DELETE CASCADE,
  PRIMARY KEY (bundle_id, thema_id)
);

CREATE TABLE IF NOT EXISTS kunden_interessen (
  kunden_id uuid NOT NULL REFERENCES kunden(id) ON DELETE CASCADE,
  thema_id  uuid NOT NULL REFERENCES themengebiete(id) ON DELETE CASCADE,
  PRIMARY KEY (kunden_id, thema_id)
);

-- ─── 4. Indizes ──────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_product_themen_product_id ON product_themen(product_id);
CREATE INDEX IF NOT EXISTS idx_product_themen_thema_id   ON product_themen(thema_id);
CREATE INDEX IF NOT EXISTS idx_bundle_themen_bundle_id   ON bundle_themen(bundle_id);
CREATE INDEX IF NOT EXISTS idx_bundle_themen_thema_id    ON bundle_themen(thema_id);
CREATE INDEX IF NOT EXISTS idx_kunden_interessen_kunden  ON kunden_interessen(kunden_id);

-- ─── 5. Bundle-Daten migrieren (alte jsonb → neue Junction-Tabelle) ──────────
-- Mapping alter Slugs zu neuen Slugs:
-- ti→ti, security→security, telemedizin→telemedizin
-- it_infrastruktur→it, modern_work→modernwork, prozess_digital→prozess
INSERT INTO bundle_themen (bundle_id, thema_id)
SELECT b.id, t.id
FROM bundles b
CROSS JOIN LATERAL jsonb_array_elements_text(COALESCE(b.themen, '[]'::jsonb)) AS slug_raw
JOIN (VALUES
  ('ti',               'ti'),
  ('security',         'security'),
  ('telemedizin',      'telemedizin'),
  ('it_infrastruktur', 'it'),
  ('modern_work',      'modernwork'),
  ('prozess_digital',  'prozess')
) AS mapping(old_slug, new_slug) ON mapping.old_slug = slug_raw
JOIN themengebiete t ON t.slug = mapping.new_slug
ON CONFLICT DO NOTHING;

-- ─── 6. RLS ──────────────────────────────────────────────────────────────────
ALTER TABLE product_themen    ENABLE ROW LEVEL SECURITY;
ALTER TABLE bundle_themen     ENABLE ROW LEVEL SECURITY;
ALTER TABLE kunden_interessen ENABLE ROW LEVEL SECURITY;

-- product_themen: alle lesen, Partner/Admin schreiben
CREATE POLICY "product_themen_read"
  ON product_themen FOR SELECT USING (true);

CREATE POLICY "product_themen_write"
  ON product_themen FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM products p WHERE p.id = product_themen.product_id
      AND (
        p.partner_id IN (SELECT id FROM partners WHERE user_id = auth.uid())
        OR EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
      )
    )
  );

-- bundle_themen: alle lesen, Admin schreiben
CREATE POLICY "bundle_themen_read"
  ON bundle_themen FOR SELECT USING (true);

CREATE POLICY "bundle_themen_write"
  ON bundle_themen FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin'));

-- kunden_interessen: nur Admins (Partner-Erweiterung kommt später)
CREATE POLICY "kunden_interessen_read"
  ON kunden_interessen FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin'));

CREATE POLICY "kunden_interessen_write"
  ON kunden_interessen FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin'));
```

- [ ] **Schritt 2: Manuelle Ausführung im Supabase SQL Editor**

Diese Migration kann NICHT automatisch geprüft werden — sie muss manuell ausgeführt werden. Füge eine Notiz in den Commit ein, dass der Implementer sie noch nicht ausführen muss (das macht der Operator).

- [ ] **Schritt 3: Commit**

```bash
git add admin/sql/migration_themengebiete_tagging.sql
git commit -m "feat: SQL migration for themengebiete junction tables

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 2: admin/products.html — Produkt- und Bundle-Themen

**Files:**
- Modify: `admin/products.html`

**Interfaces:**
- Consumes: `themengebiete` (alle aktiven, inkl. finder_pref_column), `product_themen`, `bundle_themen`
- Produces: `product_themen`-Zeilen, `bundle_themen`-Zeilen, weiterhin Boolean-Spalten auf `products`

**Hintergrund:** products.html hat THREE tab-like pages: step-1 (Produktdaten), step-2 (Bild/Lösungsseite), step-3 (EK-Staffel). Step-1 hat bereits hardcodierte Themen-Checkboxen (`f-ti`, `f-security`, `f-telemedizin`, `f-it-infra`, `f-modern-work`, `f-prozess`) die Boolean-Spalten auf products schreiben — diese werden durch dynamische Chips ERSETZT, schreiben aber weiterhin in beide Systeme.

Das Bundle-Modal (separate `#bundle-modal-bg`) hat 6 hardcodierte `<label class="bg-check"><input name="b-thema">` Checkboxen — diese werden ebenfalls durch Chips ersetzt.

- [ ] **Schritt 1: State-Variablen am Anfang des `<script>`-Blocks ergänzen**

Suche nach der Stelle wo andere `let`-Variablen deklariert sind (z.B. `let allProducts`, `let allBundles`) und füge direkt daneben hinzu:

```javascript
let allThemen = [];
let prodSelectedThemen = [];
let bundleSelectedThemen = [];
```

- [ ] **Schritt 2: Themengebiete beim Init laden**

In der `init()`-Funktion (oder wo `allProducts` und `allBundles` geladen werden), ergänze:

```javascript
const { data: themenData } = await sb.from('themengebiete')
  .select('id, name, slug, farbe, finder_pref_column')
  .eq('aktiv', true)
  .order('sortierung');
allThemen = themenData || [];
```

- [ ] **Schritt 3: Chip-Funktionen für Produkte hinzufügen**

Füge diese zwei Funktionen zum `<script>` hinzu (z.B. nach den Bundle-Themen-Funktionen die du in Schritt 5 hinzufügst):

```javascript
function renderProdThemenChips() {
  const wrap = document.getElementById('prod-themen-chips');
  if (!wrap) return;
  wrap.innerHTML = allThemen.map(t => {
    const active = prodSelectedThemen.includes(t.id);
    return `<button type="button" onclick="toggleProdThema('${t.id}')"
      style="padding:4px 12px;border-radius:20px;border:1.5px solid ${active ? t.farbe : '#e2e8f0'};
             background:${active ? t.farbe + '22' : 'white'};color:${active ? t.farbe : '#64748b'};
             font-size:0.78rem;font-weight:700;cursor:pointer;transition:all .15s;">${esc(t.name)}</button>`;
  }).join('');
}

function toggleProdThema(id) {
  prodSelectedThemen = prodSelectedThemen.includes(id)
    ? prodSelectedThemen.filter(x => x !== id)
    : [...prodSelectedThemen, id];
  renderProdThemenChips();
}
```

- [ ] **Schritt 4: Alten Themen-Checkboxen-Block in Step 1 ersetzen**

Suche den Block, der mit `<div style="margin-top:6px;font-size:0.72rem;font-weight:700;color:var(--gray-500);text-transform:uppercase;letter-spacing:0.06em;margin-bottom:6px;">Themen-Zuordnung</div>` beginnt und die 6 Toggle-Rows (`f-ti`, `f-security`, etc.) enthält. Ersetze den GESAMTEN Block (von diesem Label bis zum Ende der Grid-Div inklusive) durch:

```html
<div style="margin-top:6px;font-size:0.72rem;font-weight:700;color:var(--gray-500);text-transform:uppercase;letter-spacing:0.06em;margin-bottom:8px;">Themengebiete</div>
<div id="prod-themen-chips" style="display:flex;flex-wrap:wrap;gap:6px;padding:4px 0;min-height:32px;"></div>
```

- [ ] **Schritt 5: Chip-Funktionen für Bundles hinzufügen**

```javascript
function renderBundleThemenChips() {
  const wrap = document.getElementById('bundle-themen-chips');
  if (!wrap) return;
  wrap.innerHTML = allThemen.map(t => {
    const active = bundleSelectedThemen.includes(t.id);
    return `<button type="button" onclick="toggleBundleThema('${t.id}')"
      style="padding:4px 12px;border-radius:20px;border:1.5px solid ${active ? t.farbe : '#e2e8f0'};
             background:${active ? t.farbe + '22' : 'white'};color:${active ? t.farbe : '#64748b'};
             font-size:0.78rem;font-weight:700;cursor:pointer;transition:all .15s;">${esc(t.name)}</button>`;
  }).join('');
}

function toggleBundleThema(id) {
  bundleSelectedThemen = bundleSelectedThemen.includes(id)
    ? bundleSelectedThemen.filter(x => x !== id)
    : [...bundleSelectedThemen, id];
  renderBundleThemenChips();
}
```

- [ ] **Schritt 6: Bundle-Modal Checkboxen ersetzen**

Im Bundle-Modal: Suche den Block mit `<label>Themenbereiche</label>` und dem Grid mit den 6 `bg-check`-Labels (name="b-thema"). Ersetze den gesamten Block durch:

```html
<div class="form-group form-full">
  <label>Themengebiete</label>
  <div id="bundle-themen-chips" style="display:flex;flex-wrap:wrap;gap:6px;padding:6px 0;min-height:32px;"></div>
</div>
```

- [ ] **Schritt 7: openBundleModal — Themen laden**

In der `openBundleModal(id)`-Funktion: Nach dem Reset der anderen Felder (wo bisher `document.querySelectorAll('[name="b-thema"]').forEach(cb => cb.checked = ...)` stand), ersetze die b-thema-Logik durch:

```javascript
// Themen: DB-Laden bei Edit, Reset bei Neu
if (id) {
  const { data: btRows } = await sb.from('bundle_themen')
    .select('thema_id').eq('bundle_id', id);
  bundleSelectedThemen = (btRows || []).map(r => r.thema_id);
} else {
  bundleSelectedThemen = [];
}
renderBundleThemenChips();
```

- [ ] **Schritt 8: openModal (Produkt) — Themen laden**

In der Funktion `openModal(id)` (die das Produkt-Modal öffnet): Nach dem Laden der anderen Produktfelder, ergänze:

```javascript
if (id) {
  const { data: ptRows } = await sb.from('product_themen')
    .select('thema_id').eq('product_id', id);
  prodSelectedThemen = (ptRows || []).map(r => r.thema_id);
} else {
  prodSelectedThemen = [];
}
renderProdThemenChips();
```

- [ ] **Schritt 9: saveProduct — Dual-Write (product_themen + Boolean-Spalten)**

In `saveProduct()`, nach dem Upsert der Produkt-Daten (nachdem `savedId` bekannt ist), ergänze:

```javascript
// product_themen: delete-all + re-insert
await sb.from('product_themen').delete().eq('product_id', savedId);
if (prodSelectedThemen.length) {
  await sb.from('product_themen').insert(
    prodSelectedThemen.map(tid => ({ product_id: savedId, thema_id: tid }))
  );
}
// Boolean-Spalten aktuell halten (Rückwärtskompatibilität für Produktfinder)
const boolUpdate = {};
allThemen.forEach(t => {
  if (t.finder_pref_column) {
    boolUpdate[t.finder_pref_column] = prodSelectedThemen.includes(t.id);
  }
});
if (Object.keys(boolUpdate).length) {
  await sb.from('products').update(boolUpdate).eq('id', savedId);
}
```

- [ ] **Schritt 10: saveBundle — bundle_themen schreiben**

In `saveBundle()`, nach dem Speichern des Bundles (nachdem `bundleId` bekannt ist), ersetze die alte `b-thema`-Zeile:
```javascript
// ALT (entfernen):
themen: [...document.querySelectorAll('[name="b-thema"]:checked')].map(cb => cb.value),
```
Entferne `themen` aus dem Bundle-Payload und füge stattdessen NACH dem Bundle-Upsert hinzu:

```javascript
// bundle_themen: delete-all + re-insert
await sb.from('bundle_themen').delete().eq('bundle_id', bundleId);
if (bundleSelectedThemen.length) {
  await sb.from('bundle_themen').insert(
    bundleSelectedThemen.map(tid => ({ bundle_id: bundleId, thema_id: tid }))
  );
}
```

- [ ] **Schritt 11: Bundle-Tabelle — themen_ids aus DB laden**

In der Funktion die `allBundles` lädt: Erweitere den Select um `bundle_themen(thema_id)`:

```javascript
const { data: bundleData } = await sb.from('bundles')
  .select('*, bundle_themen(thema_id)')
  .order('name');
allBundles = (bundleData || []).map(b => ({
  ...b,
  thema_ids: (b.bundle_themen || []).map(bt => bt.thema_id)
}));
```

- [ ] **Schritt 12: Bundle-Tabelle — BUNDLE_THEMEN_CFG ersetzen**

Suche `const BUNDLE_THEMEN_CFG = [...]` und die renderBundleTable-Funktion. Ersetze den `BUNDLE_THEMEN_CFG.filter(...)` Block durch:

```javascript
const themenTags = allThemen
  .filter(t => (b.thema_ids || []).includes(t.id))
  .map(t => `<span style="display:inline-block;background:${t.farbe}22;color:${t.farbe};font-size:0.68rem;font-weight:700;padding:2px 7px;border-radius:20px;margin:1px;">${esc(t.name)}</span>`)
  .join('');
```

Lösche danach die gesamte `BUNDLE_THEMEN_CFG`-Konstante.

- [ ] **Schritt 13: Produkt-Tabelle — Themen-Badges**

Beim Laden der Produkte: Erweitere den Select um `product_themen(thema_id, themengebiete(name, farbe))`:

```javascript
const { data: productsData } = await sb.from('products')
  .select('*, product_themen(thema_id, themengebiete(name, farbe))')
  // ... bestehende Filter/Order
```

In der renderProductTable-Funktion: Füge eine Themen-Spalte `<th>Themen</th>` hinzu und rendere Badges:

```javascript
const themenBadges = (p.product_themen || [])
  .map(pt => `<span style="display:inline-block;background:${pt.themengebiete.farbe}22;color:${pt.themengebiete.farbe};font-size:0.68rem;font-weight:700;padding:2px 7px;border-radius:20px;margin:1px;">${esc(pt.themengebiete.name)}</span>`)
  .join('') || '<span style="color:#cbd5e1;">–</span>';
```

- [ ] **Schritt 14: Commit**

```bash
git add admin/products.html
git commit -m "feat: dynamic themengebiete chips for products and bundles

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 3: admin/kunden.html — Interessen + VC-Themen

**Files:**
- Modify: `admin/kunden.html`

**Interfaces:**
- Consumes: `themengebiete`, `kunden_interessen`, `products` mit `product_themen`
- Produces: `kunden_interessen`-Zeilen

**Hintergrund:** kunden.html nutzt ein Master-Detail-Split-Layout. Die Kundenkarte hat Tab 0 (Übersicht) und Tab 1 (Vertrieb). Tab 0 wird durch `renderKarteTab0()` gerendert, das `renderKarteTab0Edit(k)` aufruft wenn ein Kunde geladen ist. Der VC-Tab ist Tab 1, gerendert durch `renderKarteTab1()`. VCs speichern ihre Produkte als kommaseparierten Text in `vc.produkte` (KEIN Junction-Table).

- [ ] **Schritt 1: State-Variablen ergänzen**

Suche den Block mit den bestehenden `let`-Variablen (z.B. `let allKunden`, `let currentKundeId`) und ergänze:

```javascript
let allThemen = [];
let kundeSelectedThemen = [];
let prodThemenMap = {}; // produktname → [{id, name, farbe}]
```

- [ ] **Schritt 2: Themengebiete und Produkt-Themen beim Init laden**

In der `init()`-Funktion nach dem Laden der anderen Daten ergänze:

```javascript
const [{ data: themenData }, { data: allProds }] = await Promise.all([
  sb.from('themengebiete').select('id, name, farbe').eq('aktiv', true).order('sortierung'),
  sb.from('products').select('produkt, product_themen(thema_id, themengebiete(id, name, farbe))')
]);
allThemen = themenData || [];
prodThemenMap = Object.fromEntries(
  (allProds || []).map(p => [
    p.produkt,
    (p.product_themen || []).map(pt => pt.themengebiete).filter(Boolean)
  ])
);
```

- [ ] **Schritt 3: Chip-Funktionen für Kunden-Interessen hinzufügen**

```javascript
function renderKundeInteressenChips() {
  const wrap = document.getElementById('kunde-interessen-chips');
  if (!wrap) return;
  wrap.innerHTML = allThemen.map(t => {
    const active = kundeSelectedThemen.includes(t.id);
    return `<button type="button" onclick="toggleKundeThema('${t.id}')"
      style="padding:4px 12px;border-radius:20px;border:1.5px solid ${active ? t.farbe : '#e2e8f0'};
             background:${active ? t.farbe + '22' : 'white'};color:${active ? t.farbe : '#64748b'};
             font-size:0.78rem;font-weight:700;cursor:pointer;transition:all .15s;">${esc(t.name)}</button>`;
  }).join('');
}

function toggleKundeThema(id) {
  kundeSelectedThemen = kundeSelectedThemen.includes(id)
    ? kundeSelectedThemen.filter(x => x !== id)
    : [...kundeSelectedThemen, id];
  renderKundeInteressenChips();
}
```

- [ ] **Schritt 4: VC-Themen-Badge-Funktion hinzufügen**

```javascript
function vcThemenBadges(vc) {
  const namen = (vc.produkte || '').split(/[,\n]/).map(s => s.trim()).filter(Boolean);
  const seen = new Set();
  const badges = namen
    .flatMap(n => prodThemenMap[n] || [])
    .filter(t => t && !seen.has(t.id) && seen.add(t.id))
    .map(t => `<span style="display:inline-block;background:${t.farbe}22;color:${t.farbe};font-size:0.68rem;font-weight:700;padding:2px 7px;border-radius:20px;margin:1px;">${esc(t.name)}</span>`)
    .join('');
  return badges || '<span style="color:#cbd5e1;">–</span>';
}
```

- [ ] **Schritt 5: Interessen-Block in renderKarteTab0() einfügen**

In `renderKarteTab0()` (die Funktion die den View-Modus rendert, nicht den Edit-Modus): Am Ende der linken Spalte (nach dem Ansprechpartner-Block), direkt vor dem schließenden `</div>` der linken Spalte, füge hinzu:

```html
<div style="margin-top:20px;">
  <div style="font-size:0.72rem;font-weight:700;color:#64748b;text-transform:uppercase;
              letter-spacing:.06em;margin-bottom:8px;">Interessen</div>
  <div id="kunde-interessen-chips" style="display:flex;flex-wrap:wrap;gap:6px;min-height:28px;"></div>
</div>
```

Nach dem `innerHTML`-Setzen der Karte: Rufe `renderKundeInteressenChips()` auf (da das Element dann im DOM ist).

- [ ] **Schritt 6: loadKundeDetail — Interessen laden**

In der Funktion die einen Kunden lädt (dort wo `currentKundeId` gesetzt wird und `renderKarteTab0()` aufgerufen wird), NACH dem renderKarteTab0()-Aufruf:

```javascript
// Interessen laden
const { data: intRows } = await sb.from('kunden_interessen')
  .select('thema_id').eq('kunden_id', currentKundeId);
kundeSelectedThemen = (intRows || []).map(r => r.thema_id);
renderKundeInteressenChips();
```

Bei einem neuen Kunden (newKunde / openNewKunde): `kundeSelectedThemen = []; renderKundeInteressenChips();`

- [ ] **Schritt 7: saveKunde — Interessen speichern**

In `saveKunde()`, nach dem erfolgreichen Upsert des Kunden (wenn `savedId` bekannt):

```javascript
// kunden_interessen: delete-all + re-insert
await sb.from('kunden_interessen').delete().eq('kunden_id', savedId);
if (kundeSelectedThemen.length) {
  await sb.from('kunden_interessen').insert(
    kundeSelectedThemen.map(tid => ({ kunden_id: savedId, thema_id: tid }))
  );
}
```

- [ ] **Schritt 8: VC-Tabelle — Themen-Spalte ergänzen**

In `renderKarteTab1()` (der Vertrieb-Tab): Suche den VC-Tabellen-Header (`<thead>`) und ergänze eine `<th>Themen</th>` Spalte am Ende (vor der Aktionen-Spalte).

Im VC-Zeilen-Template: Ergänze eine `<td>${vcThemenBadges(vc)}</td>` (an derselben Position wie der neue Header).

- [ ] **Schritt 9: Commit**

```bash
git add admin/kunden.html
git commit -m "feat: themengebiete interessen on kunden + vc themen column

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 4: index.html — Dynamischer Topic-Filter

**Files:**
- Modify: `index.html`

**Interfaces:**
- Consumes: `themengebiete` (inkl. `finder_pref_column`), `bundle_themen`

**Hintergrund:** index.html ist sehr groß (4000+ Zeilen). Es gibt zwei Themen-Systeme:
1. `ASSESSMENT_TOPICS` — Array von `{id, label, color, pref}` — pref=Produktfinder-Boolean-Spalten-Name. Wird in der Wizard-Sidebar und dem Step-2-Ergebnis-Topic-Filter verwendet.
2. `BUNDLES` — Array aus DB; bisher mit `b.themen` (jsonb-Slugs); nach Task 1 können die Bundle-Themen aus `bundle_themen` geladen werden.

Die ASSESSMENT_TOPICS werden an einer Stelle statisch definiert (`let ASSESSMENT_TOPICS = [...]` ca. Zeile 3101) und können an einer zweiten Stelle überschrieben werden (Partner-Whitelabel, ca. Zeile 4784: `ASSESSMENT_TOPICS = ALL_TOPICS.filter(...)`).

- [ ] **Schritt 1: Supabase-Client für index.html prüfen**

Suche im `<script>`-Block nach `const sb = supabase.createClient(...)` oder `supabase.createClient(`. Der Supabase-Client ist bereits vorhanden (der Produktfinder lädt ja schon Daten). Notiere den Variablennamen des Supabase-Clients (wahrscheinlich `_sb` oder `sb`). Nutze diesen für die weiteren DB-Abfragen.

- [ ] **Schritt 2: ASSESSMENT_TOPICS dynamisch laden**

Suche die statische Definition von `ASSESSMENT_TOPICS` (ca. Zeile 3101):
```javascript
let ASSESSMENT_TOPICS = [
  { id: 'security', label: 'Cybersecurity', color: '#E53E3E', pref: 'security' },
  ...
];
```

Ersetze diese durch eine leere Initial-Definition:
```javascript
let ASSESSMENT_TOPICS = [];
```

Suche dann die Hauptlade-Funktion von index.html (wahrscheinlich eine async init-Funktion oder ein DOMContentLoaded-Handler der die Produktdaten lädt). Ergänze dort das Laden der Themengebiete und Befüllen von ASSESSMENT_TOPICS:

```javascript
// Themengebiete laden und ASSESSMENT_TOPICS befüllen
const { data: themenData } = await _sb.from('themengebiete')
  .select('id, name, slug, farbe, finder_pref_column')
  .eq('aktiv', true)
  .order('sortierung');
ASSESSMENT_TOPICS = (themenData || [])
  .filter(t => t.finder_pref_column)
  .map(t => ({
    id:    t.slug,
    label: t.name,
    color: t.farbe,
    pref:  t.finder_pref_column
  }));
```

**Wichtig:** Der Partner-Whitelabel-Override (ca. Zeile 4784 `ASSESSMENT_TOPICS = ALL_TOPICS.filter(...)`) nutzt eine lokale `ALL_TOPICS`-Konstante. Diese muss ebenfalls auf die DB-Daten umgestellt werden. Suche den Block und ersetze `ALL_TOPICS` durch `ASSESSMENT_TOPICS` (da ASSESSMENT_TOPICS jetzt schon die volle Liste enthält):

```javascript
// ALT:
// const ALL_TOPICS = [...];
// ASSESSMENT_TOPICS = ALL_TOPICS.filter(t => config.themen.includes(t.pref));
// NEU:
ASSESSMENT_TOPICS = ASSESSMENT_TOPICS.filter(t => config.themen.includes(t.pref));
```

- [ ] **Schritt 3: BUNDLES — bundle_themen laden**

Suche wo `BUNDLES` geladen wird (ca. Zeile 4869):
```javascript
const { data: bundleData } = await _sb.from('bundles').select('*').eq('aktiv', true);
BUNDLES = bundleData || [];
```

Erweitere den Select:
```javascript
const { data: bundleData } = await _sb.from('bundles')
  .select('*, bundle_themen(thema_id)')
  .eq('aktiv', true);
BUNDLES = (bundleData || []).map(b => ({
  ...b,
  thema_ids: (b.bundle_themen || []).map(bt => bt.thema_id)
}));
```

- [ ] **Schritt 4: Bundle-Filter — b.themen → b.thema_ids**

Suche die Zeile (ca. 3506):
```javascript
if (!(b.themen || []).some(t => wizSelectedTopics.has(t))) return false;
```

Ersetze durch:
```javascript
if (!(b.thema_ids || []).some(id => {
  const t = ASSESSMENT_TOPICS.find(at => at.id === (ASSESSMENT_TOPICS.find(at2 => at2.id === id || /* slug lookup */ false)?.id));
  // Direkte ID-Prüfung: wizSelectedTopics enthält slug-ids, thema_ids sind UUIDs
  // Wir brauchen eine Mapping-Map: slug → uuid
  return false; // wird in Schritt 5 korrekt
})) return false;
```

**Hinweis:** Die `wizSelectedTopics` ist ein Set von ASSESSMENT_TOPICS-IDs (Slugs wie `'ti'`, `'security'`). Die `b.thema_ids` sind UUIDs aus der `bundle_themen`-Tabelle. Ein direkter Vergleich ist nicht möglich. Deshalb baue in Schritt 5 eine Mapping-Map.

- [ ] **Schritt 5: Slug-zu-UUID-Map bauen und Bundle-Filter korrekt stellen**

Nach dem Laden der Themengebiete (Schritt 2), baue eine Map:

```javascript
// Map: slug → thema uuid (für Bundle-Filter in wizSelectedTopics-Vergleich)
const themaSlugToId = Object.fromEntries((themenData || []).map(t => [t.slug, t.id]));
```

Ersetze den Bundle-Filter (Zeile ca. 3506) jetzt korrekt:

```javascript
// wizSelectedTopics enthält slugs; b.thema_ids enthält UUIDs → über themaSlugToId mappen
const selectedIds = new Set([...wizSelectedTopics].map(slug => themaSlugToId[slug]).filter(Boolean));
if (selectedIds.size > 0 && !(b.thema_ids || []).some(id => selectedIds.has(id))) return false;
```

(Der alte Code hatte `if (wizSelectedTopics.size > 0 && ...)` — passe die Größenprüfung entsprechend an.)

- [ ] **Schritt 6: Commit**

```bash
git add index.html
git commit -m "feat: dynamic ASSESSMENT_TOPICS and bundle themen filter in Produktfinder

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 5: loesung-public.html — Themen-Badges

**Files:**
- Modify: `loesung-public.html`

**Interfaces:**
- Consumes: `product_themen`, `themengebiete` (via nested select)

**Hintergrund:** loesung-public.html lädt ein Produkt via `?id=` Parameter und rendert eine Hero-Sektion. Es gibt bereits ein hardcodiertes `THEMEN`-Objekt das Boolean-Spalten auf products mapped. Die Themen-Tags werden als `hero-tag`-Spans in `div.hero-tags` gerendert.

Aktuelle Logik (ersetzen):
```javascript
// ALT — Boolean-Spalten:
const themenTags = Object.entries(THEMEN)
  .filter(([k]) => p[k])
  .map(([, t]) => `<span class="hero-tag" style="background:${t.color}18;color:${t.color};border:1px solid ${t.color}33">${t.label}</span>`)
  .join('');
```

- [ ] **Schritt 1: Produkt-Select auf product_themen-Join erweitern**

Suche die Zeile (ca. Zeile 170):
```javascript
const { data: product, error } = await sb.from('products')
  .select('*')
  .eq('id', productId)
  .eq('published', true)
  .single();
```

Ersetze durch:
```javascript
const { data: product, error } = await sb.from('products')
  .select('*, product_themen(thema_id, themengebiete(name, farbe))')
  .eq('id', productId)
  .eq('published', true)
  .single();
```

- [ ] **Schritt 2: themenTags-Berechnung ersetzen**

Suche in der `renderPage(p)`-Funktion die `themenTags`-Zeile (nutzt `Object.entries(THEMEN)...`). Ersetze sie durch:

```javascript
const themenTags = (p.product_themen || [])
  .map(pt => `<span class="hero-tag" style="background:${pt.themengebiete.farbe}18;color:${pt.themengebiete.farbe};border:1px solid ${pt.themengebiete.farbe}33">${esc(pt.themengebiete.name)}</span>`)
  .join('');
```

- [ ] **Schritt 3: THEMEN-Konstante löschen**

Suche den Block:
```javascript
const THEMEN = {
  ti:               { label: 'Telematik Infrastruktur', color: '#3C4A7C' },
  security:         { label: 'Cybersecurity',           color: '#E53E3E' },
  ...
};
```

Lösche diesen Block vollständig (er wird nicht mehr benötigt).

- [ ] **Schritt 4: Commit**

```bash
git add loesung-public.html
git commit -m "feat: themengebiete badges from DB on loesung-public

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Self-Review

**Spec-Coverage:**
- ✅ Task 1: SQL-Migration (Junction-Tables, finder_pref_column, Bundle-Migration, RLS)
- ✅ Task 2: products.html — Produkt-Chips, Bundle-Chips, Dual-Write, Tabellen-Badges
- ✅ Task 3: kunden.html — Interessen-Chips, VC-Themen-Badges (via prodThemenMap)
- ✅ Task 4: index.html — ASSESSMENT_TOPICS dynamisch, Bundle-Filter via bundle_themen
- ✅ Task 5: loesung-public.html — Badges aus product_themen

**Typ-Konsistenz:**
- `prodSelectedThemen` / `bundleSelectedThemen` / `kundeSelectedThemen` — alle `string[]` (UUIDs)
- `allThemen` — `{id, name, slug?, farbe, finder_pref_column?}[]` (Tasks 2+3)
- `thema_ids` auf Bundles — `string[]` (UUIDs) aus `bundle_themen.thema_id`
- `themaSlugToId` — `{[slug: string]: string}` (Task 4)
- `prodThemenMap` — `{[produktname: string]: {id, name, farbe}[]}` (Task 3)

**Globale Constraints gecheckt:**
- Kein API-Key in Files — ✅ anon key ist bereits in den Dateien, kein Resend key
- `esc()` überall verwendet — ✅
- Kein Build-Step — ✅
- Alte `bundles.themen`-Spalte nicht gedroppt — ✅
- Dual-Write für products (product_themen + Boolean) — ✅
