-- ============================================================
-- Migration: SGB XI – Pflege-Regulatorik (8 Einträge)
-- Neue Kategorie: 'Pflege'
-- Stand: Oktober 2025
-- Ausführen nach: migration_regulatorik_cybersecurity_telemedizin.sql
-- ============================================================

INSERT INTO public.recht_datenbank
  (law_abbr, law_name, law_status, paragraph_id, paragraph_title, content, relevance_note, category, effective_date, source_url, tags)
VALUES

-- 1. § 8 Abs. 8 SGB XI – Digitalisierungsförderung
('SGB XI', 'Sozialgesetzbuch Elftes Buch – Soziale Pflegeversicherung', 'in Kraft',
 '§ 8 Abs. 8 SGB XI',
 'Förderung der Digitalisierung in der Pflege',
 E'Zugelassene ambulante und stationäre Pflegeeinrichtungen (§ 72 SGB XI) erhalten einen einmaligen Zuschuss für Investitionen in digitale Anwendungen und IT-Infrastruktur.\n\nHöhe: Bis zu 40 % der anerkannten Ausgaben, maximal 12.000 € pro Einrichtung aus dem Ausgleichsfonds der Pflegeversicherung.\n\nFörderfähig u. a.: Hard- und Software für digitale Pflegedokumentation, Dienstplanung, Kommunikationssysteme, Cybersicherheit, TI-Komponenten (Konnektor, eHBA, VPN-Zugangsdienst), Schulungen.\n\nFörderzeitraum: 2019–2030, jeweils einmalig pro Einrichtung.\n\nAntrag bei der zuständigen Pflegekasse. Richtlinien des GKV-Spitzenverbandes vom 08.04.2019, zuletzt geändert 12.07.2023.',
 'Direkter Verkaufsansatz: Pflegeeinrichtungen können bis zu 12.000 € Bundesförderung für TI-Hardware, Konnektoren und Software abrufen – eHS kann diesen Fördertopf aktiv in der Kundenberatung einsetzen, um die Einstiegshürde zu senken.',
 'Pflege',
 '2019-01-01',
 'https://www.gesetze-im-internet.de/sgb_11/__8.html',
 ARRAY['SGB XI','§ 8 Abs. 8','Digitalisierung','Förderung','Pflegeeinrichtungen','TI-Finanzierung','12000 Euro']),

-- 2. § 40a SGB XI – Digitale Pflegeanwendungen (DiPA)
('SGB XI', 'Sozialgesetzbuch Elftes Buch – Soziale Pflegeversicherung', 'in Kraft',
 '§ 40a SGB XI',
 'Digitale Pflegeanwendungen (DiPA)',
 E'Pflegebedürftige (Pflegegrad 1–5) haben Anspruch auf Versorgung mit digitalen Pflegeanwendungen, die vom BfArM in das DiPA-Verzeichnis (§ 78a SGB XI) aufgenommen wurden.\n\nGeltungsbereich: Anwendungen, die Selbstständigkeit, Kommunikation, kognitive und motorische Fähigkeiten fördern, Sicherheit stärken oder informelle Pflegepersonen unterstützen.\n\nErstattungsverfahren: Pflegekasse genehmigt Antrag des Pflegebedürftigen. Erstmalige Genehmigung zeitlich auf max. 6 Monate begrenzt.\n\nMehrkosten: Bei Funktionen über den erstattungsfähigen Umfang hinaus trägt der Pflegebedürftige die Differenz selbst.\n\nSchnittstellenregelung zu SGB V: Bei Überschneidung mit § 33a SGB V (DiGA) prüft die Pflegekasse die vorrangige Leistungspflicht der Krankenkasse.\n\nEingeführt durch DVPMG (01.01.2022), zuletzt geändert 22.12.2025.',
 'DiPA = Pflege-Pendant zur DiGA. Hersteller digitaler Pflegeanwendungen können über das Fast-Track-Verfahren (§ 78a SGB XI) BfArM-Listung und Erstattungsfähigkeit erreichen – relevantes Wachstumsfeld für eHS-Partnerlösungen.',
 'Pflege',
 '2022-01-01',
 'https://www.gesetze-im-internet.de/sgb_11/__40a.html',
 ARRAY['SGB XI','§ 40a','DiPA','digitale Pflegeanwendungen','BfArM','DVPMG','Pflegekasse','DiGA']),

