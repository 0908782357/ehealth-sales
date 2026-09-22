-- ============================================================
-- Migration: Alliance CMS – Stufenkonfiguration
-- Tabellen: alliance_tiers + alliance_features
-- ============================================================

-- 1. Tabellen anlegen
CREATE TABLE IF NOT EXISTS alliance_tiers (
  slug        text PRIMARY KEY,
  name        text        NOT NULL,
  featured    boolean     NOT NULL DEFAULT false,
  sort_order  int         NOT NULL DEFAULT 0,
  features    jsonb       NOT NULL DEFAULT '[]'::jsonb
);

CREATE TABLE IF NOT EXISTS alliance_features (
  id          serial      PRIMARY KEY,
  label       text        NOT NULL,
  standard    boolean     NOT NULL DEFAULT false,
  premium     boolean     NOT NULL DEFAULT false,
  strategisch boolean     NOT NULL DEFAULT false,
  sort_order  int         NOT NULL DEFAULT 0
);

-- 2. RLS aktivieren
ALTER TABLE alliance_tiers    ENABLE ROW LEVEL SECURITY;
ALTER TABLE alliance_features ENABLE ROW LEVEL SECURITY;

-- 3. RLS-Policies (anon = öffentliche Alliance-Seite; authenticated = Admin-Portal)
DROP POLICY IF EXISTS "public_read_alliance_tiers"    ON alliance_tiers;
DROP POLICY IF EXISTS "admin_all_alliance_tiers"      ON alliance_tiers;
DROP POLICY IF EXISTS "public_read_alliance_features" ON alliance_features;
DROP POLICY IF EXISTS "admin_all_alliance_features"   ON alliance_features;

CREATE POLICY "public_read_alliance_tiers"
  ON alliance_tiers FOR SELECT TO anon USING (true);

CREATE POLICY "admin_all_alliance_tiers"
  ON alliance_tiers FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "public_read_alliance_features"
  ON alliance_features FOR SELECT TO anon USING (true);

CREATE POLICY "admin_all_alliance_features"
  ON alliance_features FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- 4. Seed-Daten (nur wenn noch keine Daten vorhanden)
INSERT INTO alliance_tiers (slug, name, featured, sort_order, features)
VALUES
  ('standard',    'Standard',    false, 1,
    '["Eintrag im Partnerverzeichnis","Newsletter & Marktinformationen","Teilnahme an offenen Events"]'::jsonb),
  ('premium',     'Premium',     true,  2,
    '["Alles aus Standard","Logo auf der Startseite","Mitarbeit in Arbeitsgruppen","Ausschreibungs- & Projekt-Alerts"]'::jsonb),
  ('strategisch', 'Strategisch', false, 3,
    '["Alles aus Premium","Leitung einer Arbeitsgruppe","Redeslots bei Netzwerk-Events","Priorisierte Partnervermittlung"]'::jsonb)
ON CONFLICT (slug) DO NOTHING;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM alliance_features) THEN
    INSERT INTO alliance_features (label, standard, premium, strategisch, sort_order) VALUES
      ('Eintrag im Partnerverzeichnis',    true,  true,  true,  10),
      ('Newsletter & Marktinformationen',  true,  true,  true,  20),
      ('Logo auf der Startseite',          false, true,  true,  30),
      ('Mitarbeit in Arbeitsgruppen',      false, true,  true,  40),
      ('Ausschreibungs- & Projekt-Alerts', false, true,  true,  50),
      ('Leitung einer Arbeitsgruppe',      false, false, true,  60),
      ('Redeslots bei Netzwerk-Events',    false, false, true,  70),
      ('Priorisierte Partnervermittlung',  false, false, true,  80);
  END IF;
END $$;
