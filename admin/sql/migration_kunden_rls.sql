-- Migration: RLS für Kunden-Bereich (Partner sehen nur eigene Kunden)
-- Ausführen in Supabase SQL Editor

-- ─── kunden: fehlende Spalten ergänzen ───────────────────────────────────────
ALTER TABLE kunden ADD COLUMN IF NOT EXISTS partner_id uuid REFERENCES partners(id) ON DELETE SET NULL;

-- ─── kunden ───────────────────────────────────────────────────────────────────
ALTER TABLE kunden ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admin: alle Kunden"    ON kunden;
DROP POLICY IF EXISTS "Partner: eigene Kunden" ON kunden;

CREATE POLICY "Admin: alle Kunden" ON kunden
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin'));

CREATE POLICY "Partner: eigene Kunden" ON kunden
  FOR ALL TO authenticated
  USING  (partner_id IN (SELECT id FROM partners WHERE user_id = auth.uid()))
  WITH CHECK (partner_id IN (SELECT id FROM partners WHERE user_id = auth.uid()));

-- ─── kunden_ansprechpartner ───────────────────────────────────────────────────
ALTER TABLE kunden_ansprechpartner ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admin: alle Ansprechpartner"    ON kunden_ansprechpartner;
DROP POLICY IF EXISTS "Partner: eigene Ansprechpartner" ON kunden_ansprechpartner;

CREATE POLICY "Admin: alle Ansprechpartner" ON kunden_ansprechpartner
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin'));

CREATE POLICY "Partner: eigene Ansprechpartner" ON kunden_ansprechpartner
  FOR ALL TO authenticated
  USING (kunden_id IN (
    SELECT id FROM kunden
    WHERE partner_id IN (SELECT id FROM partners WHERE user_id = auth.uid())
  ))
  WITH CHECK (kunden_id IN (
    SELECT id FROM kunden
    WHERE partner_id IN (SELECT id FROM partners WHERE user_id = auth.uid())
  ));

-- ─── kunden_aktivitaeten ──────────────────────────────────────────────────────
ALTER TABLE kunden_aktivitaeten ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admin: alle Aktivitaeten"    ON kunden_aktivitaeten;
DROP POLICY IF EXISTS "Partner: eigene Aktivitaeten" ON kunden_aktivitaeten;

CREATE POLICY "Admin: alle Aktivitaeten" ON kunden_aktivitaeten
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin'));

CREATE POLICY "Partner: eigene Aktivitaeten" ON kunden_aktivitaeten
  FOR ALL TO authenticated
  USING (kunden_id IN (
    SELECT id FROM kunden
    WHERE partner_id IN (SELECT id FROM partners WHERE user_id = auth.uid())
  ))
  WITH CHECK (kunden_id IN (
    SELECT id FROM kunden
    WHERE partner_id IN (SELECT id FROM partners WHERE user_id = auth.uid())
  ));

-- ─── kunden_interessen ────────────────────────────────────────────────────────
ALTER TABLE kunden_interessen ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admin: alle Interessen"    ON kunden_interessen;
DROP POLICY IF EXISTS "Partner: eigene Interessen" ON kunden_interessen;

CREATE POLICY "Admin: alle Interessen" ON kunden_interessen
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin'));

CREATE POLICY "Partner: eigene Interessen" ON kunden_interessen
  FOR ALL TO authenticated
  USING (kunden_id IN (
    SELECT id FROM kunden
    WHERE partner_id IN (SELECT id FROM partners WHERE user_id = auth.uid())
  ))
  WITH CHECK (kunden_id IN (
    SELECT id FROM kunden
    WHERE partner_id IN (SELECT id FROM partners WHERE user_id = auth.uid())
  ));

-- ─── verkaufschancen ──────────────────────────────────────────────────────────
ALTER TABLE verkaufschancen ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admin: alle VCs"    ON verkaufschancen;
DROP POLICY IF EXISTS "Partner: eigene VCs" ON verkaufschancen;

CREATE POLICY "Admin: alle VCs" ON verkaufschancen
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin'));

CREATE POLICY "Partner: eigene VCs" ON verkaufschancen
  FOR ALL TO authenticated
  USING (kunden_id IN (
    SELECT id FROM kunden
    WHERE partner_id IN (SELECT id FROM partners WHERE user_id = auth.uid())
  ))
  WITH CHECK (kunden_id IN (
    SELECT id FROM kunden
    WHERE partner_id IN (SELECT id FROM partners WHERE user_id = auth.uid())
  ));
