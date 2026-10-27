-- Migration: Regulatorik-Seed – Cybersecurity & Telemedizin
-- VORAUSSETZUNG: migration_regulatorik.sql muss bereits ausgeführt worden sein (Tabelle recht_datenbank)
-- AUSFÜHRUNG: Supabase Dashboard → SQL Editor → New query → Run

INSERT INTO public.recht_datenbank
  (law_abbr, law_name, law_status, paragraph_id, paragraph_title, content, relevance_note, category, effective_date, source_url, tags)
VALUES

-- =========================================================
-- CYBERSECURITY
-- =========================================================

-- SGB V § 390 – IT-Sicherheit Vertragsärzte
('SGB V',
 'Sozialgesetzbuch Fünftes Buch – Gesetzliche Krankenversicherung',
 'in Kraft',
 '§ 390 SGB V',
 'IT-Sicherheitsrichtlinie für Vertragsärzte und Praxen (KBV)',
 E'§ 390 SGB V verpflichtet die Kassenärztliche Bundesvereinigung (KBV), eine verbindliche Richtlinie zur IT-Sicherheit für alle Vertragsärzte, Vertragspsychotherapeuten und Medizinische Versorgungszentren (MVZ) zu erlassen.\n\nKBV-IT-Sicherheitsrichtlinie (gilt seit Oktober 2022):\nDie Richtlinie staffelt Anforderungen nach Praxisgröße:\n\nBasisanforderungen (alle Praxen):\n• Passwortmanagement und sichere Authentifizierung\n• Virenschutz und Firewall\n• Regelmäßige Datensicherung (Backup & Wiederherstellung)\n• Patch-Management (Software-Updates zeitnah einspielen)\n• Zugriffsschutz auf Praxissysteme\n\nErweiterte Anforderungen (mittlere Praxen, > 5 Behandler):\n• Zusätzliche Netzwerksegmentierung\n• Protokollierung von Zugriffen\n• Notfallkonzept\n\nHohe Anforderungen (Großpraxen/MVZ, > 26 Behandler):\n• Informationssicherheits-Managementsystem (ISMS)\n• Penetrationstests\n• Beauftragter für Informationssicherheit\n\nSchulungspflicht:\n• Alle Praxismitarbeiter müssen regelmäßig zu IT-Sicherheit geschult werden (Security Awareness)\n\nDoppelregulierung ab Dezember 2025:\n• Größere Praxen und MVZ unterliegen nach NIS2UmsuCG zusätzlich dem BSIG\n• Bundesärztekammer kritisiert fehlende Abgrenzung der Pflichten',
 'Direkt betroffen: alle KIM- und TI-Messenger-Kunden (Arztpraxen). IT-Sicherheitsrichtlinie ist Compliance-Voraussetzung für den TI-Betrieb. Sicherheitsprodukte und -beratung als Vertriebsansatz bei Praxis-Neukunden.',
 'Cybersecurity',
 '2022-10-01',
 'https://www.kbv.de/html/it-sicherheit.php',
 ARRAY['SGB V','§ 390','IT-Sicherheit','KBV','Richtlinie','Vertragsärzte','Praxis','Cybersecurity']),

