-- Migration: Produkte für Partner per Firmennamen sichtbar machen
-- Problem: Admin ordnet Produkte per "Unternehmen"-Textfeld zu, aber RLS prüft nur partner_id (FK).
-- Fix: Neue SELECT-Policy, die Partnern Zugriff gewährt wenn unternehmen = user_profiles.firma.
-- Ausführen im Supabase SQL Editor

DROP POLICY IF EXISTS "Partner: eigene Produkte lesen (nach Firma)" ON public.products;

CREATE POLICY "Partner: eigene Produkte lesen (nach Firma)"
  ON public.products FOR SELECT
  TO authenticated
  USING (
    unternehmen IN (
      SELECT firma FROM public.user_profiles
      WHERE user_id = auth.uid()
        AND firma IS NOT NULL
        AND firma <> ''
    )
  );
