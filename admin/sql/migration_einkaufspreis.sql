-- Migration: Einkaufspreis für Produkte
-- Ausführen in Supabase SQL Editor

ALTER TABLE products
  ADD COLUMN IF NOT EXISTS einkaufspreis_flat numeric;

COMMENT ON COLUMN products.einkaufspreis_flat
  IS 'Interner Einkaufspreis (EK) netto — nur für Admins sichtbar, für Margenkalkulation';
