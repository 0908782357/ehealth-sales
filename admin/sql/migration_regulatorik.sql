-- Migration: Regulatorik-Wissensdatenbank
-- Neue Tabelle recht_datenbank: strukturierte Gesetzestexte mit Relevanzbewertung
-- AUSFÜHRUNG: Supabase Dashboard → SQL Editor → New query → Run

-- -----------------------------------------------------------------------
-- 1. Tabelle anlegen
-- -----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.recht_datenbank (
  id              uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
  law_abbr        text        NOT NULL,
  law_name        text        NOT NULL,
  law_status      text        NOT NULL DEFAULT 'in Kraft'
                  CHECK (law_status IN ('in Kraft','Kabinettsbeschluss','parlamentarische Beratung','Referentenentwurf','in Vorbereitung','aufgehoben')),
  paragraph_id    text,
  paragraph_title text        NOT NULL,
  content         text        NOT NULL,
  relevance_note  text,
  category        text        NOT NULL DEFAULT 'Überblick',
  effective_date  date,
  source_url      text,
  tags            text[]      DEFAULT '{}',
  created_at      timestamptz DEFAULT now(),
  updated_at      timestamptz DEFAULT now(),
  created_by      uuid        REFERENCES auth.users(id)
);

-- Auto-Update updated_at
CREATE OR REPLACE FUNCTION set_recht_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_recht_datenbank_updated_at ON public.recht_datenbank;
CREATE TRIGGER trg_recht_datenbank_updated_at
  BEFORE UPDATE ON public.recht_datenbank
  FOR EACH ROW EXECUTE FUNCTION set_recht_updated_at();

-- -----------------------------------------------------------------------
-- 2. RLS
-- -----------------------------------------------------------------------
ALTER TABLE public.recht_datenbank ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Regulatorik: lesen für alle Angemeldeten" ON public.recht_datenbank;
CREATE POLICY "Regulatorik: lesen für alle Angemeldeten"
  ON public.recht_datenbank FOR SELECT
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS "Regulatorik: schreiben nur Admin" ON public.recht_datenbank;
CREATE POLICY "Regulatorik: schreiben nur Admin"
  ON public.recht_datenbank FOR ALL
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = auth.uid() AND role = 'admin')
  );

-- -----------------------------------------------------------------------
-- 3. Seed-Daten: GeDiG — Gesetz für Daten und digitale Innovation im Gesundheitswesen
--    Stand: Kabinettsbeschluss 15.07.2026, parlamentarische Beratung läuft
--    Quelle: Bundesgesundheitsministerium, Kabinettsentwurf
-- -----------------------------------------------------------------------

INSERT INTO public.recht_datenbank
  (law_abbr, law_name, law_status, paragraph_id, paragraph_title, content, relevance_note, category, source_url, tags)
VALUES

-- Überblick
('GeDiG',
 'Gesetz für Daten und digitale Innovation im Gesundheitswesen',
 'parlamentarische Beratung',
 NULL,
 'Überblick und Gesetzesziel',
 E'Das GeDiG (auch GeDIG) ist ein umfassendes Artikelgesetz, das die Digitalisierung des deutschen Gesundheitswesens weiter vorantreibt und zentrale EU-Vorgaben in nationales Recht umsetzt.\n\nWesentliche Regelungsbereiche:\n• Umsetzung der EU-Verordnung 2025/327 über den Europäischen Gesundheitsdatenraum (EHDS) – primäre und sekundäre Nutzung von Gesundheitsdaten\n• Erweiterung und Stärkung der elektronischen Patientenakte (ePA)\n• Verpflichtender Ausbau sicherer TI-Kommunikation (KIM, TI-Messenger) und Ablösung des Faxes\n• Einführung der elektronischen Überweisung und bundesweit einheitlichen digitalen Versorgungseinstiegs\n• Interoperabilitätspflichten für Leistungserbringer und Hersteller\n• Erweiterung der Aufgaben der gematik (Betriebsstabilität, Cyberresilienz)\n• Weiterentwicklung der Datenzugangsstelle beim BfArM\n\nStatus: Kabinettsbeschluss 15.07.2026. Referentenentwurf vom 05.05.2026. Parlamentarische Beratung läuft; Inkrafttreten voraussichtlich 2027.',
 'Kerngesetz für die digitale Transformation im Gesundheitswesen. Betrifft direkt Produkte und Services im TI/eHealth-Umfeld (TI-Messenger, KIM, ePA-Anbindung, Interoperabilität).',
 'Überblick',
 'https://www.bundesgesundheitsministerium.de/presse/pressemitteilungen/kabinett-beschliesst-gedig-pm-15-07-2026',
 ARRAY['GeDiG','Digitalisierung','EHDS','ePA','TI','Überblick']),

