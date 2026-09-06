/* =========================================================================
   eHealth Alliance Compass — lokale Standalone-Variante
   Domänenmodell und Bewertungslogik sind 1:1 aus dem Original übernommen:
     Module -> Category -> Question -> Requirements (weight, discreteOptions)
     Answer -> requirementAnswers {fulfilled 0..3 | bool, disabled}
     Rating  = gewichteter Erfüllungsgrad  (StandardAssessment.calculatePercentage)
     Category-Aggregation + Handlungsempfehlungen (Lambda ComputeEvaluation)
   ========================================================================= */

/* ---------------------------------------------------------------- i18n --- */
const L = {
  DE: {
    nav_home: "Start", nav_assessment: "Assessment", nav_eval: "Auswertung", nav_quiz: "Quiz",
    hero_sub: "Compliance Assessment — lokale Instanz. Alle Fragen, Bewertungslogik und Auswertungen laufen vollständig in diesem Browser.",
    modules: "Assessments", modules_sub: "Wählen Sie ein Modul, um mit der Bewertung zu beginnen.",
    start: "Assessment starten", start_quiz: "Quiz starten", cont: "Fortsetzen",
    customer: "Mandant / Organisation", customer_ph: "z. B. Musterklinik GmbH",
    questions: "Fragen", categories: "Kategorien", category: "Kategorie",
    question: "Frage", requirements: "Anforderungen", requirement: "Anforderung",
    fulfilled_pct: "Erfüllte Anforderungen in Prozent:",
    contact: "Ansprechperson", comments: "Anmerkungen", source: "Quelle:",
    not_relevant: "Nicht relevant", weight: "Gewicht",
    save: "Speichern", saved: "Antwort gespeichert.",
    prev: "Zurück", next: "Weiter", to_eval: "Auswertung erzeugen",
    progress: "Fortschritt", answered: "beantwortet",
    r0: "Nicht erfüllt", r1: "Kaum erfüllt", r2: "Weitgehend erfüllt", r3: "Erfüllt",
    eval_title: "Auswertung", overall: "Gesamtergebnis", points: "Punkte",
    result_by_cat: "Ergebnis nach Kategorie", recommendations: "Handlungsempfehlungen",
    no_recs: "Alle bewerteten Anforderungen sind erfüllt — keine Handlungsempfehlungen offen.",
    summary: "Zusammenfassung", print: "Drucken / PDF", export: "JSON exportieren",
    back_assessment: "Zurück zum Assessment", reset: "Assessment zurücksetzen",
    reset_confirm: "Alle Antworten dieses Moduls wirklich löschen?",
    incomplete: "Noch nicht alle Fragen beantwortet — die Auswertung berücksichtigt nur bewertete Fragen.",
    score_of: "von", quiz_q: "Frage", quiz_of: "von", quiz_next: "Nächste Frage",
    quiz_result: "Ergebnis", quiz_correct: "richtig beantwortet", quiz_again: "Nochmal",
    quiz_solution: "Auflösung", answers_saved: "Antworten werden lokal im Browser gespeichert (localStorage).",
    completely: "vollständig beantwortet", partially: "teilweise beantwortet", open: "offen",
    your_answer: "Ihre Einschätzung", maturity: "Reifegrad:", target: "Zielbild",
  },
  EN: {
    nav_home: "Home", nav_assessment: "Assessment", nav_eval: "Evaluation", nav_quiz: "Quiz",
    hero_sub: "Compliance assessment — local instance. All questions, rating logic and evaluations run entirely in this browser.",
    modules: "Assessments", modules_sub: "Pick a module to start the assessment.",
    start: "Start assessment", start_quiz: "Start quiz", cont: "Continue",
    customer: "Customer / organisation", customer_ph: "e.g. Example Hospital Ltd.",
    questions: "Questions", categories: "Categories", category: "Category",
    question: "Question", requirements: "Requirements", requirement: "Requirement",
    fulfilled_pct: "Fulfilled requirements in percent:",
    contact: "Contact", comments: "Comments", source: "Source:",
    not_relevant: "Not relevant", weight: "Weight",
    save: "Save", saved: "Answer saved.",
    prev: "Back", next: "Next", to_eval: "Create evaluation",
    progress: "Progress", answered: "answered",
    r0: "Not fulfilled", r1: "Barely fulfilled", r2: "Largely fulfilled", r3: "Fulfilled",
    eval_title: "Evaluation", overall: "Overall result", points: "points",
    result_by_cat: "Result by category", recommendations: "Recommendations",
    no_recs: "All rated requirements are fulfilled — no open recommendations.",
    summary: "Summary", print: "Print / PDF", export: "Export JSON",
    back_assessment: "Back to assessment", reset: "Reset assessment",
    reset_confirm: "Really delete all answers of this module?",
    incomplete: "Not all questions answered yet — the evaluation only covers rated questions.",
    score_of: "of", quiz_q: "Question", quiz_of: "of", quiz_next: "Next question",
    quiz_result: "Result", quiz_correct: "answered correctly", quiz_again: "Again",
    quiz_solution: "Solution", answers_saved: "Answers are stored locally in your browser (localStorage).",
    completely: "fully answered", partially: "partially answered", open: "open",
    your_answer: "Your assessment", maturity: "Maturity:", target: "Target state",
  },
};
const t = (k) => L[S.lang][k] || k;
const ratingLabel = (v) => t("r" + v);

