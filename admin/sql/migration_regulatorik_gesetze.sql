-- Migration: Regulatorik-Seed – TI, KHZG, KHVVG, DVG, DigiG, PDSG, GDNG, DSGVO
-- VORAUSSETZUNG: migration_regulatorik.sql muss bereits ausgeführt worden sein (Tabelle recht_datenbank)
-- AUSFÜHRUNG: Supabase Dashboard → SQL Editor → New query → Run

INSERT INTO public.recht_datenbank
  (law_abbr, law_name, law_status, paragraph_id, paragraph_title, content, relevance_note, category, effective_date, source_url, tags)
VALUES

-- =========================================================
-- SGB V — Telematikinfrastruktur (Grundlagen)
-- =========================================================

('SGB V',
 'Sozialgesetzbuch Fünftes Buch – Gesetzliche Krankenversicherung',
 'in Kraft',
 '§§ 306–309, 291 SGB V',
 'Telematikinfrastruktur – Grundlagen und Anschlusspflicht',
 E'§§ 306–309 SGB V (vormals §§ 291a, 291b) definieren die rechtliche Grundlage der Telematikinfrastruktur (TI) für das deutsche Gesundheitswesen.\n\nKernregelungen:\n• § 306 SGB V: Grundstruktur der TI – bundesweites sicheres Kommunikationsnetz für alle Leistungserbringer (Ärzte, Zahnärzte, Psychotherapeuten, Krankenhäuser, Apotheken, Krankenkassen)\n• § 307 SGB V: Aufgaben der gematik – Aufbau, Betrieb und Weiterentwicklung der TI\n• § 308 SGB V: Pflicht zur Anbindung an die TI für Vertragsärzte, Zahnärzte, Krankenhäuser, Apotheken und weitere Leistungserbringer\n• § 309 SGB V: Sanktionen bei fehlender TI-Anbindung – Honorarkürzungen um 1 % bei Vertragsärzten\n• § 291 SGB V: Elektronische Gesundheitskarte (eGK) als zentraler Schlüssel zur TI-Nutzung\n\nTechnische Grundlage:\n• Konnektor: sicheres Gateway zwischen der IT der Leistungserbringer und der TI (wird durch Software-Konnektoren abgelöst)\n• Sicherer TI-Zugangspunkt für alle TI-Anwendungen (ePA, eRezept, eAU, KIM, TI-Messenger)\n\nInkrafttreten: TI sukzessive seit 2017 (eGK-Rollout); laufend erweitert durch DVG, PDSG, DVPMG, DigiG und GeDiG.',
 'Kernmarkt für eHealth Sales: Alle Produkte rund um TI-Anbindung (Konnektor, KIM, TI-Messenger) basieren auf dieser gesetzlichen Pflicht. Leistungserbringer ohne TI-Anbindung riskieren Honorarkürzungen.',
 'TI',
 '2017-07-01',
 'https://www.gesetze-im-internet.de/sgb_5/__306.html',
 ARRAY['SGB V','TI','Telematikinfrastruktur','gematik','Konnektor','Anschlusspflicht','eGK']),

-- SGB V ePA
('SGB V',
 'Sozialgesetzbuch Fünftes Buch – Gesetzliche Krankenversicherung',
 'in Kraft',
 '§§ 341–346 SGB V',
 'Elektronische Patientenakte (ePA)',
 E'§§ 341–346 SGB V regeln die elektronische Patientenakte (ePA) – ein lebenslanges, versichertengeführtes digitales Gesundheitsdossier für alle GKV-Versicherten.\n\nKernregelungen:\n• § 341 SGB V: Jede gesetzlich krankenversicherte Person hat Anspruch auf eine ePA\n• § 342 SGB V: Inhalt – Befunde, Diagnosen, Medikationsplan, Arztbriefe, Impfausweis, Kinderuntersuchungsheft, Mutterbericht, DiGA-Daten\n• § 343 SGB V: Zugriffs- und Zugriffsrechte – Versicherte bestimmen, wer Zugriff erhält\n• § 344 SGB V: Befüllungspflicht für Leistungserbringer (sukzessive ausgebaut)\n• § 345 SGB V: Technische Anforderungen – TI-basiert, gematik-zertifiziert\n• § 346 SGB V: Opt-out-Nutzung für Forschungszwecke (eingeführt durch DigiG 2024)\n\nEntwicklungsstufen:\n• 2021 (PDSG): ePA 1.0 – Opt-in-Modell, sehr geringe Nutzung (< 1 %)\n• 2024 (DigiG): ePA für alle – Opt-out, bundesweiter Rollout ab Januar 2025; alle GKV-Versicherten erhalten automatisch eine ePA\n• 2025: ePA 3.0 – elektronischer Medikationsplan, erweiterte Apothekenzugriffsrechte',
 'ePA-Anbindung und -Integration sind ein zentrales Vertriebsargument für KIM-/TI-Lösungen. Ab 2025 breite Nutzung erwartet (Opt-out). Apotheken als neue ePA-Akteure erweitern den Markt.',
 'ePA',
 '2021-01-01',
 'https://www.gesetze-im-internet.de/sgb_5/__341.html',
 ARRAY['SGB V','ePA','§ 341','Opt-out','Patientenakte','TI']),

