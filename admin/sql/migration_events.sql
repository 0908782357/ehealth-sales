-- Migration: Themengebiete + Events
-- Ausführen im Supabase SQL Editor

-- ─── Themengebiete ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS themengebiete (
  id           uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name         text NOT NULL,
  slug         text NOT NULL UNIQUE,
  farbe        text NOT NULL DEFAULT '#1C74B8',
  beschreibung text,
  sortierung   int NOT NULL DEFAULT 0,
  aktiv        boolean NOT NULL DEFAULT true,
  created_at   timestamptz DEFAULT now()
);

-- Starter-Daten (später über Admin-UI verwaltbar)
INSERT INTO themengebiete (name, slug, farbe, sortierung) VALUES
  ('Telematikinfrastruktur', 'ti',         '#0F4C81', 10),
  ('ePA & Digitale Akten',  'epa',         '#12A594', 20),
  ('KI im Gesundheitswesen','ki',          '#7C3AED', 30),
  ('Cybersecurity',         'security',    '#DC2626', 40),
  ('Abrechnung & Finanzierung', 'abrechnung', '#D97706', 50),
  ('IT-Infrastruktur',      'it',          '#475569', 60),
  ('Telemedizin',           'telemedizin', '#0891B2', 70),
  ('Regulatory & Zulassung','regulatory',  '#16A34A', 80)
ON CONFLICT (slug) DO NOTHING;

-- ─── Events ───────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS events (
  id               uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  titel            text NOT NULL,
  kurzbeschreibung text NOT NULL,
  beschreibung     text,
  datum            date NOT NULL,
  uhrzeit_start    time NOT NULL,
  dauer_min        int NOT NULL DEFAULT 60,
  format           text NOT NULL DEFAULT 'webinar',
  -- webinar | roundtable | workshop | vortrag
  max_teilnehmer   int,
  teilnahme_link   text,
  partner_id       uuid REFERENCES partners(id) ON DELETE SET NULL,
  status           text NOT NULL DEFAULT 'entwurf',
  -- entwurf | geplant | abgeschlossen | abgesagt
  oeffentlich      boolean NOT NULL DEFAULT false,
  created_at       timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_events_datum       ON events(datum);
CREATE INDEX IF NOT EXISTS idx_events_partner_id  ON events(partner_id);
CREATE INDEX IF NOT EXISTS idx_events_status      ON events(status);
CREATE INDEX IF NOT EXISTS idx_events_oeffentlich ON events(oeffentlich);

-- ─── Event-Themen (Junction) ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS event_themen (
  event_id  uuid NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  thema_id  uuid NOT NULL REFERENCES themengebiete(id) ON DELETE CASCADE,
  PRIMARY KEY (event_id, thema_id)
);

-- ─── Event-Anmeldungen ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS event_anmeldungen (
  id            uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  event_id      uuid NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  user_id       uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  status        text NOT NULL DEFAULT 'angemeldet',
  -- angemeldet | storniert | warteliste
  angemeldet_am timestamptz DEFAULT now(),
  UNIQUE(event_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_event_anm_event_id ON event_anmeldungen(event_id);
CREATE INDEX IF NOT EXISTS idx_event_anm_user_id  ON event_anmeldungen(user_id);

-- ─── RLS ──────────────────────────────────────────────────────────────────────
ALTER TABLE themengebiete    ENABLE ROW LEVEL SECURITY;
ALTER TABLE events           ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_themen     ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_anmeldungen ENABLE ROW LEVEL SECURITY;

-- themengebiete: jeder liest, nur Admins schreiben
CREATE POLICY "themengebiete_read_all"
  ON themengebiete FOR SELECT USING (true);

CREATE POLICY "themengebiete_admin_write"
  ON themengebiete FOR ALL
  USING (
    EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
  );

-- events: anon liest nur öffentliche+geplante+zukünftige
CREATE POLICY "events_public_read"
  ON events FOR SELECT
  USING (oeffentlich = true AND status = 'geplant' AND datum >= CURRENT_DATE);

-- events: eingeloggte User lesen alle öffentlichen (auch vergangene für Meine Anmeldungen)
CREATE POLICY "events_auth_read"
  ON events FOR SELECT
  TO authenticated
  USING (true);

-- events: Partner verwalten eigene
CREATE POLICY "events_partner_write"
  ON events FOR ALL
  TO authenticated
  USING (
    partner_id IN (
      SELECT id FROM partners WHERE user_id = auth.uid()
    )
    OR EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
  );

-- event_themen: folgt events-Rechten
CREATE POLICY "event_themen_read"
  ON event_themen FOR SELECT USING (true);

CREATE POLICY "event_themen_write"
  ON event_themen FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM events e
      WHERE e.id = event_themen.event_id
      AND (
        e.partner_id IN (SELECT id FROM partners WHERE user_id = auth.uid())
        OR EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
      )
    )
  );

-- event_anmeldungen: User sieht eigene
CREATE POLICY "event_anm_user_read"
  ON event_anmeldungen FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM events e
      WHERE e.id = event_anmeldungen.event_id
      AND e.partner_id IN (SELECT id FROM partners WHERE user_id = auth.uid())
    )
    OR EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "event_anm_user_write"
  ON event_anmeldungen FOR ALL
  TO authenticated
  USING (user_id = auth.uid());
