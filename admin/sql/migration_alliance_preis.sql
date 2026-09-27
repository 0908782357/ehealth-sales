-- Migration: Jahresbeitrag zu alliance_tiers hinzufügen
-- Ausführen in: Supabase SQL Editor

ALTER TABLE alliance_tiers
  ADD COLUMN IF NOT EXISTS preis integer DEFAULT NULL;

-- Startwerte (Basis = Standard, Premium, Strategisch)
UPDATE alliance_tiers SET preis = 690  WHERE slug = 'standard';
UPDATE alliance_tiers SET preis = 1990 WHERE slug = 'premium';
UPDATE alliance_tiers SET preis = 5900 WHERE slug = 'strategisch';
