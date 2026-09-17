-- Migration: EK Staffelpreise für Produkte + Bundles + EK-Preis auf Bundle-Items
-- Ausführen in Supabase SQL Editor

-- Produkte: EK Staffelpreise
ALTER TABLE products
  ADD COLUMN IF NOT EXISTS einkaufspreis_staffel jsonb;

COMMENT ON COLUMN products.einkaufspreis_staffel
  IS 'Mengenabhängige EK-Staffelpreise, z.B. [{"ab":1,"label":"1–4 Instanzen","ek":80},{"ab":5,"label":"5–9 Instanzen","ek":320}] — nur für Admins sichtbar';

-- Bundle-Items: gespeicherter EK-Preis pro Position
ALTER TABLE bundle_items
  ADD COLUMN IF NOT EXISTS ek_preis numeric;

COMMENT ON COLUMN bundle_items.ek_preis
  IS 'Zugeordneter EK-Preis für dieses Bundle-Item (aus Staffel oder Pauschal-EK) — für Margenkalkulation';

-- Bundles: EK auf Bundle-Ebene (optionaler Gesamt-EK)
ALTER TABLE bundles
  ADD COLUMN IF NOT EXISTS einkaufspreis_flat numeric;

ALTER TABLE bundles
  ADD COLUMN IF NOT EXISTS einkaufspreis_staffel jsonb;

COMMENT ON COLUMN bundles.einkaufspreis_flat
  IS 'Optionaler pauschaler EK für das gesamte Bundle (z.B. ausgehandelter Listenpreis) — nur für Admins sichtbar';

COMMENT ON COLUMN bundles.einkaufspreis_staffel
  IS 'Mengenabhängige EK-Staffelpreise auf Bundle-Ebene, z.B. [{"ab":1,"label":"1 Standort","ek":500}] — nur für Admins sichtbar';