-- ePA
('GeDiG',
 'Gesetz für Daten und digitale Innovation im Gesundheitswesen',
 'parlamentarische Beratung',
 '§§ in SGB V',
 'Erweiterung der elektronischen Patientenakte (ePA)',
 E'Das GeDiG enthält weitreichende Änderungen am SGB V zur Weiterentwicklung der elektronischen Patientenakte.\n\nKernregelungen:\n• Apotheken erhalten erweiterte Zugriffsrechte auf ePA-Daten zur Stärkung der Arzneimitteltherapiesicherheit (AMTS). Apotheken können Medikamentenwechselwirkungen direkt in der ePA prüfen.\n• Einführung einer elektronischen Überweisung: Überweisungen sollen digital über die TI übermittelt werden, Papierüberweisungen werden abgelöst.\n• Einheitlicher digitaler Versorgungseinstieg mit Ersteinschätzung und Terminvermittlung\n• Ausbau der ePA-Nutzung für Sekundärzwecke (Forschung, Qualitätssicherung) im Rahmen des EHDS\n\nKritik:\n• Bundesärztekammer sieht in zentralen ePA-Regelungen einen massiven Eingriff in die Arzt-Patienten-Beziehung und in die ärztliche Schweigepflicht.',
 'Relevant für Produkte, die ePA-Schnittstellen nutzen oder integrieren. Apotheken als neue ePA-Nutzergruppe erweitert den Markt für ePA-Integration. TI-Konnektorlösungen und ePA-Middleware betroffen.',
 'ePA',
 'https://www.bundesgesundheitsministerium.de/fileadmin/Dateien/3_Downloads/Gesetze_und_Verordnungen/GuV/G/GeDIG_RefE.pdf',
 ARRAY['GeDiG','ePA','Apotheke','AMTS','eÜberweisung','SGB V']),

-- EHDS
('GeDiG',
 'Gesetz für Daten und digitale Innovation im Gesundheitswesen',
 'parlamentarische Beratung',
 'EU-VO 2025/327',
 'Umsetzung des Europäischen Gesundheitsdatenraums (EHDS)',
 E'Das GeDiG setzt die EU-Verordnung 2025/327 über den Europäischen Gesundheitsdatenraum (European Health Data Space, EHDS) in deutsches Recht um.\n\nPrimärnutzung (Patientenversorgung):\n• Patienten erhalten EU-weit Zugang zu ihren Gesundheitsdaten\n• ePA dient als nationaler EHDS-Datenzugangspunkt\n• Interoperabilität zwischen EU-Mitgliedstaaten verpflichtend\n\nSekundärnutzung (Forschung & Innovation):\n• Nutzung anonymisierter oder pseudonymisierter Gesundheitsdaten für Forschung, Statistik, Politikgestaltung\n• Datenzugangsstelle beim BfArM wird zur nationalen EHDS-Zugangsstelle\n• Antragsbasierter Datenzugang für Forscher, Behörden, Industrie\n• Voraussetzung: Zweckbindung, Datenschutz-Grundverordnung (DSGVO) vollständig einhalten\n\nZeitplan:\n• EU-VO 2025/327 gilt seit 2025\n• Nationales Umsetzungsgesetz (GeDiG) muss bis zur vom EU-Recht vorgegebenen Frist in Kraft treten',
 'Eröffnet neue Geschäftsfelder: Datenprodukte, Forschungspartner-Anbindung, EHDS-Zugangsdienste. Alliance-Partner aus Pharma/Forschung direkt betroffen. KIM/TI-Messenger als mögliche sichere Übertragungswege in EHDS-Kontext.',
 'Datenzugang',
 'https://eur-lex.europa.eu/legal-content/DE/TXT/?uri=OJ:L_202500327',
 ARRAY['GeDiG','EHDS','EU','Datenzugang','Forschung','BfArM','Sekundärnutzung']),