-- SGB V § 391 – IT-Sicherheit Krankenhäuser
('SGB V',
 'Sozialgesetzbuch Fünftes Buch – Gesetzliche Krankenversicherung',
 'in Kraft',
 '§ 391 SGB V',
 'IT-Sicherheit für Krankenhäuser – B3S und NIS2',
 E'§ 391 SGB V (neu gefasst durch NIS2UmsuCG, Dezember 2025; vormals § 75c SGB V seit 2021) verpflichtet alle zugelassenen Krankenhäuser zu angemessenen Vorkehrungen für die IT-Sicherheit.\n\nKernregelungen:\n• Alle zugelassenen Krankenhäuser sind erfasst – nicht nur KRITIS-Betreiber\n• Schutzziele: Verfügbarkeit, Integrität, Vertraulichkeit und Authentizität der IT-Systeme\n• Maßnahmen müssen dem aktuellen Stand der Technik entsprechen und verhältnismäßig sein\n• Security-Awareness-Schulungen für alle Mitarbeiter mit Systemzugang verpflichtend\n• Nachweis gegenüber dem BSI alle 3 Jahre (Audit, Zertifizierung oder Selbstauskunft)\n\nBranchenspezifischer Sicherheitsstandard (B3S):\n• Krankenhäuser können die Anforderungen durch Umsetzung des B3S „Gesundheitsversorgung im Krankenhaus" nachweisen\n• B3S ist vom BSI anerkannt; aktuelle Version: B3S v1.1\n• B3S deckt gleichzeitig einen Großteil der NIS2-Anforderungen ab\n\nAusnahme (§ 391 Abs. 5):\n• Krankenhäuser, die bereits als KRITIS-Betreiber nach BSIG reguliert sind, sind von § 391 ausgenommen (Vermeidung von Doppelregulierung)\n\nInkrafttreten:\n• Als § 75c SGB V seit Januar 2022; neu als § 391 SGB V ab 6. Dezember 2025',
 'Krankenhäuser als eHealth-Sales-Kunden benötigen IT-Sicherheitslösungen (SIEM, Firewalls, Backup) als Compliance-Voraussetzung. B3S-Umsetzung ist Vertriebsargument für IT-Security-Partner der Alliance.',
 'Cybersecurity',
 '2022-01-01',
 'https://www.buzer.de/391_SGB_V.htm',
 ARRAY['SGB V','§ 391','§ 75c','IT-Sicherheit','Krankenhaus','B3S','BSI','KRITIS','NIS2','Cybersecurity']),

-- NIS2UmsuCG
('NIS2UmsuCG',
 'NIS2-Umsetzungs- und Cybersicherheitsstärkungsgesetz',
 'in Kraft',
 'BSIG (neu)',
 'NIS2-Umsetzung Deutschland – Inkrafttreten Dezember 2025',
 E'Das NIS2-Umsetzungs- und Cybersicherheitsstärkungsgesetz (NIS2UmsuCG) trat am 6. Dezember 2025 in Kraft und setzt die EU-Richtlinie 2022/2555 (NIS2) in deutsches Recht um. Es reformiert das BSI-Gesetz (BSIG) grundlegend.\n\nGesundheitswesen voll erfasst:\nGesundheitsdienstleister werden als "wichtige Einrichtungen" oder "besonders wichtige Einrichtungen" eingestuft:\n• Besonders wichtig: ≥ 250 Mitarbeiter oder > 50 Mio. € Umsatz und > 43 Mio. € Bilanzsumme\n• Wichtig: ≥ 50 Mitarbeiter oder > 10 Mio. € Umsatz und Bilanzsumme\n\nPflichten für betroffene Einrichtungen (§§ 28–38 BSIG neu):\n• Registrierung beim BSI (über "Mein Unternehmenskonto")\n• Risikomanagementsystem: Sicherheitskonzept, Zugriffskontrolle, Kryptografie, Business Continuity, Supply-Chain-Sicherheit\n• Schulungspflicht für Leitungsorgane (Geschäftsführer, Vorstände)\n\nMeldepflichten bei erheblichen Sicherheitsvorfällen:\n• 24 Stunden: Frühwarnung an BSI\n• 72 Stunden: Vorfallsbericht\n• 1 Monat: Abschlussbericht\n\nSanktionen (§ 65 BSIG):\n• Besonders wichtige Einrichtungen: bis zu 10 Mio. € oder 2 % des weltweiten Jahresumsatzes\n• Wichtige Einrichtungen: bis zu 7 Mio. € oder 1,4 % des weltweiten Jahresumsatzes\n• Persönliche Haftung von Leitungsorganen möglich\n\nBesonderheit Gesundheitswesen:\n• Krankenhäuser, die bereits nach § 391 SGB V reguliert sind, können bei Einhaltung des B3S einen Großteil der NIS2-Anforderungen abdecken',
 'Betrifft alle größeren eHealth-Sales-Kunden direkt. IT-Security-Beratung und Compliance-Produkte für Arztpraxen, MVZ, Krankenhäuser und Krankenkassen. Vertriebsargument: NIS2-Compliance als Pflicht, nicht als Option.',
 'Cybersecurity',
 '2025-12-06',
 'https://www.usd.de/nis2umsucg-offiziell-in-kraft/',
 ARRAY['NIS2UmsuCG','NIS2','BSIG','BSI','Cybersecurity','IT-Sicherheit','Gesundheitswesen','Meldepflicht','KRITIS']),