-- 3. § 78a SGB XI – DiPA-Verzeichnis und Zulassungsverfahren
('SGB XI', 'Sozialgesetzbuch Elftes Buch – Soziale Pflegeversicherung', 'in Kraft',
 '§ 78a SGB XI',
 'Verzeichnis für digitale Pflegeanwendungen (BfArM)',
 E'Das Bundesinstitut für Arzneimittel und Medizinprodukte (BfArM) führt ein Verzeichnis erstattungsfähiger digitaler Pflegeanwendungen.\n\nAufnahmeverfahren: Fast-Track analog DiGA (§ 139e SGB V). Hersteller können seit Dezember 2022 Anträge stellen.\n\nPrüfkriterien: Nachweis eines pflegerischen Nutzens, Datensicherheit, Interoperabilität (HL7 FHIR).\n\nVergütung: GKV-Spitzenverband verhandelt Erstattungsbetrag innerhalb von 3 Monaten nach Aufnahme, rückwirkend ab Listungsdatum.\n\nRechtsverordnung (VDiPA): Konkretisiert das Aufnahmeverfahren. DiPA-Rahmenvereinbarung in Kraft seit 22.06.2023.\n\nGesetzliche Grundlage: § 78a Abs. 1 und 5 SGB XI i. V. m. § 134 Abs. 3 SGB V.',
 'Marktzugangsnorm für Hersteller digitaler Pflegeanwendungen. Für eHS relevant als Orientierung für Partnerlösungen und als Nachweis regulatorischer Absicherung von Produktempfehlungen gegenüber Pflegeeinrichtungen.',
 'Pflege',
 '2022-12-01',
 'https://www.gesetze-im-internet.de/sgb_11/__78a.html',
 ARRAY['SGB XI','§ 78a','DiPA','BfArM','Verzeichnis','Fast-Track','Vergütung','DVPMG','FHIR']),

-- 4. § 105 SGB XI – Abrechnung ambulante Pflege / KIM-Pflicht ab 2027
('SGB XI', 'Sozialgesetzbuch Elftes Buch – Soziale Pflegeversicherung', 'in Kraft',
 '§ 105 SGB XI',
 'Abrechnung ambulanter Pflegedienste – TI-Pflicht ab 01.10.2027',
 E'Ambulante Pflegedienste sind verpflichtet, Abrechnungen elektronisch über die Telematikinfrastruktur (TI) zu übermitteln.\n\nFristen:\n- Ab 01.04.2025: Elektronische Abrechnung für Leistungen nach §§ 36, 39, 45b SGB XI möglich.\n- Ab 01.10.2027: Übermittlung der Abrechnung über KIM (Kommunikation im Medizinwesen) innerhalb der TI verpflichtend für alle ambulanten Pflegedienste.\n- Ab 01.10.2027 zusätzlich: Beratungsbesuche (§ 37 SGB XI) und Leistungen der häuslichen Krankenpflege (SGB V).\n\nVoraussetzungen: TI-Anschluss nach § 341 Abs. 8 SGB V (Pflicht seit 01.07.2025), KIM-Adresse registriert.\n\nSanktion: Ohne TI-Anschluss und KIM-Adresse ist elektronische Abrechnung nicht möglich – faktischer Ausschluss von der Vergütung für ambulante Leistungen.',
 'KIM-Pflicht für ambulante Pflegedienste ab Oktober 2027 ist ein harter Compliance-Druck. Dienste ohne KIM-Adresse verlieren die Abrechnungsfähigkeit – starkes Verkaufsargument für eHS TI- und KIM-Lösungen.',
 'Pflege',
 '2025-04-01',
 'https://www.gesetze-im-internet.de/sgb_11/__105.html',
 ARRAY['SGB XI','§ 105','KIM','Abrechnung','ambulante Pflege','TI-Pflicht','2027','SGB V']),

