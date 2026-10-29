-- ============================================================
-- Migration: portal_permissions Phase 1
-- Komplettiert die Berechtigungs-Matrix für das Admin-UI
-- Fügt fehlende Zeilen hinzu ohne bestehende zu überschreiben
-- ============================================================

INSERT INTO public.portal_permissions (perm_id, kunde, standard, premium, strategisch)
VALUES
  -- Immer sichtbar (DB-Eintrag für Admin-UI-Vollständigkeit)
  ('ti_lagebild',     'read',   'read',   'read',   'read'),
  ('infinity_report', 'read',   'read',   'read',   'read'),
  -- Regulatorik war bisher nur in DEFS, fehlt in DB
  ('regulatorik',     'hidden', 'read',   'read',   'read')
ON CONFLICT (perm_id) DO NOTHING;
