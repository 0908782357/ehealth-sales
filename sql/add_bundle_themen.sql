-- Themenbereiche-Spalte für Bundles
-- Werte: 'security' | 'ti' | 'it' | 'modernwork' | 'prozess' | 'telemedizin'
ALTER TABLE bundles ADD COLUMN IF NOT EXISTS themen text[] DEFAULT '{}';
