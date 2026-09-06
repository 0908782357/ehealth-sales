/* =========================================================================
   Alliance Assessment — Einstiegsassessment
   Quelle: Foliensatz eHealth Alliance, Folie 6 „1. TI & Fachdienste"

   Format: je Frage genau eine Auswahl aus vier Reifegradstufen.
   Die Optionen stehen absteigend vom Zielbild zur ungünstigsten Lage —
   Position 1 = 3 Punkte, Position 4 = 0 Punkte. Das entspricht dem
   discreteOptions-Modell des Originals (fulfilled 0..3).

   Weitere Kategorien: einfach als zusätzliches Objekt anhängen.
   ========================================================================= */
const ALLIANCE_SOURCE = {
  id: "mod-alliance",
  name: "Alliance Assessment",
  version: "Einstiegsassessment",
  owner: "Marco",
  introText: {
    DE: "Einstiegsassessment der eHealth Alliance: Standortbestimmung zu Telematikinfrastruktur und Fachdiensten. Je Frage wird die zutreffende Reifegradstufe gewählt.",
    EN: "eHealth Alliance entry assessment: positioning on telematics infrastructure and specialist services. For each question, the applicable maturity level is selected.",
  },
  categories: [
    {
      name: "TI & Fachdienste",
      questions: [
        {
          content: "Wie ist Ihre TI-Anbindung heute technisch aufgebaut?",
          options: [
            "TI-Gateway, betrieben durch einen Dienstleister",
            "Eigene Konnektoren im Haus, Wartung geregelt",
            "Eigene Konnektoren, Wartungs- und Patchstand unklar",
            "Mischbetrieb über mehrere Standorte, kein Gesamtüberblick",
          ],
        },
        {
          content: "Wie weit sind Sie bei VSDM 2.0 und dem Wechsel auf ZETA?",
          options: [
            "Migrationsfahrplan liegt vor, Termine mit Herstellern abgestimmt",
            "Auswirkungen auf KIS/PVS bewertet, Fahrplan offen",
            "Thema bekannt, noch keine Bewertung",
            "Erstmals damit befasst",
          ],
        },
        {
          content: "Wer ist bei einer TI-Störung Ihr erster Ansprechpartner?",
          options: [
            "Ein Dienstleister mit vertraglich zugesicherter Reaktionszeit",
            "Mehrere Anbieter, Zuständigkeiten sind dokumentiert",
            "Mehrere Anbieter, die Klärung dauert im Ernstfall",
            "Eigene IT klärt selbst / nicht geregelt",
          ],
        },
      ],
    },

    /* Folie 7 — „2. Informationssicherheit & NIS2" */
    {
      name: "Informationssicherheit & NIS2",
      questions: [
        {
          content: "Haben Sie Ihre NIS2-Betroffenheit geprüft?",
          options: [
            "Ja, dokumentiert und beim BSI registriert",
            "Ja geprüft, Registrierung noch offen",
            "Prüfung läuft",
            "Nicht geprüft / Betroffenheit unklar",
          ],
        },
        {
          content: "Auf welchem Stand ist Ihr ISMS?",
          options: [
            "Auditiert nach ISO 27001 oder B3S, Nachweise aktuell",
            "ISMS im Aufbau, Nachweise unvollständig",
            "Einzelmaßnahmen ohne Managementsystem",
            "Kein ISMS vorhanden",
          ],
        },
        {
          content: "Wie steuern Sie Risiken Ihrer IT-Dienstleister und Lieferanten?",
          options: [
            "Lieferanteninventar mit Kritikalitätsklassen und Vertragsklauseln",
            "Inventar vorhanden, Verträge nicht angepasst",
            "Nur die größten Dienstleister erfasst",
            "Keine strukturierte Übersicht",
          ],
        },
      ],
    },

    /* Folie 8 — „3. Interoperabilität & Daten" */
    {
      name: "Interoperabilität & Daten",
      questions: [
        {
          content: "Liegen für Ihre Systeme die ePA-Konformitätsbescheinigungen vor?",
          options: [
            "Für alle relevanten Systeme vorhanden",
            "Teilweise, Lücken sind bekannt",
            "Beim Hersteller angefragt, keine belastbare Aussage",
            "Stand nicht bekannt",
          ],
        },
        {
          content: "Wie tauschen KIS, RIS, LIS und Medizingeräte heute Daten aus?",
          options: [
            "Über eine zentrale Integrationsplattform mit FHIR/ISiK",
            "Punkt-zu-Punkt-Schnittstellen, vollständig dokumentiert",
            "Historisch gewachsen, teilweise undokumentiert",
            "Überwiegend manuelle Übergaben und Doppelerfassung",
          ],
        },
        {
          content: "Können Sie klinische Daten hausweit auswerten?",
          options: [
            "Ja, klinisches Data Repository im Betrieb",
            "Aufbau begonnen",
            "Daten liegen in Silos, Auswertung nur projektweise",
            "Keine Datenstrategie vorhanden",
          ],
        },
      ],
    },
  ],
};
