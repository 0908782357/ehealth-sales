-- MANUAL STEP: Paste this file into https://supabase.com/dashboard/project/focysklymhmcfwgxdtuk/sql and run.

-- admin/sql/migration_registrierungen_tickets.sql
-- Registrierungen von Endkunden (öffentliches Formular → Admin-Genehmigung)
CREATE TABLE IF NOT EXISTS public.registrierungen (
  id               uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  vorname          text NOT NULL,
  nachname         text NOT NULL,
  email            text NOT NULL,
  firma            text NOT NULL,
  berufsgruppe_id  uuid REFERENCES public.berufsgruppen(id) ON DELETE SET NULL,
  produkt_id       uuid REFERENCES public.products(id) ON DELETE SET NULL,
  anliegen         text,
  status           text NOT NULL DEFAULT 'ausstehend',
  -- ausstehend | genehmigt | abgelehnt
  ablehnungsgrund  text,
  erstellt_am      timestamptz DEFAULT now()
);

-- RLS: anonym darf einfügen (öffentliches Formular), nur Admins dürfen lesen/updaten
ALTER TABLE public.registrierungen ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Öffentlich: registrieren"
  ON public.registrierungen FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Admin: alle Registrierungen verwalten"
  ON public.registrierungen FOR ALL
  USING (EXISTS (
    SELECT 1 FROM public.user_roles WHERE user_id = auth.uid() AND role = 'admin'
  ));

-- Support-Tickets (von Endkunden erstellt, von Admins priorisiert und Partnern zugewiesen)
CREATE TABLE IF NOT EXISTS public.support_tickets (
  id                   uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  titel                text NOT NULL,
  beschreibung         text NOT NULL,
  kunden_id            uuid REFERENCES public.kunden(id) ON DELETE SET NULL,
  user_id              uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  produkt_id           uuid REFERENCES public.products(id) ON DELETE SET NULL,
  prioritaet           text,
  -- NULL (neu) | niedrig | mittel | hoch | kritisch
  status               text NOT NULL DEFAULT 'offen',
  -- offen | in_bearbeitung | geloest | geschlossen
  assigned_partner_id  uuid REFERENCES public.user_profiles(id) ON DELETE SET NULL,
  notiz_intern         text,
  created_at           timestamptz DEFAULT now(),
  updated_at           timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_tickets_user_id    ON public.support_tickets(user_id);
CREATE INDEX IF NOT EXISTS idx_tickets_kunden_id  ON public.support_tickets(kunden_id);
CREATE INDEX IF NOT EXISTS idx_tickets_partner_id ON public.support_tickets(assigned_partner_id);
CREATE INDEX IF NOT EXISTS idx_tickets_status     ON public.support_tickets(status);

ALTER TABLE public.support_tickets ENABLE ROW LEVEL SECURITY;

-- Endkunde sieht nur eigene Tickets
CREATE POLICY "Kunde: eigene Tickets lesen"
  ON public.support_tickets FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Endkunde kann neue Tickets anlegen
CREATE POLICY "Kunde: Ticket erstellen"
  ON public.support_tickets FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Partner sieht zugewiesene Tickets, kann sie updaten
CREATE POLICY "Partner: zugewiesene Tickets verwalten"
  ON public.support_tickets FOR ALL
  TO authenticated
  USING (
    assigned_partner_id IN (
      SELECT id FROM public.user_profiles WHERE user_id = auth.uid()
    )
    OR EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = auth.uid() AND role = 'admin')
  );

-- Admin: voller Zugriff
CREATE POLICY "Admin: alle Tickets verwalten"
  ON public.support_tickets FOR ALL
  USING (EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = auth.uid() AND role = 'admin'));
