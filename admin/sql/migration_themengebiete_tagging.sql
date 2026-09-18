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
