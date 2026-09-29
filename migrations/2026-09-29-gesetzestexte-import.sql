-- Gesetzestexte-Import aus 05_gesetze Dokumenten, 2026-09-29
-- rechtsgrundlage wird nur gesetzt wenn noch leer

-- ── TI-Finanzierung & Pflichten (Thema: ti) ──
INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('6341b398-e27d-40be-a986-ec566a68a434', 'ti', '§§ 376, 378 SGB V; § 341 Abs. 6 SGB V; § 347 SGB V', 'Finanzierung. Vertragsparteien wären KBV und GKV-SV; die Höhe hat das BMG per Festlegung gesetzt (TI-Festlegung, gültig ab 01.07.2023), übernommen als Anlage 32 BMV-Ä. Monatliche All-in-Pauschale je Standort nach Praxisgröße am letzten Quartalstag: bis 3 Ärzte 263,62 €, 4–6: 313,52 €, 7–9: 359,10 €, je weitere 3: +31,70 €. Die Pauschale steigt jeweils zum 1.1. mit dem Orientierungswert (§ 10 Abs. 2 TI-Festlegung); die reduzierten Pauschalen 2 und 3 sind zum 31.12.2025 ausgelaufen. Auszahlung über die KV mit der Quartalsabrechnung. — KBV, Stand 08.01.2026; KVN-Übersicht 2026
Rechtsgrundlage. § 378 Abs. 1–4 SGB V (Finanzierung); § 291b Abs. 5 (VSDM-Kürzung); § 341 Abs. 6 (ePA-Kürzung); § 360 Abs. 17 (E-Rezept-Kürzung); § 347 (ePA-Befüllpflicht seit 01.10.2025). — KVB-FAQ Honorarkürzungen
Anforderungen. Konnektor oder TI-Gateway, eHealth-Kartenterminal, eHBA, SMC-B. Pflichtanwendungen für die volle Pauschale in jeweils aktueller Version: NFDM/eMP, ePA (seit 2025 ePA 3.0), KIM, eAU, E-Rezept; KVen können Fachgruppen von einzelnen Anwendungen befreien. — KBV TI-Seite; KV Hessen
Nachweis und Sanktion. Nachweis gegenüber der KV quartalsweise über die Abrechnung (PVS übermittelt u. a. ePA-Fähigkeit im BESA-Satz, Feldkennungen 0225 ff.). Folgen:
Eine Anwendung fehlt: Pauschale −50 %; zwei fehlen: keine Pauschale.
Kein VSDM/keine TI-Anbindung: Honorar −2,5 %, tagesgenau bis zum Anschluss.
Keine ePA-Ausstattung: Honorar −1 % (entfällt, wenn bereits die VSDM-Kürzung greift). Seit 01.01.2026 wird das wieder vollzogen; 2025 war sanktionsfrei.
Keine E-Rezept-Fähigkeit: zusätzlich −1 % seit Q2/2024.
— KV Saarland; AOK, 12/2025
Hinweis: Privatpraxen ohne Kassenzulassung haben keinen Finanzierungsanspruch.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('ca4e83f8-d4ea-4359-be60-a3c249942444', 'ti', '§§ 376, 378 SGB V; § 341 Abs. 6 SGB V; § 347 SGB V', 'Finanzierung. Vertragsparteien wären KBV und GKV-SV; die Höhe hat das BMG per Festlegung gesetzt (TI-Festlegung, gültig ab 01.07.2023), übernommen als Anlage 32 BMV-Ä. Monatliche All-in-Pauschale je Standort nach Praxisgröße am letzten Quartalstag: bis 3 Ärzte 263,62 €, 4–6: 313,52 €, 7–9: 359,10 €, je weitere 3: +31,70 €. Die Pauschale steigt jeweils zum 1.1. mit dem Orientierungswert (§ 10 Abs. 2 TI-Festlegung); die reduzierten Pauschalen 2 und 3 sind zum 31.12.2025 ausgelaufen. Auszahlung über die KV mit der Quartalsabrechnung. — KBV, Stand 08.01.2026; KVN-Übersicht 2026
Rechtsgrundlage. § 378 Abs. 1–4 SGB V (Finanzierung); § 291b Abs. 5 (VSDM-Kürzung); § 341 Abs. 6 (ePA-Kürzung); § 360 Abs. 17 (E-Rezept-Kürzung); § 347 (ePA-Befüllpflicht seit 01.10.2025). — KVB-FAQ Honorarkürzungen
Anforderungen. Konnektor oder TI-Gateway, eHealth-Kartenterminal, eHBA, SMC-B. Pflichtanwendungen für die volle Pauschale in jeweils aktueller Version: NFDM/eMP, ePA (seit 2025 ePA 3.0), KIM, eAU, E-Rezept; KVen können Fachgruppen von einzelnen Anwendungen befreien. — KBV TI-Seite; KV Hessen
Nachweis und Sanktion. Nachweis gegenüber der KV quartalsweise über die Abrechnung (PVS übermittelt u. a. ePA-Fähigkeit im BESA-Satz, Feldkennungen 0225 ff.). Folgen:
Eine Anwendung fehlt: Pauschale −50 %; zwei fehlen: keine Pauschale.
Kein VSDM/keine TI-Anbindung: Honorar −2,5 %, tagesgenau bis zum Anschluss.
Keine ePA-Ausstattung: Honorar −1 % (entfällt, wenn bereits die VSDM-Kürzung greift). Seit 01.01.2026 wird das wieder vollzogen; 2025 war sanktionsfrei.
Keine E-Rezept-Fähigkeit: zusätzlich −1 % seit Q2/2024.
— KV Saarland; AOK, 12/2025
Hinweis: Privatpraxen ohne Kassenzulassung haben keinen Finanzierungsanspruch.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('34b5b023-7b10-4070-99ef-ad164f6b8144', 'ti', '§§ 376, 378 SGB V; § 291b Abs. 5 SGB V', 'Finanzierung. KZBV und GKV-SV; Höhe per BMG-Festlegung vom 01.11.2023, gültig ab 01.07.2023. Beträge und Staffel identisch mit den Vertragsärzten (2026: 263,62 / 313,52 / 359,10 €, je weitere 3 Zahnärzte +31,70 €). Auszahlung quartalsweise je Standort über die KZV, für 2026 erstmals im Juli für Q1. — KZVB, Stand 08/2026; GKV-SV-Vereinbarungsliste
Rechtsgrundlage. § 378 SGB V (Finanzierung); Honorarkürzungen nach § 291b Abs. 5 und § 341 Abs. 6 SGB V gelten für alle an der vertrags(zahn)ärztlichen Versorgung Teilnehmenden.
Anforderungen. Konnektor oder andere Anschlussart, eHBA, SMC-B, eHealth-Kartenterminal. Pflichtanwendungen laut KZVB u. a. NFDM/eMP und ePA in aktueller Version. Die vollständige Liste steht in § 5 der Festlegung; die habe ich nicht im Volltext geöffnet — offen.
Nachweis und Sanktion. TI-Eigenerklärung (TI-EK) gegenüber der KZV; neu zugelassene Praxen haben 3 Monate nach Anschluss Zeit, dann wird rückwirkend ab Zulassung gezahlt. Fehlt eine Anwendung: −50 %; zwei fehlen oder keine Anbindung: keine Pauschale, zusätzlich Honorarkürzung möglich. — KZVLB', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('0ce75c5d-8f60-443b-972e-7e828b8edb1f', 'ti', '§§ 376, 377 SGB V; § 341 Abs. 7 SGB V; § 5 Abs. 3e KHEntgG', 'Finanzierung. Vereinbarung GKV-SV/DKG nach § 377 Abs. 3 SGB V zum 01.01.2025, Stand 09.01.2026; ersetzt die Fassung vom 01.01.2024. Telematikzuschlag im Rahmen der Budgetverhandlung (Kostenträger nach § 18 Abs. 2 KHG):
Basis ab Vereinbarungszeitraum 2024: 40.000 € je Krankenhaus + 168,60 € je Planbett/teilstationärem Platz pro Jahr.
Erstanschluss 07/2021–12/2023 mit bereits erstatteter Erstausstattung: 30 Monate lang 7.000 € + 90,06 €/Bett.
Dynamisierung jährlich zum 1.1. mit dem Veränderungswert nach § 9 Abs. 1b KHEntgG; die konkreten Werte 2026 stehen nicht in der Vereinbarung — offen.
Abrechnung: Jahresvolumen geteilt durch vereinbarte Fallzahl, gesondert auf jeder voll-/teilstationären Rechnung; außerhalb Erlösbudget, Mehr-/Mindererlöse werden im Folgejahr voll ausgeglichen.
KH-Ambulanzen ohne organisatorische Anbindung an ein KH (ASV, HSA, PIA, SPZ u. a.): monatliche TI-Pauschale 192,80 € + 7,20 € je eHBA (Basiswerte), Refinanzierung auf Landesebene. MVZ und Notfallambulanzen nach § 75 Abs. 1b erhalten ihre Pauschale über die KV.
— Vereinbarung § 377, GKV-SV-PDF 07.01.2026; DKG-Fassung Stand 09.01.2026
Rechtsgrundlage. §§ 376, 377 SGB V; Anschlusspflicht § 341 Abs. 7 SGB V; Abschlag § 5 Abs. 3e KHEntgG bzw. § 5 Abs. 5 BPflV; Digitalisierungsabschlag § 5 Abs. 3h KHEntgG / § 5 Abs. 7 BPflV.
Anforderungen (§ 4 der Vereinbarung). Anwendungen in aktueller Version: NFDM/eMP, ePA 3.0 (spätestens sechs Monate nach 01.10.2025, also ab 01.04.2026), KIM, eAU, E-Verordnungen (seit 01.01.2025). Komponenten: Konnektor (Einbox, RZ, Highspeed) oder ausdrücklich TI-Gateway, inkl. gSMC-K und VPN-Zugangsdienst; eHealth-Kartenterminals; HBA oder zugelassene digitale Identität; SMC-B/SM-B. VSDM, eArztbrief, TI-Messenger, E-Rechnung und mobile Kartenterminals sind in der Pauschale mit abgegolten.
Nachweis und Sanktion.
Formblatt Anlage 1 (Anwendungen und Betriebsbeginn, bezogen auf das Vorjahr) in der Budgetverhandlung; Kassen dürfen ab ePA 3.0 Protokolle oder Belege mit Installationsdatum und Version anfordern.
Fehlt eine Anwendung: Zuschlag −50 % für die betroffenen Monate; zwei fehlen oder keine Anbindung: kein Zuschlag. Kürzungen erstmals im Abrechnungszeitraum 2025.
Kein TI-Anschluss: 1 % Abschlag je voll-/teilstationärem Fall; Nachweis per Formblatt Anlage 2 auf Verlangen der Kasse.
Vertragsärztlich tätige KH-Bereiche ohne VSDM: −2,5 %.
Digitalisierungsabschlag (KHZG-Dienste): bis 2 % je Fall; Nachweis jährlich zum 31.12. (erstmals 31.12.2025) maschinenlesbar mit Konformitätserklärungen; 2025/2026 zählt nur Verfügbarkeit, ab 2027 steigt der Nutzungsanteil (2027: 20 %). Ausnahmen bei beauftragtem KIS-Wechsel oder Schließung.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('6cc18cb7-5ad6-4179-b7a7-5dee7ca4d5f7', 'ti', '§§ 376, 379 SGB V', 'Finanzierung. DAV und GKV-SV; Höhe per BMG-Festlegung vom 27.06.2023 (§ 379 Abs. 2 i. V. m. § 378 Abs. 3, 4 SGB V), gültig ab 01.07.2023. Gilt nur für inländische öffentliche Apotheken. Monatliche All-in-Pauschale nach GKV-Rx-Packungen pro Jahr; Auszahlung rückwirkend zum Ende des Folgequartals durch den Nacht- und Notdienstfonds (NNF), der sich das Geld beim GKV-SV holt. Dynamisierung mit dem Punktwert nach § 87 Abs. 2e SGB V.
— NNF Zahlung & Bescheid, Stand 2026; BMG-Festlegung DAV
Rechtsgrundlage. §§ 376, 379 SGB V.
Anforderungen. Konnektor, SMC-B, HBA, stationäre Kartenterminals (Mehrbedarf für E-Rezept-Abruf per eGK einkalkuliert). Drei Pflichtanwendungen für die volle Pauschale: eMP einsehen, KIM-Adresse (seit 01.04.2024), ePA für alle (seit 01.10.2025).
Nachweis und Sanktion. Nachweise im NNF-Portal; die Apotheke hat drei Monate Zeit, eine neue Pflichtanwendung nachzuweisen (ePA: bis 31.12.2025). Eine Anwendung fehlt: −50 %; zwei fehlen: keine Zahlung, Wiederaufnahme ab dem Monat nach Nachweis. Eine gesetzliche Vergütungskürzung analog § 291b für Apotheken habe ich nicht gefunden. Der DAV hält eine Anpassung der Pauschalenhöhe nur noch per Gesetz für möglich. — PZ, 12/2025; Gelbe Liste, 05/2026', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('fa37e3b5-ba5f-4dc8-9c6d-0f3a18c95d42', 'ti', '§ 106b Abs. 1, 2 SGB XI; § 341 Abs. 8 SGB V', 'Finanzierung. Vereinbarung des Verfahrens zur Kostenerstattung zwischen GKV-SV (als Spitzenverband Bund der Pflegekassen) und den Trägerverbänden auf Bundesebene, § 106b SGB XI i. V. m. § 380 SGB V; veröffentlicht 04/2024, rückwirkend ab 01.07.2023. Anspruch hat jede nach § 72 SGB XI zugelassene Einrichtung, gebunden an den Versorgungsvertrag (nicht mehr ans IK). Finanziert von den Pflegekassen über den GKV-SV; die PKV beteiligt sich anteilig.
Basis 07/2023: Grundpauschale 192,80 €/Monat + zwei Zuschlagspauschalen je 7,20 € (eHBA).
2026: 213,75 € + je 7,99 €. Diese Zahl stammt aus einer Sekundärquelle; sie deckt sich rechnerisch mit 207,93 € (2025, GKV-SV) × 1,028.
Anschluss 01/2021–06/2023 mit bereits erstatteter Erstausstattung: 30 Monate lang −50 %.
Auszahlung quartalsweise durch den GKV-SV.
Wer Verträge nach SGB XI und SGB V hat, bekommt die Pauschale nur einmal.
— GKV-SV-Vereinbarung Pflege SGB XI (09.04.2024); GKV-SV-Vortrag Antragsportal, 03/2025; Leben Pflege Digital, Stand 2026 (sekundär)
Rechtsgrundlage. § 106b Abs. 1, 2 SGB XI (Finanzierung); § 341 Abs. 8 SGB V (Pflicht zu ePA-Zugriff und TI-Anschluss).
Anforderungen. Konnektor inkl. gSMC-K und VPN-Zugangsdienst, ggf. im Rechenzentrum, oder TI-Gateway mit RZ-Konnektor; eHealth-Kartenterminal; SMC-B (Org oder Pflege). Pflichtanwendung für die Pauschale ist KIM in aktueller Version.
Nachweis und Sanktion. Vor der ersten Zahlung Eigenerklärung im GKV-Antragsportal (Telematik-ID der SMC-B, Eintrag im Verzeichnisdienst, IK laut DCS Pflege, Versorgungsvertrag). Der GKV-SV darf bei unplausiblen Angaben Nachweise anfordern. Pro fehlender Anwendung −50 %, bei zwei keine Pauschale. Eine gesetzliche Vergütungskürzung bei fehlender Anbindung habe ich für SGB-XI-Einrichtungen nicht gefunden.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('4afb3e5b-aa00-4188-ae33-904cf28fbf47', 'ti', '§ 380 SGB V; § 360 Abs. 8 SGB V', 'Finanzierung. Eigene GKV-SV-Vereinbarung nach § 380 SGB V für Leistungserbringer, die ausschließlich Leistungen nach §§ 24g, 37 (häusliche Krankenpflege), 37b (SAPV), 37c (außerklinische Intensivpflege), 39a Abs. 1 (stationäre Hospize) oder 39c SGB V erbringen und nichts nach SGB XI abrechnen. In Kraft rückwirkend zum 01.07.2023. Beträge wie Pflege SGB XI (Basis 192,80 € + 2 × 7,20 €, 2026 dynamisiert). Kostenträger GKV; die PKV erstattet dem GKV-SV einen Anteil. Neuverhandlung der Höhe alle zwei Jahre (§ 378 Abs. 5 SGB V). — GKV-SV-Vereinbarung Pflege SGB V (10.04.2024)
Rechtsgrundlage. § 380 SGB V (Finanzierung); § 360 Abs. 8 SGB V (Anbindungspflicht HKP und AKI für den Abruf elektronischer Verordnungen).
Anforderungen. Wie Pflege SGB XI: Konnektor/TI-Gateway, Kartenterminal, SMC-B, KIM.
Nachweis und Sanktion. Eigenerklärung im GKV-Antragsportal; Nachweis der technischen Inbetriebnahme per Bestätigung des Dienstleisters (PDF), eHBA-Zuschlag per Telematik-ID. Stichprobenprüfungen möglich, Nachweise vorhalten. Eine gesetzliche Vergütungskürzung nicht gefunden.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('cdc4a8f4-4b85-4e3d-ac87-13dc0ccd9b47', 'ti', '§§ 376, 380 SGB V', 'Finanzierung. GKV-SV und Hebammenverbände, Vereinbarung nach § 380 Abs. 1 und 3 Satz 1 Nr. 1, Satz 2 SGB V, gültig ab 01.07.2023. Monatliche Grundpauschale plus Zuschlag je eHBA, quartalsweise über das GKV-Antragsportal. Den Betrag 2026 habe ich in keiner Primärquelle gefunden; Dienstleister nennen 221,74 € inkl. eHBA, was 213,75 + 7,99 € entspräche — nicht verifiziert. — GKV-SV-Vereinbarungsliste
Rechtsgrundlage. §§ 376, 380 SGB V.
Anforderungen. Konnektor oder TI-Gateway, eHealth-Kartenterminal, eHBA, SMC-B (über das eGBR), KIM.
Nachweis und Sanktion. Eigenerklärung im GKV-Antragsportal. Eine Anbindungspflicht besteht für Hebammen nicht; der DHV hat das beim BMG rückversichert. Folge bei fehlender Ausstattung ist nur der Wegfall der Pauschale. — Handelsblatt, 07/2025', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('3e5ae3b2-4e8d-4be9-939a-3c31a1ea8087', 'ti', '§ 380 SGB V; § 360 Abs. 8 SGB V', 'Finanzierung. GKV-SV und Physio-Verbände, Vereinbarung nach § 380 Abs. 1 und 3 Satz 1 Nr. 2 SGB V (Fassung 09.04.2024), gültig ab 01.07.2023, für Praxen mit Zulassung nach § 124 Abs. 1 SGB V. 2025 laut Verband 207,93 € + 7,77 € je eHBA; 2026 213,75 € + 7,99 € (sekundär). Quartalsweise über das GKV-Antragsportal. — GKV-SV-Vereinbarung Physio; Physio Deutschland, 01/2025; up|unternehmen praxis, 02/2026
Rechtsgrundlage. § 380 SGB V (Finanzierung); § 360 Abs. 8 SGB V (Anbindungspflicht für Heilmittelerbringer).
Anforderungen. Konnektor inkl. gSMC-K und VPN-Zugangsdienst oder RZ-/Gateway-Lösung, eHealth-Kartenterminal, SMC-B und eHBA über das eGBR, KIM. Der GKV-SV prüft die Anspruchsberechtigung über ein SMC-B-Verzeichnis.
Nachweis und Sanktion. Eigenerklärung im GKV-Antragsportal. Ohne Anschluss und Pflichtausstattung keine Pauschale. Eine gesetzliche Vergütungskürzung für Heilmittelerbringer habe ich nicht gefunden.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('04ca7e79-8ea0-4845-be67-e6754d6caf0b', 'ti', '§ 380 SGB V; § 360 Abs. 8 SGB V', 'Finanzierung. GKV-SV und die maßgeblichen Berufsverbände dieser vier Bereiche, TI-Finanzierungsvereinbarung nach § 380 Abs. 2 Nr. 1 und Abs. 4 Nr. 1 SGB V. Anspruch ab technischer Inbetriebnahme, frühestens ab 01.07.2024, je zugelassenem IK im Heilmittelleistungserbringerverzeichnis. Grundpauschale plus Mitarbeiterpauschale je eHBA, Auszahlung alle drei Monate; Anträge im GKV-Portal seit 01.10.2025, rückwirkend bis 07/2024 bei Antrag innerhalb eines Quartals nach Portalstart.
Betrag 2026 — strittig: Laut up|unternehmen praxis 205,83 € + 7,69 € je eHBA, weil der GKV-SV für diese Gruppen auf der Physio-Pauschale 2024 aufsetzte. Mehrere Dienstleister nennen dagegen 213,75 € wie bei Physio. Die Vereinbarungsanlage mit den Beträgen konnte ich nicht öffnen — vor Kundenaussagen im GKV-Portal prüfen. — GKV-SV-Vereinbarung Heilmittel (01.07.2024); up|unternehmen praxis, 02/2026
Rechtsgrundlage. § 380 SGB V (Finanzierung); § 360 Abs. 8 SGB V (Anbindungspflicht).
Anforderungen. Anschluss an die TI, SMC-B und eHBA über das eGBR (Telematik-ID der SMC-B ist Pflichtangabe im Portal), Kartenterminal, KIM; Details laut Eigenerklärung der Vereinbarung.
Nachweis und Sanktion. Eigenerklärung im GKV-Antragsportal; Pauschale nur, solange Komponenten, Dienste und Anwendungen vorhanden und funktionstüchtig sind. Gesetzliche Vergütungskürzung nicht gefunden.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('22f30954-7196-40db-b859-2526bdd8bed6', 'ti', '§ 380 SGB V; § 360 Abs. 8 SGB V', 'Finanzierung. GKV-SV und die maßgeblichen Berufsverbände dieser vier Bereiche, TI-Finanzierungsvereinbarung nach § 380 Abs. 2 Nr. 1 und Abs. 4 Nr. 1 SGB V. Anspruch ab technischer Inbetriebnahme, frühestens ab 01.07.2024, je zugelassenem IK im Heilmittelleistungserbringerverzeichnis. Grundpauschale plus Mitarbeiterpauschale je eHBA, Auszahlung alle drei Monate; Anträge im GKV-Portal seit 01.10.2025, rückwirkend bis 07/2024 bei Antrag innerhalb eines Quartals nach Portalstart.
Betrag 2026 — strittig: Laut up|unternehmen praxis 205,83 € + 7,69 € je eHBA, weil der GKV-SV für diese Gruppen auf der Physio-Pauschale 2024 aufsetzte. Mehrere Dienstleister nennen dagegen 213,75 € wie bei Physio. Die Vereinbarungsanlage mit den Beträgen konnte ich nicht öffnen — vor Kundenaussagen im GKV-Portal prüfen. — GKV-SV-Vereinbarung Heilmittel (01.07.2024); up|unternehmen praxis, 02/2026
Rechtsgrundlage. § 380 SGB V (Finanzierung); § 360 Abs. 8 SGB V (Anbindungspflicht).
Anforderungen. Anschluss an die TI, SMC-B und eHBA über das eGBR (Telematik-ID der SMC-B ist Pflichtangabe im Portal), Kartenterminal, KIM; Details laut Eigenerklärung der Vereinbarung.
Nachweis und Sanktion. Eigenerklärung im GKV-Antragsportal; Pauschale nur, solange Komponenten, Dienste und Anwendungen vorhanden und funktionstüchtig sind. Gesetzliche Vergütungskürzung nicht gefunden.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('403547bd-2718-4e83-825e-e3cf690b777d', 'ti', '§ 380 SGB V; § 360 Abs. 8 SGB V', 'Finanzierung. GKV-SV und die maßgeblichen Berufsverbände dieser vier Bereiche, TI-Finanzierungsvereinbarung nach § 380 Abs. 2 Nr. 1 und Abs. 4 Nr. 1 SGB V. Anspruch ab technischer Inbetriebnahme, frühestens ab 01.07.2024, je zugelassenem IK im Heilmittelleistungserbringerverzeichnis. Grundpauschale plus Mitarbeiterpauschale je eHBA, Auszahlung alle drei Monate; Anträge im GKV-Portal seit 01.10.2025, rückwirkend bis 07/2024 bei Antrag innerhalb eines Quartals nach Portalstart.
Betrag 2026 — strittig: Laut up|unternehmen praxis 205,83 € + 7,69 € je eHBA, weil der GKV-SV für diese Gruppen auf der Physio-Pauschale 2024 aufsetzte. Mehrere Dienstleister nennen dagegen 213,75 € wie bei Physio. Die Vereinbarungsanlage mit den Beträgen konnte ich nicht öffnen — vor Kundenaussagen im GKV-Portal prüfen. — GKV-SV-Vereinbarung Heilmittel (01.07.2024); up|unternehmen praxis, 02/2026
Rechtsgrundlage. § 380 SGB V (Finanzierung); § 360 Abs. 8 SGB V (Anbindungspflicht).
Anforderungen. Anschluss an die TI, SMC-B und eHBA über das eGBR (Telematik-ID der SMC-B ist Pflichtangabe im Portal), Kartenterminal, KIM; Details laut Eigenerklärung der Vereinbarung.
Nachweis und Sanktion. Eigenerklärung im GKV-Antragsportal; Pauschale nur, solange Komponenten, Dienste und Anwendungen vorhanden und funktionstüchtig sind. Gesetzliche Vergütungskürzung nicht gefunden.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('1aa04e28-7118-473d-9643-e2db57530e7b', 'ti', '§ 380 SGB V; § 360 Abs. 8 SGB V', 'Finanzierung. GKV-SV und die maßgeblichen Berufsverbände dieser vier Bereiche, TI-Finanzierungsvereinbarung nach § 380 Abs. 2 Nr. 1 und Abs. 4 Nr. 1 SGB V. Anspruch ab technischer Inbetriebnahme, frühestens ab 01.07.2024, je zugelassenem IK im Heilmittelleistungserbringerverzeichnis. Grundpauschale plus Mitarbeiterpauschale je eHBA, Auszahlung alle drei Monate; Anträge im GKV-Portal seit 01.10.2025, rückwirkend bis 07/2024 bei Antrag innerhalb eines Quartals nach Portalstart.
Betrag 2026 — strittig: Laut up|unternehmen praxis 205,83 € + 7,69 € je eHBA, weil der GKV-SV für diese Gruppen auf der Physio-Pauschale 2024 aufsetzte. Mehrere Dienstleister nennen dagegen 213,75 € wie bei Physio. Die Vereinbarungsanlage mit den Beträgen konnte ich nicht öffnen — vor Kundenaussagen im GKV-Portal prüfen. — GKV-SV-Vereinbarung Heilmittel (01.07.2024); up|unternehmen praxis, 02/2026
Rechtsgrundlage. § 380 SGB V (Finanzierung); § 360 Abs. 8 SGB V (Anbindungspflicht).
Anforderungen. Anschluss an die TI, SMC-B und eHBA über das eGBR (Telematik-ID der SMC-B ist Pflichtangabe im Portal), Kartenterminal, KIM; Details laut Eigenerklärung der Vereinbarung.
Nachweis und Sanktion. Eigenerklärung im GKV-Antragsportal; Pauschale nur, solange Komponenten, Dienste und Anwendungen vorhanden und funktionstüchtig sind. Gesetzliche Vergütungskürzung nicht gefunden.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('dd57fb19-53a4-4b26-a5ef-1d5df6e5dbb7', 'ti', '§ 380 SGB V (dem Grunde nach); § 360 SGB V', 'Finanzierung. Keine Vereinbarung. § 380 SGB V hätte GKV-SV und die Spitzenorganisationen der Hilfsmittelerbringer zu einer Vereinbarung verpflichtet; Erstattung war für präqualifizierte Betriebe (§ 126 SGB V) ab 01.07.2024 vorgesehen. Der GKV-SV sieht bislang keinen Handlungsbedarf, weil außer der E-Verordnung keine Pflichtanwendungen bestehen, und hat Verhandlungen frühestens für 2026 bzw. Sommer 2026 in Aussicht gestellt. Ein Verhandlungsergebnis habe ich bis 29.09.2026 nicht gefunden. — Verlag Orthopädie-Technik, 08/2025; Sonimundus, 04/2026
Rechtsgrundlage. § 380 SGB V (Finanzierungsanspruch dem Grunde nach); § 360 SGB V (E-Verordnung, Anbindungspflicht).
Anforderungen. SMC-B über die Handwerkskammer (Gesundheitshandwerke) bzw. das eGBR. Laut Branchenquelle ist der elektronische Berufsausweis keine Voraussetzung mehr für den Anschluss; ohne eBA bleibt aber der ePA-Zugriff verschlossen. Die Rechtsnorm dazu habe ich nicht verifiziert. — D-Trust
Nachweis und Sanktion. Mangels Vereinbarung kein Nachweisverfahren und keine Pauschale. Sanktionen bei fehlender Anbindung: unklar.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('78b3ba50-7279-4a7a-a9d9-8405062beeb6', 'ti', '§ 380 SGB V (dem Grunde nach); § 360 SGB V', 'Finanzierung. Keine Vereinbarung. § 380 SGB V hätte GKV-SV und die Spitzenorganisationen der Hilfsmittelerbringer zu einer Vereinbarung verpflichtet; Erstattung war für präqualifizierte Betriebe (§ 126 SGB V) ab 01.07.2024 vorgesehen. Der GKV-SV sieht bislang keinen Handlungsbedarf, weil außer der E-Verordnung keine Pflichtanwendungen bestehen, und hat Verhandlungen frühestens für 2026 bzw. Sommer 2026 in Aussicht gestellt. Ein Verhandlungsergebnis habe ich bis 29.09.2026 nicht gefunden. — Verlag Orthopädie-Technik, 08/2025; Sonimundus, 04/2026
Rechtsgrundlage. § 380 SGB V (Finanzierungsanspruch dem Grunde nach); § 360 SGB V (E-Verordnung, Anbindungspflicht).
Anforderungen. SMC-B über die Handwerkskammer (Gesundheitshandwerke) bzw. das eGBR. Laut Branchenquelle ist der elektronische Berufsausweis keine Voraussetzung mehr für den Anschluss; ohne eBA bleibt aber der ePA-Zugriff verschlossen. Die Rechtsnorm dazu habe ich nicht verifiziert. — D-Trust
Nachweis und Sanktion. Mangels Vereinbarung kein Nachweisverfahren und keine Pauschale. Sanktionen bei fehlender Anbindung: unklar.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('85e2cf1b-6a0a-4599-a655-bd5796729398', 'ti', '§ 380 SGB V (dem Grunde nach); § 360 SGB V', 'Finanzierung. Keine Vereinbarung. § 380 SGB V hätte GKV-SV und die Spitzenorganisationen der Hilfsmittelerbringer zu einer Vereinbarung verpflichtet; Erstattung war für präqualifizierte Betriebe (§ 126 SGB V) ab 01.07.2024 vorgesehen. Der GKV-SV sieht bislang keinen Handlungsbedarf, weil außer der E-Verordnung keine Pflichtanwendungen bestehen, und hat Verhandlungen frühestens für 2026 bzw. Sommer 2026 in Aussicht gestellt. Ein Verhandlungsergebnis habe ich bis 29.09.2026 nicht gefunden. — Verlag Orthopädie-Technik, 08/2025; Sonimundus, 04/2026
Rechtsgrundlage. § 380 SGB V (Finanzierungsanspruch dem Grunde nach); § 360 SGB V (E-Verordnung, Anbindungspflicht).
Anforderungen. SMC-B über die Handwerkskammer (Gesundheitshandwerke) bzw. das eGBR. Laut Branchenquelle ist der elektronische Berufsausweis keine Voraussetzung mehr für den Anschluss; ohne eBA bleibt aber der ePA-Zugriff verschlossen. Die Rechtsnorm dazu habe ich nicht verifiziert. — D-Trust
Nachweis und Sanktion. Mangels Vereinbarung kein Nachweisverfahren und keine Pauschale. Sanktionen bei fehlender Anbindung: unklar.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('4dfafd17-ae33-493f-b5b5-d6b5401fd126', 'ti', '§ 380 SGB V (dem Grunde nach); § 360 SGB V', 'Finanzierung. Keine Vereinbarung. § 380 SGB V hätte GKV-SV und die Spitzenorganisationen der Hilfsmittelerbringer zu einer Vereinbarung verpflichtet; Erstattung war für präqualifizierte Betriebe (§ 126 SGB V) ab 01.07.2024 vorgesehen. Der GKV-SV sieht bislang keinen Handlungsbedarf, weil außer der E-Verordnung keine Pflichtanwendungen bestehen, und hat Verhandlungen frühestens für 2026 bzw. Sommer 2026 in Aussicht gestellt. Ein Verhandlungsergebnis habe ich bis 29.09.2026 nicht gefunden. — Verlag Orthopädie-Technik, 08/2025; Sonimundus, 04/2026
Rechtsgrundlage. § 380 SGB V (Finanzierungsanspruch dem Grunde nach); § 360 SGB V (E-Verordnung, Anbindungspflicht).
Anforderungen. SMC-B über die Handwerkskammer (Gesundheitshandwerke) bzw. das eGBR. Laut Branchenquelle ist der elektronische Berufsausweis keine Voraussetzung mehr für den Anschluss; ohne eBA bleibt aber der ePA-Zugriff verschlossen. Die Rechtsnorm dazu habe ich nicht verifiziert. — D-Trust
Nachweis und Sanktion. Mangels Vereinbarung kein Nachweisverfahren und keine Pauschale. Sanktionen bei fehlender Anbindung: unklar.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('8a80efc5-474a-4383-818d-0bd1e769c766', 'ti', '§ 380 SGB V (dem Grunde nach); § 360 SGB V', 'Finanzierung. Keine Vereinbarung. § 380 SGB V hätte GKV-SV und die Spitzenorganisationen der Hilfsmittelerbringer zu einer Vereinbarung verpflichtet; Erstattung war für präqualifizierte Betriebe (§ 126 SGB V) ab 01.07.2024 vorgesehen. Der GKV-SV sieht bislang keinen Handlungsbedarf, weil außer der E-Verordnung keine Pflichtanwendungen bestehen, und hat Verhandlungen frühestens für 2026 bzw. Sommer 2026 in Aussicht gestellt. Ein Verhandlungsergebnis habe ich bis 29.09.2026 nicht gefunden. — Verlag Orthopädie-Technik, 08/2025; Sonimundus, 04/2026
Rechtsgrundlage. § 380 SGB V (Finanzierungsanspruch dem Grunde nach); § 360 SGB V (E-Verordnung, Anbindungspflicht).
Anforderungen. SMC-B über die Handwerkskammer (Gesundheitshandwerke) bzw. das eGBR. Laut Branchenquelle ist der elektronische Berufsausweis keine Voraussetzung mehr für den Anschluss; ohne eBA bleibt aber der ePA-Zugriff verschlossen. Die Rechtsnorm dazu habe ich nicht verifiziert. — D-Trust
Nachweis und Sanktion. Mangels Vereinbarung kein Nachweisverfahren und keine Pauschale. Sanktionen bei fehlender Anbindung: unklar.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('10826430-b08b-4f18-b49d-08e53d63671b', 'ti', '§ 380 SGB V (dem Grunde nach); § 360 SGB V', 'Finanzierung. Keine Vereinbarung. § 380 SGB V hätte GKV-SV und die Spitzenorganisationen der Hilfsmittelerbringer zu einer Vereinbarung verpflichtet; Erstattung war für präqualifizierte Betriebe (§ 126 SGB V) ab 01.07.2024 vorgesehen. Der GKV-SV sieht bislang keinen Handlungsbedarf, weil außer der E-Verordnung keine Pflichtanwendungen bestehen, und hat Verhandlungen frühestens für 2026 bzw. Sommer 2026 in Aussicht gestellt. Ein Verhandlungsergebnis habe ich bis 29.09.2026 nicht gefunden. — Verlag Orthopädie-Technik, 08/2025; Sonimundus, 04/2026
Rechtsgrundlage. § 380 SGB V (Finanzierungsanspruch dem Grunde nach); § 360 SGB V (E-Verordnung, Anbindungspflicht).
Anforderungen. SMC-B über die Handwerkskammer (Gesundheitshandwerke) bzw. das eGBR. Laut Branchenquelle ist der elektronische Berufsausweis keine Voraussetzung mehr für den Anschluss; ohne eBA bleibt aber der ePA-Zugriff verschlossen. Die Rechtsnorm dazu habe ich nicht verifiziert. — D-Trust
Nachweis und Sanktion. Mangels Vereinbarung kein Nachweisverfahren und keine Pauschale. Sanktionen bei fehlender Anbindung: unklar.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('5d9b8b08-d063-4fba-b4a0-41401a5aac4c', 'ti', '§ 380 SGB V; § 88 Abs. 1 Satz 2 SGB V', 'Finanzierung. GKV-SV und VDZI, Vereinbarung nach § 380 Abs. 2 Nr. 2 und Abs. 4 Nr. 3 SGB V, gültig ab 01.07.2024. Monatliche Pauschale, Start 192,80 €, Antrag und Abrechnung direkt beim GKV-SV. Betrag 2026 nicht verifiziert. — VDZI; ZINB
Rechtsgrundlage. § 380 SGB V; Datenaustausch über Vertrag nach § 88 Abs. 1 Satz 2 SGB V.
Anforderungen. SMC-B und Berufsausweis über die Handwerkskammer; TI-fähige Dentalsoftware gab es laut ZINB noch nicht.
Nachweis und Sanktion. Laut VDZI ist die Anbindung freiwillig; Folge fehlender Ausstattung ist nur der Wegfall der Pauschale.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('ae0782c4-6659-4fb3-8df1-18557efdd33e', 'ti', '§ 381 Abs. 1, 2 SGB V', 'Finanzierung. Vereinbarung nach § 381 Abs. 1 und 2 SGB V zwischen GKV-SV, DRV Bund, SVLFG (als Landwirtschaftliche Alterskasse, Beitritt nach § 381 Abs. 4), PKV-Verband und den Einrichtungsverbänden (u. a. BDPK). Fassung 17.04.2023, rückwirkend ab 01.01.2022. Ausgleich als einrichtungsindividueller TI-Zuschlag je Behandlungstag auf den Vergütungssatz, gezahlt von jedem Kostenträger für seine Belegungstage:
Anschaffung und Einbindung von Konnektor, SMC-B, Kartenterminals: über 5 Jahre.
Anpassung der IT-Infrastruktur und organisatorische Umstellung (Planung, Schulung): über 2 Jahre.
Laufender Betrieb (VPN, Wartung, Support, Updates): über 5 Jahre.
Bemessung nach Fachabteilungen/Indikationen, Standorten (Kriterium: gemeinsam genutzte IT) und Behandlungskapazitäten; Divisor = Abrechnungstage aller Träger (DRV, GKV, LAK, PKV) im Vorjahr.
Abrechnung: GKV und LAK mit Entgeltschlüssel 99051492; DRV maschinell zusammen mit den Pflegekosten, ohne gesonderten Ausweis.
Kostenträger und Rechtsgrundlage je Träger.
Anforderungen. Breitbandanschluss, angepasste Klinik-Software, VPN-Zugangsdienst, Einbox- oder RZ-Konnektor bzw. TI-Gateway, eHealth-Kartenterminals, SMC-B-Reha, eHBA. Verpflichtende Fachanwendungen für den Zuschlag sind nicht festgelegt; genannt werden KIM, VSDM, ePA.
Nachweis und Sanktion. Anlage 1 (Angaben zur Anspruchsermittlung) spätestens 6 Wochen vor geplanter Inbetriebnahme an die zuständige Stelle: federführender Kassen-Landesverband, wenn die GKV Hauptbeleger ist, sonst der federführende DRV-Träger. Unverzüglich nach Inbetriebnahme: Inbetriebnahmeprotokoll, VPN-Nachweis, Nutzungserklärung. Zahlung ab dem Ablauf eines Kalendermonats nach Inbetriebnahme. Die Anbindung ist freiwillig (PDSG); Sanktionen gibt es daher keine. — BDPK-FAQ, Stand 15.07.2026; Vereinbarung § 381 (17.04.2023); DEGEMED', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('6234d658-32a6-45c9-baa3-2361e89ae48c', 'ti', '§ 382 SGB V', 'Finanzierung. Vereinbarung des GKV-SV mit den obersten Landesbehörden bzw. von ihnen bestimmten Stellen nach § 382 Abs. 1 und 2 SGB V, Fassung 12.03.2024, gültig ab 01.07.2023. Die Rechtsträger der ÖGD-Behörden erhalten eine monatliche TI-Pauschale in entsprechender Anwendung der Vertragsärzte-Regelung; Anschluss 01/2021–06/2023 mit erstatteter Erstausstattung: 30 Monate −50 %. Konkreter Betrag 2026 und Antragsweg: nicht verifiziert. — GKV-SV-Vereinbarung ÖGD
Rechtsgrundlage. § 382 SGB V.
Anforderungen. Konnektor/Gateway, Kartenterminal, eHBA, SMC-B/SM-B oder eID für ÖGD-Behörden; Pflichtanwendungen: nicht geprüft.
Nachweis und Sanktion. Unklar; eine Anbindungspflicht mit Sanktion habe ich nicht gefunden.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('02f299c0-45ee-42f2-9dfe-fe984b72f73d', 'ti', '§ 382a SGB V', 'Finanzierung. GKV-SV-Vereinbarung nach § 382a SGB V vom 14.10.2024, Anspruch ab 01.01.2025. Berechtigt sind Fachärzte für Arbeitsmedizin und Ärzte mit Zusatzbezeichnung Betriebsmedizin, die nicht vertragsärztlich tätig sind; bei inner- und überbetrieblichen Diensten der leitende Betriebsarzt. Höhe nach Staffel der Tabelle 3 der BMG-Festlegung für Vertragsärzte, bei mehr als 9 Ärzten Zuschlag je Dreiergruppe. Ob die Dynamisierung auf 263,62 € (2026) übernommen wird, steht nicht im Auszug — offen. Auszahlung quartalsweise durch den GKV-SV. — GKV-SV-Vereinbarung Betriebsärzte
Rechtsgrundlage. § 382a SGB V i. V. m. § 352 Satz 1 Nr. 18 SGB V.
Nachweis und Sanktion. Nachweis gegenüber dem GKV-SV; fehlt er, keine Pauschale, volle Pauschale erst ab dem Monat nach Nachweis. Gesetzliche Sanktion nicht gefunden.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();


-- ── IT-Sicherheit (Thema: security) ──
INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('6341b398-e27d-40be-a986-ec566a68a434', 'security', '§ 390 SGB V; NIS2/BSIG; DSGVO Art. 32', 'Gesetzliche Grundlage. § 390 SGB V (seit DigiG vom 22.03.2024, vorher § 75b). KBV und KZBV müssen im Einvernehmen mit dem BSI eine Richtlinie zur IT-Sicherheit in der vertrags(zahn)ärztlichen Versorgung erlassen; sie konkretisiert die TOMs nach Art. 32 DSGVO und wird regelmäßig an den Stand der Technik angepasst. Die Richtlinie ist für alle Praxen verbindlich. — KZBV
Richtlinien und Stand.
KBV: Neufassung in Kraft 01.04.2025; neue Anforderungen seit 01.10.2025 verpflichtend. — KBV-Richtlinie (PDF); KBV-Praxisnachricht 03.04.2025
KZBV: Version 1.1, in Kraft 02.07.2025; neue Anforderungen seit 02.01.2026 verpflichtend. — KZBV-Richtlinie V1.1 (PDF)
Anforderungen (gestaffelt nach Personen, die ständig mit Datenverarbeitung betraut sind).
Neu seit 2025: geregelte Einarbeitung, regelmäßige Sensibilisierung und Schulung, E-Mail-Sicherheit, Prüfung von Cloud-Diensten, Backup-Wiederherstellungstests. — KVN; dsn group, 08/2026
Förderung. Keine Regelförderung für IT-Sicherheit in Praxen gefunden; die TI-Pauschale deckt nur TI-Komponenten. Ausnahme: große MVZ, radiologische Praxen und Labore, die unter NIS2 fallen, sind für Teil B des Sofortprogramms Cybersicherheit vorgesehen (siehe Krankenhäuser).
Nachweis und Sanktion. Ein Nachweis gegenüber KV/KZV ist nicht vorgesehen; Dokumentation der Maßnahmen verlangt die Richtlinie selbst. Eine Vergütungskürzung bei Nichtumsetzung gibt es im SGB V nicht. Haftungs- und Bußgeldrisiko über DSGVO (Art. 83) und Berufsrecht. MVZ/Praxen ab 50 Beschäftigten zusätzlich NIS2 mit BSI-Registrierung und Meldepflichten. Die KBV zertifiziert IT-Dienstleister, die Praxen bei der Umsetzung unterstützen (Absatz in § 390 nicht geprüft).', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('ca4e83f8-d4ea-4359-be60-a3c249942444', 'security', '§ 390 SGB V; NIS2/BSIG; DSGVO Art. 32', 'Gesetzliche Grundlage. § 390 SGB V (seit DigiG vom 22.03.2024, vorher § 75b). KBV und KZBV müssen im Einvernehmen mit dem BSI eine Richtlinie zur IT-Sicherheit in der vertrags(zahn)ärztlichen Versorgung erlassen; sie konkretisiert die TOMs nach Art. 32 DSGVO und wird regelmäßig an den Stand der Technik angepasst. Die Richtlinie ist für alle Praxen verbindlich. — KZBV
Richtlinien und Stand.
KBV: Neufassung in Kraft 01.04.2025; neue Anforderungen seit 01.10.2025 verpflichtend. — KBV-Richtlinie (PDF); KBV-Praxisnachricht 03.04.2025
KZBV: Version 1.1, in Kraft 02.07.2025; neue Anforderungen seit 02.01.2026 verpflichtend. — KZBV-Richtlinie V1.1 (PDF)
Anforderungen (gestaffelt nach Personen, die ständig mit Datenverarbeitung betraut sind).
Neu seit 2025: geregelte Einarbeitung, regelmäßige Sensibilisierung und Schulung, E-Mail-Sicherheit, Prüfung von Cloud-Diensten, Backup-Wiederherstellungstests. — KVN; dsn group, 08/2026
Förderung. Keine Regelförderung für IT-Sicherheit in Praxen gefunden; die TI-Pauschale deckt nur TI-Komponenten. Ausnahme: große MVZ, radiologische Praxen und Labore, die unter NIS2 fallen, sind für Teil B des Sofortprogramms Cybersicherheit vorgesehen (siehe Krankenhäuser).
Nachweis und Sanktion. Ein Nachweis gegenüber KV/KZV ist nicht vorgesehen; Dokumentation der Maßnahmen verlangt die Richtlinie selbst. Eine Vergütungskürzung bei Nichtumsetzung gibt es im SGB V nicht. Haftungs- und Bußgeldrisiko über DSGVO (Art. 83) und Berufsrecht. MVZ/Praxen ab 50 Beschäftigten zusätzlich NIS2 mit BSI-Registrierung und Meldepflichten. Die KBV zertifiziert IT-Dienstleister, die Praxen bei der Umsetzung unterstützen (Absatz in § 390 nicht geprüft).', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('34b5b023-7b10-4070-99ef-ad164f6b8144', 'security', '§ 390 SGB V; NIS2/BSIG; DSGVO Art. 32', 'Gesetzliche Grundlage. § 390 SGB V (seit DigiG vom 22.03.2024, vorher § 75b). KBV und KZBV müssen im Einvernehmen mit dem BSI eine Richtlinie zur IT-Sicherheit in der vertrags(zahn)ärztlichen Versorgung erlassen; sie konkretisiert die TOMs nach Art. 32 DSGVO und wird regelmäßig an den Stand der Technik angepasst. Die Richtlinie ist für alle Praxen verbindlich. — KZBV
Richtlinien und Stand.
KBV: Neufassung in Kraft 01.04.2025; neue Anforderungen seit 01.10.2025 verpflichtend. — KBV-Richtlinie (PDF); KBV-Praxisnachricht 03.04.2025
KZBV: Version 1.1, in Kraft 02.07.2025; neue Anforderungen seit 02.01.2026 verpflichtend. — KZBV-Richtlinie V1.1 (PDF)
Anforderungen (gestaffelt nach Personen, die ständig mit Datenverarbeitung betraut sind).
Neu seit 2025: geregelte Einarbeitung, regelmäßige Sensibilisierung und Schulung, E-Mail-Sicherheit, Prüfung von Cloud-Diensten, Backup-Wiederherstellungstests. — KVN; dsn group, 08/2026
Förderung. Keine Regelförderung für IT-Sicherheit in Praxen gefunden; die TI-Pauschale deckt nur TI-Komponenten. Ausnahme: große MVZ, radiologische Praxen und Labore, die unter NIS2 fallen, sind für Teil B des Sofortprogramms Cybersicherheit vorgesehen (siehe Krankenhäuser).
Nachweis und Sanktion. Ein Nachweis gegenüber KV/KZV ist nicht vorgesehen; Dokumentation der Maßnahmen verlangt die Richtlinie selbst. Eine Vergütungskürzung bei Nichtumsetzung gibt es im SGB V nicht. Haftungs- und Bußgeldrisiko über DSGVO (Art. 83) und Berufsrecht. MVZ/Praxen ab 50 Beschäftigten zusätzlich NIS2 mit BSI-Registrierung und Meldepflichten. Die KBV zertifiziert IT-Dienstleister, die Praxen bei der Umsetzung unterstützen (Absatz in § 390 nicht geprüft).', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('0ce75c5d-8f60-443b-972e-7e828b8edb1f', 'security', '§ 391 SGB V; BSIG § 8a (KRITIS); NIS2; DSGVO Art. 32', 'Gesetzliche Grundlage – § 391 SGB V (seit DigiG, Fassung nach NIS2UmsuCG vom 02.12.2025).
Abs. 1: Krankenhäuser sind verpflichtet, nach dem Stand der Technik angemessene organisatorische und technische Vorkehrungen gegen Störungen der Verfügbarkeit, Integrität und Vertraulichkeit ihrer IT-Systeme, Komponenten und Prozesse zu treffen, die für ihre Funktionsfähigkeit und den Schutzbedarf der Patientendaten maßgeblich sind.
Abs. 2: Dazu gehören verpflichtende Maßnahmen zur Security-Awareness der Mitarbeitenden.
Abs. 3: Angemessen, wenn der Aufwand nicht außer Verhältnis zu den Ausfallfolgen oder dem Schutzbedarf steht.
Abs. 4: Erfüllbar insbesondere durch einen branchenspezifischen Sicherheitsstandard, dessen Eignung das BSI nach § 30 Abs. 8 BSIG festgestellt hat (B3S „Medizinische Versorgung“ der DKG).
Abs. 5: Gilt für alle Krankenhäuser, soweit sie nicht ohnehin als Betreiber kritischer Anlagen nach §§ 30, 31, 39 BSIG verpflichtet sind.
— dejure § 391; lxgesetze § 391; DKG B3S
Zusätzlich NIS2/BSIG. Fast jedes Plankrankenhaus liegt über 50 Beschäftigten und ist damit mindestens wichtige Einrichtung; ab 250 besonders wichtig; ab 30.000 vollstationären Fällen KRITIS mit Systemen zur Angriffserkennung (§ 31 BSIG) und Nachweis alle drei Jahre. Außerdem § 393 SGB V für Cloud-Dienste.
Förderung.
— apotheke adhoc, 28.09.2026; Detecon, 09/2026 (sekundär); Vergabe Projektträger (tendigo); zm-online, Haushalt 2026; LfP Bayern KHZG; FAQ Transformationsfonds SH
Nachweis und Sanktion.
§ 391 selbst enthält kein Nachweisverfahren und keine eigene Sanktion.
KRITIS-Häuser: Nachweis gegenüber dem BSI alle drei Jahre (§ 39 BSIG), üblich über B3S-Prüfung.
Nicht-KRITIS: BSI kann Nachweise anordnen, frühestens ab 06.12.2028.
Alle NIS2-Häuser: BSI-Registrierung, Vorfallmeldungen; Bußgelder nach BSIG.
Indirekt: Digitalisierungsabschlag bis 2 % je Fall, wenn KHZG-Dienste (FTB 2–6) fehlen; FTB 10 zählt nicht dazu. Nachweis jährlich zum 31.12. (siehe TI-Übersicht).', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('6cc18cb7-5ad6-4179-b7a7-5dee7ca4d5f7', 'security', '§ 390 SGB V; NIS2; DSGVO Art. 32', 'Gesetzliche Grundlage. Eine SGB-V-Sondernorm wie § 390/391 für öffentliche Apotheken habe ich nicht gefunden. Es gelten § 393 SGB V (Cloud), DSGVO und größenabhängig NIS2: Laut ABDA wichtige Einrichtung ab 50 Beschäftigten (Teilzeit anteilig, Filialen zusammengerechnet) oder Umsatz und Bilanz je > 10 Mio. €. KRITIS erst ab 4,65 Mio. abgegebenen Rx-Packungen pro Jahr (sekundär). — apotheke adhoc, 28.09.2026; PTA IN LOVE (sekundär)
Förderung. Öffentliche Apotheken sind im Sofortprogramm nach heutigem Stand nicht genannt; förderfähig sind Krankenhausapotheken (Teil B) und „Einrichtungen zur Versorgung mit Medikamenten“. Ob darunter NIS2-pflichtige Filialverbünde fallen, ist offen. Die TI-Pauschale deckt keine allgemeine IT-Sicherheit.
Nachweis und Sanktion. Nur NIS2-pflichtige Apotheken: BSI-Registrierung, Vorfallmeldungen, Nachweis auf Anordnung; Bußgelder nach BSIG. Sonst DSGVO.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('fa37e3b5-ba5f-4dc8-9c6d-0f3a18c95d42', 'security', '§ 390 SGB V; NIS2; DSGVO Art. 32', 'Gesetzliche Grundlage. Keine pflegespezifische IT-Sicherheitsnorm im SGB XI gefunden. Es gilt DSGVO Art. 32.
§ 393 SGB V: gilt für Leistungserbringer des Vierten Kapitels SGB V, also für HKP- und AKI-Dienste (§ 132a SGB V). Für reine SGB-XI-Einrichtungen ist die Anwendbarkeit nach dem Wortlaut unklar; Verbände nennen „Pflegeberufe“ pauschal mit. — BVMed-Infoblatt
NIS2: Die Erfassung stationärer Langzeitpflege ist nicht sicher. Der Sektor Gesundheit knüpft nach meinem Verständnis an Gesundheitsdienstleister im Sinne der Patientenmobilitäts-Richtlinie an, die Langzeitpflege ausnimmt — das ist meine Auslegung, nicht verifiziert. Ambulante Dienste mit HKP-Leistungen ab 50 Beschäftigten dürften eher erfasst sein. Bitte mit BSI-Betroffenheitsprüfung klären.
Förderung – § 8 Abs. 8 SGB XI. Einmaliger Zuschuss aus dem Ausgleichsfonds der Pflegeversicherung für digitale oder technische Ausrüstung und damit verbundene Schulungen: 40 % der Ausgaben, max. 12.000 € je Einrichtung, aufteilbar, Ausgaben bis 31.12.2030. Richtlinien des GKV-SV, zuletzt geändert 12.07.2023, gültig seit 15.08.2023. Antrag bei der Pflegekasse (Landesverband) mit Verwendungsnachweis. Investitionen in die IT- und Cybersicherheit sind im Gesetzestext ausdrücklich als förderfähig genannt. Anspruch nur bei Zulassung nach SGB XI, reine HKP-Dienste profitieren nicht. — DAK zu § 8 Abs. 8 SGB XI; BMG-RefE PNOG mit Normtext (05.06.2026); Paritätischer; vdek Hessen, Flyer bis 2030
Nachweis und Sanktion. Für IT-Sicherheit selbst: kein Nachweisverfahren. Für die Förderung: Verwendungsnachweis gegenüber der Pflegekasse. Sanktionen nur über DSGVO bzw. NIS2, falls anwendbar.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('4afb3e5b-aa00-4188-ae33-904cf28fbf47', 'security', '§ 390 SGB V; NIS2; DSGVO Art. 32', 'Gesetzliche Grundlage. Keine pflegespezifische IT-Sicherheitsnorm im SGB XI gefunden. Es gilt DSGVO Art. 32.
§ 393 SGB V: gilt für Leistungserbringer des Vierten Kapitels SGB V, also für HKP- und AKI-Dienste (§ 132a SGB V). Für reine SGB-XI-Einrichtungen ist die Anwendbarkeit nach dem Wortlaut unklar; Verbände nennen „Pflegeberufe“ pauschal mit. — BVMed-Infoblatt
NIS2: Die Erfassung stationärer Langzeitpflege ist nicht sicher. Der Sektor Gesundheit knüpft nach meinem Verständnis an Gesundheitsdienstleister im Sinne der Patientenmobilitäts-Richtlinie an, die Langzeitpflege ausnimmt — das ist meine Auslegung, nicht verifiziert. Ambulante Dienste mit HKP-Leistungen ab 50 Beschäftigten dürften eher erfasst sein. Bitte mit BSI-Betroffenheitsprüfung klären.
Förderung – § 8 Abs. 8 SGB XI. Einmaliger Zuschuss aus dem Ausgleichsfonds der Pflegeversicherung für digitale oder technische Ausrüstung und damit verbundene Schulungen: 40 % der Ausgaben, max. 12.000 € je Einrichtung, aufteilbar, Ausgaben bis 31.12.2030. Richtlinien des GKV-SV, zuletzt geändert 12.07.2023, gültig seit 15.08.2023. Antrag bei der Pflegekasse (Landesverband) mit Verwendungsnachweis. Investitionen in die IT- und Cybersicherheit sind im Gesetzestext ausdrücklich als förderfähig genannt. Anspruch nur bei Zulassung nach SGB XI, reine HKP-Dienste profitieren nicht. — DAK zu § 8 Abs. 8 SGB XI; BMG-RefE PNOG mit Normtext (05.06.2026); Paritätischer; vdek Hessen, Flyer bis 2030
Nachweis und Sanktion. Für IT-Sicherheit selbst: kein Nachweisverfahren. Für die Förderung: Verwendungsnachweis gegenüber der Pflegekasse. Sanktionen nur über DSGVO bzw. NIS2, falls anwendbar.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('3e5ae3b2-4e8d-4be9-939a-3c31a1ea8087', 'security', '§ 390 SGB V; DSGVO Art. 32', 'Gesetzliche Grundlage. Keine berufsgruppenspezifische IT-Sicherheitsnorm und keine Richtlinie analog § 390 gefunden. Es gelten § 393 SGB V (alle sind Leistungserbringer des Vierten Kapitels), DSGVO Art. 32 und NIS2 ab 50 Beschäftigten (relevant für größere Ketten, z. B. Hörakustik- oder Sanitätshaus-Filialisten und große Therapiezentren).
Förderung. Keine gefunden. Die TI-Pauschalen (soweit vorhanden) decken nur TI-Komponenten. Hilfsmittelerbringer sind im Sofortprogramm nicht genannt.
Nachweis und Sanktion. Kein SGB-Nachweisverfahren; bei Cloud-Software müssen sie das C5-Typ-2-Testat des Anbieters vorhalten. Sanktionen über DSGVO, bei NIS2-Pflicht über BSIG.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('04ca7e79-8ea0-4845-be67-e6754d6caf0b', 'security', '§ 390 SGB V; DSGVO Art. 32', 'Gesetzliche Grundlage. Keine berufsgruppenspezifische IT-Sicherheitsnorm und keine Richtlinie analog § 390 gefunden. Es gelten § 393 SGB V (alle sind Leistungserbringer des Vierten Kapitels), DSGVO Art. 32 und NIS2 ab 50 Beschäftigten (relevant für größere Ketten, z. B. Hörakustik- oder Sanitätshaus-Filialisten und große Therapiezentren).
Förderung. Keine gefunden. Die TI-Pauschalen (soweit vorhanden) decken nur TI-Komponenten. Hilfsmittelerbringer sind im Sofortprogramm nicht genannt.
Nachweis und Sanktion. Kein SGB-Nachweisverfahren; bei Cloud-Software müssen sie das C5-Typ-2-Testat des Anbieters vorhalten. Sanktionen über DSGVO, bei NIS2-Pflicht über BSIG.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('22f30954-7196-40db-b859-2526bdd8bed6', 'security', '§ 390 SGB V; DSGVO Art. 32', 'Gesetzliche Grundlage. Keine berufsgruppenspezifische IT-Sicherheitsnorm und keine Richtlinie analog § 390 gefunden. Es gelten § 393 SGB V (alle sind Leistungserbringer des Vierten Kapitels), DSGVO Art. 32 und NIS2 ab 50 Beschäftigten (relevant für größere Ketten, z. B. Hörakustik- oder Sanitätshaus-Filialisten und große Therapiezentren).
Förderung. Keine gefunden. Die TI-Pauschalen (soweit vorhanden) decken nur TI-Komponenten. Hilfsmittelerbringer sind im Sofortprogramm nicht genannt.
Nachweis und Sanktion. Kein SGB-Nachweisverfahren; bei Cloud-Software müssen sie das C5-Typ-2-Testat des Anbieters vorhalten. Sanktionen über DSGVO, bei NIS2-Pflicht über BSIG.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('403547bd-2718-4e83-825e-e3cf690b777d', 'security', '§ 390 SGB V; DSGVO Art. 32', 'Gesetzliche Grundlage. Keine berufsgruppenspezifische IT-Sicherheitsnorm und keine Richtlinie analog § 390 gefunden. Es gelten § 393 SGB V (alle sind Leistungserbringer des Vierten Kapitels), DSGVO Art. 32 und NIS2 ab 50 Beschäftigten (relevant für größere Ketten, z. B. Hörakustik- oder Sanitätshaus-Filialisten und große Therapiezentren).
Förderung. Keine gefunden. Die TI-Pauschalen (soweit vorhanden) decken nur TI-Komponenten. Hilfsmittelerbringer sind im Sofortprogramm nicht genannt.
Nachweis und Sanktion. Kein SGB-Nachweisverfahren; bei Cloud-Software müssen sie das C5-Typ-2-Testat des Anbieters vorhalten. Sanktionen über DSGVO, bei NIS2-Pflicht über BSIG.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('1aa04e28-7118-473d-9643-e2db57530e7b', 'security', '§ 390 SGB V; DSGVO Art. 32', 'Gesetzliche Grundlage. Keine berufsgruppenspezifische IT-Sicherheitsnorm und keine Richtlinie analog § 390 gefunden. Es gelten § 393 SGB V (alle sind Leistungserbringer des Vierten Kapitels), DSGVO Art. 32 und NIS2 ab 50 Beschäftigten (relevant für größere Ketten, z. B. Hörakustik- oder Sanitätshaus-Filialisten und große Therapiezentren).
Förderung. Keine gefunden. Die TI-Pauschalen (soweit vorhanden) decken nur TI-Komponenten. Hilfsmittelerbringer sind im Sofortprogramm nicht genannt.
Nachweis und Sanktion. Kein SGB-Nachweisverfahren; bei Cloud-Software müssen sie das C5-Typ-2-Testat des Anbieters vorhalten. Sanktionen über DSGVO, bei NIS2-Pflicht über BSIG.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('cdc4a8f4-4b85-4e3d-ac87-13dc0ccd9b47', 'security', '§ 390 SGB V; DSGVO Art. 32', 'Gesetzliche Grundlage. Keine berufsgruppenspezifische IT-Sicherheitsnorm und keine Richtlinie analog § 390 gefunden. Es gelten § 393 SGB V (alle sind Leistungserbringer des Vierten Kapitels), DSGVO Art. 32 und NIS2 ab 50 Beschäftigten (relevant für größere Ketten, z. B. Hörakustik- oder Sanitätshaus-Filialisten und große Therapiezentren).
Förderung. Keine gefunden. Die TI-Pauschalen (soweit vorhanden) decken nur TI-Komponenten. Hilfsmittelerbringer sind im Sofortprogramm nicht genannt.
Nachweis und Sanktion. Kein SGB-Nachweisverfahren; bei Cloud-Software müssen sie das C5-Typ-2-Testat des Anbieters vorhalten. Sanktionen über DSGVO, bei NIS2-Pflicht über BSIG.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('dd57fb19-53a4-4b26-a5ef-1d5df6e5dbb7', 'security', '§ 390 SGB V; DSGVO Art. 32', 'Gesetzliche Grundlage. Keine berufsgruppenspezifische IT-Sicherheitsnorm und keine Richtlinie analog § 390 gefunden. Es gelten § 393 SGB V (alle sind Leistungserbringer des Vierten Kapitels), DSGVO Art. 32 und NIS2 ab 50 Beschäftigten (relevant für größere Ketten, z. B. Hörakustik- oder Sanitätshaus-Filialisten und große Therapiezentren).
Förderung. Keine gefunden. Die TI-Pauschalen (soweit vorhanden) decken nur TI-Komponenten. Hilfsmittelerbringer sind im Sofortprogramm nicht genannt.
Nachweis und Sanktion. Kein SGB-Nachweisverfahren; bei Cloud-Software müssen sie das C5-Typ-2-Testat des Anbieters vorhalten. Sanktionen über DSGVO, bei NIS2-Pflicht über BSIG.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('78b3ba50-7279-4a7a-a9d9-8405062beeb6', 'security', '§ 390 SGB V; DSGVO Art. 32', 'Gesetzliche Grundlage. Keine berufsgruppenspezifische IT-Sicherheitsnorm und keine Richtlinie analog § 390 gefunden. Es gelten § 393 SGB V (alle sind Leistungserbringer des Vierten Kapitels), DSGVO Art. 32 und NIS2 ab 50 Beschäftigten (relevant für größere Ketten, z. B. Hörakustik- oder Sanitätshaus-Filialisten und große Therapiezentren).
Förderung. Keine gefunden. Die TI-Pauschalen (soweit vorhanden) decken nur TI-Komponenten. Hilfsmittelerbringer sind im Sofortprogramm nicht genannt.
Nachweis und Sanktion. Kein SGB-Nachweisverfahren; bei Cloud-Software müssen sie das C5-Typ-2-Testat des Anbieters vorhalten. Sanktionen über DSGVO, bei NIS2-Pflicht über BSIG.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('85e2cf1b-6a0a-4599-a655-bd5796729398', 'security', '§ 390 SGB V; DSGVO Art. 32', 'Gesetzliche Grundlage. Keine berufsgruppenspezifische IT-Sicherheitsnorm und keine Richtlinie analog § 390 gefunden. Es gelten § 393 SGB V (alle sind Leistungserbringer des Vierten Kapitels), DSGVO Art. 32 und NIS2 ab 50 Beschäftigten (relevant für größere Ketten, z. B. Hörakustik- oder Sanitätshaus-Filialisten und große Therapiezentren).
Förderung. Keine gefunden. Die TI-Pauschalen (soweit vorhanden) decken nur TI-Komponenten. Hilfsmittelerbringer sind im Sofortprogramm nicht genannt.
Nachweis und Sanktion. Kein SGB-Nachweisverfahren; bei Cloud-Software müssen sie das C5-Typ-2-Testat des Anbieters vorhalten. Sanktionen über DSGVO, bei NIS2-Pflicht über BSIG.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('4dfafd17-ae33-493f-b5b5-d6b5401fd126', 'security', '§ 390 SGB V; DSGVO Art. 32', 'Gesetzliche Grundlage. Keine berufsgruppenspezifische IT-Sicherheitsnorm und keine Richtlinie analog § 390 gefunden. Es gelten § 393 SGB V (alle sind Leistungserbringer des Vierten Kapitels), DSGVO Art. 32 und NIS2 ab 50 Beschäftigten (relevant für größere Ketten, z. B. Hörakustik- oder Sanitätshaus-Filialisten und große Therapiezentren).
Förderung. Keine gefunden. Die TI-Pauschalen (soweit vorhanden) decken nur TI-Komponenten. Hilfsmittelerbringer sind im Sofortprogramm nicht genannt.
Nachweis und Sanktion. Kein SGB-Nachweisverfahren; bei Cloud-Software müssen sie das C5-Typ-2-Testat des Anbieters vorhalten. Sanktionen über DSGVO, bei NIS2-Pflicht über BSIG.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('5d9b8b08-d063-4fba-b4a0-41401a5aac4c', 'security', '§ 390 SGB V; DSGVO Art. 32', 'Gesetzliche Grundlage. Keine berufsgruppenspezifische IT-Sicherheitsnorm und keine Richtlinie analog § 390 gefunden. Es gelten § 393 SGB V (alle sind Leistungserbringer des Vierten Kapitels), DSGVO Art. 32 und NIS2 ab 50 Beschäftigten (relevant für größere Ketten, z. B. Hörakustik- oder Sanitätshaus-Filialisten und große Therapiezentren).
Förderung. Keine gefunden. Die TI-Pauschalen (soweit vorhanden) decken nur TI-Komponenten. Hilfsmittelerbringer sind im Sofortprogramm nicht genannt.
Nachweis und Sanktion. Kein SGB-Nachweisverfahren; bei Cloud-Software müssen sie das C5-Typ-2-Testat des Anbieters vorhalten. Sanktionen über DSGVO, bei NIS2-Pflicht über BSIG.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('ae0782c4-6659-4fb3-8df1-18557efdd33e', 'security', '§ 391 SGB V; NIS2; DSGVO Art. 32', 'Gesetzliche Grundlage. § 391 SGB V gilt nur für Krankenhäuser, nicht für Einrichtungen nach § 107 Abs. 2 SGB V. Eine eigene SGB-V-, SGB-VI- oder DRV-Vorgabe zur IT-Sicherheit habe ich nicht gefunden. Es gelten § 393 SGB V (Reha-Einrichtungen mit Versorgungsvertrag nach §§ 111 ff. sind Leistungserbringer des Vierten Kapitels), DSGVO und NIS2: Reha-Kliniken ab 50 Beschäftigten werden in Branchenübersichten als NIS2-pflichtig geführt (sekundär). Für ambulante Reha gilt dasselbe, die Schwelle wird dort seltener erreicht.
Kostenträger und Förderung. Weder GKV noch DRV noch Unfallversicherung finanzieren IT-Sicherheit gesondert; der § 381-TI-Zuschlag deckt nur TI-Ausstattung. Reha ist nach heutigem Stand weder im Sofortprogramm Cybersicherheit (nur akut-stationärer Pfad) noch im KHZG. Einzige Stellschraube: IT-Sicherheitskosten in den Vergütungsverhandlungen mit GKV bzw. DRV geltend machen — dazu habe ich keine Regelung gefunden.
Nachweis und Sanktion. Kein Nachweis gegenüber Kostenträgern. Bei NIS2-Pflicht BSI-Registrierung, Meldungen, Nachweis auf Anordnung (ab 12/2028); Bußgelder nach BSIG. Unterschied stationär/ambulant besteht nur über die Größenschwelle. — legiscope, 09/2026 (sekundär)', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('6234d658-32a6-45c9-baa3-2361e89ae48c', 'security', '§ 390 SGB V; BSIG; DSGVO Art. 32', 'Gesetzliche Grundlage. Keine SGB-Norm zur IT-Sicherheit der Gesundheitsämter. Maßgeblich sind Landes-Informationssicherheitsrecht, kommunale Vorgaben und DSGVO. Das NIS2UmsuCG gilt für Länder und Kommunen nicht direkt; Landesgesetze können Vergleichbares vorsehen (sekundär). Für TI-Anbindung gilt § 393 SGB V nur, soweit das Amt als Leistungserbringer nach SGB V handelt — unklar. — secjur, 09/2026 (sekundär)
Förderung – Pakt für den ÖGD. Bund-Länder-Vereinbarung, 4 Mrd. € von 2021 bis 31.12.2026, davon rund 800 Mio. € Digitalisierung (EU-finanziert, DARP). Förderung von Maßnahmen zur Steigerung des digitalen Reifegrads nach BMG-Förderleitfaden vom 22.04.2022; Messung über ein Reifegradmodell mit acht Dimensionen. Ob IT-Sicherheit eine eigene Dimension ist, habe ich nicht geprüft. Der Pakt soll Ende 2026 auslaufen; eine Anschlussfinanzierung ist offen. — Sozialministerium BW; LfGA NRW; Ärzteblatt, 02/2026
Nachweis und Sanktion. Nur förderrechtlich (Verwendungsnachweis, Reifegradmessung). Keine IT-Sicherheitssanktion gefunden.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();


-- ── Telemedizin (Thema: telemedizin) ──
INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('6341b398-e27d-40be-a986-ec566a68a434', 'telemedizin', '§ 87 Abs. 2a SGB V; § 291g SGB V; § 7 Abs. 4 MBO-Ä', 'Videosprechstunde:
Vergütung: Leistungen, die laut EBM per Video erbracht werden dürfen, plus Technikzuschlag GOP 01450 (40 Punkte, rund 5,10 €) je Kontakt für die Kosten des zertifizierten Videodienstes. Seit 01.04.2025 Zuschlag GOP 01452 (30 Punkte) zur Grund-/Versichertenpauschale, wenn ein bekannter Patient im Quartal ausschließlich per Video behandelt wird und die Praxis eine strukturierte Anschlussversorgung nach Anlage 31c vorhält. GOP 01444 (Authentifizierung unbekannter Patienten) befristet bis 31.12.2026.
Mengenregeln: Die 30-%-Obergrenze je GOP ist rückwirkend zum 01.01.2025 entfallen. Seit 01.04.2025 dürfen bis zu 50 % der Behandlungsfälle einer Praxis reine Videofälle sein. In reinen Videofällen werden Pauschalen fachgruppenabhängig um 20, 25 oder 30 % gekürzt; Schweregradzuschläge sind nicht berechnungsfähig.
Deckel 01450 (korrigiert in Lauf 2): Seit 01.07.2025 max. 700 Punkte je Arzt und Quartal (vorher 1.899), also rund 89 € bzw. 18 Videosprechstunden; Beschluss des Bewertungsausschusses, 778. Sitzung. Seit 01.04.2025 dürfen auch Nuklearmediziner Videosprechstunden abrechnen.
Anforderungen: zertifizierter Videodienst nach Anlage 31b (Informationssicherheit, Datenschutz, Inhalte); Anzeige bei der KV mit Bescheinigung des Anbieters; Fallkennzeichnung 88220 bei reinem Videokontakt; Anlage 31c: Terminvergabe nur nach medizinischer Dringlichkeit, Angebot in der Praxis sichtbar ausweisen. Nicht für Laborärzte, Pathologen, Radiologen.
Rechtsgrundlagen: § 87 Abs. 2a, Abs. 2o, § 365 SGB V; Anlagen 31b und 31c BMV-Ä (Fassung in Kraft 01.07.2026 laut KBV).
— KBV Videosprechstunde; KV Hessen, Abrechnung; KVN, Stand 01.07.2026; KV Brandenburg

Videofallkonferenz mit Pflegekräften:
GOP 01442 (86 Punkte), max. dreimal im Krankheitsfall; nur ausschließlich per Video möglich und daher von Mengenregeln ausgenommen. Nur der einladende Arzt rechnet 01450 ab. Technische Grundlage Anlage 31b.

Telekonsil:
GOP 01670 Einholung (110 Punkte, bis zu zweimal im Behandlungsfall), GOP 01671 ff. Beurteilung mit schriftlichem Konsiliarbericht. Übermittlung per eArztbrief/KIM oder anderen Diensten nach Anlage 31a; Videokonsil nach Anlage 31b. Voraussetzung: Arzt-Patienten-Kontakt im Quartal; Einwilligung. Anlage 31c verpflichtet, das Ergebnis in die ePA zu übertragen. Rechtsgrundlage § 367 SGB V. — Bioscientia (sekundär)

Telemonitoring bei Herzinsuffizienz:
Grundlage: G-BA-Beschluss (Nr. 37 Anlage I MVV-RL), QS-Vereinbarung nach § 135 Abs. 2 SGB V; im EBM seit 01.01.2022.
Vergütung: TMZ-Leistungen GOP 13583–13587 und Kostenpauschale 40910 (z. B. 13584: 1.100 Punkte je Behandlungsfall); PBA-Leistungen in den Kapiteln 3, 4 und 13.
Anforderungen: Das TMZ braucht eine KV-Genehmigung (Facharzt Kardiologie, Genehmigung Rhythmusimplantat-Kontrolle, technische Ausstattung nach § 5 QS-V); der primär behandelnde Arzt nicht. Geräte als CE-gekennzeichnete Medizinprodukte mit täglicher Datenübertragung und automatischer Analyse. Eine Vereinbarung nach § 367a SGB V steht laut KBV noch aus.
— KBV Telemonitoring; KV Hessen', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('ca4e83f8-d4ea-4359-be60-a3c249942444', 'telemedizin', '§ 87 Abs. 2a SGB V; § 291g SGB V; § 7 Abs. 4 MBO-Ä', 'Videosprechstunde:
Vergütung: Leistungen, die laut EBM per Video erbracht werden dürfen, plus Technikzuschlag GOP 01450 (40 Punkte, rund 5,10 €) je Kontakt für die Kosten des zertifizierten Videodienstes. Seit 01.04.2025 Zuschlag GOP 01452 (30 Punkte) zur Grund-/Versichertenpauschale, wenn ein bekannter Patient im Quartal ausschließlich per Video behandelt wird und die Praxis eine strukturierte Anschlussversorgung nach Anlage 31c vorhält. GOP 01444 (Authentifizierung unbekannter Patienten) befristet bis 31.12.2026.
Mengenregeln: Die 30-%-Obergrenze je GOP ist rückwirkend zum 01.01.2025 entfallen. Seit 01.04.2025 dürfen bis zu 50 % der Behandlungsfälle einer Praxis reine Videofälle sein. In reinen Videofällen werden Pauschalen fachgruppenabhängig um 20, 25 oder 30 % gekürzt; Schweregradzuschläge sind nicht berechnungsfähig.
Deckel 01450 (korrigiert in Lauf 2): Seit 01.07.2025 max. 700 Punkte je Arzt und Quartal (vorher 1.899), also rund 89 € bzw. 18 Videosprechstunden; Beschluss des Bewertungsausschusses, 778. Sitzung. Seit 01.04.2025 dürfen auch Nuklearmediziner Videosprechstunden abrechnen.
Anforderungen: zertifizierter Videodienst nach Anlage 31b (Informationssicherheit, Datenschutz, Inhalte); Anzeige bei der KV mit Bescheinigung des Anbieters; Fallkennzeichnung 88220 bei reinem Videokontakt; Anlage 31c: Terminvergabe nur nach medizinischer Dringlichkeit, Angebot in der Praxis sichtbar ausweisen. Nicht für Laborärzte, Pathologen, Radiologen.
Rechtsgrundlagen: § 87 Abs. 2a, Abs. 2o, § 365 SGB V; Anlagen 31b und 31c BMV-Ä (Fassung in Kraft 01.07.2026 laut KBV).
— KBV Videosprechstunde; KV Hessen, Abrechnung; KVN, Stand 01.07.2026; KV Brandenburg

Videofallkonferenz mit Pflegekräften:
GOP 01442 (86 Punkte), max. dreimal im Krankheitsfall; nur ausschließlich per Video möglich und daher von Mengenregeln ausgenommen. Nur der einladende Arzt rechnet 01450 ab. Technische Grundlage Anlage 31b.

Telekonsil:
GOP 01670 Einholung (110 Punkte, bis zu zweimal im Behandlungsfall), GOP 01671 ff. Beurteilung mit schriftlichem Konsiliarbericht. Übermittlung per eArztbrief/KIM oder anderen Diensten nach Anlage 31a; Videokonsil nach Anlage 31b. Voraussetzung: Arzt-Patienten-Kontakt im Quartal; Einwilligung. Anlage 31c verpflichtet, das Ergebnis in die ePA zu übertragen. Rechtsgrundlage § 367 SGB V. — Bioscientia (sekundär)

Telemonitoring bei Herzinsuffizienz:
Grundlage: G-BA-Beschluss (Nr. 37 Anlage I MVV-RL), QS-Vereinbarung nach § 135 Abs. 2 SGB V; im EBM seit 01.01.2022.
Vergütung: TMZ-Leistungen GOP 13583–13587 und Kostenpauschale 40910 (z. B. 13584: 1.100 Punkte je Behandlungsfall); PBA-Leistungen in den Kapiteln 3, 4 und 13.
Anforderungen: Das TMZ braucht eine KV-Genehmigung (Facharzt Kardiologie, Genehmigung Rhythmusimplantat-Kontrolle, technische Ausstattung nach § 5 QS-V); der primär behandelnde Arzt nicht. Geräte als CE-gekennzeichnete Medizinprodukte mit täglicher Datenübertragung und automatischer Analyse. Eine Vereinbarung nach § 367a SGB V steht laut KBV noch aus.
— KBV Telemonitoring; KV Hessen', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('34b5b023-7b10-4070-99ef-ad164f6b8144', 'telemedizin', '§ 87 SGB V; § 7 Abs. 4 MBO-Ä', 'Vergütung (BEMA): Videosprechstunde VS (16 Punkte), Videofallkonferenz mit Pflege- und Unterstützungspersonen VFKa (12) / VFKb (6, je weiterer Versicherter), Telekonsile 181b/182b als Videokonsil, Technikzuschlag TZ (16 Punkte, max. zehnmal je Praxis und Quartal).
Einschränkung: VS und VFK nur bei Versicherten mit Pflegegrad, Eingliederungshilfe oder Versorgung über einen Kooperationsvertrag nach § 119b SGB V; Anspruch in der Akte dokumentieren. VFK max. dreimal je Quartal, nur mit persönlichem Kontakt in den letzten drei Quartalen. Telekonsile für alle Versicherten.
Anforderungen: Videodienst nach Anlage 16 BMV-Z (Fassung 01.01.2026); keine Aufzeichnung; Einwilligung; Vorstellung aller Anwesenden.
Rechtsgrundlage: § 366 SGB V.
— KZBV BEMA 01.01.2025; KZV Berlin', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('0ce75c5d-8f60-443b-972e-7e828b8edb1f', 'telemedizin', '§ 115b SGB V; § 120 SGB V; § 7 Abs. 4 MBO-Ä', 'Transformationsfonds: Die Bildung telemedizinischer Netzwerkstrukturen ist ein eigener Fördertatbestand nach KHTFV (siehe Förderübersicht).
KH-Ambulanzen, ermächtigte Ärzte: rechnen Videosprechstunde und Telekonsil nach EBM ab, soweit sie vertragsärztlich tätig sind.
Stationäre Telekonsile zwischen Kliniken: Eine eigene bundesweite Vergütungsregel habe ich nicht gefunden; üblich sind Kooperationsverträge, Selektivverträge oder Landesprogramme.', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('6cc18cb7-5ad6-4179-b7a7-5dee7ca4d5f7', 'telemedizin', '§ 11 Abs. 1a ApoG; § 129 SGB V', 'Rechtsgrundlage: § 129 Abs. 5h SGB V (DigiG); Versicherte haben Anspruch. Vereinbarung als Anlage 13 zum Rahmenvertrag nach § 129 Abs. 2 SGB V (Erste Änderungsvereinbarung), in Kraft 01.07.2026. Vergütung per Schiedsspruch; die ABDA nennt als Datum den 16.04.2026, eine Sekundärquelle den 08.05.2026.
Inhalt: Unterstützung bei der vertragsärztlichen Videosprechstunde nach § 365 (technische Hilfe, strukturierte Ersteinschätzung oder beides). Weitere Leistungen, etwa einfache Routineaufgaben, nur in Modellprojekten.
Vergütung: Pauschale je Leistung inkl. Technik: 30,00 € (01.07.2026–30.06.2027), 25,50 €, 23,00 €, ab 01.07.2029 21,50 € (sekundär). Abrechnung über Sonderkennzeichen, per Sonderbeleg bis 28.02.2027, danach elektronisch (sekundär).
Anforderungen: vertraulicher Raum, datenschutzkonforme Technik, Videodienst nach § 365, eingewiesenes Personal; freie Arzt- und Apothekenwahl, Zuweisungsverbot.
— ABDA aTM; Erste Änderungsvereinbarung Rahmenvertrag § 129; PZ, 06/2026; doctorbox (sekundär)', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('3e5ae3b2-4e8d-4be9-939a-3c31a1ea8087', 'telemedizin', '§ 87 SGB V; SGB XI; § 7 Abs. 4 MBO-Ä', 'Heilmittelerbringer: Videotherapie:
Rechtsgrundlage: § 125 Abs. 2a SGB V (DVPMG); G-BA-Heilmittel-Richtlinie (Videotherapie); Umsetzung in den Verträgen nach § 125 Abs. 1 SGB V, Regelversorgung seit 01.04.2022 für Physiotherapie, Ergotherapie, Stimm-/Sprech-/Sprach-/Schlucktherapie und Ernährungstherapie.
Vergütung: gleiche Preise wie in Präsenz, eigene Positionsnummern (z. B. Physio X1221 Manuelle Therapie telemedizinisch: 35,59 € ab 01.01.2026).
Anforderungen Physiotherapie: KG Einzel, KG Gruppe und KG Muko bis zur Hälfte der verordneten Einheiten; KG-ZNS nach Bobath bis drei Einheiten; Manuelle Therapie eine Einheit. Erstbehandlung und Verlaufskontrollen persönlich; Durchführung aus den zugelassenen Praxisräumen; Arzt darf Videotherapie ausschließen; Einwilligung und datenschutzkonforme Anwendung.
Andere Bereiche (ergänzt in Lauf 2): Ergotherapie max. 30 % aller Behandlungen je Leistungserbringer und Quartal, erste Einheit in Präsenz, bis zu zwei Einheiten je Verordnung als Telefonberatung; Logopädie max. 30 % je Quartal, Kennzeichnung „TML“ auf der Verordnung; Ernährungstherapie bis 50 % des Zeitkontingents, davon bis 30 Minuten telefonisch; Podologie keine Videotherapie. Nur zertifizierte Videoanbieter. — AOK-Handout Ergotherapie; GKV-SV „90 Prozent“; dmrz (sekundär)
— GKV-SV Vertrag Physiotherapie mit Videotherapie; Anlage 2 Vergütung ab 01.01.2026

Pflege: Telepflege:
Regelvergütung: keine eigene telemedizinische Leistungsposition in der Pflegeversicherung gefunden.
Modellprogramm § 125a SGB XI: 5 Mio. € aus dem Ausgleichsfonds, 2022 bis Ende 2025, zwölf Projekte; abgeschlossen. Der GKV-SV muss bis 31.12.2027 Empfehlungen zur Umsetzung erarbeiten (Fassung nach BEEP, ab 01.01.2026).
Indirekt: Pflegekräfte nehmen an ärztlichen Videofallkonferenzen (EBM 01442, BEMA VFK) teil, erhalten dafür aber keine eigene Vergütung. Telemedizinische Erbringung häuslicher Krankenpflege: Regelung nicht gefunden.
— GKV-SV Modellprogramm § 125a; § 125a SGB XI

Hebammen:
Rechtsgrundlage: § 134a Abs. 1d SGB V (DVPMG) verpflichtet die Vertragspartner, Leistungen der Hebammenhilfe per Videobetreuung zu vereinbaren. Umgesetzt im neuen Hebammenhilfevertrag für Leistungen seit 01.11.2025 (Änderungsvereinbarung vom 16.03.2026); davor befristete Übergangsvereinbarungen.
Vergütung: Videobetreuung ersetzt die analoge ambulante Leistung und wird mit eigenen Gebührenpositionen (Endziffer „3“) abgerechnet; bei kontingentierten Leistungen wird sie aufs Kontingent angerechnet. Auch Geburtsvorbereitungs- und Rückbildungskurse können per Video laufen.
Anforderungen: technische Voraussetzungen in Anlage 4 zum Vertrag; nur vom GKV-SV für Hebammen gelistete Videodienste; Meldung des Video-Angebots für die Vertragspartnerliste. Versichertenbestätigung seit 2026 auch als digital unterschriebenes PDF.
— Hebammenhilfevertrag (GKV-SV); Änderungsvereinbarung 16.03.2026; GKV-SV FAQ, Stand 02.02.2026', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('04ca7e79-8ea0-4845-be67-e6754d6caf0b', 'telemedizin', '§ 87 SGB V; SGB XI; § 7 Abs. 4 MBO-Ä', 'Heilmittelerbringer: Videotherapie:
Rechtsgrundlage: § 125 Abs. 2a SGB V (DVPMG); G-BA-Heilmittel-Richtlinie (Videotherapie); Umsetzung in den Verträgen nach § 125 Abs. 1 SGB V, Regelversorgung seit 01.04.2022 für Physiotherapie, Ergotherapie, Stimm-/Sprech-/Sprach-/Schlucktherapie und Ernährungstherapie.
Vergütung: gleiche Preise wie in Präsenz, eigene Positionsnummern (z. B. Physio X1221 Manuelle Therapie telemedizinisch: 35,59 € ab 01.01.2026).
Anforderungen Physiotherapie: KG Einzel, KG Gruppe und KG Muko bis zur Hälfte der verordneten Einheiten; KG-ZNS nach Bobath bis drei Einheiten; Manuelle Therapie eine Einheit. Erstbehandlung und Verlaufskontrollen persönlich; Durchführung aus den zugelassenen Praxisräumen; Arzt darf Videotherapie ausschließen; Einwilligung und datenschutzkonforme Anwendung.
Andere Bereiche (ergänzt in Lauf 2): Ergotherapie max. 30 % aller Behandlungen je Leistungserbringer und Quartal, erste Einheit in Präsenz, bis zu zwei Einheiten je Verordnung als Telefonberatung; Logopädie max. 30 % je Quartal, Kennzeichnung „TML“ auf der Verordnung; Ernährungstherapie bis 50 % des Zeitkontingents, davon bis 30 Minuten telefonisch; Podologie keine Videotherapie. Nur zertifizierte Videoanbieter. — AOK-Handout Ergotherapie; GKV-SV „90 Prozent“; dmrz (sekundär)
— GKV-SV Vertrag Physiotherapie mit Videotherapie; Anlage 2 Vergütung ab 01.01.2026

Pflege: Telepflege:
Regelvergütung: keine eigene telemedizinische Leistungsposition in der Pflegeversicherung gefunden.
Modellprogramm § 125a SGB XI: 5 Mio. € aus dem Ausgleichsfonds, 2022 bis Ende 2025, zwölf Projekte; abgeschlossen. Der GKV-SV muss bis 31.12.2027 Empfehlungen zur Umsetzung erarbeiten (Fassung nach BEEP, ab 01.01.2026).
Indirekt: Pflegekräfte nehmen an ärztlichen Videofallkonferenzen (EBM 01442, BEMA VFK) teil, erhalten dafür aber keine eigene Vergütung. Telemedizinische Erbringung häuslicher Krankenpflege: Regelung nicht gefunden.
— GKV-SV Modellprogramm § 125a; § 125a SGB XI

Hebammen:
Rechtsgrundlage: § 134a Abs. 1d SGB V (DVPMG) verpflichtet die Vertragspartner, Leistungen der Hebammenhilfe per Videobetreuung zu vereinbaren. Umgesetzt im neuen Hebammenhilfevertrag für Leistungen seit 01.11.2025 (Änderungsvereinbarung vom 16.03.2026); davor befristete Übergangsvereinbarungen.
Vergütung: Videobetreuung ersetzt die analoge ambulante Leistung und wird mit eigenen Gebührenpositionen (Endziffer „3“) abgerechnet; bei kontingentierten Leistungen wird sie aufs Kontingent angerechnet. Auch Geburtsvorbereitungs- und Rückbildungskurse können per Video laufen.
Anforderungen: technische Voraussetzungen in Anlage 4 zum Vertrag; nur vom GKV-SV für Hebammen gelistete Videodienste; Meldung des Video-Angebots für die Vertragspartnerliste. Versichertenbestätigung seit 2026 auch als digital unterschriebenes PDF.
— Hebammenhilfevertrag (GKV-SV); Änderungsvereinbarung 16.03.2026; GKV-SV FAQ, Stand 02.02.2026', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('22f30954-7196-40db-b859-2526bdd8bed6', 'telemedizin', '§ 87 SGB V; SGB XI; § 7 Abs. 4 MBO-Ä', 'Heilmittelerbringer: Videotherapie:
Rechtsgrundlage: § 125 Abs. 2a SGB V (DVPMG); G-BA-Heilmittel-Richtlinie (Videotherapie); Umsetzung in den Verträgen nach § 125 Abs. 1 SGB V, Regelversorgung seit 01.04.2022 für Physiotherapie, Ergotherapie, Stimm-/Sprech-/Sprach-/Schlucktherapie und Ernährungstherapie.
Vergütung: gleiche Preise wie in Präsenz, eigene Positionsnummern (z. B. Physio X1221 Manuelle Therapie telemedizinisch: 35,59 € ab 01.01.2026).
Anforderungen Physiotherapie: KG Einzel, KG Gruppe und KG Muko bis zur Hälfte der verordneten Einheiten; KG-ZNS nach Bobath bis drei Einheiten; Manuelle Therapie eine Einheit. Erstbehandlung und Verlaufskontrollen persönlich; Durchführung aus den zugelassenen Praxisräumen; Arzt darf Videotherapie ausschließen; Einwilligung und datenschutzkonforme Anwendung.
Andere Bereiche (ergänzt in Lauf 2): Ergotherapie max. 30 % aller Behandlungen je Leistungserbringer und Quartal, erste Einheit in Präsenz, bis zu zwei Einheiten je Verordnung als Telefonberatung; Logopädie max. 30 % je Quartal, Kennzeichnung „TML“ auf der Verordnung; Ernährungstherapie bis 50 % des Zeitkontingents, davon bis 30 Minuten telefonisch; Podologie keine Videotherapie. Nur zertifizierte Videoanbieter. — AOK-Handout Ergotherapie; GKV-SV „90 Prozent“; dmrz (sekundär)
— GKV-SV Vertrag Physiotherapie mit Videotherapie; Anlage 2 Vergütung ab 01.01.2026

Pflege: Telepflege:
Regelvergütung: keine eigene telemedizinische Leistungsposition in der Pflegeversicherung gefunden.
Modellprogramm § 125a SGB XI: 5 Mio. € aus dem Ausgleichsfonds, 2022 bis Ende 2025, zwölf Projekte; abgeschlossen. Der GKV-SV muss bis 31.12.2027 Empfehlungen zur Umsetzung erarbeiten (Fassung nach BEEP, ab 01.01.2026).
Indirekt: Pflegekräfte nehmen an ärztlichen Videofallkonferenzen (EBM 01442, BEMA VFK) teil, erhalten dafür aber keine eigene Vergütung. Telemedizinische Erbringung häuslicher Krankenpflege: Regelung nicht gefunden.
— GKV-SV Modellprogramm § 125a; § 125a SGB XI

Hebammen:
Rechtsgrundlage: § 134a Abs. 1d SGB V (DVPMG) verpflichtet die Vertragspartner, Leistungen der Hebammenhilfe per Videobetreuung zu vereinbaren. Umgesetzt im neuen Hebammenhilfevertrag für Leistungen seit 01.11.2025 (Änderungsvereinbarung vom 16.03.2026); davor befristete Übergangsvereinbarungen.
Vergütung: Videobetreuung ersetzt die analoge ambulante Leistung und wird mit eigenen Gebührenpositionen (Endziffer „3“) abgerechnet; bei kontingentierten Leistungen wird sie aufs Kontingent angerechnet. Auch Geburtsvorbereitungs- und Rückbildungskurse können per Video laufen.
Anforderungen: technische Voraussetzungen in Anlage 4 zum Vertrag; nur vom GKV-SV für Hebammen gelistete Videodienste; Meldung des Video-Angebots für die Vertragspartnerliste. Versichertenbestätigung seit 2026 auch als digital unterschriebenes PDF.
— Hebammenhilfevertrag (GKV-SV); Änderungsvereinbarung 16.03.2026; GKV-SV FAQ, Stand 02.02.2026', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('403547bd-2718-4e83-825e-e3cf690b777d', 'telemedizin', '§ 87 SGB V; SGB XI; § 7 Abs. 4 MBO-Ä', 'Heilmittelerbringer: Videotherapie:
Rechtsgrundlage: § 125 Abs. 2a SGB V (DVPMG); G-BA-Heilmittel-Richtlinie (Videotherapie); Umsetzung in den Verträgen nach § 125 Abs. 1 SGB V, Regelversorgung seit 01.04.2022 für Physiotherapie, Ergotherapie, Stimm-/Sprech-/Sprach-/Schlucktherapie und Ernährungstherapie.
Vergütung: gleiche Preise wie in Präsenz, eigene Positionsnummern (z. B. Physio X1221 Manuelle Therapie telemedizinisch: 35,59 € ab 01.01.2026).
Anforderungen Physiotherapie: KG Einzel, KG Gruppe und KG Muko bis zur Hälfte der verordneten Einheiten; KG-ZNS nach Bobath bis drei Einheiten; Manuelle Therapie eine Einheit. Erstbehandlung und Verlaufskontrollen persönlich; Durchführung aus den zugelassenen Praxisräumen; Arzt darf Videotherapie ausschließen; Einwilligung und datenschutzkonforme Anwendung.
Andere Bereiche (ergänzt in Lauf 2): Ergotherapie max. 30 % aller Behandlungen je Leistungserbringer und Quartal, erste Einheit in Präsenz, bis zu zwei Einheiten je Verordnung als Telefonberatung; Logopädie max. 30 % je Quartal, Kennzeichnung „TML“ auf der Verordnung; Ernährungstherapie bis 50 % des Zeitkontingents, davon bis 30 Minuten telefonisch; Podologie keine Videotherapie. Nur zertifizierte Videoanbieter. — AOK-Handout Ergotherapie; GKV-SV „90 Prozent“; dmrz (sekundär)
— GKV-SV Vertrag Physiotherapie mit Videotherapie; Anlage 2 Vergütung ab 01.01.2026

Pflege: Telepflege:
Regelvergütung: keine eigene telemedizinische Leistungsposition in der Pflegeversicherung gefunden.
Modellprogramm § 125a SGB XI: 5 Mio. € aus dem Ausgleichsfonds, 2022 bis Ende 2025, zwölf Projekte; abgeschlossen. Der GKV-SV muss bis 31.12.2027 Empfehlungen zur Umsetzung erarbeiten (Fassung nach BEEP, ab 01.01.2026).
Indirekt: Pflegekräfte nehmen an ärztlichen Videofallkonferenzen (EBM 01442, BEMA VFK) teil, erhalten dafür aber keine eigene Vergütung. Telemedizinische Erbringung häuslicher Krankenpflege: Regelung nicht gefunden.
— GKV-SV Modellprogramm § 125a; § 125a SGB XI

Hebammen:
Rechtsgrundlage: § 134a Abs. 1d SGB V (DVPMG) verpflichtet die Vertragspartner, Leistungen der Hebammenhilfe per Videobetreuung zu vereinbaren. Umgesetzt im neuen Hebammenhilfevertrag für Leistungen seit 01.11.2025 (Änderungsvereinbarung vom 16.03.2026); davor befristete Übergangsvereinbarungen.
Vergütung: Videobetreuung ersetzt die analoge ambulante Leistung und wird mit eigenen Gebührenpositionen (Endziffer „3“) abgerechnet; bei kontingentierten Leistungen wird sie aufs Kontingent angerechnet. Auch Geburtsvorbereitungs- und Rückbildungskurse können per Video laufen.
Anforderungen: technische Voraussetzungen in Anlage 4 zum Vertrag; nur vom GKV-SV für Hebammen gelistete Videodienste; Meldung des Video-Angebots für die Vertragspartnerliste. Versichertenbestätigung seit 2026 auch als digital unterschriebenes PDF.
— Hebammenhilfevertrag (GKV-SV); Änderungsvereinbarung 16.03.2026; GKV-SV FAQ, Stand 02.02.2026', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('fa37e3b5-ba5f-4dc8-9c6d-0f3a18c95d42', 'telemedizin', '§ 87 SGB V; SGB XI; § 7 Abs. 4 MBO-Ä', 'Heilmittelerbringer: Videotherapie:
Rechtsgrundlage: § 125 Abs. 2a SGB V (DVPMG); G-BA-Heilmittel-Richtlinie (Videotherapie); Umsetzung in den Verträgen nach § 125 Abs. 1 SGB V, Regelversorgung seit 01.04.2022 für Physiotherapie, Ergotherapie, Stimm-/Sprech-/Sprach-/Schlucktherapie und Ernährungstherapie.
Vergütung: gleiche Preise wie in Präsenz, eigene Positionsnummern (z. B. Physio X1221 Manuelle Therapie telemedizinisch: 35,59 € ab 01.01.2026).
Anforderungen Physiotherapie: KG Einzel, KG Gruppe und KG Muko bis zur Hälfte der verordneten Einheiten; KG-ZNS nach Bobath bis drei Einheiten; Manuelle Therapie eine Einheit. Erstbehandlung und Verlaufskontrollen persönlich; Durchführung aus den zugelassenen Praxisräumen; Arzt darf Videotherapie ausschließen; Einwilligung und datenschutzkonforme Anwendung.
Andere Bereiche (ergänzt in Lauf 2): Ergotherapie max. 30 % aller Behandlungen je Leistungserbringer und Quartal, erste Einheit in Präsenz, bis zu zwei Einheiten je Verordnung als Telefonberatung; Logopädie max. 30 % je Quartal, Kennzeichnung „TML“ auf der Verordnung; Ernährungstherapie bis 50 % des Zeitkontingents, davon bis 30 Minuten telefonisch; Podologie keine Videotherapie. Nur zertifizierte Videoanbieter. — AOK-Handout Ergotherapie; GKV-SV „90 Prozent“; dmrz (sekundär)
— GKV-SV Vertrag Physiotherapie mit Videotherapie; Anlage 2 Vergütung ab 01.01.2026

Pflege: Telepflege:
Regelvergütung: keine eigene telemedizinische Leistungsposition in der Pflegeversicherung gefunden.
Modellprogramm § 125a SGB XI: 5 Mio. € aus dem Ausgleichsfonds, 2022 bis Ende 2025, zwölf Projekte; abgeschlossen. Der GKV-SV muss bis 31.12.2027 Empfehlungen zur Umsetzung erarbeiten (Fassung nach BEEP, ab 01.01.2026).
Indirekt: Pflegekräfte nehmen an ärztlichen Videofallkonferenzen (EBM 01442, BEMA VFK) teil, erhalten dafür aber keine eigene Vergütung. Telemedizinische Erbringung häuslicher Krankenpflege: Regelung nicht gefunden.
— GKV-SV Modellprogramm § 125a; § 125a SGB XI

Hebammen:
Rechtsgrundlage: § 134a Abs. 1d SGB V (DVPMG) verpflichtet die Vertragspartner, Leistungen der Hebammenhilfe per Videobetreuung zu vereinbaren. Umgesetzt im neuen Hebammenhilfevertrag für Leistungen seit 01.11.2025 (Änderungsvereinbarung vom 16.03.2026); davor befristete Übergangsvereinbarungen.
Vergütung: Videobetreuung ersetzt die analoge ambulante Leistung und wird mit eigenen Gebührenpositionen (Endziffer „3“) abgerechnet; bei kontingentierten Leistungen wird sie aufs Kontingent angerechnet. Auch Geburtsvorbereitungs- und Rückbildungskurse können per Video laufen.
Anforderungen: technische Voraussetzungen in Anlage 4 zum Vertrag; nur vom GKV-SV für Hebammen gelistete Videodienste; Meldung des Video-Angebots für die Vertragspartnerliste. Versichertenbestätigung seit 2026 auch als digital unterschriebenes PDF.
— Hebammenhilfevertrag (GKV-SV); Änderungsvereinbarung 16.03.2026; GKV-SV FAQ, Stand 02.02.2026', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('4afb3e5b-aa00-4188-ae33-904cf28fbf47', 'telemedizin', '§ 87 SGB V; SGB XI; § 7 Abs. 4 MBO-Ä', 'Heilmittelerbringer: Videotherapie:
Rechtsgrundlage: § 125 Abs. 2a SGB V (DVPMG); G-BA-Heilmittel-Richtlinie (Videotherapie); Umsetzung in den Verträgen nach § 125 Abs. 1 SGB V, Regelversorgung seit 01.04.2022 für Physiotherapie, Ergotherapie, Stimm-/Sprech-/Sprach-/Schlucktherapie und Ernährungstherapie.
Vergütung: gleiche Preise wie in Präsenz, eigene Positionsnummern (z. B. Physio X1221 Manuelle Therapie telemedizinisch: 35,59 € ab 01.01.2026).
Anforderungen Physiotherapie: KG Einzel, KG Gruppe und KG Muko bis zur Hälfte der verordneten Einheiten; KG-ZNS nach Bobath bis drei Einheiten; Manuelle Therapie eine Einheit. Erstbehandlung und Verlaufskontrollen persönlich; Durchführung aus den zugelassenen Praxisräumen; Arzt darf Videotherapie ausschließen; Einwilligung und datenschutzkonforme Anwendung.
Andere Bereiche (ergänzt in Lauf 2): Ergotherapie max. 30 % aller Behandlungen je Leistungserbringer und Quartal, erste Einheit in Präsenz, bis zu zwei Einheiten je Verordnung als Telefonberatung; Logopädie max. 30 % je Quartal, Kennzeichnung „TML“ auf der Verordnung; Ernährungstherapie bis 50 % des Zeitkontingents, davon bis 30 Minuten telefonisch; Podologie keine Videotherapie. Nur zertifizierte Videoanbieter. — AOK-Handout Ergotherapie; GKV-SV „90 Prozent“; dmrz (sekundär)
— GKV-SV Vertrag Physiotherapie mit Videotherapie; Anlage 2 Vergütung ab 01.01.2026

Pflege: Telepflege:
Regelvergütung: keine eigene telemedizinische Leistungsposition in der Pflegeversicherung gefunden.
Modellprogramm § 125a SGB XI: 5 Mio. € aus dem Ausgleichsfonds, 2022 bis Ende 2025, zwölf Projekte; abgeschlossen. Der GKV-SV muss bis 31.12.2027 Empfehlungen zur Umsetzung erarbeiten (Fassung nach BEEP, ab 01.01.2026).
Indirekt: Pflegekräfte nehmen an ärztlichen Videofallkonferenzen (EBM 01442, BEMA VFK) teil, erhalten dafür aber keine eigene Vergütung. Telemedizinische Erbringung häuslicher Krankenpflege: Regelung nicht gefunden.
— GKV-SV Modellprogramm § 125a; § 125a SGB XI

Hebammen:
Rechtsgrundlage: § 134a Abs. 1d SGB V (DVPMG) verpflichtet die Vertragspartner, Leistungen der Hebammenhilfe per Videobetreuung zu vereinbaren. Umgesetzt im neuen Hebammenhilfevertrag für Leistungen seit 01.11.2025 (Änderungsvereinbarung vom 16.03.2026); davor befristete Übergangsvereinbarungen.
Vergütung: Videobetreuung ersetzt die analoge ambulante Leistung und wird mit eigenen Gebührenpositionen (Endziffer „3“) abgerechnet; bei kontingentierten Leistungen wird sie aufs Kontingent angerechnet. Auch Geburtsvorbereitungs- und Rückbildungskurse können per Video laufen.
Anforderungen: technische Voraussetzungen in Anlage 4 zum Vertrag; nur vom GKV-SV für Hebammen gelistete Videodienste; Meldung des Video-Angebots für die Vertragspartnerliste. Versichertenbestätigung seit 2026 auch als digital unterschriebenes PDF.
— Hebammenhilfevertrag (GKV-SV); Änderungsvereinbarung 16.03.2026; GKV-SV FAQ, Stand 02.02.2026', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();

INSERT INTO bg_topic_requirements (berufsgruppe_id, thema, rechtsgrundlage, gesetzestext, aktualisiert_am)
VALUES ('cdc4a8f4-4b85-4e3d-ac87-13dc0ccd9b47', 'telemedizin', '§ 87 SGB V; SGB XI; § 7 Abs. 4 MBO-Ä', 'Heilmittelerbringer: Videotherapie:
Rechtsgrundlage: § 125 Abs. 2a SGB V (DVPMG); G-BA-Heilmittel-Richtlinie (Videotherapie); Umsetzung in den Verträgen nach § 125 Abs. 1 SGB V, Regelversorgung seit 01.04.2022 für Physiotherapie, Ergotherapie, Stimm-/Sprech-/Sprach-/Schlucktherapie und Ernährungstherapie.
Vergütung: gleiche Preise wie in Präsenz, eigene Positionsnummern (z. B. Physio X1221 Manuelle Therapie telemedizinisch: 35,59 € ab 01.01.2026).
Anforderungen Physiotherapie: KG Einzel, KG Gruppe und KG Muko bis zur Hälfte der verordneten Einheiten; KG-ZNS nach Bobath bis drei Einheiten; Manuelle Therapie eine Einheit. Erstbehandlung und Verlaufskontrollen persönlich; Durchführung aus den zugelassenen Praxisräumen; Arzt darf Videotherapie ausschließen; Einwilligung und datenschutzkonforme Anwendung.
Andere Bereiche (ergänzt in Lauf 2): Ergotherapie max. 30 % aller Behandlungen je Leistungserbringer und Quartal, erste Einheit in Präsenz, bis zu zwei Einheiten je Verordnung als Telefonberatung; Logopädie max. 30 % je Quartal, Kennzeichnung „TML“ auf der Verordnung; Ernährungstherapie bis 50 % des Zeitkontingents, davon bis 30 Minuten telefonisch; Podologie keine Videotherapie. Nur zertifizierte Videoanbieter. — AOK-Handout Ergotherapie; GKV-SV „90 Prozent“; dmrz (sekundär)
— GKV-SV Vertrag Physiotherapie mit Videotherapie; Anlage 2 Vergütung ab 01.01.2026

Pflege: Telepflege:
Regelvergütung: keine eigene telemedizinische Leistungsposition in der Pflegeversicherung gefunden.
Modellprogramm § 125a SGB XI: 5 Mio. € aus dem Ausgleichsfonds, 2022 bis Ende 2025, zwölf Projekte; abgeschlossen. Der GKV-SV muss bis 31.12.2027 Empfehlungen zur Umsetzung erarbeiten (Fassung nach BEEP, ab 01.01.2026).
Indirekt: Pflegekräfte nehmen an ärztlichen Videofallkonferenzen (EBM 01442, BEMA VFK) teil, erhalten dafür aber keine eigene Vergütung. Telemedizinische Erbringung häuslicher Krankenpflege: Regelung nicht gefunden.
— GKV-SV Modellprogramm § 125a; § 125a SGB XI

Hebammen:
Rechtsgrundlage: § 134a Abs. 1d SGB V (DVPMG) verpflichtet die Vertragspartner, Leistungen der Hebammenhilfe per Videobetreuung zu vereinbaren. Umgesetzt im neuen Hebammenhilfevertrag für Leistungen seit 01.11.2025 (Änderungsvereinbarung vom 16.03.2026); davor befristete Übergangsvereinbarungen.
Vergütung: Videobetreuung ersetzt die analoge ambulante Leistung und wird mit eigenen Gebührenpositionen (Endziffer „3“) abgerechnet; bei kontingentierten Leistungen wird sie aufs Kontingent angerechnet. Auch Geburtsvorbereitungs- und Rückbildungskurse können per Video laufen.
Anforderungen: technische Voraussetzungen in Anlage 4 zum Vertrag; nur vom GKV-SV für Hebammen gelistete Videodienste; Meldung des Video-Angebots für die Vertragspartnerliste. Versichertenbestätigung seit 2026 auch als digital unterschriebenes PDF.
— Hebammenhilfevertrag (GKV-SV); Änderungsvereinbarung 16.03.2026; GKV-SV FAQ, Stand 02.02.2026', NOW())
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  rechtsgrundlage = COALESCE(NULLIF(bg_topic_requirements.rechtsgrundlage,''), EXCLUDED.rechtsgrundlage),
  gesetzestext = EXCLUDED.gesetzestext,
  aktualisiert_am = NOW();


-- Ende