-- SGB V eRezept
('SGB V',
 'Sozialgesetzbuch Fünftes Buch – Gesetzliche Krankenversicherung',
 'in Kraft',
 '§§ 360–363 SGB V',
 'Elektronisches Rezept (eRezept)',
 E'§§ 360–363 SGB V regeln das elektronische Rezept (eRezept) als verbindlichen Pflichtstandard für alle GKV-Verordnungen.\n\nKernregelungen:\n• § 360 SGB V: Verpflichtung für alle Vertragsärzte zur ausschließlichen Ausstellung von eRezepten\n• § 361 SGB V: Technische Infrastruktur – zentraler Fachdienst eRezept der gematik\n• § 362 SGB V: Einlösung in Apotheken über die TI oder über Apps der Krankenkassen; Ausdruck (Muster-16) weiterhin als Notfallvariante möglich\n• § 363 SGB V: Betäubungsmittelrezepte und besondere Arzneimittel unterliegen gesonderten Regelungen\n\nZeitplan:\n• Januar 2024: Pflicht für alle Vertragsärzte (durch DigiG verbindlich festgelegt)\n• Sanktionen: Kassen kürzen Vergütung bei fehlender eRezept-Fähigkeit\n\nBedeutung:\n• Das eRezept löst das rosa Muster-16-Papierrezept vollständig ab\n• Ca. 500 Mio. Rezepte jährlich werden digitalisiert\n• TI-Fachdienst der gematik verarbeitet alle eRezepte',
 'Direkt relevant für KIM- und TI-Messaging-Produkte (eRezept wird über TI-Kanäle übermittelt). Apotheken-Anbindung an TI ist Voraussetzung für eRezept-Einlösung – starkes Vertriebsargument.',
 'TI',
 '2024-01-01',
 'https://www.gesetze-im-internet.de/sgb_5/__360.html',
 ARRAY['SGB V','eRezept','§ 360','Verordnung','gematik','TI','Apotheke']),

-- SGB V eAU
('SGB V',
 'Sozialgesetzbuch Fünftes Buch – Gesetzliche Krankenversicherung',
 'in Kraft',
 '§ 295 Abs. 1 SGB V',
 'Elektronische Arbeitsunfähigkeitsbescheinigung (eAU)',
 E'§ 295 Abs. 1 SGB V regelt die elektronische Arbeitsunfähigkeitsbescheinigung (eAU) – die erste flächendeckend genutzte TI-Anwendung im Praxisalltag.\n\nKernregelungen:\n• Ärzte übermitteln AU-Bescheinigungen seit 01.01.2023 ausschließlich elektronisch direkt an die Krankenkassen\n• Krankenkassen stellen die eAU digital für Arbeitgeber bereit (Abruf über ein gesichertes Verfahren)\n• Arbeitnehmer müssen den „gelben Schein" nicht mehr zum Arbeitgeber bringen; Ausdruck auf Wunsch möglich\n• Technische Übermittlung: ausschließlich über KIM (TI-Kanal)\n\nBedeutung:\n• Ca. 150 Mio. AU-Bescheinigungen jährlich werden digital übermittelt\n• Wegbereiter und Referenzprojekt für weitere papierlose TI-Prozesse\n• Höchste TI-Nutzungsrate aller Anwendungen (nahezu 100 % der Vertragsärzte)\n\nVorläufer: Papier-AU (Muster 1, Muster 17) seit 2023 obsolet in der Arzt-Kasse-Kommunikation.',
 'eAU ist Nachweis der Praxistauglichkeit von KIM. Praxen, die KIM noch nicht nutzen, verstoßen gegen ihre Pflicht. Starkes Argument für KIM-Einführung bei Bestandskunden ohne aktives KIM.',
 'TI',
 '2023-01-01',
 'https://www.gesetze-im-internet.de/sgb_5/__295.html',
 ARRAY['SGB V','eAU','§ 295','KIM','Arbeitsunfähigkeit','TI']),

