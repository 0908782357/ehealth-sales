# Themengebiete-Tagging — System-weite Erweiterung

## Ziel

Die `themengebiete`-Tabelle (eingeführt mit dem Events-System) wird zur einzigen Quelle für Topic-Tags im gesamten Portal. Produkte, Bundles und Kunden erhalten Junction-Tabellen für ihre Themen-Zuordnungen. Der Produktfinder (index.html) und Lösungsseiten laden ihre Filter und Badges dynamisch aus der DB statt aus hartcodierten Arrays.

## Architektur

- **Datenmodell:** Junction-Tabellen analog zu `event_themen` — normalisiert, Referenzintegrität über FKs
- **UI-Pattern:** identisch zu events.html — Themen-Chips als Multiselect, delete-all + re-insert beim Speichern, DB-Load on init
- **Kunden-VC-Themen:** werden beim Rendern aus den zugeordneten Produkten berechnet (kein eigenes Storage)
- **Alte `bundles.themen`-jsonb-Spalte:** bleibt erhalten (kein DROP), wird aber nicht mehr beschrieben

## Tech Stack

- Supabase JS SDK v2 (CDN, kein Build-Step)
- Static HTML/JS SPA
- Supabase project: `focysklymhmcfwgxdtuk`

## Spec

Keine separate Spec-Datei — dieses Dokument ist die Spec.

## Global Constraints

- Supabase anon key darf in HTML-Dateien stehen (öffentlich)
- Resend API key darf NIEMALS in git-tracked files stehen
- Kein Build-Step, kein npm — reines HTML/JS mit CDN
- Bestehende RLS-Policies nicht brechen
- `esc()`-Funktion für alle user-generierten Inhalte verwenden (XSS-Schutz)
- Chip-Multiselect-Pattern aus events.html übernehmen (delete-all + re-insert, `let selectedThemen = []`)
- Alte `bundles.themen`-jsonb-Spalte: weiterhin vorhanden, nicht mehr beschreiben

---

## Task 1: SQL-Migration

**Datei:** `admin/sql/migration_themengebiete_tagging.sql` (neu erstellen)

### Schritt 1 — Fehlende Themengebiete ergänzen

```sql
INSERT INTO themengebiete (name, slug, farbe, sortierung) VALUES
  ('Modern Work',             'modernwork', '#6DC52D', 90),
  ('Prozess Digitalisierung', 'prozess',    '#ED8936', 100)
ON CONFLICT (slug) DO NOTHING;
```

### Schritt 2 — Junction-Tabellen

```sql
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
```

### Schritt 3 — Bundle-Migration (alte jsonb → neue Junction-Tabelle)

Alte Slugs in `bundles.themen` (jsonb) weichen von neuen Slugs ab. Mapping:

| Alt (jsonb-Wert) | Neu (themengebiete.slug) |
|---|---|
| `ti` | `ti` |
| `security` | `security` |
| `telemedizin` | `telemedizin` |
| `it_infrastruktur` | `it` |
| `modern_work` | `modernwork` |
| `prozess_digital` | `prozess` |

```sql
INSERT INTO bundle_themen (bundle_id, thema_id)
SELECT b.id, t.id
FROM bundles b
CROSS JOIN LATERAL jsonb_array_elements_text(COALESCE(b.themen, '[]'::jsonb)) AS slug_raw
JOIN (VALUES
  ('ti',              'ti'),
  ('security',        'security'),
  ('telemedizin',     'telemedizin'),
  ('it_infrastruktur','it'),
  ('modern_work',     'modernwork'),
  ('prozess_digital', 'prozess')
) AS mapping(old_slug, new_slug) ON mapping.old_slug = slug_raw
JOIN themengebiete t ON t.slug = mapping.new_slug
ON CONFLICT DO NOTHING;
```

### Schritt 4 — Indizes

