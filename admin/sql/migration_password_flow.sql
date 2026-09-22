-- ============================================================
-- Migration: Einladungs-Flow – password_set + RLS
-- ============================================================

-- 1. Spalte hinzufügen
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS password_set boolean NOT NULL DEFAULT false;

-- 2. RLS: Nutzer darf eigenes Profil lesen (per user_id oder per E-Mail für frisch eingeloggte)
DROP POLICY IF EXISTS "user_can_read_own_profile" ON user_profiles;
CREATE POLICY "user_can_read_own_profile"
  ON user_profiles FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR email = auth.email());

-- 3. RLS: Nutzer darf eigenes Profil updaten – auch bei noch nicht verknüpftem user_id
DROP POLICY IF EXISTS "user_can_update_own_profile" ON user_profiles;
CREATE POLICY "user_can_update_own_profile"
  ON user_profiles FOR UPDATE
  TO authenticated
  USING (email = auth.email())
  WITH CHECK (email = auth.email());
