-- Migration: Kundenkarte-Erweiterung
-- Ausführen in Supabase SQL Editor

-- kunden: neue Adressfelder
ALTER TABLE kunden ADD COLUMN IF NOT EXISTS adresse text;
ALTER TABLE kunden ADD COLUMN IF NOT EXISTS plz     text;
ALTER TABLE kunden ADD COLUMN IF NOT EXISTS ort     text;

-- Ansprechpartner je Kunde
CREATE TABLE IF NOT EXISTS kunden_ansprechpartner (
  id         uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  kunden_id  uuid NOT NULL REFERENCES kunden(id) ON DELETE CASCADE,
  name       text NOT NULL,
  email      text,
  telefon    text,
  rolle      text,
  created_at timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_kunden_ansprechpartner_kunden_id ON kunden_ansprechpartner(kunden_id);

-- Aktivitäten & Notizen je Kunde
CREATE TABLE IF NOT EXISTS kunden_aktivitaeten (
  id             uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  kunden_id      uuid NOT NULL REFERENCES kunden(id) ON DELETE CASCADE,
  text           text NOT NULL,
  typ            text NOT NULL DEFAULT 'notiz',  -- notiz, aufgabe, anruf, email, meeting
  datum_geplant  date,
  erledigt       boolean NOT NULL DEFAULT false,
  created_at     timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_kunden_aktivitaeten_kunden_id ON kunden_aktivitaeten(kunden_id);