/* ------------------------------------------------- Domänenmodell aufbauen --- */
/* Mapping der Compass-Assessment-Fragen (InputData.jsx) auf das Original-Schema:
     Area                       -> Category.name
     Question                   -> Question.content  + Requirement.text
     Suggestions for Improvement-> Requirement.solution (Handlungsempfehlung)
   Bewertung diskret 0..3, wie im Original bei discreteOptions = true.          */
const ASSESSMENT_MODULE = {
  id: "mod-test-automation",
  name: "Test Automation",
  icon: "assets/TestAutomation.png",
  version: "Standard",
  language: "EN",
  introText: {
    DE: "Assessment zur Reife der Testautomatisierung und Testabdeckung in Projekten — Fragen, Anforderungen und Handlungsempfehlungen aus dem eHealth Alliance Compass Fragenkatalog.",
    EN: "Assessment of test automation and test coverage maturity in projects — questions, requirements and recommendations from the eHealth Alliance Compass question catalogue.",
  },
  categories: COMPASS_QUESTION_SOURCE.map((row, i) => {
    const cid = "cat-" + i, qid = "q-" + i, rid = "req-" + i;
    return {
      id: cid, index: i, name: row.Area,
      questions: [{
        id: qid, index: i, categoryId: cid, title: row.Area,
        content: row.Question, package: "Basic",
        source: "eHealth Alliance Compass — Test Automation",
        requirements: {
          [rid]: {
            id: rid, text: row.Question, weight: 1,
            discreteOptions: true, discreteSolutions: false,
            solution: row["Suggestions for Improvement"],
          },
        },
      }],
    };
  }),
};
/* Alliance Assessment (_alliance.js) — Auswahlfragen mit vier Reifegradstufen.
   Position 1 der Optionsliste ist das Zielbild (3 Punkte), Position 4 die
   ungünstigste Lage (0 Punkte). Umsetzung über dasselbe Requirement-Modell:
   ein Requirement je Frage, discreteOptions = true, aber mit eigenen
   Stufenbeschriftungen statt „Nicht erfüllt … Erfüllt".                      */
const ALLIANCE_MODULE = {
  id: ALLIANCE_SOURCE.id,
  name: ALLIANCE_SOURCE.name,
  icon: "assets/eHealthAllianceMark.svg",
  version: ALLIANCE_SOURCE.version,
  owner: ALLIANCE_SOURCE.owner,
  language: "DE",
  introText: ALLIANCE_SOURCE.introText,
  categories: ALLIANCE_SOURCE.categories.map((cat, ci) => ({
    id: `all-cat-${ci}`,
    index: ci,
    name: cat.name,
    questions: cat.questions.map((q, qi) => {
      const qid = `all-q-${ci}-${qi}`, rid = `all-req-${ci}-${qi}`;
      // Optionen absteigend: Index 0 => 3 Punkte, Index 3 => 0 Punkte
      const levels = q.options.map((label, oi) => ({ value: q.options.length - 1 - oi, label }));
      return {
        id: qid, index: qi, categoryId: `all-cat-${ci}`, title: cat.name,
        content: q.content, package: "Basic",
        source: q.source || "eHealth Alliance — Einstiegsassessment",
        requirements: {
          [rid]: {
            id: rid, text: q.content, weight: 1,
            discreteOptions: true, discreteSolutions: false,
            levels,
            // Ohne Handlungsempfehlung in der Vorlage: als Empfehlung wird das
            // Zielbild ausgewiesen, also die oberste Option der Frage.
            solution: `Zielbild: ${q.options[0]}`,
          },
        },
      };
    }),
  })),
};

const MODULES = {
  [ALLIANCE_MODULE.id]: ALLIANCE_MODULE,
  [ASSESSMENT_MODULE.id]: ASSESSMENT_MODULE,
};
const allQuestions = (m) => m.categories.flatMap((c) => c.questions);
const DEFAULT_MODULE_ID = ALLIANCE_MODULE.id;
const currentModule = () => MODULES[S.moduleId] || MODULES[DEFAULT_MODULE_ID];

/* ------------------------------------------------------------- State ------ */
const STORE_KEY = "eha-compass-local-v1";
const S = {
  lang: "DE", view: "home", moduleId: null, customer: "",
  catIndex: 0, answers: {},
  quiz: { index: 0, chosen: {}, done: false },
  flash: "",
};
function persist() {
  try {
    localStorage.setItem(STORE_KEY, JSON.stringify({
      lang: S.lang, customer: S.customer, answers: S.answers, quiz: S.quiz, moduleId: S.moduleId,
    }));
  } catch (e) { /* z. B. file:// im Private Mode */ }
}
function restore() {
  try {
    const raw = localStorage.getItem(STORE_KEY);
    if (!raw) return;
    const d = JSON.parse(raw);
    if (d.lang) S.lang = d.lang;
    if (d.customer) S.customer = d.customer;
    if (d.answers) S.answers = d.answers;
    if (d.quiz) S.quiz = d.quiz;
    if (d.moduleId && MODULES[d.moduleId]) S.moduleId = d.moduleId;
  } catch (e) { /* ignorieren */ }
}