-- SGB V KIM / TI-Messenger
('SGB V',
 'Sozialgesetzbuch Fünftes Buch – Gesetzliche Krankenversicherung',
 'in Kraft',
 '§ 311 SGB V (KIM), § 311a SGB V (TI-Messenger)',
 'KIM und TI-Messenger – sichere Kommunikation in der TI',
 E'§ 311 SGB V und § 311a SGB V regeln die sicheren digitalen Kommunikationswege in der Telematikinfrastruktur.\n\nKIM – Kommunikation im Medizinwesen (§ 311 SGB V):\n• Verschlüsselter E-Mail-Dienst innerhalb der TI\n• Pflicht zur Nutzung für definierte Kommunikationsprozesse: eAU, eArztbrief, eHeil- und Kostenplan, Befundübermittlung an Krankenkassen\n• Alle Vertragsärzte, Zahnärzte, Psychotherapeuten, Krankenhäuser und Apotheken müssen über eine KIM-Adresse verfügen\n• Mehrere zertifizierte KIM-Anbieter am Markt (Wettbewerb, Portabilität)\n\nTI-Messenger (§ 311a SGB V):\n• Sicheres Instant-Messaging innerhalb der TI für alle Leistungserbringer\n• Föderiertes offenes Protokoll (Matrix), mehrere Anbieter möglich\n• Interoperabilität: TIM-Nutzer können anbietergrenzenübergreifend kommunizieren\n• Pflicht-Rollout: sukzessive ab 2025 für Vertragsärzte; Erweiterung auf weitere Berufsgruppen\n• Ziel: Ablösung von Fax und unverschlüsselter E-Mail im professionellen Gesundheitswesen',
 'Kernproduktbereich für eHealth Sales. KIM-Pflicht ist ein starkes Vertriebsargument. TI-Messenger ist Wachstumsmarkt 2025/2026. Fax-Ablösung durch GeDiG schafft weiteren Druck zur TIM-Einführung.',
 'TI',
 '2021-01-01',
 'https://www.gesetze-im-internet.de/sgb_5/__311.html',
 ARRAY['SGB V','KIM','TI-Messenger','§ 311','§ 311a','Kommunikation','TI','Fax']),

-- =========================================================
-- KHZG — Krankenhauszukunftsgesetz
-- =========================================================

('KHZG',
 'Krankenhauszukunftsgesetz',
 'in Kraft',
 NULL,
 'Überblick – Digitalisierungsförderung Krankenhäuser',
 E'Das Krankenhauszukunftsgesetz (KHZG) vom 29. Oktober 2020 stellt 3 Mrd. Euro Bundesfördermittel für die Digitalisierung der Krankenhäuser bereit (Gesamtvolumen inkl. Länderkofinanzierung ca. 4,3 Mrd. Euro).\n\nZiel:\nModernisierung der IT-Infrastruktur in Krankenhäusern – digitale Patientenversorgung, sichere Kommunikation und effizientere Prozesse.\n\nStruktur:\n• Förderanträge bei der Bundesanstalt für Soziale Sicherung (BAS) über die Bundesländer\n• 30 % Kofinanzierung durch Länder oder Krankenhausträger erforderlich\n• 11 Fördertatbestände (FTB 1–11) als Investitionsschwerpunkte\n• FTB 2–6 tragen Pflichtcharakter: Nachweis der Nutzung bei ≥ 60 % bis 31.12.2027 erforderlich\n• Bei Nichterfüllung: Vergütungsabschläge von 2 % ab 2025\n\nFristen:\n• Antragsende: 31.12.2024\n• Nutzungsnachweis: 31.12.2027',
 'Krankenhäuser als eHealth-Sales-Kunden investieren KHZG-Mittel in TI-Produkte (KIM, TI-Messenger, IT-Security). FTB 2–6-Pflicht erzeugt Handlungsdruck bis 2027.',
 'Überblick',
 '2020-10-29',
 'https://www.bundesgesundheitsministerium.de/themen/krankenhaus/khzg.html',
 ARRAY['KHZG','Krankenhaus','Digitalisierung','Förderung','KHZF','Bundesamt für Soziale Sicherung']),

('KHZG',
 'Krankenhauszukunftsgesetz',
 'in Kraft',
 'FTB 1–11',
 'Fördertatbestände – 11 Investitionsschwerpunkte',
 E'11 Fördertatbestände (FTB) definieren die förderfähigen Investitionsbereiche des KHZG:\n\nFTB 1: Patientenportale (digitale Aufnahme, Entlassung, Kommunikation mit Patienten)\nFTB 2 (Pflicht): Klinisches Entscheidungsunterstützungssystem (klinische Dokumentation, Behandlungsleitlinien, Warnhinweise)\nFTB 3 (Pflicht): Digitale Pflegedokumentation / Pflege-Cockpit am Patientenbett\nFTB 4 (Pflicht): Medikationsmanagement (elektronischer Medikationsplan, AMTS-Prüfung)\nFTB 5 (Pflicht): Digitaler Anforderungs- und Ergebnisworkflow in der Diagnostik (Labor, Radiologie)\nFTB 6 (Pflicht): Telemedizinische Netzwerke und Videosprechstunde\nFTB 7: Leistungsanforderungs- und -steuerungssystem (interne Kommunikation, Betten-Management)\nFTB 8: Digitales Dokumentenmanagement und papierlose Ablauforganisation\nFTB 9: IT-Sicherheit (BSI-konforme Systeme, SIEM, Penetrationstests)\nFTB 10: Digitale Notaufnahme und Leitstellen-Management\nFTB 11: Digitale Infrastruktur (WLAN, Endgeräte, Vernetzung)\n\nSanktionsmechanismus FTB 2–6:\n• Ab 2025: Vergütungsabschläge, wenn Investitionen nicht ausreichend genutzt werden (< 60 % Nutzungsgrad)\n• Nachweis gegenüber BAS bis 31.12.2027',
 'FTB 4 (Medikationsmanagement) und FTB 9 (IT-Sicherheit) sind Ansatzpunkte für eHealth-Sales-Produkte. IT-Security-Partner profitieren direkt von FTB 9. TI-Produkte können unter FTB 5/7 eingeordnet werden.',
 'TI',
 '2020-10-29',
 'https://www.bundesgesundheitsministerium.de/themen/krankenhaus/khzg.html',
 ARRAY['KHZG','FTB','Fördertatbestände','Krankenhaus','IT-Security','Digitalisierung','AMTS']),

