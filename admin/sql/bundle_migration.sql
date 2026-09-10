-- ============================================================
-- Bundle-Produkte System Migration
-- Im Supabase SQL Editor ausführen (einmalig)
-- ============================================================

-- ============================================================
-- 1. bundle_items
--    Detaillierte Zusammensetzung eines Bundles:
--    - typ='included' → im Pauschalpreis enthalten
--    - typ='addon'    → optional buchbar (nicht enthalten)
--    - extendable=true → bei 'included': zusätzliche Menge buchbar
-- ============================================================
CREATE TABLE IF NOT EXISTS bundle_items (
  id                  uuid         DEFAULT gen_random_uuid() PRIMARY KEY,
  bundle_id           uuid         NOT NULL REFERENCES bundles(id) ON DELETE CASCADE,
  product_id          uuid         NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
  typ                 text         NOT NULL DEFAULT 'included'
                                   CHECK (typ IN ('included', 'addon')),
  extendable          boolean      NOT NULL DEFAULT false,
  included_quantity   integer      NOT NULL DEFAULT 1,
  extra_preis         numeric(10,2),
  extra_preis_einheit text         DEFAULT 'pro Monat',
  sort_order          integer      DEFAULT 0,
  created_at          timestamptz  DEFAULT now()
);

-- ============================================================
-- 2. bundle_berufsgruppen
--    M:N – welche Berufsgruppen können ein Bundle sehen?
--    Leere Tabelle (keine Zeilen) = für alle sichtbar.
-- ============================================================
CREATE TABLE IF NOT EXISTS bundle_berufsgruppen (
  bundle_id           uuid    NOT NULL REFERENCES bundles(id) ON DELETE CASCADE,
  berufsgruppe_nr     integer NOT NULL,
  PRIMARY KEY (bundle_id, berufsgruppe_nr)
);

-- ============================================================
-- 3. order_items
--    Extras (erweiterbare / optionale Produkte), die ein Kunde
--    zusammen mit einem Bundle bestellt hat.
-- ============================================================
CREATE TABLE IF NOT EXISTS order_items (
  id                  uuid         DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id            uuid         NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  bundle_item_id      uuid         REFERENCES bundle_items(id) ON DELETE SET NULL,
  product_id          uuid         REFERENCES products(id) ON DELETE SET NULL,
  product_name        text,        -- Snapshot: Name zum Bestellzeitpunkt
  quantity            integer      NOT NULL DEFAULT 1,
  preis               numeric(10,2),
  preis_einheit       text,
  created_at          timestamptz  DEFAULT now()
);

-- ============================================================
-- 4. shop_items: bundle_id Spalte hinzufügen
--    Ein Shop-Eintrag kann jetzt wahlweise auf ein Produkt
--    ODER auf ein Bundle verweisen.
-- ============================================================
ALTER TABLE shop_items
  ADD COLUMN IF NOT EXISTS bundle_id uuid REFERENCES bundles(id) ON DELETE SET NULL;

-- ============================================================
-- 5. Performance-Indexes
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_bundle_items_bundle_id  ON bundle_items(bundle_id);
CREATE INDEX IF NOT EXISTS idx_bundle_items_product_id ON bundle_items(product_id);
CREATE INDEX IF NOT EXISTS idx_bundle_bg_bundle_id     ON bundle_berufsgruppen(bundle_id);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id    ON order_items(order_id);

-- ============================================================
-- 6. Row Level Security
--    Hinweis: Absicherung nach deinem RLS-Schema anpassen.
--    Diese Policies erlauben anon-Zugriff (wie bei orders etc.)
-- ============================================================

ALTER TABLE bundle_items         ENABLE ROW LEVEL SECURITY;
ALTER TABLE bundle_berufsgruppen ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items          ENABLE ROW LEVEL SECURITY;

-- bundle_items
CREATE POLICY "bundle_items_select" ON bundle_items FOR SELECT USING (true);
CREATE POLICY "bundle_items_insert" ON bundle_items FOR INSERT WITH CHECK (true);
CREATE POLICY "bundle_items_update" ON bundle_items FOR UPDATE USING (true);
CREATE POLICY "bundle_items_delete" ON bundle_items FOR DELETE USING (true);

-- bundle_berufsgruppen
CREATE POLICY "bbg_select" ON bundle_berufsgruppen FOR SELECT USING (true);
CREATE POLICY "bbg_insert" ON bundle_berufsgruppen FOR INSERT WITH CHECK (true);
CREATE POLICY "bbg_delete" ON bundle_berufsgruppen FOR DELETE USING (true);

-- order_items
CREATE POLICY "order_items_select" ON order_items FOR SELECT USING (true);
CREATE POLICY "order_items_insert" ON order_items FOR INSERT WITH CHECK (true);
CREATE POLICY "order_items_delete" ON order_items FOR DELETE USING (true);
