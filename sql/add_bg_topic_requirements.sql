-- Gesetzliche Anforderungen je Berufsgruppe und Themenbereich
CREATE TABLE IF NOT EXISTS bg_topic_requirements (
  id                uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  berufsgruppe_id   uuid REFERENCES berufsgruppen(id) ON DELETE CASCADE,
  thema             text NOT NULL,   -- 'security' | 'ti' | 'it' | 'modernwork' | 'prozess' | 'telemedizin'
  finanzierungsart  text,
  rechtsgrundlage   text,
  foerdergeber      text,
  gueltig_seit      text,
  foerderbetrag     text,
  bedingungen       text,
  auszahlung        text,
  has_rechner       boolean DEFAULT false,
  aktualisiert_am   timestamptz DEFAULT now(),
  UNIQUE(berufsgruppe_id, thema)
);

-- Bestehende TI-Daten aus berufsgruppen in die neue Tabelle migrieren
INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, finanzierungsart, rechtsgrundlage, foerdergeber, gueltig_seit, foerderbetrag, bedingungen, auszahlung, has_rechner)
SELECT
  id,
  'ti',
  ti_finanzierungsart,
  ti_rechtsgrundlage,
  ti_foerdergeber,
  ti_gueltig_seit,
  ti_foerderbetrag,
  ti_bedingungen,
  ti_auszahlung,
  COALESCE(has_rechner, false)
FROM berufsgruppen
WHERE ti_finanzierungsart IS NOT NULL OR ti_rechtsgrundlage IS NOT NULL OR has_rechner = true
ON CONFLICT (berufsgruppe_id, thema) DO NOTHING;