-- =========================================================
-- KHVVG — Krankenhausversorgungsverbesserungsgesetz
-- =========================================================

('KHVVG',
 'Krankenhausversorgungsverbesserungsgesetz',
 'in Kraft',
 NULL,
 'Überblick – Krankenhausreform 2024',
 E'Das Krankenhausversorgungsverbesserungsgesetz (KHVVG) ist die umfassendste Reform der Krankenhausversorgung in Deutschland seit Jahrzehnten.\n\nBundesrat-Zustimmung: 22. November 2024\nInkrafttreten: 12. Dezember 2024\n\nZiele:\n• Qualitätssteigerung durch Spezialisierung und Mindestmengen\n• Stärkere Vorhaltefinanzierung statt reiner Fallpauschalen-Vergütung (DRG)\n• Strukturbereinigung: nicht jedes Krankenhaus muss alle Leistungen anbieten\n• Sicherung der Versorgung auch in ländlichen Regionen\n\nKernelemente:\n• 65 Leistungsgruppen (LG) mit definierten Qualitätskriterien (reduziert auf 61 durch KHAG April 2026)\n• Vorhaltepauschalen: 60 % Vorhaltevergütung / 40 % Fallpauschalen (DRG)\n• Mindestvorhaltezahlen als Voraussetzung für Leistungsgruppenzuweisung durch die Länder\n• Stufenmodell für Krankenhauslevel (Level 1i – Grundversorgung bis Level 3 – Maximalversorgung)\n• Transformationsfonds: 50 Mrd. € über 10 Jahre (Bund 25 Mrd. + Länder 25 Mrd.) für Umstrukturierungen\n\nNachfolgeänderung:\n• KHAG (Krankenhausänderungsgesetz, April 2026): Reduzierung 65 → 61 LG, Vorhaltevergütung auf 2030 verschoben',
 'Krankenhäuser als KHVVG-betroffene Einrichtungen benötigen digitale Unterstützung bei LG-Dokumentation, Qualitätsnachweisen und Prozesssteuerung – Vertriebschance für KIS-integrierte TI-Lösungen.',
 'Überblick',
 '2024-12-12',
 'https://forum-verlag.com/fachwissen/gesundheitswesen-und-pflege/khvvg/',
 ARRAY['KHVVG','Krankenhaus','Krankenhausreform','Leistungsgruppen','Vorhaltefinanzierung','DRG','Transformationsfonds']),

('KHVVG',
 'Krankenhausversorgungsverbesserungsgesetz',
 'in Kraft',
 '§§ 17b, 26b KHG',
 'Leistungsgruppen und Qualitätskriterien',
 E'Das KHVVG führt 65 (nach KHAG: 61) bundesweit einheitliche Leistungsgruppen (LG) ein, die als Grundlage für Leistungsplanung, Zulassung und Vergütung dienen.\n\nSystemlogik:\n• Länder weisen jeder Krankenhausabteilung die LG zu, für die sie die Qualitätskriterien erfüllen\n• Ohne LG-Zuweisung darf eine Leistung nicht erbracht und nicht vergütet werden\n• Qualitätskriterien: Mindestfallzahlen, Facharztpräsenz, technische Ausstattung, strukturelle Anforderungen\n\nLeistungsgruppen-Bereiche (Auswahl der 61 LG):\n• Allgemeinchirurgie, Unfallchirurgie, Orthopädie\n• Innere Medizin, Kardiologie, Pneumologie, Gastroenterologie\n• Geburtshilfe, Gynäkologie\n• Neurologie, Neurochirurgie\n• Intensivmedizin, Notfallversorgung\n• Onkologie, Hämatologie\n• Pädiatrie, Neonatologie\n• Geriatrie\n\nFolgen für Krankenhäuser:\n• Krankenhäuser müssen LG-Anforderungen durch strukturelle Maßnahmen oder Kooperationen erfüllen\n• LG-Verlust = Entzug der Betriebserlaubnis für diese Leistungen\n• Kleine Krankenhäuser werden sich auf wenige Leistungsgruppen fokussieren müssen',
 'Strukturwandel schafft Bedarf nach digitalen Qualitätsnachweissystemen und Prozessdokumentation – Anknüpfungspunkt für KIS-/TI-Lösungen im Krankenhausbereich.',
 'Überblick',
 '2024-12-12',
 'https://forum-verlag.com/fachwissen/gesundheitswesen-und-pflege/khvvg/',
 ARRAY['KHVVG','Leistungsgruppen','Qualitätskriterien','Krankenhaus','Mindestmengen','KHAG']),