-- IT-SiG 2.0 / KRITIS
('IT-SiG 2.0',
 'IT-Sicherheitsgesetz 2.0 (Zweites Gesetz zur Erhöhung der Sicherheit informationstechnischer Systeme)',
 'in Kraft',
 '§ 8a BSIG (alt)',
 'KRITIS-Betreiber im Gesundheitswesen',
 E'Das IT-Sicherheitsgesetz 2.0 (in Kraft seit 28. Mai 2021) erweiterte den Schutz kritischer Infrastrukturen (KRITIS) und bildet die Grundlage für KRITIS-Pflichten von Krankenhäusern und anderen Gesundheitseinrichtungen.\n\nKRITIS-Sektor "Gesundheit":\nFolgende Einrichtungen gelten als Betreiber kritischer Infrastrukturen (KRITIS), wenn definierte Schwellenwerte nach der KRITIS-Verordnung (KritisV) überschritten werden:\n• Krankenhäuser: ab ca. 30.000 vollstationären Behandlungsfällen pro Jahr\n• Labore: ab bestimmten Untersuchungsvolumina\n• Pharmazeutische Großhändler und Blutbanken: nach Versorgungsrelevanz\n\nPflichten der KRITIS-Betreiber (§ 8a BSIG a.F.):\n• Technische und organisatorische Maßnahmen nach „Stand der Technik"\n• Meldung erheblicher Störungen an das BSI (§ 8b BSIG)\n• Nachweispflicht gegenüber BSI alle 2 Jahre (Audits, Prüfberichte, Zertifikate)\n• Benennung einer Kontaktstelle zum BSI (24/7 erreichbar)\n• Einsatz von Systemen zur Angriffserkennung (seit IT-SiG 2.0)\n\nSysteme zur Angriffserkennung (SzA, seit IT-SiG 2.0):\n• Pflicht zur Implementierung von SzA für KRITIS-Betreiber im Gesundheitswesen\n• Seit 1. Mai 2023 müssen KRITIS-Krankenhäuser nachweisbare SzA betreiben\n• BSI hat Orientierungshilfe zu SzA veröffentlicht\n\nWeiterentwicklung:\n• Durch NIS2UmsuCG (Dez. 2025) werden KRITIS-Anforderungen in das reformierte BSIG integriert\n• Begriff "kritische Anlage" ersetzt "KRITIS-Betreiber"\n• Schwellenwerte in der neuen KRITIS-Verordnung werden angepasst',
 'KRITIS-Krankenhäuser sind Hochwertkunden für IT-Security-Partner. SzA-Pflicht (seit 2023) schafft direkten Bedarf. Viele regionale Krankenhäuser sind noch nicht KRITIS-konform – Vertriebschance.',
 'Cybersecurity',
 '2021-05-28',
 'https://www.bsi.bund.de/DE/Themen/KRITIS-und-regulierte-Unternehmen/Kritische-Infrastrukturen/kritis_node.html',
 ARRAY['IT-SiG 2.0','KRITIS','BSI','§ 8a BSIG','Krankenhaus','SzA','Angriffserkennung','Cybersecurity','IT-Sicherheit']),