/* ----------------------------------------------------- Bewertungslogik ---- */
/* identisch zu StandardAssessment.calculatePercentage() */
function computeRating(question, answer) {
  let sum = 0, total = 0;
  for (const req of Object.values(question.requirements || {})) {
    const a = answer?.requirementAnswers?.[req.id];
    if (a?.disabled) continue;
    total += Number(req.weight);
    const f = a?.fulfilled || 0;
    if (f) {
      if (req.discreteOptions) sum += (Number(req.weight) * Number(f)) / 3;
      else sum += Number(req.weight);
    }
  }
  return total ? (sum / total) * 100 : 0;
}
const hasAnswer = (qid) => !!S.answers[qid];
function answerOf(qid) {
  if (!S.answers[qid]) S.answers[qid] = { requirementAnswers: {}, responsibleRole: "", answerText: "" };
  return S.answers[qid];
}

/* Kategorie-Aggregation — analog Lambda ComputeEvaluation */
function evaluate(mod) {
  const byCat = mod.categories.map((c, i) => {
    const rows = c.questions.map((q) => {
      const a = S.answers[q.id];
      return { q, a, rating: a ? Math.round(computeRating(q, a)) : 0, answered: !!a };
    });
    const totalRating = rows.reduce((acc, r) => acc + r.rating, 0);
    const maxRating = rows.length * 100;
    const recommendations = [];
    rows.forEach((r) => {
      if (!r.a) return;
      Object.values(r.q.requirements || {}).forEach((req) => {
        const ra = r.a.requirementAnswers?.[req.id];
        if (!ra || ra.disabled) return;
        const f = ra.fulfilled || 0;
        const weak = req.discreteOptions ? Number(f) <= 1 : !f;
        if (weak && req.solution) {
          recommendations.push({ category: c.name, question: r.q.content, solution: req.solution });
        }
      });
    });
    return {
      categoryId: c.id, name: c.name, index: i + 1, rows,
      totalRating, maxRating, recommendations,
      completelyAnswered: rows.every((r) => r.answered),
      answeredCount: rows.filter((r) => r.answered).length,
      totalRatingInPercent: maxRating ? totalRating / maxRating : 0,
    };
  });
  const answeredCats = byCat.filter((c) => c.answeredCount > 0);
  const totalRating = answeredCats.reduce((a, c) => a + c.totalRating, 0);
  const maxRating = answeredCats.reduce((a, c) => a + c.rows.filter((r) => r.answered).length * 100, 0);
  return {
    byCat, answeredCats, totalRating, maxRating,
    overall: maxRating ? (totalRating / maxRating) * 100 : 0,
    complete: byCat.every((c) => c.completelyAnswered),
    recommendations: byCat.flatMap((c) => c.recommendations),
  };
}

/* Ersetzt den GPT-Fließtext des Originals durch eine deterministische,
   lokal erzeugte Zusammenfassung nach demselben Prompt-Aufbau.            */
function summaryText(mod, ev) {
  const de = S.lang === "DE";
  const pct = (x) => Math.round(x * 100) + "%";
  const sorted = [...ev.answeredCats].sort((a, b) => b.totalRatingInPercent - a.totalRatingInPercent);
  if (!sorted.length) return de ? "Es liegen noch keine bewerteten Fragen vor." : "No rated questions yet.";
  const strong = sorted.filter((c) => c.totalRatingInPercent >= 0.67).map((c) => c.name);
  const weak = sorted.filter((c) => c.totalRatingInPercent < 0.34).map((c) => c.name);
  const mid = sorted.filter((c) => c.totalRatingInPercent >= 0.34 && c.totalRatingInPercent < 0.67).map((c) => c.name);
  const list = (arr) => arr.join(de ? ", " : ", ");
  let s = "";
  if (de) {
    s += `Das Assessment „${mod.name}" wurde für ${S.customer || "den Mandanten"} mit ${ev.answeredCats.reduce((a, c) => a + c.answeredCount, 0)} bewerteten Fragen in ${ev.answeredCats.length} Kategorien durchgeführt. `;
    s += `Das Gesamtergebnis liegt bei ${Math.round(ev.overall)}% (${ev.totalRating} von ${ev.maxRating} Punkten).\n\n`;
    if (strong.length) s += `Stärken zeigen sich in: ${list(strong)}. Diese Bereiche sind weitgehend oder vollständig erfüllt und sollten auf dem erreichten Niveau gehalten werden.\n\n`;
    if (mid.length) s += `Teilweise erfüllt sind: ${list(mid)}. Hier bestehen Ansatzpunkte zur Verbesserung mit überschaubarem Aufwand.\n\n`;
    if (weak.length) s += `Deutlichen Handlungsbedarf gibt es in: ${list(weak)}. Diese Kategorien sollten priorisiert adressiert werden.\n\n`;
    s += `Insgesamt wurden ${ev.recommendations.length} Handlungsempfehlung(en) abgeleitet.`;
  } else {
    s += `The "${mod.name}" assessment was carried out for ${S.customer || "the customer"} with ${ev.answeredCats.reduce((a, c) => a + c.answeredCount, 0)} rated questions across ${ev.answeredCats.length} categories. `;
    s += `The overall result is ${Math.round(ev.overall)}% (${ev.totalRating} out of ${ev.maxRating} points).\n\n`;
    if (strong.length) s += `Strengths are found in: ${list(strong)}. These areas are largely or fully fulfilled and should be kept at the level reached.\n\n`;
    if (mid.length) s += `Partially fulfilled: ${list(mid)}. There is room for improvement here with moderate effort.\n\n`;
    if (weak.length) s += `Clear need for action in: ${list(weak)}. These categories should be addressed with priority.\n\n`;
    s += `In total ${ev.recommendations.length} recommendation(s) were derived.`;
  }
  return s;
}