-- Interoperabilität
('GeDiG',
 'Gesetz für Daten und digitale Innovation im Gesundheitswesen',
 'parlamentarische Beratung',
 '§§ in SGB V / SGB XI',
 'Interoperabilitätspflichten',
 E'Das GeDiG schafft verbindliche Interoperabilitätspflichten für Leistungserbringer und Systemhersteller.\n\nKernregelungen:\n• Leistungserbringer müssen Gesundheitsdaten künftig in interoperablen Formaten vorhalten (HL7 FHIR als Leitstandard)\n• Hersteller von Praxisverwaltungssystemen (PVS), Krankenhausinformationssystemen (KIS) und weiterer IT-Systeme müssen Interoperabilität technisch sicherstellen\n• Schnittstellen müssen für ePA, EHDS und TI-Dienste offen sein\n• Zertifizierungsanforderungen für Systeme, die in der TI betrieben werden\n• Einheitliche Semantik und Syntax über alle Versorgungssektoren (ambulant, stationär, Pflege)\n\nUmsetzungsfristen:\n• Gestaffelte Fristen für verschiedene Systemkategorien; konkrete Daten werden per Verordnung festgesetzt\n\nKritik:\n• Deutsche Krankenhausgesellschaft (DKG): Neue Verpflichtungen und technische Anforderungen berücksichtigen die reale Umsetzbarkeit in Krankenhäusern nicht ausreichend.',
 'Direkt relevant für alle IT-Produkte, die im Gesundheitswesen eingesetzt werden. Interoperabilitätspflicht schafft Nachfrage nach Middleware, Integrationsplattformen und FHIR-Lösungen. Alliance-Partner müssen Konformität sicherstellen.',
 'Interoperabilität',
 'https://www.bundesgesundheitsministerium.de/fileadmin/Dateien/3_Downloads/Gesetze_und_Verordnungen/GuV/G/GeDIG_RefE.pdf',
 ARRAY['GeDiG','Interoperabilität','FHIR','PVS','KIS','SGB V']),

-- TI-Kommunikation
('GeDiG',
 'Gesetz für Daten und digitale Innovation im Gesundheitswesen',
 'parlamentarische Beratung',
 '§§ in SGB V',
 'TI-Kommunikation: KIM, TI-Messenger, Fax-Ablösung',
 E'Das GeDiG schreibt den verpflichtenden Ausbau sicherer Kommunikationswege in der Telematikinfrastruktur vor und beendet das Fax im Gesundheitswesen.\n\nKernregelungen:\n• KIM (Kommunikation im Medizinwesen): Verpflichtende Nutzung für definierte Kommunikationsprozesse (z. B. Arztbriefe, Rezepte, Befundübermittlung)\n• TI-Messenger: Verpflichtender Einsatz für Sofortkommunikation innerhalb der TI; soll Fax und herkömmliche E-Mail ersetzen\n• Fax-Ablösung: Gesetzliche Festlegung des Ablöse-Termins für das Fax im professionellen Gesundheitswesen\n• Sichere Übermittlung von Patientendaten nur noch über TI-zertifizierte Kanäle\n• Sanktionsmechanismen für Leistungserbringer, die weiter unsichere Kommunikation einsetzen\n\nGematik-Rolle:\n• gematik erhält erweiterte Befugnisse zur Durchsetzung und Zertifizierung von TI-Kommunikationslösungen',
 'Kernmarkt von eHealth Sales. KIM- und TI-Messenger-Produkte sind direkt durch diese Pflichten adressiert. Fax-Ablösung schafft Bedarf bei Bestandskunden. Vertriebsargument für PKV- und Leistungserbringer-Kunden.',
 'TI',
 'https://www.bundesgesundheitsministerium.de/presse/pressemitteilungen/kabinett-beschliesst-gedig-pm-15-07-2026',
 ARRAY['GeDiG','KIM','TI-Messenger','Fax','TI','gematik','Kommunikation']),