('KHVVG',
 'Krankenhausversorgungsverbesserungsgesetz',
 'in Kraft',
 '§ 17b KHG (geändert)',
 'Vorhaltefinanzierung und Transformationsfonds',
 E'Das KHVVG reformiert das Vergütungssystem der Krankenhäuser grundlegend: Neben Fallpauschalen (DRG) werden Vorhaltepauschalen eingeführt.\n\nVergütungslogik:\n• Vorhaltepauschalen: 60 % der leistungsgruppenspezifischen Vergütung – gezahlt unabhängig von der tatsächlichen Auslastung\n• Fallpauschalen (DRG): 40 % – weiterhin leistungsabhängig\n• Die Vorhaltepauschale richtet sich nach den DRGs der tatsächlich behandelten Fälle; sie deckt die Vorhaltekosten der zugewiesenen Kapazitäten\n• LG-Zuweisung durch das Land ist Voraussetzung für den Zugang zur Vorhaltefinanzierung\n\nZeitplan:\n• Übergangslösung ab 2025 (KHVVG)\n• Volle Vorhaltevergütung: ursprünglich 2027, durch KHAG auf 2030 verschoben\n\nTransformationsfonds:\n• Volumen: 50 Mrd. € über 10 Jahre\n• Finanzierung: Bund 25 Mrd. € + Länder 25 Mrd. €\n• Zweck: Strukturanpassungen, Krankenhaus-Umwandlungen, Bildung von Gesundheitszentren, Spezialisierungsförderung\n• Auszahlung: projektgebunden, Antragstellung erforderlich',
 'Transformationsfonds finanziert Umstrukturierungen – schafft Investitionsspielraum für Digitalisierung. Vorhaltepauschalen-Logik fördert Spezialisierung und Kooperationen, was neue IT-Verbundlösungen erfordert.',
 'Überblick',
 '2024-12-12',
 'https://www.roedl.com/insights/bezahlung-krankenhaeuser-neue-vorhalteverguetung/',
 ARRAY['KHVVG','Vorhaltefinanzierung','DRG','Fallpauschalen','Transformationsfonds','Krankenhaus']),

-- =========================================================
-- DVG — Digitale-Versorgung-Gesetz
-- =========================================================

('DVG',
 'Digitale-Versorgung-Gesetz',
 'in Kraft',
 '§ 33a SGB V',
 'Digitale Gesundheitsanwendungen (DiGA) – Apps auf Rezept',
 E'Das Digitale-Versorgung-Gesetz (DVG), in Kraft seit 19. Dezember 2019, schuf erstmals einen gesetzlichen Anspruch auf Digitale Gesundheitsanwendungen (DiGA) für GKV-Versicherte.\n\nGesetzlicher Anspruch (§ 33a SGB V, NEU durch DVG):\n• GKV-Versicherte haben Anspruch auf Versorgung mit DiGAs, die im BfArM-Verzeichnis gelistet sind\n• Verordnung durch jeden Arzt, Zahnarzt oder Psychotherapeuten möglich\n• Alternativ: Genehmigung durch die Krankenkasse\n\nFast-Track-Verfahren (BfArM):\n• Antragseinreichung durch Hersteller\n• 3-Monats-Entscheidungsfrist für BfArM\n• Vorläufige Zulassung nach Sicherheits-/Datenschutzprüfung; Nutzennachweise können innerhalb von 12 Monaten nachgereicht werden\n• Dauerzulassung nach erbrachtem Nutzennachweis\n\nVergütung:\n• 1. Jahr: Herstellerpreise (frei festgesetzt)\n• Ab Monat 13: Verhandlung mit GKV-Spitzenverband; Einigung oder Schiedsstelle\n\nAnforderungen an DiGA-Hersteller (DiGAV):\n• Datenschutz und Datensicherheit nach BSI-Standard\n• Funktionstauglichkeit, Robustheit, Patientensicherheit\n• Interoperabilität (FHIR-Schnittstellen)\n\nWeiterentwicklung:\n• DVPMG (2021): Ergänzung um Digitale Pflegeanwendungen (DiPA)\n• DigiG (2024): Reform der Nutzennachweispflichten',
 'DiGA ist ein relevantes Geschäftsfeld für Alliance-Partner aus dem Health-IT-Bereich. BfArM-Zulassung ist Marktzugang; Compliance-Anforderungen (DiGAV) sind hoch. eHealth Sales kann Hersteller beim Vertrieb und der TI-Integration unterstützen.',
 'DiGA',
 '2019-12-19',
 'https://www.bundesgesundheitsministerium.de/themen/digitalisierung/digitale-versorgung-gesetz.html',
 ARRAY['DVG','DiGA','§ 33a','Apps auf Rezept','BfArM','Fast-Track','DiGAV','GKV']),