-- EU NIS2-Richtlinie
('NIS2-RL',
 'EU-Richtlinie 2022/2555 über Maßnahmen für ein hohes gemeinsames Cybersicherheitsniveau (NIS2)',
 'in Kraft',
 'Art. 3, 21, 23 RL 2022/2555',
 'NIS2-Richtlinie EU – Grundlage der deutschen Umsetzung',
 E'Die EU-Richtlinie 2022/2555 (NIS2-Richtlinie) vom 27. Dezember 2022 ersetzt die NIS1-Richtlinie (2016/1148) und schafft ein einheitliches Cybersicherheitsniveau in der EU. Deutschland hat sie durch das NIS2UmsuCG (Dez. 2025) umgesetzt.\n\nAnwendungsbereich Gesundheitswesen:\n• Gesundheitsdienstleister sind explizit als "wesentlicher Sektor" (Anhang I) eingestuft\n• Betrifft: Krankenhäuser, Krankenkassen, Arzneimittelhersteller, Medizintechnikhersteller, Forschungseinrichtungen, Labore, Blutbanken\n\nKernpflichten (Art. 21 NIS2-RL):\n• Risikoanalyse und Sicherheitskonzepte\n• Incident Response und Business Continuity\n• Sicherheit der Lieferkette (Supply Chain Security)\n• Sicherheit bei Erwerb, Entwicklung und Betrieb von IKT-Systemen\n• Kryptografie und Verschlüsselung\n• Multi-Faktor-Authentifizierung (MFA)\n• Security-Schulungen für Leitungsorgane\n\nMeldepflichten (Art. 23 NIS2-RL):\n• Erhebliche Sicherheitsvorfälle innerhalb von 24 h melden (Frühwarnung)\n• Vorfallsbericht nach 72 h\n• Abschlussbericht nach 1 Monat\n\nEU-weite Kooperation:\n• CyCLONe-Netzwerk: koordiniertes EU-Krisenmanagement bei großen Cyberangriffen\n• Gegenseitige Informationspflichten der nationalen Behörden\n\nBezug zur Telematikinfrastruktur:\n• TI-Produkte (KIM, TI-Messenger, Konnektoren) müssen NIS2-konforme Sicherheitsstandards erfüllen\n• gematik erhält durch GeDiG erweiterte Durchsetzungsbefugnisse für NIS2-Anforderungen',
 'NIS2-Richtlinie ist der EU-Rahmen hinter KRITIS, § 390/391 SGB V und NIS2UmsuCG. Alle TI-Produkte und eHealth-Dienstleistungen müssen NIS2-Anforderungen (Art. 21) erfüllen. Supply-Chain-Security betrifft Alliance-Partner direkt.',
 'Cybersecurity',
 '2023-01-16',
 'https://eur-lex.europa.eu/legal-content/DE/TXT/?uri=CELEX:32022L2555',
 ARRAY['NIS2','EU-Richtlinie','Cybersecurity','Art. 21','Gesundheitswesen','Supply Chain','MFA','gematik','TI']),

-- =========================================================
-- TELEMEDIZIN
-- =========================================================