-- 5. § 106b SGB XI – TI-Finanzierungspauschale für Pflegeeinrichtungen
('SGB XI', 'Sozialgesetzbuch Elftes Buch – Soziale Pflegeversicherung', 'in Kraft',
 '§ 106b SGB XI',
 'Finanzierung der TI-Einbindung von Pflegeeinrichtungen (TI-Pauschale)',
 E'Pflegeeinrichtungen mit Versorgungsvertrag nach § 72 SGB XI erhalten eine monatliche TI-Pauschale aus dem Ausgleichsfonds der Pflegeversicherung.\n\nBetrag (Stand 2025): 207,93 € Grundpauschale pro Einrichtung und Monat; zusätzliche Zuschläge für elektronische Heilberufsausweise (eHBAs) je ca. 7,77 €/Monat.\n\nAmbulante Pflegedienste: Kosten werden anteilig von Kranken- und Pflegekasse getragen, im Verhältnis ihrer Ausgaben für häusliche Krankenpflege zu Pflegesachleistungen (Abs. 3).\n\nVerfahren: Finanzierungsvereinbarung zwischen GKV-Spitzenverband, PKV-Verband und Trägerverbänden im Benehmen mit dem BMG (Abs. 2); angelehnt an § 380 Abs. 2 Nr. 4 SGB V.\n\nDoppelfinanzierung ausgeschlossen: Einrichtung mit § 72-Vertrag und SGB V-Vertrag erhält TI-Pauschale nur einmal.\n\nPauschale wird alle 2 Jahre angepasst.',
 'Direkte Finanzierungsgrundlage für TI-Betriebskosten in Pflegeeinrichtungen. eHS kann die TI-Pauschale (207,93 €/Monat) als laufende Gegenfinanzierung von TI-Betriebskosten und KIM-Lizenzkosten in Angeboten transparent ausweisen.',
 'Pflege',
 '2021-01-01',
 'https://www.gesetze-im-internet.de/sgb_11/__106b.html',
 ARRAY['SGB XI','§ 106b','TI-Pauschale','Finanzierung','Pflegeeinrichtungen','Ausgleichsfonds','KIM','eHBA']),

-- 6. § 114 Abs. 1 SGB XI – Digitale Qualitätsprüfungsplattform (Frist 31.10.2027)
('SGB XI', 'Sozialgesetzbuch Elftes Buch – Soziale Pflegeversicherung', 'in Kraft',
 '§ 114 Abs. 1 SGB XI',
 'Qualitätsprüfungen – Digitale Daten- und Kommunikationsplattform bis 31.10.2027',
 E'Der GKV-Spitzenverband ist verpflichtet, bis zum 31. Oktober 2027 eine digitale Daten- und Kommunikationsplattform für die Planung, Vergabe und Durchführung von Qualitätsprüfungen nach § 114 SGB XI einzurichten.\n\nGrundsatz: Bereits vorhandene digitale Übermittlungsformate zwischen Landesverbänden der Pflegekassen und dem Medizinischen Dienst (MD) bzw. PKV-Prüfdienst sind zu berücksichtigen und weiterzuentwickeln.\n\nPrüfungstypen: Regelprüfung, Anlassprüfung, Wiederholungsprüfung durch MD, PKV-Prüfdienst oder beauftragte Sachverständige.\n\nAuswirkung auf Einrichtungen: Pflegeeinrichtungen müssen Prüfdaten strukturiert und digital bereitstellen können – setzt interoperable Pflegedokumentationssysteme voraus.',
 'Bis Oktober 2027 müssen alle Qualitätsprüfungsprozesse digital abgewickelt werden. Pflegeeinrichtungen benötigen Dokumentationssysteme, die Prüfdaten exportieren können – Anknüpfungspunkt für eHS-Softwarepartner und Infrastrukturberatung.',
 'Pflege',
 '2026-04-16',
 'https://www.gesetze-im-internet.de/sgb_11/__114.html',
 ARRAY['SGB XI','§ 114','Qualitätsprüfung','MDK','Pflegedokumentation','Digitalisierung','2027','GKV-Spitzenverband']),

