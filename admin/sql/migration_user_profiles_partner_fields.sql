-- Migration: logo_url und website zu user_profiles hinzufügen
-- Wird für die Alliance-Partnerseite benötigt
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS logo_url text;
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS website  text;