```sql
CREATE INDEX IF NOT EXISTS idx_product_themen_product_id ON product_themen(product_id);
CREATE INDEX IF NOT EXISTS idx_product_themen_thema_id   ON product_themen(thema_id);
CREATE INDEX IF NOT EXISTS idx_bundle_themen_bundle_id   ON bundle_themen(bundle_id);
CREATE INDEX IF NOT EXISTS idx_bundle_themen_thema_id    ON bundle_themen(thema_id);
CREATE INDEX IF NOT EXISTS idx_kunden_interessen_kunden  ON kunden_interessen(kunden_id);
```

### Schritt 5 — RLS

```sql
ALTER TABLE product_themen   ENABLE ROW LEVEL SECURITY;
ALTER TABLE bundle_themen    ENABLE ROW LEVEL SECURITY;
ALTER TABLE kunden_interessen ENABLE ROW LEVEL SECURITY;

-- product_themen: alle lesen, Partner/Admin schreiben
CREATE POLICY "product_themen_read"
  ON product_themen FOR SELECT USING (true);

CREATE POLICY "product_themen_write"
  ON product_themen FOR ALL TO authenticated
  USING (
    EXISTS (SELECT 1 FROM products p WHERE p.id = product_themen.product_id
      AND (p.partner_id IN (SELECT id FROM partners WHERE user_id = auth.uid())
           OR EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')))
  );

-- bundle_themen: alle lesen, Admin schreiben
CREATE POLICY "bundle_themen_read"
  ON bundle_themen FOR SELECT USING (true);

CREATE POLICY "bundle_themen_write"
  ON bundle_themen FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin'));

-- kunden_interessen: Admin liest/schreibt alles; Partner nur eigene Kunden
CREATE POLICY "kunden_interessen_read"
  ON kunden_interessen FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin'));

CREATE POLICY "kunden_interessen_write"
  ON kunden_interessen FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin'));
```

---

## Task 2: admin/products.html — Produkt-Themen

**Datei:** `admin/products.html` (modifizieren)

### Interfaces
- Konsumiert: `themengebiete` (alle aktiven), `product_themen` (für geladene Produkte)
- Produziert: `product_themen`-Zeilen via delete-all + re-insert

### State-Variablen (neu)
```javascript
let allThemen = [];          // aus DB geladen, einmalig beim Init
let prodSelectedThemen = []; // aktive Auswahl im Produkt-Modal
let bundleSelectedThemen = []; // aktive Auswahl im Bundle-Modal
```

### DB-Load beim Init
```javascript
const { data: themenData } = await sb.from('themengebiete')
  .select('id, name, slug, farbe')
  .eq('aktiv', true)
  .order('sortierung');
allThemen = themenData || [];
```

### Produkt-Modal — Themen-Block (in Schritt 2, nach Berufsgruppen)
```html
<div class="form-group" style="grid-column:1/-1;">
  <label>Themengebiete</label>
  <div id="prod-themen-chips" style="display:flex;flex-wrap:wrap;gap:6px;padding:8px 0;min-height:36px;"></div>
</div>
```

```javascript
function renderProdThemenChips() {
  const wrap = document.getElementById('prod-themen-chips');
  wrap.innerHTML = allThemen.map(t => {
    const active = prodSelectedThemen.includes(t.id);
    return `<button type="button" onclick="toggleProdThema('${t.id}')"
      style="padding:4px 12px;border-radius:20px;border:1.5px solid ${active ? t.farbe : '#e2e8f0'};
             background:${active ? t.farbe + '22' : 'white'};color:${active ? t.farbe : '#64748b'};
             font-size:0.78rem;font-weight:700;cursor:pointer;">${esc(t.name)}</button>`;
  }).join('');
}

function toggleProdThema(id) {
  prodSelectedThemen = prodSelectedThemen.includes(id)
    ? prodSelectedThemen.filter(x => x !== id)
    : [...prodSelectedThemen, id];
  renderProdThemenChips();
}
```

### Beim Öffnen des Produkt-Modals (openProductEdit / newProduct)
```javascript
// Themen laden
const { data: ptRows } = await sb.from('product_themen')
  .select('thema_id').eq('product_id', productId);