-- gematik
('GeDiG',
 'Gesetz für Daten und digitale Innovation im Gesundheitswesen',
 'parlamentarische Beratung',
 '§§ in SGB V',
 'Erweiterte Aufgaben der gematik',
 E'Das GeDiG stärkt die Rolle der gematik als nationale Infrastrukturgesellschaft für die Digitalisierung des Gesundheitswesens.\n\nNeue Aufgaben und Befugnisse:\n• Betriebsstabilität der TI: gematik erhält verschärfte Durchsetzungsbefugnisse gegenüber TI-Dienstleistern bei Betriebsstörungen\n• Cyberresilienz: Neue Mindeststandards für TI-Komponenten hinsichtlich IT-Sicherheit; Anlehnung an BSI-Anforderungen und NIS2-Richtlinie\n• Zertifizierung: Erweiterte Zertifizierungspflichten für Konnektoren, TI-Messenger, KIM-Dienste und EHDS-Zugangspunkte\n• Koordination EHDS: gematik wird nationale Anlaufstelle für technische EHDS-Fragen\n• Interoperabilitätsverzeichnis: gematik führt das nationale Interoperabilitätsverzeichnis und kann Standards verbindlich festschreiben',
 'Alle Produkte, die eine gematik-Zulassung benötigen (Konnektoren, KIM, TI-Messenger), sind direkt betroffen. Höhere Zertifizierungsanforderungen können Markteintrittsbarrieren erhöhen. Bestehende Zulassungen müssen ggf. erneuert werden.',
 'TI',
 'https://www.bundesgesundheitsministerium.de/fileadmin/Dateien/3_Downloads/Gesetze_und_Verordnungen/GuV/G/GeDIG_RefE.pdf',
 ARRAY['GeDiG','gematik','TI','Zertifizierung','Cyberresilienz','NIS2']),

-- BfArM
('GeDiG',
 'Gesetz für Daten und digitale Innovation im Gesundheitswesen',
 'parlamentarische Beratung',
 '§§ in SGB V / GDNG',
 'Datenzugangsstelle BfArM — Forschungsdatenzentrum',
 E'Das GeDiG baut die Datenzugangsstelle beim Bundesinstitut für Arzneimittel und Medizinprodukte (BfArM) aus und macht sie zur nationalen EHDS-Zugangsstelle für Sekundärdaten.\n\nKernregelungen:\n• Das Forschungsdatenzentrum Gesundheit (FDZ) beim BfArM wird weiterentwickelt und erhält mehr Kompetenzen\n• Antragsbasierter Zugang für Forscher, Behörden und Industrieunternehmen zu pseudonymisierten Gesundheitsdaten\n• Verknüpfung von Abrechnungsdaten (GKV), ePA-Daten, Registerdaten\n• Technische und rechtliche Voraussetzungen für EHDS-Sekundärnutzung werden harmonisiert\n• Treuhänder-Modell: Datenhaltung bleibt beim BfArM, Analyse in sicherer Umgebung (Secure Processing Environment)\n\nEU-Anbindung:\n• BfArM wird nationaler EHDS-Zugangspunkt (Health Data Access Body) gemäß EU-VO 2025/327',
 'Forschungs- und Industrie-Partner der Alliance können potenziell Zugang zu Forschungsdaten erhalten. Datenprodukte rund um BfArM-Infrastruktur sind ein wachsendes Marktsegment. Relevant für PKV-Modul und Qualitätssicherungsprodukte.',
 'Datenzugang',
 'https://www.bundesgesundheitsministerium.de/fileadmin/Dateien/3_Downloads/Gesetze_und_Verordnungen/GuV/G/GeDIG_RefE.pdf',
 ARRAY['GeDiG','BfArM','FDZ','Forschungsdaten','EHDS','Sekundärnutzung']),

