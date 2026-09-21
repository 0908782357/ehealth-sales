-- Migration: Alliance-Partner-Seite
-- Ausführen im Supabase SQL Editor

-- Ort-Feld für die Alliance-Partnerseite (alliance_partner-Spalte wird nicht mehr benötigt)
ALTER TABLE partners ADD COLUMN IF NOT EXISTS ort text;

-- Alte Spalte aufräumen falls bereits angelegt
ALTER TABLE partners DROP COLUMN IF EXISTS alliance_partner;

-- Funktion neu erstellen: alle Partner, Tier aus user_roles
-- Mapping: premium→premium, strategisch→partner, standard/null→basis
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
    p.name       AS firma,
    p.logo_url,
    p.website,
    p.ort,
    CASE ur.partner_tier
      WHEN 'premium'     THEN 'premium'
      WHEN 'strategisch' THEN 'partner'
      ELSE                    'basis'
    END AS alliance_partner
  FROM partners p
  LEFT JOIN user_roles ur ON ur.user_id = p.user_id
  ORDER BY
    CASE ur.partner_tier
      WHEN 'premium'     THEN 1
      WHEN 'strategisch' THEN 2
      ELSE 3
    END,
    p.name ASC;
$$;

GRANT EXECUTE ON FUNCTION get_alliance_partners() TO anon;
