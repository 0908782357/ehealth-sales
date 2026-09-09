-- ================================================================
-- TI-Finanzierungsvereinbarungen – Datenimport
-- Quelle: TI-Finanzierungsvereinbarung.html | Stand: September 2026
-- Rechtsgrundlage: §§ 371–382 SGB V
-- ================================================================
-- Prüfabfrage VORHER – zeigt Berufsgruppen-Namen in der DB:
-- SELECT nr, name FROM berufsgruppen ORDER BY nr;

-- ── 1. Vertragsärzte / Psychotherapeuten ────────────────────────
INSERT INTO bg_topic_requirements
  (berufsgruppe_id, thema, finanzierungsart, rechtsgrundlage, foerdergeber, gueltig_seit, foerderbetrag, bedingungen, auszahlung)
SELECT id, 'ti',
  'Monatliche Pauschale',
  '§ 378 SGB V',
  'GKV-SV / KBV',
  '1.7.2023',
  '263,62 – 390,80 €/Monat (staffelweise je Praxisgröße, +2,8 % p.a.)',
  'Pflichtanwendungen: NFDM/eMP, ePA, eAU, eArztbrief, eRezept. Bei 1 fehlender Anwendung −50 %; bei ≥ 2 entfällt Pauschale vollständig. KV kann Fachgruppen von einzelnen Anwendungen befreien. Kürzung ab 1.4.2026 bei fehlender ePA 3.0.',
  'Automatisch durch Kassenärztliche Vereinigung (KV) im Rahmen der Quartalsabrechnung – keine gesonderte Antragstellung nötig.'
FROM berufsgruppen
WHERE name ILIKE '%arztprax%' OR name ILIKE '%vertragsarzt%' OR name ILIKE '%vertragsärzt%'
   OR name ILIKE '%niedergelassen%' OR name ILIKE '%hausarzt%' OR name ILIKE '%psychotherapeut%'
   OR name ILIKE '%allgemeinmedizin%'
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  finanzierungsart = EXCLUDED.finanzierungsart, rechtsgrundlage = EXCLUDED.rechtsgrundlage,
  foerdergeber = EXCLUDED.foerdergeber, gueltig_seit = EXCLUDED.gueltig_seit,
  foerderbetrag = EXCLUDED.foerderbetrag, bedingungen = EXCLUDED.bedingungen,
  auszahlung = EXCLUDED.auszahlung, aktualisiert_am = now();

-- ── 2. Vertragszahnärzte ────────────────────────────────────────
INSERT INTO bg_topic_requirements
  (berufsgruppe_id, thema, finanzierungsart, rechtsgrundlage, foerdergeber, gueltig_seit, foerderbetrag, bedingungen, auszahlung)
SELECT id, 'ti',
  'Monatliche Pauschale',
  '§ 378 SGB V',
  'GKV-SV / KZBV',
  '1.7.2023',
  '263,62 – 390,80 €/Monat (nach Praxisgröße; selbe Formel wie Ärzte)',
  'Vollständige TI-Ausstattung + Pflichtanwendungen (NFDM/eMP, ePA, eAU, eRezept). Übergangsstufen (TI-Pauschale 2/3 für Erstanschluss 2021–2023) liefen zum 31.12.2025 aus.',
  'Automatisch über Kassenzahnärztliche Vereinigung (KZV) nach Abgabe der TI-Eigenerklärung.'
FROM berufsgruppen
WHERE name ILIKE '%zahnarzt%' OR name ILIKE '%zahnärzt%' OR name ILIKE '%zahnmed%'
   OR name ILIKE '%zahnarztprax%'
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  finanzierungsart = EXCLUDED.finanzierungsart, rechtsgrundlage = EXCLUDED.rechtsgrundlage,
  foerdergeber = EXCLUDED.foerdergeber, gueltig_seit = EXCLUDED.gueltig_seit,
  foerderbetrag = EXCLUDED.foerderbetrag, bedingungen = EXCLUDED.bedingungen,
  auszahlung = EXCLUDED.auszahlung, aktualisiert_am = now();

