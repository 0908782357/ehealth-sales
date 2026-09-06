/* =========================================================================
   Digital-Health-Quiz — KHZG, NIS2, TI, ePA
   10 Multiple-Choice-Fragen mit Auflösungstext. Struktur unverändert
   gegenüber dem Original (assessmentData.jsx), nur der Inhalt ist neu.
   ========================================================================= */
const COMPASS_QUIZ_SOURCE = [
  {
    index: 0,
    questionText:
      "Wie viel Fördervolumen stand über den Krankenhauszukunftsfonds (KHZG) insgesamt bereit?",
    optionA: "1,3 Mrd. €",
    optionB: "3,0 Mrd. €",
    optionC: "4,3 Mrd. €",
    optionD: "8,0 Mrd. €",
    correctOption: "optionC",
    solutionText:
      "Bis zu 4,3 Mrd. €: 3 Mrd. € vom Bund, bis zu 1,3 Mrd. € von Ländern und Trägern. Die Förderquote lag bei 70 % Bund zu 30 % Land oder Träger.\n\nAha: Mindestens 15 % der beantragten Mittel mussten in IT-Sicherheit fließen — das KHZG war damit auch das größte Cybersicherheitsprogramm, das die deutsche Krankenhauslandschaft je gesehen hat. Viele Häuser haben diese Quote als Pflichtübung abgehakt, statt sie als bezahlte Grundlage für das zu nutzen, was NIS2 heute ohnehin verlangt.",
  },
  {
    index: 1,
    questionText:
      "Was passiert seit 2025 mit Krankenhäusern, die die KHZG-Muss-Kriterien nicht erfüllen?",
    optionA: "Nichts, die Förderung verfällt lediglich",
    optionB: "Abschlag von bis zu 2 % des Rechnungsbetrags je vollstationärem Fall",
    optionC: "Einmalige Geldbuße von 50.000 €",
    optionD: "Rückzahlung der erhaltenen Fördermittel",
    correctOption: "optionB",
    solutionText:
      "Seit dem 1. Januar 2025 greift ein Abschlag von bis zu 2 % des Rechnungsbetrags je vollstationärem Fall (§ 5 Abs. 3h KHEntgG), wenn die Muss-Kriterien der Fördertatbestände 2 bis 6 nicht erfüllt sind.\n\nAha: Das ist keine einmalige Buße, sondern trifft die laufenden Erlöse — dauerhaft. Bei einem Haus mit 100 Mio. € Erlös sind das bis zu 2 Mio. € pro Jahr. Die Digitalisierung nicht zu machen ist damit teurer, als sie zu machen.",
  },
  {
    index: 2,
    questionText:
      "Wie hoch können Bußgelder für „wesentliche Einrichtungen\" nach NIS2 maximal ausfallen?",
    optionA: "500.000 €",
    optionB: "2 Mio. € oder 1 % des Jahresumsatzes",
    optionC: "10 Mio. € oder 2 % des weltweiten Jahresumsatzes",
    optionD: "20 Mio. € oder 4 % des Jahresumsatzes",
    correctOption: "optionC",
    solutionText:
      "Bis zu 10 Mio. € oder 2 % des weltweiten Jahresumsatzes — je nachdem, welcher Betrag höher ist. Für „wichtige Einrichtungen\" sind es bis zu 7 Mio. € oder 1,4 %.\n\nAha: Der eigentliche Unterschied zur DSGVO ist nicht die Höhe, sondern die Adressierung. NIS2 nimmt die Geschäftsleitung persönlich in die Pflicht: Sie muss die Risikomanagementmaßnahmen billigen, ihre Umsetzung überwachen und sich dafür schulen lassen. IT-Sicherheit ist damit endgültig kein Thema mehr, das man an die IT-Abteilung delegieren kann.",
  },
  {
    index: 3,
    questionText:
      "Wie schnell muss ein erheblicher Sicherheitsvorfall nach NIS2 erstmals gemeldet werden?",
    optionA: "Innerhalb von 24 Stunden",
    optionB: "Innerhalb von 72 Stunden",
    optionC: "Innerhalb von 7 Tagen",
    optionD: "Innerhalb von 30 Tagen",
    correctOption: "optionA",
    solutionText:
      "Dreistufig: Frühwarnung binnen 24 Stunden, vollständige Meldung binnen 72 Stunden, Abschlussbericht binnen eines Monats.\n\nAha: Die 24 Stunden laufen ab Kenntnis des Vorfalls — nicht ab dem Zeitpunkt, an dem man verstanden hat, was passiert ist. Wer am Montagmorgen bemerkt, was am Freitagabend begann, hat die Frist fast aufgebraucht, bevor die erste Analyse steht. Ohne vorbereiteten Meldeprozess mit benannten Verantwortlichen ist sie praktisch nicht zu halten.",
  },
  {
    index: 4,
    questionText:
      "Welche Krankenhäuser müssen IT-Sicherheit nach dem Stand der Technik umsetzen?",
    optionA: "Nur KRITIS-Häuser ab 30.000 vollstationären Fällen",
    optionB: "Alle Krankenhäuser",
    optionC: "Nur Universitätskliniken",
    optionD: "Nur Häuser, die KHZG-Mittel erhalten haben",
    correctOption: "optionB",
    solutionText:
      "§ 75c SGB V verpflichtet seit dem 1. Januar 2022 alle Krankenhäuser, angemessene organisatorische und technische Vorkehrungen nach dem Stand der Technik zu treffen — unabhängig von Größe, Trägerschaft und KRITIS-Status.\n\nAha: Die vielzitierte 30.000-Fälle-Schwelle entscheidet nur darüber, wem gegenüber man es nachweisen muss, nicht darüber, ob man es tun muss. Ein Haus mit 15.000 Fällen ist genauso in der Pflicht — es muss es nur niemandem beweisen. Bis etwas passiert.",
  },
  {
    index: 5,
    questionText:
      "Wie viele gesetzlich Versicherte haben der elektronischen Patientenakte widersprochen?",
    optionA: "Unter 5 %",
    optionB: "Rund 15 %",
    optionC: "Rund 30 %",
    optionD: "Über 50 %",
    correctOption: "optionA",
    solutionText:
      "Die Widerspruchsquote blieb im niedrigen einstelligen Prozentbereich. Rund 70 Millionen Akten wurden automatisch angelegt.\n\nAha: Zehn Jahre Freiwilligkeit brachten die ePA auf etwa 1 % Verbreitung. Eine einzige Änderung — von Opt-in auf Opt-out — brachte sie in wenigen Monaten über 95 %. Nicht die Technik war das Hindernis, sondern die Voreinstellung.",
  },
  {
    index: 6,
    questionText:
      "Welche Branche verzeichnet weltweit die höchsten Kosten pro Datenleck?",
    optionA: "Finanzsektor",
    optionB: "Energieversorgung",
    optionC: "Öffentliche Verwaltung",
    optionD: "Gesundheitswesen",
    correctOption: "optionD",
    solutionText:
      "Das Gesundheitswesen führt diese Statistik seit über einem Jahrzehnt ununterbrochen an — zuletzt rund 10 Mio. US-Dollar je Vorfall und damit etwa das Doppelte des branchenübergreifenden Durchschnitts.\n\nAha: Der Hauptgrund ist nicht schlechtere Technik, sondern die Entdeckungsdauer. Angriffe im Gesundheitswesen bleiben im Schnitt am längsten unbemerkt, und die Kosten wachsen mit jedem Monat, den ein Angreifer im Netz verbringt. Detection zahlt sich schneller aus als jede weitere Firewall.",
  },
  {
    index: 7,
    questionText:
      "Ab wie vielen vollstationären Fällen pro Jahr gilt ein Krankenhaus als KRITIS-Anlage?",
    optionA: "10.000",
    optionB: "20.000",
    optionC: "30.000",
    optionD: "50.000",
    correctOption: "optionC",
    solutionText:
      "Ab 30.000 vollstationären Fällen im Jahr (BSI-KritisV). Der Nachweis nach § 8a BSIG ist dann alle zwei Jahre fällig, üblicherweise über den branchenspezifischen Sicherheitsstandard B3S der DKG.\n\nAha: Das betrifft nur einige Hundert der rund 1.700 deutschen Krankenhäuser — diese versorgen aber die Mehrheit aller Fälle. Wer knapp unter der Schwelle liegt, sollte trotzdem rechnen: Fusionen, Zukäufe und wachsende Fallzahlen führen regelmäßig dazu, dass ein Haus über Nacht KRITIS wird, ohne darauf vorbereitet zu sein.",
  },
  {
    index: 8,
    questionText:
      "Was gilt für ISiK-Schnittstellen in Krankenhausinformationssystemen?",
    optionA: "Freiwillige Empfehlung der gematik",
    optionB: "Gesetzlich verpflichtend für die Hersteller",
    optionC: "Nur für KHZG-geförderte Häuser verbindlich",
    optionD: "Nur für Universitätskliniken verbindlich",
    correctOption: "optionB",
    solutionText:
      "§ 373 SGB V verpflichtet die gematik, verbindliche Schnittstellen festzulegen. ISiK ist damit Pflicht und kein Zusatzmodul — technisch auf Basis von HL7 FHIR.\n\nAha: Interoperabilität ist damit keine Sonderleistung mehr, die man beim KIS-Hersteller einzeln beauftragen und bezahlen müsste. Wer bei der nächsten Vertragsverhandlung nicht ausdrücklich darauf besteht, lässt etwas liegen, das ihm ohnehin zusteht.",
  },
  {
    index: 9,
    questionText:
      "Wie kommt eine Gesundheits-App in die Erstattung der gesetzlichen Krankenkassen?",
    optionA: "Zulassung als Arzneimittel beim Paul-Ehrlich-Institut",
    optionB: "Einzelvertrag mit jeder Krankenkasse",
    optionC: "Gar nicht, Apps sind immer Selbstzahlerleistung",
    optionD: "Aufnahme in das DiGA-Verzeichnis des BfArM",
    correctOption: "optionD",
    solutionText:
      "Über das DiGA-Verzeichnis des BfArM. Danach ist die App für rund 74 Millionen gesetzlich Versicherte verordnungs- und erstattungsfähig — ein einziger Antrag statt Verhandlungen mit jeder Kasse.\n\nAha: Bei vorläufiger Aufnahme darf der Hersteller den Preis im ersten Jahr frei festlegen; verhandelt wird erst danach. Deutschland war das erste Land der Welt mit einem solchen Regelweg für die „App auf Rezept\" — ein Standortvorteil, der international deutlich stärker beachtet wird als hierzulande.",
  },
];