-- 7. § 125 SGB XI – Modellprogramm TI Pflege
('SGB XI', 'Sozialgesetzbuch Elftes Buch – Soziale Pflegeversicherung', 'in Kraft',
 '§ 125 SGB XI',
 'Modellprogramm zur Einbindung der Pflegeeinrichtungen in die TI',
 E'Der GKV-Spitzenverband führte ein wissenschaftlich begleitetes Modellprogramm zur Erprobung der TI-Anbindung in Pflegeeinrichtungen durch.\n\nLaufzeit: 2020–2024, finanziert aus dem Ausgleichsfonds der Pflegeversicherung (10 Mio. €).\n\nProjekttypen:\n- Typ A: TI-Anschluss und sektorenübergreifender Datenaustausch via KIM – 87 Einrichtungen (60 stationär, 27 ambulant).\n- Typ B: Innovative digitale Pflegeanwendungen mit TI-Bezug (Vitalwerteübertragung, digitale Medikationspläne, Kommunikationsplattformen).\n\nAbschlussberichte: BQS Institut (Oktober 2024), Prognos/GKV-Spitzenverband (Juli 2025).\n\nNachfolge: § 125b SGB XI – Kompetenzzentrum Digitalisierung und Pflege führt Ergebnisse in die Fläche.',
 'Das Modellprogramm liefert die Evidenzgrundlage für die TI-Pflichtanbindung ab 01.07.2025. Ergebnisse (87 Einrichtungen, KIM-Praxistests) belegen Umsetzbarkeit – verwertbar für eHS-Verkaufsargumentation mit Praxisbeispielen.',
 'Pflege',
 '2020-01-01',
 'https://www.gkv-spitzenverband.de/pflegeversicherung/forschung/modellprojekte_125/pflege_modellprojekte_125.jsp',
 ARRAY['SGB XI','§ 125','Modellprogramm','TI Pflege','KIM','GKV-Spitzenverband','Pilotprojekt','2024']),

-- 8. § 125b SGB XI – Kompetenzzentrum Digitalisierung und Pflege
('SGB XI', 'Sozialgesetzbuch Elftes Buch – Soziale Pflegeversicherung', 'in Kraft',
 '§ 125b SGB XI',
 'Kompetenzzentrum Digitalisierung und Pflege (KompDiP)',
 E'Auf Basis von § 125b SGB XI wurde das Kompetenzzentrum Digitalisierung und Pflege (KompDiP) eingerichtet. Finanzierung und Trägerschaft: GKV-Spitzenverband.\n\nAufgaben:\n- Unterstützung und Beratung von Pflegeeinrichtungen bei der TI-Anbindung und digitalen Transformation.\n- Schulungsangebote, Leitfäden und Best-Practice-Materialien basierend auf dem Modellprogramm nach § 125 SGB XI.\n- Vernetzung von Einrichtungen, Herstellern und Kostenträgern.\n\nZiel: Diffusion der Erkenntnisse aus dem Modellprogramm in die Regelversorgung aller Pflegeeinrichtungen.\n\nAktiv seit 2023, bundesweit.',
 'Das KompDiP ist zentraler Ansprechpartner für Pflegeeinrichtungen bei TI-Fragen – Kooperationspotenzial für eHS (Informationspartnerschaft, Sichtbarkeit als empfohlener Anbieter in Beratungsunterlagen).',
 'Pflege',
 '2023-01-01',
 'https://www.gkv-spitzenverband.de/pflegeversicherung/kompetenzzentrum_125b_sgb_xi/kompetenzzentrum_d_p_125b.jsp',
 ARRAY['SGB XI','§ 125b','KompDiP','Kompetenzzentrum','Digitalisierung','Pflege','GKV','TI-Beratung']);