-- ── 3. Krankenhäuser ────────────────────────────────────────────
INSERT INTO bg_topic_requirements
  (berufsgruppe_id, thema, finanzierungsart, rechtsgrundlage, foerdergeber, gueltig_seit, foerderbetrag, bedingungen, auszahlung)
SELECT id, 'ti',
  'Fallbezogener Zuschlag',
  '§ 377 SGB V',
  'GKV-SV / DKG',
  'seit 2018, jährlich angepasst',
  'Individuell (Budgetverhandlung je Haus – kein bundesweit einheitlicher Betrag)',
  'Nachweis TI-Anschluss, ePA und E-Rezept (Formulare Anlage 1 und 2 der Vereinbarung). Telematikzuschlag wird individuell via DKG-Berechnungshilfe (Excel v6.5) kalkuliert. Kürzung bei fehlender ePA 3.0 ab 1.4.2026. Gilt auch für Hochschulambulanzen und Notaufnahmen.',
  'Über laufende Krankenhausabrechnung bzw. Budgetverhandlung mit Kostenträgern. Bei Nichteinigung entscheidet Schiedsstelle (Frist: 2 Monate).'
FROM berufsgruppen
WHERE name ILIKE '%krankenhaus%' OR name ILIKE '%klinikum%' OR name ILIKE '%akutklinik%'
   OR name ILIKE '%hospital%'
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  finanzierungsart = EXCLUDED.finanzierungsart, rechtsgrundlage = EXCLUDED.rechtsgrundlage,
  foerdergeber = EXCLUDED.foerdergeber, gueltig_seit = EXCLUDED.gueltig_seit,
  foerderbetrag = EXCLUDED.foerderbetrag, bedingungen = EXCLUDED.bedingungen,
  auszahlung = EXCLUDED.auszahlung, aktualisiert_am = now();

-- ── 4. Öffentliche Apotheken ─────────────────────────────────────
INSERT INTO bg_topic_requirements
  (berufsgruppe_id, thema, finanzierungsart, rechtsgrundlage, foerdergeber, gueltig_seit, foerderbetrag, bedingungen, auszahlung)
SELECT id, 'ti',
  'Monatliche Pauschale',
  '§§ 376, 379 SGB V',
  'GKV-SV / DAV / Notdienstfonds (NNF)',
  '1.7.2023',
  '205,99 – 279,69 €/Monat (nach GKV-Rx-Volumen, seither +3–4 % p.a.)',
  'Vollständiger TI-Anschluss inkl. E-Rezept und eMP-Fähigkeit. Staffelung nach GKV-Jahresrezeptvolumen (4 Quartale rückblickend). In ersten 30 Monaten reduzierte Pauschale. Max. 10 Kartenterminals je Standort förderfähig. Bei fehlender Pflichtanwendung weitere Reduzierung.',
  'Quartalsweise über Notdienstfonds (NNF) des DAV. Jährliche Bearbeitungsgebühr 48 € (ermäßigt für Altanschlüsse).'
FROM berufsgruppen
WHERE name ILIKE '%apothek%'
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  finanzierungsart = EXCLUDED.finanzierungsart, rechtsgrundlage = EXCLUDED.rechtsgrundlage,
  foerdergeber = EXCLUDED.foerdergeber, gueltig_seit = EXCLUDED.gueltig_seit,
  foerderbetrag = EXCLUDED.foerderbetrag, bedingungen = EXCLUDED.bedingungen,
  auszahlung = EXCLUDED.auszahlung, aktualisiert_am = now();

-- ── 5. Vorsorge- / Rehabilitationseinrichtungen ─────────────────
-- nr=23 ist bekannt, zusätzlich Name-Matching als Fallback
INSERT INTO bg_topic_requirements
  (berufsgruppe_id, thema, finanzierungsart, rechtsgrundlage, foerdergeber, gueltig_seit, foerderbetrag, bedingungen, auszahlung, has_rechner)
