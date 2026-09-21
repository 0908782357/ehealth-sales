-- Migration: Icon-Feld für Themengebiete
-- Ausführen im Supabase SQL Editor

ALTER TABLE themengebiete ADD COLUMN IF NOT EXISTS icon_svg text;
