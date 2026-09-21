-- Migration: Alliance-Partner-Seite
-- Ausführen im Supabase SQL Editor

-- Ort-Feld für die Alliance-Partnerseite (alliance_partner-Spalte wird nicht mehr benötigt)
ALTER TABLE partners ADD COLUMN IF NOT EXISTS ort text;

-- Alte Spalte aufräumen falls bereits angelegt
ALTER TABLE partners DROP COLUMN IF EXISTS alliance_partner;

-- Funktion neu erstellen: alle Partner, Tier aus user_roles
-- SET search_path ist wichtig für SECURITY DEFINER Funktionen in Supabase
DROP FUNCTION IF EXISTS get_alliance_partners();

CREATE OR REPLACE FUNCTION get_alliance_partners()
RETURNS TABLE(
  firma            text,
  logo_url         text,
  website          text,
  ort              text,
  alliance_partner text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT
    p.name::text       AS firma,
    p.logo_url::text,
    p.website::text,
    p.ort::text,
    (CASE ur.partner_tier
      WHEN 'premium'     THEN 'premium'
      WHEN 'strategisch' THEN 'partner'
      ELSE                    'basis'
    END)::text AS alliance_partner
  FROM partners p
  LEFT JOIN user_roles ur ON ur.user_id = p.user_id
  ORDER BY
    CASE ur.partner_tier
      WHEN 'premium'     THEN 1
      WHEN 'strategisch' THEN 2
      ELSE 3
    END,
    p.name ASC;
END;
$$;

GRANT EXECUTE ON FUNCTION get_alliance_partners() TO anon;

-- -------------------------------------------------------
-- DIAGNOSE: Diese Abfragen im SQL Editor prüfen
-- -------------------------------------------------------
-- 1. Gibt es Partner in der Tabelle?
--    SELECT id, name, logo_url, ort, user_id FROM partners;
--
-- 2. Funktioniert die Funktion direkt?
--    SELECT * FROM get_alliance_partners();
--
-- 3. Hat anon Zugriff auf die Funktion?
--    SELECT has_function_privilege('anon', 'get_alliance_partners()', 'execute');
-- -------------------------------------------------------