-- TSVG Überblick
('TSVG',
 'Terminservice- und Versorgungsgesetz',
 'in Kraft',
 NULL,
 'Überblick – Videosprechstunde und Versorgungsstärkung 2019',
 E'Das Terminservice- und Versorgungsgesetz (TSVG), in Kraft seit 11. Mai 2019, verankerte die Videosprechstunde erstmals als GKV-Regelleistung und stärkte die ambulante Versorgung.\n\nTelemedizin-relevante Kernregelungen:\n• § 87 SGB V (geändert): Auftrag an den Bewertungsausschuss (BA), Videosprechstunden im EBM zu verankern und zu vergüten\n• Erste EBM-Ziffern für Videosprechstunden ab Juli 2019\n• § 365 SGB V: Technische Anforderungen für zugelassene Videodienste\n\nVersorgungsstärkung:\n• Terminservicestellen (TSS) bei den KVen: 24/7-Erreichbarkeit; Facharzttermin innerhalb von 4 Wochen garantiert\n• Offene Sprechstunden: Mindestens 25 Stunden/Woche für Vertragsärzte\n• Bezahlte Überweisungen in KV-Notfallpraxen bei Wartezeiten > 4 Wochen\n\nWeitere Digitalisierungsmaßnahmen:\n• Verstärkter Ausbau der TI-Anbindung für Therapeuten und Hebammen\n• Einführung des Zuzahlungsbefreiungsmanagements über eGK\n\nInkrafttreten: 11. Mai 2019',
 'TSVG schuf den GKV-Vergütungsrahmen für Telemedizin. Videosprechstunden-Anbieter sind als Infrastrukturpartner relevant. TSS-Auftrag zeigt politischen Willen zur digitalen Versorgungsstärkung.',
 'Telemedizin',
 '2019-05-11',
 'https://www.bundesgesundheitsministerium.de/themen/krankenversicherung/ambulante-versorgung/tsvg.html',
 ARRAY['TSVG','Telemedizin','Videosprechstunde','EBM','§ 87','TSS','Terminservice','GKV']),

-- SGB V §§ 87, 365 Videosprechstunde
('SGB V',
 'Sozialgesetzbuch Fünftes Buch – Gesetzliche Krankenversicherung',
 'in Kraft',
 '§§ 87, 365 SGB V',
 'Videosprechstunde – Vergütung und technische Zulassung',
 E'§ 87 SGB V (Abs. 2a, 2n, 2o) und § 365 SGB V bilden die gesetzliche Grundlage für die Videosprechstunde als GKV-Regelleistung.\n\n§ 87 Abs. 2a SGB V – Vergütung:\n• Videosprechstunden werden im EBM (Einheitlicher Bewertungsmaßstab) vergütet\n• Frühere Mengenbeschränkung von 30 % je Quartal und Arzt wurde durch DigiG 2024 weitgehend aufgehoben\n• Videokonsilleistungen werden zusätzlich vergütet\n\n§ 87 Abs. 2n SGB V:\n• Bewertungsausschuss hat Auftrag, Videosprechstunden weiterzuentwickeln und neue Leistungen aufzunehmen\n• Regelmäßige Anpassung der EBM-Ziffern an technische und medizinische Entwicklungen\n\n§ 87 Abs. 2o SGB V:\n• KBV und GKV-Spitzenverband vereinbaren Qualitätsvorgaben für Videosprechstunden\n• Anlage 31c zum BMV-Ä: gültig seit 01.03.2025; Schwerpunkt Versorgungsqualität und räumliche Nähe\n• Ab 01.09.2025: Videotermine sollen bevorzugt für Patienten im direkten Einzugsgebiet angeboten werden\n\n§ 365 SGB V – Technische Anforderungen:\n• Videosprechstunden nur über zugelassene Videodiensteanbieter\n• KBV führt und aktualisiert die Positivliste zugelassener Anbieter\n• Pflicht zur Ende-zu-Ende-Verschlüsselung\n• Keine dauerhaften Aufzeichnungen der Konsultation\n• Technische Details in Anlage 31b zum BMV-Ä',
 'Videosprechstunden-Dienste sind förderfähig (KHZG FTB 6) und GKV-vergütet. Technische Infrastruktur (TI-Zugang, Verschlüsselung, Abrechnungsanbindung) ist ein konkreter Vertriebsansatz für eHealth-Sales-Produkte.',
 'Telemedizin',
 '2019-07-01',
 'https://www.gesetze-im-internet.de/sgb_5/__365.html',
 ARRAY['SGB V','§ 87','§ 365','Videosprechstunde','EBM','Telemedizin','KBV','GKV','Anlage 31b','Anlage 31c']),

