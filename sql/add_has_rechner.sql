-- Spalte hinzufügen
ALTER TABLE berufsgruppen
  ADD COLUMN IF NOT EXISTS has_rechner boolean DEFAULT false;

-- Rehakliniken (nr=23) auf true setzen
UPDATE berufsgruppen
  SET has_rechner = true
  WHERE nr = 23;