-- =========================================================
-- DigiG — Digitalgesetz (2024)
-- =========================================================

('DigiG',
 'Gesetz zur Beschleunigung der Digitalisierung des Gesundheitswesens (Digitalgesetz)',
 'in Kraft',
 NULL,
 'Überblick – Digitalgesetz 2024',
 E'Das Digitalgesetz (DigiG) wurde am 25. März 2024 verkündet und trat am 26. März 2024 in Kraft. Es ist das zentrale Digitalisierungsgesetz der 20. Legislaturperiode.\n\nKernregelungen:\n• ePA für alle (Opt-out): Bis 15. Januar 2025 erhalten alle GKV-Versicherten automatisch eine ePA, sofern sie nicht aktiv widersprechen (§§ 341 ff. SGB V, geändert)\n• eRezept-Pflicht: Ab 01.01.2024 müssen alle Vertragsärzte eRezepte ausstellen; Sanktionen bei Nichterfüllung\n• TI-Messenger (§ 311a SGB V): Pflicht-Rollout für alle Vertragsärzte ab 2025; schrittweise Ausweitung auf weitere Berufsgruppen\n• Medikationsplan digital: Ab 15. Januar 2025 müssen Apotheken den elektronischen Medikationsplan in der ePA führen\n• DiGA-Reform: Härtere Nutzennachweisanforderungen für dauerhaft zugelassene DiGAs; Anpassungen beim Zulassungsverfahren\n• E-Rezept-Plattformen: Nur Plattformen, die alle Apotheken listen, dürfen eRezepte vermitteln\n• GDNG: Zugleich mit dem DigiG trat das Gesundheitsdatennutzungsgesetz (GDNG) in Kraft (s. separate Einträge)\n\nInkrafttreten: 26. März 2024',
 'DigiG ist der wichtigste regulatorische Treiber für 2024/2025. ePA für alle und TI-Messenger-Pflicht sind starke Vertriebsargumente für alle TI-Produkte. eRezept-Pflicht schafft Handlungsdruck bei Nachzüglern.',
 'TI',
 '2024-03-26',
 'https://www.bundesgesundheitsministerium.de/themen/digitalisierung/digitale-versorgung-gesetz.html',
 ARRAY['DigiG','ePA','eRezept','TI-Messenger','Opt-out','2024','Digitalgesetz']),

('DigiG',
 'Gesetz zur Beschleunigung der Digitalisierung des Gesundheitswesens (Digitalgesetz)',
 'in Kraft',
 '§§ 341–346 SGB V (geändert)',
 'ePA für alle – Opt-out-Modell ab 2025',
 E'Das DigiG stellt mit der Einführung der "ePA für alle" die wichtigste Änderung am ePA-System seit dessen Einführung dar.\n\nOpt-out-Modell:\n• Alle GKV-Versicherten erhalten bis 15. Januar 2025 automatisch eine ePA (Widerspruchslösung)\n• Widerspruch möglich bei der Krankenkasse – jederzeit vor und nach dem Stichtag\n• Nach Widerspruch wird die ePA nicht befüllt; bestehende Daten können gelöscht werden\n\nUmfang ePA 3.0 (ab 2025):\n• Medikationsliste (automatisch durch Apotheken befüllt ab 15.01.2025)\n• Labor- und Befunddaten\n• Arztbriefe und Diagnosen\n• Impfdokumente, Vorsorgepässe\n• DiGA-Daten\n\nForschungsnutzung (§ 346 SGB V):\n• Anonymisierte/pseudonymisierte ePA-Daten können für Forschung genutzt werden (Opt-out-Modell)\n• Gesonderter Widerspruch möglich ausschließlich gegen Forschungsnutzung\n\nBedeutung:\n• Erstmals breite ePA-Nutzung erwartet (bislang Opt-in mit < 1 % Nutzungsrate)\n• Ca. 74 Mio. GKV-Versicherte erhalten eine ePA',
 'Breite ePA-Nutzung ab 2025 schafft neuen Bedarf nach ePA-Integration für alle Leistungserbringer (Ärzte, Apotheken, Krankenhäuser). Middleware und Integrationslösungen sind gefragte Produkte.',
 'ePA',
 '2025-01-15',
 'https://www.bundesgesundheitsministerium.de/themen/digitalisierung/elektronische-patientenakte.html',
 ARRAY['DigiG','ePA','Opt-out','§ 341','§ 346','Medikationsplan','Forschung','2025']),

