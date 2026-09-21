-- Migration: Assessment-Fragen DB-gesteuert
-- Ausführen im Supabase SQL Editor

-- ─── 1. Tabelle anlegen ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS assessment_questions (
  id         uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  thema_id   uuid NOT NULL REFERENCES themengebiete(id) ON DELETE CASCADE,
  frage      text NOT NULL,
  sortierung integer DEFAULT 10,
  aktiv      boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_assessment_questions_thema_id ON assessment_questions(thema_id);

-- ─── 2. RLS ──────────────────────────────────────────────────────────────────
ALTER TABLE assessment_questions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "assessment_questions_read"
  ON assessment_questions FOR SELECT USING (true);

CREATE POLICY "assessment_questions_write"
  ON assessment_questions FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin'));

-- ─── 3. Bestehende 12 Fragen migrieren ───────────────────────────────────────
INSERT INTO assessment_questions (thema_id, frage, sortierung)
SELECT t.id, q.frage, q.sortierung
FROM (VALUES
  ('security',    'Wie wichtig ist Ihnen IT-Sicherheit für Ihre Einrichtung?',                   10),
  ('security',    'Haben Sie Bedenken bezüglich Cyberangriffen oder Datenschutzverletzungen?',   20),
  ('ti',          'Stehen TI-Anwendungen wie ePA, eRezept oder TI-Messenger auf Ihrer Agenda?', 10),
  ('ti',          'Haben Sie Unterstützungsbedarf bei der TI-Anbindung oder Ausstattung?',       20),
  ('it',          'Benötigen Sie Unterstützung bei Ihren IT-Systemen oder der Hardware?',        10),
  ('it',          'Planen Sie Investitionen in Ihre IT-Infrastruktur in den nächsten 12 Monaten?', 20),
  ('modernwork',  'Interessieren Sie sich für flexible, ortsunabhängige Arbeitslösungen?',       10),
  ('modernwork',  'Planen Sie den Einsatz digitaler Kommunikations- oder Kollaborationstools?',  20),
  ('prozess',     'Möchten Sie Verwaltungsprozesse in Ihrer Einrichtung digitalisieren?',        10),
  ('prozess',     'Ist die Reduzierung von Papierprozessen ein wichtiges Ziel für Sie?',         20),
  ('telemedizin', 'Interessieren Sie sich für Videosprechstunden oder Remote-Behandlung?',       10),
  ('telemedizin', 'Sind digitale Monitoring-Lösungen für Ihre Patienten relevant?',              20)
) AS q(slug, frage, sortierung)
JOIN themengebiete t ON t.slug = q.slug
ON CONFLICT DO NOTHING;