prodSelectedThemen = (ptRows || []).map(r => r.thema_id);
renderProdThemenChips();
// Bei neuem Produkt: prodSelectedThemen = []; renderProdThemenChips();
```

### Beim Speichern (saveProduct — nach dem upsert)
```javascript
// Themen: delete-all + re-insert
await sb.from('product_themen').delete().eq('product_id', savedId);
if (prodSelectedThemen.length) {
  await sb.from('product_themen').insert(
    prodSelectedThemen.map(tid => ({ product_id: savedId, thema_id: tid }))
  );
}
```

### Produkt-Tabelle — Themen-Badge-Spalte
Neue `<th>Themen</th>` in der Tabelle. Beim Laden der Produkte werden Themen per JOIN geladen:
```javascript
const { data: products } = await sb.from('products')
  .select('*, product_themen(thema_id, themengebiete(name, farbe))');
```
Darstellung als farbige Chips in der Zeile.

### Bundle-Modal — Themen ersetzen
Die 6 hardcodierten `<label class="bg-check">...<input name="b-thema">` Checkboxen werden entfernt und durch denselben Chip-Block ersetzt (mit `bundleSelectedThemen` und `renderBundleThemenChips()`).

Beim Speichern eines Bundles:
```javascript
await sb.from('bundle_themen').delete().eq('bundle_id', savedBundleId);
if (bundleSelectedThemen.length) {
  await sb.from('bundle_themen').insert(
    bundleSelectedThemen.map(tid => ({ bundle_id: savedBundleId, thema_id: tid }))
  );
}
```

Bundle-Tabelle: `BUNDLE_THEMEN_CFG` wird durch DB-Load aus `bundle_themen` ersetzt.

---

## Task 3: admin/kunden.html — Interessen + VC-Themen

**Datei:** `admin/kunden.html` (modifizieren)

### Interfaces
- Konsumiert: `themengebiete`, `kunden_interessen`, `product_themen`
- Produziert: `kunden_interessen`-Zeilen

### State-Variablen (neu)
```javascript
let allThemen = [];            // einmalig beim Init
let kundeSelectedThemen = [];  // manuelle Interessen-Tags für aktiven Kunden
```

### DB-Load beim Init
```javascript
const { data: themenData } = await sb.from('themengebiete')
  .select('id, name, farbe').eq('aktiv', true).order('sortierung');
allThemen = themenData || [];
```

### Tab 1 — Interessen-Block (unter Ansprechpartner)
```html
<div style="margin-top:20px;">
  <div style="font-size:0.72rem;font-weight:700;color:#64748b;text-transform:uppercase;
              letter-spacing:.06em;margin-bottom:8px;">Interessen</div>
  <div id="kunde-interessen-chips" style="display:flex;flex-wrap:wrap;gap:6px;"></div>
</div>
```

Chip-Render-Funktion analog zu events.html (`renderKundeThemenChips`, `toggleKundeThema`).

### Beim Laden eines Kunden (loadKundeDetail)
```javascript
const { data: intRows } = await sb.from('kunden_interessen')
  .select('thema_id').eq('kunden_id', kundeId);
kundeSelectedThemen = (intRows || []).map(r => r.thema_id);
renderKundeThemenChips();
```

### Beim Speichern (saveKunde)
```javascript
await sb.from('kunden_interessen').delete().eq('kunden_id', savedId);
if (kundeSelectedThemen.length) {
  await sb.from('kunden_interessen').insert(
    kundeSelectedThemen.map(tid => ({ kunden_id: savedId, thema_id: tid }))
  );
}
```

### Tab 2 — VC-Tabelle: Themen-Spalte
VCs speichern Produkte als kommaseparierten Text (`vc.produkte = "Produkt A, Produkt B"`), nicht als Product-IDs. Themen werden daher im Frontend über den Produktnamen aufgelöst.

Beim Init werden alle Produkte mit ihren Themen geladen:
```javascript
const { data: allProds } = await sb.from('products')
  .select('id, produkt, product_themen(thema_id, themengebiete(id, name, farbe))');
