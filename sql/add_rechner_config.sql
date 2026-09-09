-- Rechner-Typ und -Konfiguration pro Berufsgruppe/Thema
-- rechner_typ: 'staffel' | 'kh_377' | 'reha_381'
-- rechner_config: JSON-Array [{label: "...", betrag: "..."}] für Staffel-Typ
ALTER TABLE bg_topic_requirements
  ADD COLUMN IF NOT EXISTS rechner_typ    text,
  ADD COLUMN IF NOT EXISTS rechner_config jsonb DEFAULT '[]'::jsonb;

-- Bestehende Rehakliniken auf reha_381 setzen
UPDATE bg_topic_requirements
SET rechner_typ = 'reha_381'
WHERE has_rechner = true AND thema = 'ti' AND rechner_typ IS NULL;