-- MBO-Ä § 7 Abs. 4 – Fernbehandlung Berufsrecht
('MBO-Ä',
 'Musterberufsordnung für Ärztinnen und Ärzte',
 'in Kraft',
 '§ 7 Abs. 4 MBO-Ä',
 'Fernbehandlung – Lockerung des Fernbehandlungsverbots 2018',
 E'§ 7 Abs. 4 der Musterberufsordnung für Ärztinnen und Ärzte (MBO-Ä) regelt die berufsrechtliche Zulässigkeit der telemedizinischen Behandlung ohne vorherigen persönlichen Kontakt.\n\nEntwicklung:\n• Bis 2018: Fernbehandlungsverbot – die ausschließliche Behandlung ohne körperlichen Arzt-Patienten-Kontakt war berufsrechtlich unzulässig\n• 121. Deutschen Ärztetag 2018 (Erfurt): Beschluss zur Lockerung des § 7 Abs. 4 MBO-Ä\n\nNeue Rechtslage (seit 2018):\n• Fernbehandlung ist im Einzelfall auch ohne vorherigen persönlichen Kontakt zulässig\n• Voraussetzungen: ärztlich vertretbar, Qualität der Versorgung gewährleistet, Patient wird über Grenzen der Fernbehandlung informiert\n• Ausschluss: keine Fernbehandlung bei unklaren, akuten oder lebensbedrohlichen Situationen ohne Erstkontakt\n\nUmsetzung durch Landesärztekammern:\n• MBO-Ä ist kein unmittelbar geltendes Recht; Länder müssen sie in ihre Kammer-Berufsordnungen übernehmen\n• Bis 2024 haben alle 17 Landesärztekammern das Fernbehandlungsverbot in verschiedenen Abstufungen gelockert\n• Bayern: Pilotprojekt bereits ab 2017 (Modellprojekt der Bayerischen LÄK)\n\nAbgrenzung:\n• Fernbehandlung ≠ Videosprechstunde: Fernbehandlung ist der allgemeine berufsrechtliche Rahmen; Videosprechstunde ist die GKV-finanzierte Unterform mit technischen Anforderungen nach § 365 SGB V\n• Privatärztliche Fernbehandlung ist möglich; GKV-Erstattung nur über § 87 SGB V / EBM',
 'Berufsrechtliche Grundlage für alle Telemedizin-Produkte. Die Lockerung des Fernbehandlungsverbots hat den Telemedizin-Markt erst eröffnet. Privatärztliche Angebote (Telekliniken, direkte Arztkontakt-Apps) sind ohne diesen Beschluss unzulässig.',
 'Telemedizin',
 '2018-05-10',
 'https://www.bundesaerztekammer.de/recht/berufsrecht/muster-berufsordnung-aerzte/',
 ARRAY['MBO-Ä','§ 7 Abs. 4','Fernbehandlung','Telemedizin','Berufsrecht','Landesärztekammer','Videosprechstunde']),