-- =========================================================
-- PDSG — Patientendaten-Schutz-Gesetz
-- =========================================================

('PDSG',
 'Patientendaten-Schutz-Gesetz',
 'in Kraft',
 '§§ 341–346 SGB V (Erstfassung)',
 'Überblick – Rechtsgrundlage ePA und TI-Datenschutz',
 E'Das Patientendaten-Schutz-Gesetz (PDSG), in Kraft seit 14. Oktober 2020, schuf die gesetzliche Grundlage für die elektronische Patientenakte (ePA) und stärkte den Datenschutz in der TI.\n\nKernregelungen:\n• §§ 341–346 SGB V (ERSTFASSUNG): Einführung der ePA als GKV-Pflichtleistung; Krankenkassen stellen ab 01.01.2021 eine ePA bereit\n• Opt-in-Modell (2021–2024): Versicherte müssen aktiv zustimmen (Gegenteil zum späteren Opt-out durch DigiG 2024)\n• Zugriffs-Logging: Jeder Datenzugriff auf die ePA wird protokolliert; Versicherte können das Zugriffsprotokoll jederzeit einsehen\n• Datenschutzgrundsätze: Datensparsamkeit, Zweckbindung, informationelle Selbstbestimmung (§§ 67 ff. SGB X)\n• Datensicherheit für TI-Komponenten: Mindestanforderungen nach BSI-Standards; Zertifizierungspflicht\n• Notfalldatensatz: Regelung zur strukturierten Hinterlegung von Notfalldaten auf der eGK\n• eRezept: Gesetzliche Grundlage für den gematik-Fachdienst eRezept geschaffen\n\nInkrafttreten: 14. Oktober 2020\n\nBedeutung:\nDas PDSG ist der Grundstein der heutigen ePA; die wesentlichen Weiterentwicklungen (ePA für alle, Opt-out) erfolgten durch das DigiG 2024.',
 'PDSG etablierte Datenschutzgrundsätze, die weiterhin gelten. TI-Produkte müssen BSI-Anforderungen und Zugriffslogging erfüllen. Compliance-Argument gegenüber Kunden beim Datenschutz.',
 'Datenschutz',
 '2020-10-14',
 'https://www.bundesgesundheitsministerium.de/themen/digitalisierung/patientendaten-schutz-gesetz.html',
 ARRAY['PDSG','ePA','Datenschutz','§ 341','BSI','TI','Zugriffsprotokoll','2020']),

-- =========================================================
-- GDNG — Gesundheitsdatennutzungsgesetz
-- =========================================================

('GDNG',
 'Gesundheitsdatennutzungsgesetz',
 'in Kraft',
 NULL,
 'Überblick – Forschungsdatenzugang und Sekundärnutzung',
 E'Das Gesundheitsdatennutzungsgesetz (GDNG), in Kraft seit 26. März 2024 (zusammen mit dem DigiG), erleichtert den Zugang zu Gesundheitsdaten für Forschung, Versorgungsplanung und Qualitätssicherung.\n\nKernregelungen:\n• Ausbau des Forschungsdatenzentrums Gesundheit (FDZ) beim BfArM als zentrale Datenzugangsstelle\n• Antragsbasierter Zugang für Forscher, Behörden und Gesundheitsindustrie zu pseudonymisierten GKV-Abrechnungsdaten\n• Ab 2025: Verknüpfung mit ePA-Daten möglich (Opt-out-Modell; § 346 SGB V)\n• Zweckbindung und DSGVO-Konformität: Pseudonymisierung, Secure Processing Environment (SPE), keine Rohdaten-Herausgabe\n• Krebsregister: Vereinfachter Datenzugang für Forschungsprojekte\n• Sekundärnutzung: Zulassung der Verknüpfung von Sozialdaten (DRV), GKV-Abrechnungsdaten und klinischen Daten\n• Vorbereitung auf den Europäischen Gesundheitsdatenraum (EHDS; EU-VO 2025/327)\n\nInkrafttreten: 26. März 2024',
 'Relevant für Alliance-Partner aus Pharma, MedTech und Forschung, die auf Versorgungsdaten angewiesen sind. FDZ BfArM als neuer Marktpartner. GDNG-Konformität ist Anforderung bei Datenprodukten.',
 'Datenzugang',
 '2024-03-26',
 'https://www.bundesgesundheitsministerium.de/themen/digitalisierung/gesundheitsdatennutzungsgesetz.html',
 ARRAY['GDNG','Forschungsdaten','FDZ','BfArM','Sekundärnutzung','ePA','EHDS','GKV']),