// allProds als Map: produkt-Name → [{id, name, farbe}, ...]
const prodThemenMap = Object.fromEntries(
  (allProds || []).map(p => [p.produkt, (p.product_themen || []).map(pt => pt.themengebiete)])
);
```

Beim Rendern einer VC-Zeile:
```javascript
function vcThemenBadges(vc) {
  const namen = (vc.produkte || '').split(/[,\n]/).map(s => s.trim()).filter(Boolean);
  const seen = new Set();
  return namen.flatMap(n => prodThemenMap[n] || [])
    .filter(t => t && !seen.has(t.id) && seen.add(t.id))
    .map(t => `<span style="display:inline-block;background:${t.farbe}22;color:${t.farbe};
                             font-size:0.68rem;font-weight:700;padding:2px 7px;border-radius:20px;
                             margin:1px;">${esc(t.name)}</span>`)
    .join('') || '<span style="color:var(--gray-300);">–</span>';
}
```

Neue `<th>Themen</th>` im VC-Header; kein eigenes DB-Feld nötig.

---

## Task 4: index.html — Dynamischer Topic-Filter

**Datei:** `index.html` (modifizieren)

### Interfaces
- Konsumiert: `themengebiete`, `product_themen`, `bundle_themen`

### Topic-Filter-Leiste (topic-filter-strip)
Aktuell: Hardcodierte Pills mit fixen Farben.
Neu: Pills werden per JS aus `themengebiete` generiert. Die `accent-color` eines Pills kommt aus `themengebiete.farbe`.

```javascript
// Beim Laden: Themengebiete holen
const { data: themenData } = await sb.from('themengebiete')
  .select('id, name, slug, farbe').eq('aktiv', true).order('sortierung');

// Topic-Filter-Strip rendern
const strip = document.getElementById('topic-filter-strip');
strip.innerHTML = themenData.map(t =>
  `<button class="topic-filter-pill" data-slug="${t.slug}" data-thema-id="${t.id}"
     style="--pill-color:${t.farbe}" onclick="filterByThema('${t.id}')">
     <span class="topic-dot" style="background:${t.farbe}"></span>${esc(t.name)}
   </button>`
).join('');
```

### Bundle-Filter (b-thema Checkboxen)
Die 6 hardcodierten `<label class="bg-check"><input name="b-thema">` werden ersetzt durch dynamisch generierte Checkboxen aus der DB. `BUNDLE_THEMEN_CFG` wird entfernt — stattdessen wird `allThemen` (aus DB) für die Darstellung verwendet.

Filter-Logik: `b.thema_ids` (Array der zugeordneten thema_ids, beim Bundle-Load per JOIN mitgeladen) statt `b.themen`.

### Produkt-Tabelle
Beim Laden der Produkte: `products.select('*, product_themen(thema_id)')` — Themen-Badges in der Produktzeile.

---

## Task 5: loesung-public.html — Themen-Badges

**Datei:** `loesung-public.html` (modifizieren)

### Interfaces
- Konsumiert: `product_themen`, `themengebiete`

### Themen-Badges im Produktkopf
Beim Laden des Produkts (via `?id=`):
```javascript
const { data: prod } = await sb.from('products')
  .select('*, product_themen(thema_id, themengebiete(name, farbe))')
  .eq('id', productId).single();

const badges = (prod.product_themen || []).map(pt =>
  `<span style="display:inline-block;padding:3px 12px;border-radius:20px;
                background:${pt.themengebiete.farbe}22;color:${pt.themengebiete.farbe};
                font-size:0.75rem;font-weight:700;">${esc(pt.themengebiete.name)}</span>`
).join('');
```

Einfügen direkt unter dem Produkt-Titel im Hero-Bereich.

---

## Nicht im Scope

- E-Mail-Benachrichtigungen
- Suche/Filter in kunden.html nach Themen
- Alliance-Website Events-Seite (bereits fertig)
- loesung.html (Admin-Seite, öffentliche Produktseite ist loesung-public.html)