-- SGB V § 368 – Telekonsil
('SGB V',
 'Sozialgesetzbuch Fünftes Buch – Gesetzliche Krankenversicherung',
 'in Kraft',
 '§ 368 SGB V',
 'Fachärztliches Telekonsil und Teledermatologie',
 E'§ 368 SGB V regelt das fachärztliche Telekonsil – die telemedizinische Konsiliarleistung ohne direkten Arzt-Patienten-Kontakt zwischen einweisenden und konsiliarisch tätigen Ärzten.\n\nKernregelungen:\n• Hausärzte können Fachärzte über die TI um ein Telekonsil bitten\n• Das Telekonsil erfolgt ohne direkte Begegnung zwischen Facharzt und Patient – nur Befunde, Bilder und Beschreibungen werden übermittelt\n• Vergütung über eigene EBM-Ziffern (Konsiliar-Ziffern)\n• Übertragung über KIM oder TI-Messenger (datenschutzkonform, Ende-zu-Ende-verschlüsselt)\n• Dokumentation: Konsilanfrage und Konsilbericht können in der ePA gespeichert werden\n\nAnwendungsbeispiele:\n• Teledermatologie: Bilder von Hautveränderungen werden vom Hausarzt digital an den Dermatologen übermittelt; Befund ohne Patientenreise\n• Teleradiologie: Radiologische Bilder werden von einem fernen Radiologen befundet\n• Telepathologie: Gewebebilder werden digital übermittelt\n• Telekardio: EKG-Befundung aus der Ferne\n\nBedeutung:\n• Entlastung der Fachärzte durch digitale Vorfilterung\n• Besonders wertvoll in unterversorgten Regionen ohne wohnortnahe Fachärzte\n• Reduziert Patientenreisen und Wartezeiten\n\nInkrafttreten: Sukzessive ab TSVG 2019; ausgebaut durch DVPMG 2021',
 'Telekonsil-Anwendungen brauchen TI-Anbindung (KIM/TI-Messenger) und ePA-Integration – starkes Vertriebsargument. Regionen mit Facharztmangel sind primäre Zielgruppe. Teledermatologie ist bereits im GKV-Katalog.',
 'Telemedizin',
 '2021-01-01',
 'https://www.gesetze-im-internet.de/sgb_5/__368.html',
 ARRAY['SGB V','§ 368','Telekonsil','Telemedizin','Teledermatologie','KIM','TI-Messenger','ePA','Facharzt']),

-- DVPMG – Telemedizin + DiPA
('DVPMG',
 'Digitale-Versorgung-und-Pflege-Modernisierungs-Gesetz',
 'in Kraft',
 NULL,
 'Überblick – Telemedizin-Ausbau und Digitale Pflegeanwendungen (DiPA)',
 E'Das Digitale-Versorgung-und-Pflege-Modernisierungs-Gesetz (DVPMG), in Kraft seit 9. Juni 2021, erweiterte die Telemedizin-Möglichkeiten in der GKV und schuf den Rahmen für Digitale Pflegeanwendungen (DiPA).\n\nTelemedizin-Ausbau:\n• Videosprechstunden werden auf weitere Fachgruppen und Therapieformen ausgedehnt\n• Ergotherapie, Physiotherapie, Logopädie und Ernährungstherapie können per Video erbracht werden\n• Psychiatrische und psychotherapeutische Leistungen per Video wurden ausgebaut\n• Telemedizinische Konsile (§ 368 SGB V) werden gestärkt\n• Erweiterte ePA-Zugriffsmöglichkeiten für Pflegeeinrichtungen\n\nDigitale Pflegeanwendungen (DiPA):\n• Einführung eines DiPA-Verzeichnisses analog zum DiGA-Verzeichnis beim BfArM\n• Pflegebedürftige in ambulanter Pflege (SGB XI) erhalten Anspruch auf DiPAs\n• Fast-Track-Verfahren analog zu DiGA\n• Anforderungen: Datenschutz, Funktionstauglichkeit, positiver Versorgungseffekt\n\nWeitere TI-Ausbauverpflichtungen:\n• Hebammen, Physiotherapeuten, Ergo- und Logopäden erhalten Pflicht zur TI-Anbindung\n• Beschleunigter ePA-Rollout\n• Einführung der digitalen Pflegedokumentation als Pflichtanwendung in Pflegeheimen\n\nInkrafttreten: 9. Juni 2021',
 'DVPMG erweitert den Kreis der TI-pflichtigen Leistungserbringer (Therapeuten, Pflegeeinrichtungen). DiPA-Markt ist Wachstumssegment. Telepflege-Anwendungen als Produktkategorie für Alliance-Partner.',
 'Telemedizin',
 '2021-06-09',
 'https://www.bundesgesundheitsministerium.de/themen/digitalisierung/digitale-versorgung-und-pflege-modernisierungsgesetz.html',
 ARRAY['DVPMG','Telemedizin','DiPA','Pflegeanwendungen','Videosprechstunde','TI','Pflege','SGB XI','ePA']);