('GDNG',
 'Gesundheitsdatennutzungsgesetz',
 'in Kraft',
 '§§ 303a ff. SGB V (geändert)',
 'Forschungsdatenzentrum (FDZ) beim BfArM',
 E'Das GDNG baut das Forschungsdatenzentrum Gesundheit (FDZ) beim Bundesinstitut für Arzneimittel und Medizinprodukte (BfArM) aus und macht es zur zentralen Anlaufstelle für Gesundheitsforschungsdaten.\n\nDatensätze des FDZ:\n• GKV-Abrechnungsdaten (§§ 303a ff. SGB V): Diagnosen, Prozeduren, Arzneimitteldaten aller ca. 74 Mio. GKV-Versicherten\n• ePA-Daten (ab 2025, Opt-out): klinische Daten aus der ePA nach Einwilligungsmodell\n• Krebsregisterdaten (verknüpfbar)\n• Sozialdaten der Deutschen Rentenversicherung (DRV) für bestimmte Fragestellungen\n\nZugangsprozess:\n• Antrag beim FDZ mit Angabe von Forschungszweck und Datenschutz-Folgenabschätzung\n• BfArM prüft Zweckbindung und Verhältnismäßigkeit\n• Datenzugang über Secure Processing Environment (SPE) – Daten verlassen das FDZ nicht\n• Ergebnisse werden als aggregierte Auswertungen herausgegeben; keine Rohdaten\n• Nutzung gebührenpflichtig\n\nEU-Anbindung (EHDS):\n• BfArM wird über das GeDiG zum nationalen Health Data Access Body (HDAB) gemäß EU-VO 2025/327\n• Internationale Forschungskooperationen über EHDS-Plattform möglich',
 'FDZ BfArM ist relevanter Anknüpfungspunkt für Forschungspartner der Alliance. Datenprodukte auf Basis von FDZ-Daten sind ein wachsender Markt. EHDS-Anbindung öffnet europäischen Datenmarkt.',
 'Datenzugang',
 '2024-03-26',
 'https://www.bundesgesundheitsministerium.de/themen/digitalisierung/gesundheitsdatennutzungsgesetz.html',
 ARRAY['GDNG','FDZ','BfArM','Forschungsdaten','SPE','EHDS','Abrechnungsdaten','Krebsregister']),

-- =========================================================
-- DSGVO — Datenschutz-Grundverordnung (Art. 9 Gesundheitsdaten)
-- =========================================================

('DSGVO',
 'Datenschutz-Grundverordnung (EU) 2016/679',
 'in Kraft',
 'Art. 9 DSGVO',
 'Verarbeitung besonderer Kategorien – Gesundheitsdaten',
 E'Art. 9 DSGVO regelt den besonderen Schutz sensibler Datenkategorien, zu denen Gesundheitsdaten zählen. Er ist die Grundnorm für jede Verarbeitung von Gesundheitsdaten in der EU.\n\nDefinition Gesundheitsdaten (Art. 4 Nr. 15 DSGVO):\nPersonenbezogene Daten, die sich auf die körperliche oder geistige Gesundheit einer natürlichen Person beziehen und aus denen Informationen über deren Gesundheitszustand hervorgehen – inkl. Daten über Nutzung von Gesundheitsdienstleistungen.\n\nGrundsatz (Art. 9 Abs. 1 DSGVO):\nVerarbeitung von Gesundheitsdaten ist grundsätzlich verboten.\n\nErlaubnistatbestände (Art. 9 Abs. 2 DSGVO):\n• Buchst. a: Ausdrückliche Einwilligung – häufigste Grundlage für DiGAs und App-basierte Angebote\n• Buchst. h: Verarbeitung für medizinische Diagnose oder Behandlung (Leistungserbringer)\n• Buchst. g: Erhebliches öffentliches Interesse – Grundlage für Gesundheitsbehörden und Krankenkassen\n• Buchst. i: Öffentliches Interesse im Bereich öffentliche Gesundheit (z. B. Meldepflichten, Seuchenbekämpfung)\n• Buchst. j: Wissenschaftliche Forschung – Grundlage für FDZ BfArM und klinische Studien\n\nNationale Ergänzungen (BDSG):\n• § 22 BDSG: Verarbeitung zu Gesundheitszwecken (Öffnungsklausel)\n• § 27 BDSG: Verarbeitung für Forschung und Statistik\n\nPflichten bei Verarbeitung von Gesundheitsdaten:\n• Datenschutz-Folgenabschätzung (DSFA) nach Art. 35 DSGVO obligatorisch\n• Benennung eines Datenschutzbeauftragten\n• Technisch-organisatorische Maßnahmen (TOM) nach Art. 32 DSGVO (BSI-Standard empfohlen)',
 'Jedes Produkt im Gesundheitswesen, das personenbezogene Daten verarbeitet (DiGA, KIM, TI-Messenger, ePA-Schnittstellen), muss Art. 9 DSGVO-konform sein. Compliance ist Marktzulassungsvoraussetzung und Vertriebsargument.',
 'Datenschutz',
 '2018-05-25',
 'https://dsgvo-gesetz.de/art-9-dsgvo/',
 ARRAY['DSGVO','Art. 9','Gesundheitsdaten','Datenschutz','Einwilligung','BDSG','DSFA','Verarbeitung']);
