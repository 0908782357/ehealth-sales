-- Migration: EK Staffelpreise für Produkte + EK-Preis auf Bundle-Items
-- Ausführen in Supabase SQL Editor

ALTER TABLE products
  ADD COLUMN IF NOT EXISTS einkaufspreis_staffel jsonb;

COMMENT ON COLUMN products.einkaufspreis_staffel
  IS 'Mengenabhängige EK-Staffelpreise, z.B. [{"ab":1,"label":"1–4 Instanzen","ek":80},{"ab":5,"label":"5–9 Instanzen","ek":320}] — nur für Admins sichtbar';

ALTER TABLE bundle_items
  ADD COLUMN IF NOT EXISTS ek_preis numeric;

COMMENT ON COLUMN bundle_items.ek_preis
  IS 'Zugeordneter EK-Preis für dieses Bundle-Item (aus Staffel oder Pauschal-EK) — für Margenkalkulation';
