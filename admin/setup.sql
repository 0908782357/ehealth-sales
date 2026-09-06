-- ============================================================
-- eHealth Sales – Supabase Schema Setup
-- In Supabase SQL Editor ausführen: https://supabase.com/dashboard
-- ============================================================

-- ---- Tabellen erstellen ----

CREATE TABLE IF NOT EXISTS public.user_roles (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  role       text NOT NULL CHECK (role IN ('admin', 'partner', 'customer')),
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.partners (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid REFERENCES auth.users(id) ON DELETE SET NULL UNIQUE,
  name       text NOT NULL,
  website    text,
  logo_url   text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.products (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_id   uuid REFERENCES public.partners(id) ON DELETE SET NULL,
  nr           integer,
  hersteller   text NOT NULL,
  reseller     text,
  produkt      text NOT NULL,
  typ          text CHECK (typ IN ('loesung', 'produkt')),
  kategorie    text CHECK (kategorie IN ('ti','kommunikation','ki','management','hardware','security','it-unterstuetzung')),
  stationaer   boolean DEFAULT true,
  mobil        boolean DEFAULT true,
  verfuegbar   integer[] DEFAULT '{}',
  bald         integer[] DEFAULT '{}',
  telemedizin  boolean DEFAULT false,
  ti           boolean DEFAULT false,
  security     boolean DEFAULT false,
  beschreibung text,
  detail_page  text,
  published    boolean DEFAULT true,
  created_at   timestamptz DEFAULT now(),
  updated_at   timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.knowledge_articles (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id  uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  title      text NOT NULL,
  slug       text UNIQUE,
  content    text,
  category   text,
  published  boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- ---- Row Level Security aktivieren ----

ALTER TABLE public.user_roles         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.partners           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.knowledge_articles ENABLE ROW LEVEL SECURITY;

-- ---- Hilfsfunktion: ist Admin? ----

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean LANGUAGE sql SECURITY DEFINER STABLE AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = auth.uid() AND role = 'admin'
  );
$$;

-- ---- Bestehende Policies entfernen (idempotent) ----

DROP POLICY IF EXISTS "Eigene Rolle lesen"                      ON public.user_roles;
DROP POLICY IF EXISTS "Admin: alle Rollen verwalten"            ON public.user_roles;
DROP POLICY IF EXISTS "Öffentlich: Partner lesen"               ON public.partners;
DROP POLICY IF EXISTS "Partner: eigenes Profil updaten"         ON public.partners;
DROP POLICY IF EXISTS "Admin: alle Partner verwalten"           ON public.partners;
DROP POLICY IF EXISTS "Öffentlich: veröffentlichte Produkte lesen" ON public.products;
DROP POLICY IF EXISTS "Admin: alle Produkte lesen"              ON public.products;
DROP POLICY IF EXISTS "Partner: eigene Produkte verwalten"      ON public.products;
DROP POLICY IF EXISTS "Admin: alle Produkte verwalten"          ON public.products;
DROP POLICY IF EXISTS "Öffentlich: publizierte Artikel lesen"   ON public.knowledge_articles;
DROP POLICY IF EXISTS "Admin: alle Artikel verwalten"           ON public.knowledge_articles;

-- ---- RLS Policies: user_roles ----

CREATE POLICY "Eigene Rolle lesen"
  ON public.user_roles FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Admin: alle Rollen verwalten"
  ON public.user_roles FOR ALL
  USING (public.is_admin());

-- ---- RLS Policies: partners ----

CREATE POLICY "Öffentlich: Partner lesen"
  ON public.partners FOR SELECT
  USING (true);

CREATE POLICY "Partner: eigenes Profil updaten"
  ON public.partners FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Admin: alle Partner verwalten"
  ON public.partners FOR ALL
  USING (public.is_admin());

-- ---- RLS Policies: products ----

CREATE POLICY "Öffentlich: veröffentlichte Produkte lesen"
  ON public.products FOR SELECT
  USING (published = true);

CREATE POLICY "Admin: alle Produkte lesen"
  ON public.products FOR SELECT
  USING (public.is_admin());

CREATE POLICY "Partner: eigene Produkte verwalten"
  ON public.products FOR ALL
  USING (
    partner_id IN (
      SELECT id FROM public.partners WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Admin: alle Produkte verwalten"
  ON public.products FOR ALL
  USING (public.is_admin());

-- ---- RLS Policies: knowledge_articles ----

CREATE POLICY "Öffentlich: publizierte Artikel lesen"
  ON public.knowledge_articles FOR SELECT
  USING (published = true);

CREATE POLICY "Admin: alle Artikel verwalten"
  ON public.knowledge_articles FOR ALL
  USING (public.is_admin());

-- ---- Tabelle: user_profiles ----

CREATE TABLE IF NOT EXISTS public.user_profiles (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid REFERENCES auth.users(id) ON DELETE SET NULL UNIQUE,
  email      text NOT NULL UNIQUE,
  vorname    text,
  nachname   text,
  firma      text,
  telefon    text,
  strasse    text,
  plz        text,
  ort        text,
  rolle      text DEFAULT 'partner' CHECK (rolle IN ('admin', 'partner', 'customer')),
  notizen    text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admin: alle Profile verwalten"     ON public.user_profiles;
DROP POLICY IF EXISTS "Nutzer: eigenes Profil lesen"      ON public.user_profiles;
DROP POLICY IF EXISTS "Nutzer: eigenes Profil verknüpfen" ON public.user_profiles;

-- Admin sieht und verwaltet alle Profile
CREATE POLICY "Admin: alle Profile verwalten"
  ON public.user_profiles FOR ALL
  USING (public.is_admin());

-- Eingeloggter Nutzer kann sein eigenes Profil lesen
CREATE POLICY "Nutzer: eigenes Profil lesen"
  ON public.user_profiles FOR SELECT
  USING (user_id = auth.uid());

-- Nutzer kann ein noch nicht verknüpftes Profil mit seiner E-Mail-Adresse übernehmen
CREATE POLICY "Nutzer: eigenes Profil verknüpfen"
  ON public.user_profiles FOR UPDATE
  USING (user_id IS NULL AND lower(email) = lower(auth.email()))
  WITH CHECK (user_id = auth.uid());

-- ---- Tabellen: Shop ----

CREATE TABLE IF NOT EXISTS public.shop_items (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id     uuid REFERENCES public.products(id) ON DELETE SET NULL,
  partner_id     uuid REFERENCES public.partners(id) ON DELETE SET NULL,
  titel          text NOT NULL,
  beschreibung   text,
  preis          numeric(10,2),
  preis_einheit  text DEFAULT 'einmalig',
  bild_url       text,
  aktiv          boolean DEFAULT true,
  requires_token boolean DEFAULT false,
  created_at     timestamptz DEFAULT now(),
  updated_at     timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.orders (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_item_id uuid REFERENCES public.shop_items(id) ON DELETE SET NULL,
  name         text NOT NULL,
  email        text NOT NULL,
  organisation text,
  nachricht    text,
  status       text DEFAULT 'pending' CHECK (status IN ('pending','approved','rejected')),
  created_at   timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.access_tokens (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id     uuid REFERENCES public.orders(id) ON DELETE CASCADE,
  shop_item_id uuid REFERENCES public.shop_items(id) ON DELETE SET NULL,
  token        uuid DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  valid        boolean DEFAULT true,
  created_at   timestamptz DEFAULT now()
);

ALTER TABLE public.shop_items    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.access_tokens ENABLE ROW LEVEL SECURITY;

-- ---- RLS Policies: shop_items ----

DROP POLICY IF EXISTS "Alle eingeloggten Nutzer: shop_items lesen"  ON public.shop_items;
DROP POLICY IF EXISTS "Admin: shop_items verwalten"                  ON public.shop_items;

CREATE POLICY "Alle eingeloggten Nutzer: shop_items lesen"
  ON public.shop_items FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Admin: shop_items verwalten"
  ON public.shop_items FOR ALL
  USING (public.is_admin());

-- ---- RLS Policies: orders ----

DROP POLICY IF EXISTS "Öffentlich: Bestellung einreichen"  ON public.orders;
DROP POLICY IF EXISTS "Admin: alle Bestellungen verwalten" ON public.orders;

CREATE POLICY "Öffentlich: Bestellung einreichen"
  ON public.orders FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Admin: alle Bestellungen verwalten"
  ON public.orders FOR ALL
  USING (public.is_admin());

-- ---- RLS Policies: access_tokens ----

DROP POLICY IF EXISTS "Öffentlich: Token validieren"       ON public.access_tokens;
DROP POLICY IF EXISTS "Admin: access_tokens verwalten"     ON public.access_tokens;

CREATE POLICY "Öffentlich: Token validieren"
  ON public.access_tokens FOR SELECT
  USING (true);

CREATE POLICY "Admin: access_tokens verwalten"
  ON public.access_tokens FOR ALL
  USING (public.is_admin());

-- ---- Spalte requires_token nachrüsten (falls Tabelle bereits besteht) ----
ALTER TABLE public.shop_items ADD COLUMN IF NOT EXISTS requires_token boolean DEFAULT false;

-- ---- Initiale Partner anlegen ----

INSERT INTO public.partners (name, website) VALUES
  ('ehex GmbH',         'https://ehex.de'),
  ('PITNAS GmbH',       'https://pitnas.de'),
  ('Prof. Valmed',      NULL),
  ('ehealth Connect',   NULL),
  ('Cherry GmbH',       NULL),
  ('eHealth Sales GmbH','https://ehealth-sales.de')
ON CONFLICT DO NOTHING;

-- ---- Bestehende 31 Produkte migrieren ----

INSERT INTO public.products (nr, hersteller, reseller, produkt, typ, kategorie, stationaer, mobil, verfuegbar, bald, telemedizin, ti, security, beschreibung, detail_page) VALUES
(1,  'ims',        'Diverse', 'TI Gateway',                     'loesung', 'ti',                 true,  true,  ARRAY[4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28], ARRAY[]::int[], false, true,  false, 'Zentraler Zugangspunkt zur Telematikinfrastruktur – sicher, zertifiziert und für alle Leistungserbringer geeignet.',              'ti-gateway'),
(2,  'ehex',       'Diverse', 'HSM-B',                          'produkt', 'ti',                 true,  true,  ARRAY[5,9,10,11,12,13,14,20,21,22,27,28],                                      ARRAY[4,6,15,16,17,18,19], false, true,  false, 'Hardware Security Module für kryptografische Schlüsselverwaltung – höchste Sicherheitsstandards in der TI.',               'hsm-b'),
(3,  'ehex',       'Diverse', 'easyTI',                         'loesung', 'ti',                 true,  false, ARRAY[6,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27],             ARRAY[]::int[], false, true,  false, 'Cloudbasierte TI-Anbindung ohne eigenen Konnektor – einfach, flexibel und kosteneffizient.',                                   'easyti'),
(4,  'ehex',       'Diverse', 'easyTI Hub',                     'loesung', 'ti',                 true,  true,  ARRAY[6,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28],          ARRAY[]::int[], false, true,  false, 'Zentraler TI-Hub für mehrere Standorte – eine Anbindung für die gesamte Einrichtung.',                                          'easyti-hub'),
(5,  'Arvato',     'Diverse', 'KIM',                            'loesung', 'kommunikation',      true,  true,  ARRAY[4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28], ARRAY[]::int[], false, true,  false, 'Kommunikation im Medizinwesen – der sichere E-Mail-Dienst der TI für Befunde, Briefe und Dokumente.',                          'kim'),
(6,  'Awesome',    'Concat',  'TIM',                            'loesung', 'kommunikation',      true,  true,  ARRAY[4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28], ARRAY[]::int[], false, true,  false, 'TI-Messenger für sichere Sofortnachrichten zwischen Leistungserbringern – DSGVO-konform und TI-integriert.',                    'tim'),
(7,  'Prof. Valmed','ehs',   'KI Arztbrief',                   'loesung', 'ki',                 true,  true,  ARRAY[4,5,7,8],                                                               ARRAY[]::int[], false, true,  false, 'KI-gestützte Arztbrief-Erstellung als zertifiziertes Medizinprodukt – spart Zeit und erhöht die Dokumentationsqualität.',     'ki-arztbrief'),
(8,  'Cherry',     'ehs',     'TMS',                            'loesung', 'management',         true,  true,  ARRAY[4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28], ARRAY[]::int[], false, true,  false, 'Token Management System für sichere Authentifizierung und zentrale Kartenverwaltung in Ihrer Einrichtung.',                    'tms'),
(9,  'ehc',        'ehc',     'Stele',                          'produkt', 'hardware',           true,  false, ARRAY[4,5,7,8,21],                                                            ARRAY[]::int[], false, true,  false, 'Digitale Empfangsstele für automatisierten Patientencheck-in – reduziert Wartezeiten und entlastet das Personal.',              'stele'),
(10, 'Medivise',   'ehc',     'Medivise Box',                   'produkt', 'hardware',           true,  false, ARRAY[4,5,7,8],                                                               ARRAY[]::int[], true,  false, false, 'Kompaktes System für digitales Medikationsmanagement – sicher, vernetzt und intuitiv zu bedienen.',                             'medivise-box'),
(11, 'ehc',        'ehc',     'Online Services',                'loesung', 'management',         true,  false, ARRAY[7],                                                                     ARRAY[]::int[], false, true,  false, 'Digitale Online-Services für Apotheken – Rezeptmanagement, Reservierung und Kundenkommunikation.',                               'online-services'),
(12, 'Samsung',    'Concat',  'Tablett',                        'produkt', 'hardware',           false, true,  ARRAY[4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28], ARRAY[]::int[], false, true,  false, 'Robuste medizinische Tablets für den professionellen Einsatz im Gesundheitswesen.',                                              'tablett'),
(13, 'Diverse',    'Diverse', 'DVO Services',                   'loesung', 'it-unterstuetzung',  true,  true,  ARRAY[4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27],   ARRAY[]::int[], false, true,  true,  'Digitaler Vor-Ort-Service: IT-Betreuung und technischer Support direkt bei Ihnen.',                                              NULL),
(14, 'PITNAS®',    'PITNAS®', 'Netzwerk-Sicherheit',            'produkt', 'security',           true,  false, ARRAY[4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28], ARRAY[]::int[], false, false, true,  'Professionelle Firewall-UTM mit integrierter TI-Option – schützt Ihre Praxisinfrastruktur zuverlässig vor Cyberangriffen.',     NULL),
(15, 'PITNAS®',    'PITNAS®', 'Infrastruktur-Sicherheit',       'loesung', 'security',           true,  true,  ARRAY[4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28], ARRAY[]::int[], false, false, true,  'Zentraler Virenschutz auf Basis von Microsoft Defender – automatisch verwaltet, stets aktuell.',                                 NULL),
(16, 'PITNAS®',    'PITNAS®', 'Infrastruktur-Verbindung',       'loesung', 'security',           true,  true,  ARRAY[4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28], ARRAY[]::int[], false, false, true,  'Sichere VPN-Verbindung für Remote-Zugriff und standortübergreifende Vernetzung – DSGVO-konform.',                                NULL),
(17, 'PITNAS®',    'PITNAS®', 'DNS-Sicherheit',                 'loesung', 'security',           true,  true,  ARRAY[4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28], ARRAY[]::int[], false, false, true,  'DNS-Schutz gegen Phishing und Malware – gefährliche Webseiten werden automatisch blockiert.',                                    NULL),
(18, 'PITNAS®',    'PITNAS®', 'Tablet und Handy Sicherheit',    'loesung', 'security',           true,  true,  ARRAY[4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28], ARRAY[]::int[], false, false, true,  'Mobiles Gerätemanagement (MDM) für Tablets und Smartphones – zentrale Verwaltung und Sicherheitsrichtlinien.',                 NULL),
(19, 'PITNAS®',    'PITNAS®', 'Infrastruktur as a Service',     'loesung', 'security',           true,  true,  ARRAY[4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28], ARRAY[]::int[], false, false, true,  'Gehostete Server-Infrastruktur in deutschen Rechenzentren – skalierbar und DSGVO-konform.',                                     NULL),
(20, 'PITNAS®',    'PITNAS®', 'Remote Backup',                  'loesung', 'security',           true,  true,  ARRAY[4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28], ARRAY[]::int[], false, false, true,  'Automatische Datensicherung in die Cloud – tägliche Backups und schnelle Wiederherstellung.',                                   NULL),
(21, 'PITNAS®',    'PITNAS®', 'Lokales Backup',                 'produkt', 'security',           true,  true,  ARRAY[4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28], ARRAY[]::int[], false, false, true,  'Lokale Datensicherung auf eigenem Hardware-Speicher – schnelle Wiederherstellung ohne Internetabhängigkeit.',                   NULL),
(22, 'PITNAS®',    'PITNAS®', 'SPAM Schutz',                    'loesung', 'security',           true,  true,  ARRAY[4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28], ARRAY[]::int[], false, false, true,  'Professioneller E-Mail-Sicherheitsfilter gegen SPAM, Phishing und Malware.',                                                    NULL),
(23, 'PITNAS®',    'PITNAS®', 'DSGVO & GoBD Konform',           'loesung', 'security',           true,  true,  ARRAY[4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28], ARRAY[]::int[], false, false, true,  'Zentraler Passwort-Manager für Teams – DSGVO- und GoBD-konform, end-to-end-verschlüsselt.',                                    NULL),
(24, 'PITNAS®',    'PITNAS®', 'Software-Lizenzen',              'produkt', 'security',           true,  true,  ARRAY[4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28], ARRAY[]::int[], false, false, true,  'Software-Lizenzen für Microsoft 365, Adobe und weitere – zentral beschafft und professionell verwaltet.',                      NULL),
(25, 'PITNAS®',    'PITNAS®', 'E-Mail Archivierung',            'loesung', 'security',           true,  true,  ARRAY[4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28], ARRAY[]::int[], false, false, true,  'Rechtssichere E-Mail-Archivierung gemäß GoBD – automatisch und manipulationssicher.',                                           NULL),
(26, 'PITNAS®',    'PITNAS®', 'IT-Monitoring',                  'loesung', 'security',           true,  true,  ARRAY[4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28], ARRAY[]::int[], false, false, true,  'Proaktives IT-Monitoring Ihrer gesamten Infrastruktur – Alarmierung bei Problemen.',                                             NULL),
(27, 'PITNAS®',    'PITNAS®', 'Abrechnungsoptimierung',         'loesung', 'security',           true,  true,  ARRAY[4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28], ARRAY[]::int[], false, false, true,  'Automatische Prüfung Ihrer KV- und HZV-Abrechnungen – findet ungenutzte Vergütungspotenziale.',                                 NULL),
(28, 'ehs',        'ehs',     'TI Readyness Workshop',          'loesung', 'it-unterstuetzung',  true,  true,  ARRAY[8,21,23],                                                               ARRAY[]::int[], false, true,  true,  'Strukturierter Workshop zur TI-Vorbereitung – wir analysieren Ihre IT-Infrastruktur.',                                          NULL),
(29, 'ehs',        'ehs',     'Security Workshop',              'loesung', 'it-unterstuetzung',  true,  true,  ARRAY[4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28], ARRAY[]::int[], false, true,  true,  'Individueller IT-Sicherheits-Workshop – wir identifizieren Schwachstellen und erarbeiten Schutzmaßnahmen.',                    NULL),
(30, 'ehs',        'ehs',     'NIS2 Audit',                     'loesung', 'it-unterstuetzung',  true,  true,  ARRAY[8],                                                                     ARRAY[]::int[], false, false, true,  'Professionelles NIS2-Audit für Krankenhäuser – Prüfung der IT-Sicherheitsanforderungen.',                                        NULL),
(31, 'ehs',        'ehs',     'Sichere Praxis § 390 SGB V',     'loesung', 'it-unterstuetzung',  true,  true,  ARRAY[4,5,6,7,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28],  ARRAY[]::int[], false, false, true,  'Beratung und Umsetzung der gesetzlichen IT-Sicherheitsanforderungen nach § 390 SGB V.',                                          NULL)
ON CONFLICT DO NOTHING;

-- ============================================================
-- NACH DER AUSFÜHRUNG:
-- 1. Supabase Dashboard → Authentication → Users → "Invite user"
--    oder per E-Mail einladen
-- 2. Nach erstem Login: in user_roles Tabelle Rolle zuweisen (ON CONFLICT für Wiederholungen):
--    INSERT INTO public.user_roles (user_id, role) VALUES ('<uuid>', 'admin')
--    ON CONFLICT (user_id) DO UPDATE SET role = 'admin';
-- 3. Partner mit user_id verknüpfen:
--    UPDATE partners SET user_id = '<uuid>' WHERE name = 'PITNAS GmbH';
-- ============================================================