/* --------------------------------------------------------- Utilities ----- */
const esc = (s) => String(s == null ? "" : s)
  .replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
  .replace(/"/g, "&quot;").replace(/'/g, "&#39;");
const barClass = (pct) => (pct >= 67 ? "" : pct >= 34 ? "warn" : "bad");

function progressBar(pct, cls) {
  return `<div class="progress ${cls != null ? cls : barClass(pct)}"><i style="width:${Math.max(0, Math.min(100, pct))}%"></i></div>`;
}

/* Radar-Chart (ersetzt recharts <RadarChart> des Originals) */
function radarChart(cats) {
  const n = cats.length;
  if (n < 3) return "";
  const size = 460, cx = size / 2, cy = size / 2 + 6, R = 150;
  const ang = (i) => (Math.PI * 2 * i) / n - Math.PI / 2;
  const pt = (i, r) => [cx + Math.cos(ang(i)) * R * r, cy + Math.sin(ang(i)) * R * r];
  let g = "";
  [0.25, 0.5, 0.75, 1].forEach((r) => {
    const p = cats.map((_, i) => pt(i, r).join(",")).join(" ");
    g += `<polygon points="${p}" fill="none" stroke="#e2e2e2" stroke-width="1"/>`;
  });
  cats.forEach((_, i) => {
    const [x, y] = pt(i, 1);
    g += `<line x1="${cx}" y1="${cy}" x2="${x}" y2="${y}" stroke="#e2e2e2" stroke-width="1"/>`;
  });
  const poly = cats.map((c, i) => pt(i, Math.max(0.02, c.totalRatingInPercent)).join(",")).join(" ");
  g += `<polygon points="${poly}" fill="#1C75BC" fill-opacity="0.22" stroke="#1C75BC" stroke-width="2"/>`;
  cats.forEach((c, i) => {
    const [x, y] = pt(i, Math.max(0.02, c.totalRatingInPercent));
    g += `<circle cx="${x}" cy="${y}" r="3.5" fill="#1C75BC"/>`;
  });
  cats.forEach((c, i) => {
    const [x, y] = pt(i, 1.15);
    const anchor = Math.abs(x - cx) < 12 ? "middle" : x > cx ? "start" : "end";
    const label = c.name.length > 22 ? c.name.slice(0, 21) + "…" : c.name;
    g += `<text x="${x}" y="${y}" text-anchor="${anchor}" dominant-baseline="middle" font-size="11" fill="#555" font-family="Inter,sans-serif">${esc(label)}</text>`;
  });
  // Seitenrand groß genug, damit die längsten Kategorienamen links/rechts nicht abschneiden
  const pad = 130;
  return `<svg viewBox="${-pad} 0 ${size + pad * 2} ${size + 20}" width="100%" style="max-width:700px">${g}</svg>`;
}

/* ------------------------------------------------------------ Views ------ */
function moduleCard(mod) {
  const qs = allQuestions(mod);
  const answered = qs.filter((q) => hasAnswer(q.id)).length;
  return `<div class="card">
    <img class="icon" src="${mod.icon}" alt="">
    <h3>${esc(mod.name)}</h3>
    <p>${esc(mod.introText[S.lang])}</p>
    <div class="chips">
      <span class="chip">${qs.length} ${esc(t("questions"))}</span>
      <span class="chip">${mod.categories.length} ${esc(t("categories"))}</span>
      <span class="chip">${esc(mod.version)}</span>
      ${mod.owner ? `<span class="chip">${esc(mod.owner)}</span>` : ""}
      <span class="chip">${answered}/${qs.length} ${esc(t("answered"))}</span>
    </div>
    <div style="display:flex;gap:10px">
      <button class="btn" data-act="start" data-mod="${mod.id}">${answered ? esc(t("cont")) : esc(t("start"))}</button>
      ${answered ? `<button class="btn ghost" data-act="evalmod" data-mod="${mod.id}">${esc(t("nav_eval"))}</button>` : ""}
    </div>
  </div>`;
}

function viewHome() {
  return `
  <div class="hero"><div class="wrap heroflex">
    <img class="mark" src="assets/eHealthAllianceWhite.svg" alt="eHealth Alliance">
    <div>
      <h1><span class="grad">Compass</span></h1>
      <p>${esc(t("hero_sub"))}</p>
    </div>
  </div></div>
  <div class="wrap section">
    <h2>${esc(t("modules"))}</h2>
    <p class="sub">${esc(t("modules_sub"))}</p>
    <div class="field" style="max-width:420px">
      <label for="cust">${esc(t("customer"))}</label>
      <input id="cust" data-inp="customer" value="${esc(S.customer)}" placeholder="${esc(t("customer_ph"))}">
    </div>
    <div class="cards">
      ${Object.values(MODULES).map(moduleCard).join("")}
      <div class="card">
        <img class="icon" src="assets/eHealthAllianceMark.svg" alt="">
        <h3>Digital-Health-Quiz</h3>
        <p>${S.lang === "DE"
      ? "Zehn Fragen zu KHZG, NIS2, ePA und TI — jede mit einer Auflösung, die mehr erklärt als nur die richtige Antwort. Gut als Einstieg in ein Kundengespräch."
      : "Ten questions on KHZG, NIS2, ePA and TI — each with an explanation that goes beyond the correct answer. A good opener for a client conversation."}</p>
        <div class="chips">
          <span class="chip">${COMPASS_QUIZ_SOURCE.length} ${esc(t("questions"))}</span>
          <span class="chip">KHZG</span>
          <span class="chip">NIS2</span>
          <span class="chip">ePA &amp; TI</span>
        </div>
        <div><button class="btn" data-act="goto" data-view="quiz">${esc(t("start_quiz"))}</button></div>
      </div>
    </div>
    <p class="sub" style="margin-top:26px">${esc(t("answers_saved"))}</p>
  </div>`;
}

function viewAssessment() {
  const mod = currentModule();
  const cats = mod.categories;
  const cat = cats[Math.max(0, Math.min(S.catIndex, cats.length - 1))];
  const qs = allQuestions(mod);
  const answered = qs.filter((q) => hasAnswer(q.id)).length;
  const overallPct = (answered / qs.length) * 100;

  const side = cats.map((c, i) => {
    const done = c.questions.filter((q) => hasAnswer(q.id)).length;
    const cls = done === c.questions.length ? "done" : done > 0 ? "partial" : "";
    return `<li><button class="${i === S.catIndex ? "active" : ""}" data-act="cat" data-i="${i}">
      <span class="dot ${cls}"></span><span>${esc(c.name)}</span></button></li>`;
  }).join("");

  const body = cat.questions.map((q) => {
    const a = S.answers[q.id];
    const pct = a ? computeRating(q, a) : 0;
    const reqs = Object.values(q.requirements || {}).sort((x, y) => y.weight - x.weight);
    // Auswahlfrage: genau ein Requirement mit vorgegebenen Reifegradstufen
    const isChoice = reqs.length === 1 && !!reqs[0].levels;
    const reqHtml = reqs.map((req) => {
      const ra = a?.requirementAnswers?.[req.id] || {};
      const off = !!ra.disabled;
      const f = Number(ra.fulfilled || 0);
      const showText = req.text !== q.content;
      const answeredQ = hasAnswer(q.id);

      // Auswahlfrage mit eigenen Stufenbeschriftungen (Alliance Assessment)
      if (req.levels) {
        const choices = req.levels.map((lv) => {
          const on = answeredQ && f === lv.value;
          const tone = lv.value <= 1 ? "low" : lv.value === 2 ? "mid" : "good";
          return `<button class="choice ${on ? "on " + tone : ""}" data-act="rate" data-q="${q.id}" data-r="${req.id}" data-v="${lv.value}">
            <span class="mark"></span><span class="lbl">${esc(lv.label)}</span><span class="pts">${lv.value}</span>
          </button>`;
        }).join("");
        return `<div class="req ${off ? "off" : ""}">
          <div class="choices ${off ? "off" : ""}">${choices}</div>
          <div class="rrow" style="margin-top:12px">
            <label class="notrel"><input type="checkbox" data-act="disable" data-q="${q.id}" data-r="${req.id}" ${off ? "checked" : ""}> ${esc(t("not_relevant"))}</label>
            <span class="weight">${esc(t("target"))}: ${esc(req.levels[0].label)}</span>
          </div>
        </div>`;
      }

      const btns = [0, 1, 2, 3].map((v) => {
        const on = f === v && (answeredQ || v > 0);
        const tone = v === 0 ? "low" : v === 1 ? "low" : v === 2 ? "mid" : "";
        return `<button class="${on ? "on " + tone : ""}" data-act="rate" data-q="${q.id}" data-r="${req.id}" data-v="${v}">${esc(ratingLabel(v))}</button>`;
      }).join("");
      return `<div class="req ${off ? "off" : ""}">
        ${showText ? `<div class="rtext">${esc(req.text)}</div>` : ""}
        <div class="rrow">
          <div class="rating ${off ? "off" : ""}">${btns}</div>
          <label class="notrel"><input type="checkbox" data-act="disable" data-q="${q.id}" data-r="${req.id}" ${off ? "checked" : ""}> ${esc(t("not_relevant"))}</label>
          <span class="weight">${esc(t("weight"))}: ${esc(req.weight)}</span>
        </div>
      </div>`;
    }).join("");

    return `<div class="qgrid">
      <div>
        <div class="qtext">${esc(q.content)}</div>
        <div style="margin-top:26px">
          <div class="field">
            <label>${esc(t("contact"))}</label>
            <input data-inp="role" data-q="${q.id}" value="${esc(a?.responsibleRole || "")}">
          </div>
          <div class="field">
            <label>${esc(t("comments"))}</label>
            <textarea rows="5" data-inp="text" data-q="${q.id}">${esc(a?.answerText || "")}</textarea>
          </div>
        </div>
        ${q.source ? `<div class="src">${esc(t("source"))} ${esc(q.source)}</div>` : ""}
      </div>
      <div class="reqbox">
        <div class="rhead">
          <span class="t">${esc(isChoice ? t("your_answer") : t("requirements"))}</span>
          <div style="min-width:210px">
            <div class="pctline"><span>${esc(isChoice ? t("maturity") : t("fulfilled_pct"))}</span><b>${Math.round(pct)}%</b></div>
            ${progressBar(pct)}
          </div>
        </div>
        ${reqHtml}
      </div>
    </div>`;
  }).join("");

  return `
  <div class="wrap assess">
    <aside class="sidebar">
      ${Object.keys(MODULES).length > 1 ? `
      <h4>${esc(t("modules"))}</h4>
      <div class="field" style="margin-bottom:18px">
        <select data-inp="module">
          ${Object.values(MODULES).map((m) =>
      `<option value="${m.id}" ${m.id === mod.id ? "selected" : ""}>${esc(m.name)}</option>`).join("")}
        </select>
      </div>` : ""}
      <h4>${esc(t("categories"))}</h4>
      <ul class="catlist">${side}</ul>
      <div style="margin-top:18px;padding-top:14px;border-top:1px solid var(--line)">
        <div class="pctline"><span>${esc(t("progress"))}</span><b>${answered}/${qs.length}</b></div>
        ${progressBar(overallPct, overallPct === 100 ? "" : "warn")}
      </div>
      <button class="btn ghost sm" style="margin-top:16px;width:100%" data-act="goto" data-view="evaluation">${esc(t("to_eval"))}</button>
      <button class="btn grey sm" style="margin-top:8px;width:100%" data-act="reset">${esc(t("reset"))}</button>
    </aside>
    <section>
      <div class="qhead">
        <div>
          <div class="kicker">${esc(t("category"))} ${S.catIndex + 1} / ${cats.length} · ${esc(mod.name)}</div>
          <h2>${esc(cat.name)}</h2>
        </div>
        <div class="stepper">${S.customer ? esc(S.customer) : ""}</div>
      </div>
      ${body}
      <div class="navrow">
        <button class="btn grey" data-act="prev" ${S.catIndex === 0 ? "disabled" : ""}>← ${esc(t("prev"))}</button>
        <div style="display:flex;align-items:center;gap:14px">
          <span class="saved">${esc(S.flash)}</span>
          <button class="btn ghost" data-act="save">${esc(t("save"))}</button>
        </div>
        ${S.catIndex === cats.length - 1
      ? `<button class="btn" data-act="goto" data-view="evaluation">${esc(t("to_eval"))} →</button>`
      : `<button class="btn" data-act="next">${esc(t("next"))} →</button>`}
      </div>
    </section>
  </div>`;
}

function viewEvaluation() {
  const mod = currentModule();
  const ev = evaluate(mod);
  const rows = ev.byCat.map((c) => {
    const pct = c.totalRatingInPercent * 100;
    const status = c.completelyAnswered ? t("completely") : c.answeredCount ? t("partially") : t("open");
    return `<tr>
      <td>${esc(c.name)}<div style="color:#999;font-size:12px">${esc(status)}</div></td>
      <td style="width:38%">${progressBar(pct)}</td>
      <td class="num">${Math.round(pct)}%</td>
      <td class="num" style="color:#888">${c.totalRating}/${c.maxRating}</td>
    </tr>`;
  }).join("");

  const recs = ev.recommendations.length
    ? ev.recommendations.map((r) => `<div class="rec">
        <h4>${esc(r.category)}</h4>
        <p>${esc(r.solution)}</p></div>`).join("")
    : `<div class="summary">${esc(t("no_recs"))}</div>`;

  return `
  <div class="evalhead"><div class="wrap">
    <h1>${esc(t("eval_title"))} — ${esc(mod.name)}</h1>
    <div class="scorewrap">
      <div><div class="score">${Math.round(ev.overall)}%</div></div>
      <div class="meta">
        ${esc(t("overall"))}: <b style="color:#fff">${ev.totalRating}</b> ${esc(t("score_of"))} ${ev.maxRating} ${esc(t("points"))}<br>
        ${esc(t("customer"))}: <b style="color:#fff">${esc(S.customer || "—")}</b><br>
        ${ev.answeredCats.reduce((a, c) => a + c.answeredCount, 0)} / ${allQuestions(mod).length} ${esc(t("answered"))}
      </div>
    </div>
  </div></div>
  <div class="wrap section">
    ${!ev.complete ? `<div class="note" style="margin-bottom:26px">${esc(t("incomplete"))}</div>` : ""}
    <div class="twocol">
      <div>
        <h2 style="font-size:20px;margin:0 0 16px">${esc(t("result_by_cat"))}</h2>
        <table class="cats">
          <thead><tr><th>${esc(t("category"))}</th><th></th><th class="num">%</th><th class="num">${esc(t("points"))}</th></tr></thead>
          <tbody>${rows}</tbody>
        </table>
      </div>
      <div style="text-align:center">${radarChart(ev.byCat)}</div>
    </div>
    <div style="margin-top:44px">
      <h2 style="font-size:20px;margin:0 0 16px">${esc(t("summary"))}</h2>
      <div class="summary">${esc(summaryText(mod, ev))}</div>
    </div>
    <div style="margin-top:44px">
      <h2 style="font-size:20px;margin:0 0 16px">${esc(t("recommendations"))} ${ev.recommendations.length ? `(${ev.recommendations.length})` : ""}</h2>
      ${recs}
    </div>
    <div class="navrow noprint">
      <button class="btn grey" data-act="goto" data-view="assessment">← ${esc(t("back_assessment"))}</button>
      <div style="display:flex;gap:10px">
        <button class="btn ghost" data-act="export">${esc(t("export"))}</button>
        <button class="btn" data-act="print">${esc(t("print"))}</button>
      </div>
    </div>
  </div>`;
}

function viewQuiz() {
  const total = COMPASS_QUIZ_SOURCE.length;
  const i = S.quiz.index;
  if (S.quiz.done || i >= total) {
    const correct = COMPASS_QUIZ_SOURCE.filter((q) => S.quiz.chosen[q.index] === q.correctOption).length;
    return `<div class="wrap quiz" style="text-align:center">
      <img src="assets/eHealthAllianceMark.svg" style="width:90px" alt="">
      <h1 style="font-weight:500;margin:18px 0 6px">${esc(t("quiz_result"))}</h1>
      <div style="font-size:56px;font-weight:500;color:var(--eha-blue)">${correct}/${total}</div>
      <p style="font-family:Inter,sans-serif;color:#555">${esc(t("quiz_correct"))}</p>
      <div style="margin-top:24px;display:flex;gap:10px;justify-content:center">
        <button class="btn ghost" data-act="quizreset">${esc(t("quiz_again"))}</button>
        <button class="btn" data-act="goto" data-view="home">${esc(t("nav_home"))}</button>
      </div>
    </div>`;
  }
  const q = COMPASS_QUIZ_SOURCE[i];
  const chosen = S.quiz.chosen[q.index];
  const keys = ["optionA", "optionB", "optionC", "optionD"];
  const opts = keys.map((k) => {
    let cls = "";
    if (chosen) cls = k === q.correctOption ? "correct" : k === chosen ? "wrong" : "";
    return `<button class="opt ${cls}" data-act="quizpick" data-k="${k}" ${chosen ? "disabled" : ""}>${esc(q[k])}</button>`;
  }).join("");
  return `<div class="wrap quiz">
    <div class="stepper" style="justify-content:space-between;display:flex">
      <span>${esc(t("quiz_q"))} ${i + 1} ${esc(t("quiz_of"))} ${total}</span>
      <span>Digital-Health-Quiz</span>
    </div>
    ${progressBar(((i) / total) * 100, "")}
    <h2 style="font-weight:500;font-size:26px;margin:22px 0 0">${esc(q.questionText)}</h2>
    <div class="opts">${opts}</div>
    ${chosen ? `<div class="solution"><b>${esc(t("quiz_solution"))}</b>${esc(q.solutionText)}</div>
      <div class="navrow"><span></span><button class="btn" data-act="quiznext">${i + 1 === total ? esc(t("quiz_result")) : esc(t("quiz_next"))} →</button></div>` : ""}
  </div>`;
}

/* ------------------------------------------------------------ Shell ------ */
function header() {
  const nav = [
    ["home", t("nav_home")],
    ["assessment", t("nav_assessment")],
    ["evaluation", t("nav_eval")],
    ["quiz", t("nav_quiz")],
  ].map(([v, label]) =>
    `<button class="${S.view === v ? "active" : ""}" data-act="goto" data-view="${v}">${esc(label)}</button>`
  ).join("");
  return `<header class="bar"><div class="wrap inner">
    <div class="brand" data-act="goto" data-view="home">
      <img class="logo" src="assets/eHealthAllianceMark.svg" alt="eHealth Alliance Compass">
      <span>eHealth Alliance <b>Compass</b></span>
    </div>
    <nav>${nav}
      <span class="langsw">
        <button class="${S.lang === "DE" ? "on" : ""}" data-act="lang" data-l="DE">DE</button>
        <button class="${S.lang === "EN" ? "on" : ""}" data-act="lang" data-l="EN">EN</button>
      </span>
    </nav>
  </div></header>`;
}
const footer = () => `<footer class="foot"><div class="wrap">
  eHealth Alliance Compass — lokale Instanz · Fragenkatalog und Bewertungslogik aus dem Compass-Repository ·
  ${new Date().getFullYear()} eHealth Alliance
</div></footer>`;

function render() {
  let main = "";
  if (S.view === "assessment") { S.moduleId = currentModule().id; main = viewAssessment(); }
  else if (S.view === "evaluation") { S.moduleId = currentModule().id; main = viewEvaluation(); }
  else if (S.view === "quiz") main = viewQuiz();
  else main = viewHome();
  document.getElementById("app").innerHTML = header() + main + footer();
  document.title = "eHealth Alliance Compass — " + (S.view === "home" ? "Start" : t("nav_" + (S.view === "assessment" ? "assessment" : S.view === "evaluation" ? "eval" : "quiz")));
}

/* ------------------------------------------------------------ Events ----- */
document.addEventListener("click", (e) => {
  const el = e.target.closest("[data-act]");
  if (!el) return;
  const act = el.dataset.act;
  const mod = currentModule();

  if (act === "goto") { S.view = el.dataset.view; S.flash = ""; window.scrollTo(0, 0); }
  else if (act === "start") { S.moduleId = el.dataset.mod; S.view = "assessment"; S.catIndex = 0; persist(); window.scrollTo(0, 0); }
  else if (act === "evalmod") { S.moduleId = el.dataset.mod; S.view = "evaluation"; persist(); window.scrollTo(0, 0); }
  else if (act === "switchmod") { S.moduleId = el.dataset.mod; S.catIndex = 0; S.flash = ""; persist(); window.scrollTo(0, 0); }
  else if (act === "lang") { S.lang = el.dataset.l; persist(); }
  else if (act === "cat") { S.catIndex = Number(el.dataset.i); S.flash = ""; window.scrollTo(0, 0); }
  else if (act === "prev") { S.catIndex = Math.max(0, S.catIndex - 1); S.flash = ""; window.scrollTo(0, 0); }
  else if (act === "next") { S.catIndex = Math.min(mod.categories.length - 1, S.catIndex + 1); S.flash = ""; window.scrollTo(0, 0); }
  else if (act === "rate") {
    const a = answerOf(el.dataset.q);
    const cur = a.requirementAnswers[el.dataset.r] || {};
    a.requirementAnswers[el.dataset.r] = { ...cur, fulfilled: Number(el.dataset.v), disabled: !!cur.disabled };
    persist(); S.flash = "";
  }
  else if (act === "disable") {
    const a = answerOf(el.dataset.q);
    const cur = a.requirementAnswers[el.dataset.r] || { fulfilled: 0 };
    a.requirementAnswers[el.dataset.r] = { ...cur, disabled: !cur.disabled };
    persist(); S.flash = "";
  }
  else if (act === "save") { persist(); S.flash = t("saved"); }
  else if (act === "reset") {
    if (!confirm(t("reset_confirm"))) return;
    allQuestions(mod).forEach((q) => delete S.answers[q.id]);
    persist();
  }
  else if (act === "print") { window.print(); return; }
  else if (act === "export") { exportJson(mod); return; }
  else if (act === "quizpick") { S.quiz.chosen[COMPASS_QUIZ_SOURCE[S.quiz.index].index] = el.dataset.k; persist(); }
  else if (act === "quiznext") {
    if (S.quiz.index + 1 >= COMPASS_QUIZ_SOURCE.length) S.quiz.done = true;
    else S.quiz.index++;
    persist(); window.scrollTo(0, 0);
  }
  else if (act === "quizreset") { S.quiz = { index: 0, chosen: {}, done: false }; persist(); }
  else return;
  render();
});

document.addEventListener("input", (e) => {
  const el = e.target.closest("[data-inp]");
  if (!el) return;
  const kind = el.dataset.inp;
  if (kind === "module") {
    S.moduleId = el.value; S.catIndex = 0; S.flash = "";
    persist(); render(); window.scrollTo(0, 0); return;
  }
  if (kind === "customer") S.customer = el.value;
  else if (kind === "role") answerOf(el.dataset.q).responsibleRole = el.value;
  else if (kind === "text") answerOf(el.dataset.q).answerText = el.value;
  persist();
});

document.addEventListener("keydown", (e) => {
  if (e.ctrlKey && (e.key === "s" || e.key === "S")) {
    e.preventDefault(); persist(); S.flash = t("saved"); render();
  }
});

function exportJson(mod) {
  const ev = evaluate(mod);
  const payload = {
    exportedAt: new Date().toISOString(),
    customer: S.customer, module: mod.name, language: S.lang,
    overallPercent: Math.round(ev.overall),
    totalRating: ev.totalRating, maxRating: ev.maxRating,
    dataByCategory: ev.byCat.map((c) => ({
      categoryId: c.categoryId, name: c.name,
      totalRating: c.totalRating, maxRating: c.maxRating,
      totalRatingInPercent: c.totalRatingInPercent,
      completelyAnswered: c.completelyAnswered,
      questionsData: c.rows.filter((r) => r.answered).map((r) => ({
        questionId: r.q.id, content: r.q.content, rating: r.rating,
        responsibleRole: r.a.responsibleRole || "", answerText: r.a.answerText || "",
      })),
    })),
    recommendations: ev.recommendations,
    introText: summaryText(mod, ev),
  };
  const blob = new Blob([JSON.stringify(payload, null, 2)], { type: "application/json" });
  const a = document.createElement("a");
  a.href = URL.createObjectURL(blob);
  a.download = "compass-evaluation-" + (S.customer || "export").replace(/[^\w\-]+/g, "_") + ".json";
  document.body.appendChild(a); a.click(); a.remove();
  setTimeout(() => URL.revokeObjectURL(a.href), 2000);
}

restore();
render();
