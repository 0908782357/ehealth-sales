-- Migration: Partner-Tier-Spalte und Produktberechtigungen für strategisch-Partner
-- Problem: Seit der Einführung des Tier-Systems konnten strategisch-Partner
--          keine Produkte mehr verwalten. Ursachen:
--          1. partner_tier-Spalte fehlte in user_roles
--          2. portal_permissions-Zeile für 'produkte' hatte ggf. strategisch=null

-- 1. Sicherstellen, dass partner_tier-Spalte in user_roles existiert
ALTER TABLE public.user_roles
  ADD COLUMN IF NOT EXISTS partner_tier text
  CHECK (partner_tier IN ('standard', 'premium', 'strategisch'));

-- 2. Produktberechtigungen in portal_permissions korrigieren:
--    strategisch → 'edit', premium → 'read' (wie in PERM_DEFS definiert)
INSERT INTO public.portal_permissions (perm_id, kunde, standard, premium, strategisch)
VALUES ('produkte', null, null, 'read', 'edit')
ON CONFLICT (perm_id) DO UPDATE
  SET strategisch = 'edit',
      premium     = COALESCE(portal_permissions.premium, 'read');