SELECT id, 'ti',
  'Fallbezogener Zuschlag',
  '§ 381 SGB V',
  'GKV-SV / degemed, BDPK u.a.',
  'rückwirkend seit 1.1.2022',
  'Individuell – tagesbezogener Telematikzuschlag je Behandlungsfall',
  'Kalkulation anhand: Anzahl Fachabteilungen/Indikationsgruppen, Anzahl Standorte, Behandlungskapazität (stat. + amb.), Abrechnungstage Vorjahr (DRV, GKV, SVLFG, PKV). Infrastrukturkosten: Amortisation 2 Jahre. Betriebskosten (VPN, Wartung): 5 Jahre. Organisationskosten werden berücksichtigt.',
  'Individuell verhandelt; fallbezogener Zuschlag in laufender Abrechnung mit Kostenträgern. DKG-Berechnungshilfe (Excel) nutzbar.',
  true
FROM berufsgruppen
WHERE nr = 23 OR name ILIKE '%reha%' OR name ILIKE '%rehabilitat%' OR name ILIKE '%vorsorge%'
   OR name ILIKE '%kureinr%'
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  finanzierungsart = EXCLUDED.finanzierungsart, rechtsgrundlage = EXCLUDED.rechtsgrundlage,
  foerdergeber = EXCLUDED.foerdergeber, gueltig_seit = EXCLUDED.gueltig_seit,
  foerderbetrag = EXCLUDED.foerderbetrag, bedingungen = EXCLUDED.bedingungen,
  auszahlung = EXCLUDED.auszahlung, has_rechner = EXCLUDED.has_rechner, aktualisiert_am = now();

-- ── 6. Pflegeeinrichtungen ───────────────────────────────────────
INSERT INTO bg_topic_requirements
  (berufsgruppe_id, thema, finanzierungsart, rechtsgrundlage, foerdergeber, gueltig_seit, foerderbetrag, bedingungen, auszahlung)
SELECT id, 'ti',
  'Monatliche Pauschale + Kartenzuschlag',
  'SGB V / § 125 SGB XI',
  'GKV-SV / Pflegeverbände',
  '1.7.2023 (rückwirkend)',
  '200,22 €/Monat + 7,48 €/eHBA (Stand ab 1.1.2024)',
  'Konnektor, VPN-Zugangsdienst, Kartenterminals, eHBA und SMC-B erforderlich. Software muss KIM unterstützen. Altverträge: 30 Monate nur 50 % der neuen Pauschale. Belege für Stichprobenprüfungen vorhalten (kein Einreichen bei Antragstellung). Zwei parallele Vereinbarungen: SGB V (amb. Krankenpflege) + SGB XI (Pflegeversicherung).',
  'Selbsterklärung über GKV-SV Online-Portal (antraege.gkv-spitzenverband.de). Auszahlung quartalsweise trotz monatlicher Berechnung. Rückwirkende Anträge bis 1.7.2023 möglich.'
FROM berufsgruppen
WHERE name ILIKE '%pflege%'
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  finanzierungsart = EXCLUDED.finanzierungsart, rechtsgrundlage = EXCLUDED.rechtsgrundlage,
  foerdergeber = EXCLUDED.foerdergeber, gueltig_seit = EXCLUDED.gueltig_seit,
  foerderbetrag = EXCLUDED.foerderbetrag, bedingungen = EXCLUDED.bedingungen,
  auszahlung = EXCLUDED.auszahlung, aktualisiert_am = now();

-- ── 7. Hebammen ──────────────────────────────────────────────────
INSERT INTO bg_topic_requirements
  (berufsgruppe_id, thema, finanzierungsart, rechtsgrundlage, foerdergeber, gueltig_seit, foerderbetrag, bedingungen, auszahlung)
