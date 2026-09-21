-- Migration: Alliance-Partner-Felder + öffentliche RPC-Funktion
-- Ausführen im Supabase SQL Editor

ALTER TABLE partners ADD COLUMN IF NOT EXISTS alliance_partner text;
ALTER TABLE partners ADD COLUMN IF NOT EXISTS ort text;

-- Öffentliche Funktion für die Alliance-Partnerseite
-- Gibt nur Partner zurück, bei denen alliance_partner gesetzt ist
-- Sortierung: Premium > Partner > Basis, dann alphabetisch

DROP FUNCTION IF EXISTS get_alliance_partners();

CREATE OR REPLACE FUNCTION get_alliance_partners()
RETURNS TABLE(
  firma            text,
  logo_url         text,
  website          text,
  ort              text,
  alliance_partner text
)
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT
    name             AS firma,
    logo_url,
    website,
    ort,
    alliance_partner
  FROM partners
  WHERE alliance_partner IS NOT NULL
  ORDER BY
    CASE alliance_partner
      WHEN 'premium' THEN 1
      WHEN 'partner' THEN 2
      WHEN 'basis'   THEN 3
      ELSE 4
    END,
    name ASC;
$$;

GRANT EXECUTE ON FUNCTION get_alliance_partners() TO anon;