-- DiGA
('GeDiG',
 'Gesetz für Daten und digitale Innovation im Gesundheitswesen',
 'parlamentarische Beratung',
 '§ 139e SGB V',
 'DiGA — Anpassungen Digitale Gesundheitsanwendungen',
 E'Das GeDiG nimmt Anpassungen am DiGA-Verfahren (§ 139e SGB V) vor, das die Zulassung und Erstattung digitaler Gesundheitsanwendungen regelt.\n\nGeplante Änderungen:\n• Überarbeitung der Nutzennachweispflichten für DiGAs der Klasse II (dauerhaft)\n• Anpassungen bei der Preisverhandlung zwischen DiGA-Herstellern und GKV-Spitzenverband\n• Stärkere Integration von DiGA-Daten in die ePA (DiGAs können Messwerte direkt in ePA schreiben)\n• Interoperabilitätspflichten für DiGA-Hersteller hinsichtlich FHIR-Schnittstellen\n• Vereinfachung des Zulassungsverfahrens für bestimmte DiGA-Kategorien\n\nHinweis: Die konkreten Änderungsartikel am § 139e SGB V sind im Referentenentwurf enthalten; die endgültige Fassung kann durch parlamentarische Beratung noch verändert werden.',
 'Alliance-Partner, die DiGAs entwickeln oder vertreiben, sind direkt betroffen. ePA-Integration von DiGA-Daten schafft neue Marktchancen. FHIR-Pflichten erhöhen Entwicklungsaufwand bei neuen DiGA-Projekten.',
 'DiGA',
 'https://www.bundesgesundheitsministerium.de/fileadmin/Dateien/3_Downloads/Gesetze_und_Verordnungen/GuV/G/GeDIG_RefE.pdf',
 ARRAY['GeDiG','DiGA','§ 139e','SGB V','ePA','FHIR']),

-- § 25b SGB V (kritisch)
('GeDiG',
 'Gesetz für Daten und digitale Innovation im Gesundheitswesen',
 'parlamentarische Beratung',
 '§ 25b SGB V (geplant)',
 'Kassendatenanalyse — umstrittene Nutzung von Versichertendaten',
 E'§ 25b SGB V (neu, geplant) erlaubt Krankenkassen die Analyse ihrer Versichertendaten für bestimmte Zwecke, z. B. zur Prävention, zum Versorgungsmanagement und zur Qualitätssicherung.\n\nGeplanter Inhalt:\n• Krankenkassen dürfen Abrechnungs- und Leistungsdaten ihrer Versicherten auswerten, um Präventionsangebote individuell anzupassen\n• Datenanalyse soll Unter- und Überversorgung erkennen helfen\n• Technische Maßnahmen: Pseudonymisierung, Datenschutz-Folgenabschätzung, Zweckbindung\n\nHarte Kritik (Stellungnahmen Mai/Juli 2026):\n• Datenschutzkonferenz der Länder: Verletzung des Rechts auf Nichtwissen (informationelle Selbstbestimmung). Risiko eines "gläsernen Versicherten".\n• G-BA und weitere Verbände: Zu weitgehende Analysebefugnisse ohne hinreichende Opt-out-Möglichkeiten\n• Es ist wahrscheinlich, dass dieser Paragraph in der parlamentarischen Beratung noch stark überarbeitet oder gestrichen wird',
 'Heiß diskutierter Paragraph. Krankenkassen als potenzielle Kunden/Partner der Alliance sollten über die Rechtslage informiert sein. Falls in Kraft: eröffnet ggf. neue Analyseprodukte, erfordert aber DSGVO-konforme Implementierung.',
 'Datenschutz',
 'https://datenschutzkonferenz-online.de/media/st/20260518_Stellungnahme_Datenschutzbehoerden-der-Laender_Gesundheitsdaten-und-Innovations-Gesetz.pdf',
 ARRAY['GeDiG','§ 25b','SGB V','Datenschutz','Kassendaten','Recht auf Nichtwissen','umstritten']);