SELECT id, 'ti',
  'Monatliche Pauschale (Beträge aktuell unklar)',
  '§ 380 SGB V',
  'GKV-SV / Deutscher Hebammenverband',
  '1.7.2021 (freiberuflich) / 1.10.2021 (Einrichtungen)',
  'Aktuelle Beträge unklar – direkt beim Deutschen Hebammenverband oder GKV-SV anfragen',
  'SMC-B (Hebammen-Ausweis), TI-Anschluss (Konnektor/TI-Gateway, Kartenterminal). Pflichtanwendungen: NFDM/eMP, ePA, KIM. Plausibel, dass zwischenzeitlich auf einheitliches Monatspauschalen-Modell umgestellt.',
  'Antragstellung über antraege.gkv-spitzenverband.de mittels SMC-B. Anspruchsfrist: Ende des auf den Anschlussmonat folgenden Quartals. Auszahlung spätestens zum 15. des dritten Monats des Folgequartals.'
FROM berufsgruppen
WHERE name ILIKE '%hebamm%'
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  finanzierungsart = EXCLUDED.finanzierungsart, rechtsgrundlage = EXCLUDED.rechtsgrundlage,
  foerdergeber = EXCLUDED.foerdergeber, gueltig_seit = EXCLUDED.gueltig_seit,
  foerderbetrag = EXCLUDED.foerderbetrag, bedingungen = EXCLUDED.bedingungen,
  auszahlung = EXCLUDED.auszahlung, aktualisiert_am = now();

-- ── 8. Heilmittelerbringer ───────────────────────────────────────
INSERT INTO bg_topic_requirements
  (berufsgruppe_id, thema, finanzierungsart, rechtsgrundlage, foerdergeber, gueltig_seit, foerderbetrag, bedingungen, auszahlung)
SELECT id, 'ti',
  'Monatliche Pauschale + Kartenzuschlag',
  '§ 380 SGB V',
  'GKV-SV / dbl, DVE, dbs, ifk, Physio Deutschland',
  '1.7.2025',
  '207,93 €/Monat + 7,77 €/Karte (SMC-B und/oder eHBA)',
  'Gilt für: Physiotherapie, Ergotherapie, Logopädie, Podologie, Ernährungstherapie. SMC-B (Praxisausweis) und eHBA (persönlicher Ausweis) erforderlich – Beantragung kann bis zu 8 Wochen dauern, frühzeitig einplanen. Anschlusspflicht verbindlich ab 1.1.2026.',
  'Quartalsweise. Rückwirkende Auszahlung möglich für Praxen mit vollständigem Anschluss bis 1.7.2024. Erste Auszahlung ab 1.10.2025 für Anschlüsse ab 1.7.2025.'
FROM berufsgruppen
WHERE name ILIKE '%heilmittel%' OR name ILIKE '%physiother%' OR name ILIKE '%ergother%'
   OR name ILIKE '%logopäd%' OR name ILIKE '%podolog%' OR name ILIKE '%ernährungsther%'
ON CONFLICT (berufsgruppe_id, thema) DO UPDATE SET
  finanzierungsart = EXCLUDED.finanzierungsart, rechtsgrundlage = EXCLUDED.rechtsgrundlage,
  foerdergeber = EXCLUDED.foerdergeber, gueltig_seit = EXCLUDED.gueltig_seit,
  foerderbetrag = EXCLUDED.foerderbetrag, bedingungen = EXCLUDED.bedingungen,
  auszahlung = EXCLUDED.auszahlung, aktualisiert_am = now();

-- ================================================================
-- Prüfabfrage NACHHER – zeigt was angelegt wurde
-- ================================================================
SELECT b.nr, b.name, r.rechtsgrundlage, r.finanzierungsart, r.foerderbetrag
FROM bg_topic_requirements r
JOIN berufsgruppen b ON b.id = r.berufsgruppe_id
WHERE r.thema = 'ti'
ORDER BY b.nr;
