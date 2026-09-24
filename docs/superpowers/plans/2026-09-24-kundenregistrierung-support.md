# Kundenregistrierung & Supportsystem – Implementierungsplan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Endkunden können sich über ein öffentliches Formular registrieren, werden vom Admin freigeschaltet und können dann Support-Tickets anlegen, die Admins priorisieren und Partnern zuweisen.

**Architecture:** Drei Phasen — (1) Registrierungsflow mit separater `registrierungen`-Tabelle, Admin-Genehmigung per Edge Function und Magic-Link-Versand; (2) Kundenportal mit rollengesteuerter Navigation und `tickets.html` für Kunden + Partner; (3) Admin-Supportverwaltung in `support.html` mit Filter, Master-Detail, Zuweisung und E-Mail-Benachrichtigungen.

**Tech Stack:** Statisches HTML/JS · Supabase JS SDK v2 via CDN (cdn.jsdelivr.net/npm/@supabase/supabase-js@2) · Supabase Edge Functions (Deno) · Resend via `send-email` Edge Function

**Spec:** docs/superpowers/specs/2026-09-24-kundenregistrierung-support-design.md

## Global Constraints

- Supabase-Projekt: `focysklymhmcfwgxdtuk.supabase.co`
- Supabase Anon-Key (darf in HTML stehen): `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZvY3lza2x5bWhtY2Z3Z3hkdHVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc1NTY1NTUsImV4cCI6MjEwMzEzMjU1NX0.VxgHwrnFUd-_7Q3pZx0L-7xY5roBZ__rUnLc5W7lOgg`
- Resend API-Key NIEMALS in HTML oder git-getrackten Dateien — nur in Edge Functions als `Deno.env.get('RESEND_API_KEY')`
- Kein Build-Step; CDN-Skripte nur von cdn.jsdelivr.net/npm/ oder cdnjs.cloudflare.com
- RLS auf allen neuen Tabellen; Edge Functions prüfen Caller-Rolle via JWT + `user_roles`-Tabelle
- E-Mails über `send-email` Edge Function (Supabase Function, NICHT send-email.php)
- `FROM` für E-Mails: `Anfragecenter <anfragecenter@ehealth-sales.de>` (wie in bestehender send-email Function)
- CSS-Variablen: `--navy: #3C4A7C`, `--green: #6DC52D`, `--navy-dark: #2d3a63`; Fonts: Inter, Montserrat
- Patterns übernehmen: `esc()`, `showMsg()`, `setupNavRole()`, `_setHeaderUser()`, `toggleNavGroup()`
- Edge Function deploy: `npx supabase functions deploy <name> --project-ref focysklymhmcfwgxdtuk`
- SQL-Migrationen werden manuell im Supabase SQL Editor ausgeführt (kein Migrationstool)
- Admin-E-Mail für Benachrichtigungen: `marco.alexandre@healoscope.de`

---

### Task 1: SQL-Migration

**Files:**
- Create: `admin/sql/migration_registrierungen_tickets.sql`

**Interfaces:**
- Produces: Tabellen `registrierungen`, `support_tickets` mit allen Spalten und RLS-Policies

- [ ] **Step 1: Erstelle die SQL-Migrationsdatei**

```sql
-- admin/sql/migration_registrierungen_tickets.sql
-- Registrierungen von Endkunden (öffentliches Formular → Admin-Genehmigung)
CREATE TABLE IF NOT EXISTS public.registrierungen (
  id               uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  vorname          text NOT NULL,
  nachname         text NOT NULL,
  email            text NOT NULL,
  firma            text NOT NULL,
  berufsgruppe_id  uuid REFERENCES public.berufsgruppen(id) ON DELETE SET NULL,
  produkt_id       uuid REFERENCES public.products(id) ON DELETE SET NULL,
  anliegen         text,
  status           text NOT NULL DEFAULT 'ausstehend',
  -- ausstehend | genehmigt | abgelehnt
  ablehnungsgrund  text,
  erstellt_am      timestamptz DEFAULT now()
);

-- RLS: anonym darf einfügen (öffentliches Formular), nur Admins dürfen lesen/updaten
ALTER TABLE public.registrierungen ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Öffentlich: registrieren"
  ON public.registrierungen FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Admin: alle Registrierungen verwalten"
  ON public.registrierungen FOR ALL
  USING (EXISTS (
    SELECT 1 FROM public.user_roles WHERE user_id = auth.uid() AND role = 'admin'
  ));

-- Support-Tickets (von Endkunden erstellt, von Admins priorisiert und Partnern zugewiesen)
CREATE TABLE IF NOT EXISTS public.support_tickets (
  id                   uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  titel                text NOT NULL,
  beschreibung         text NOT NULL,
  kunden_id            uuid REFERENCES public.kunden(id) ON DELETE SET NULL,
  user_id              uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  produkt_id           uuid REFERENCES public.products(id) ON DELETE SET NULL,
  prioritaet           text,
  -- NULL (neu) | niedrig | mittel | hoch | kritisch
  status               text NOT NULL DEFAULT 'offen',
  -- offen | in_bearbeitung | geloest | geschlossen
  assigned_partner_id  uuid REFERENCES public.user_profiles(id) ON DELETE SET NULL,
  notiz_intern         text,
  created_at           timestamptz DEFAULT now(),
  updated_at           timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_tickets_user_id    ON public.support_tickets(user_id);
CREATE INDEX IF NOT EXISTS idx_tickets_kunden_id  ON public.support_tickets(kunden_id);
CREATE INDEX IF NOT EXISTS idx_tickets_partner_id ON public.support_tickets(assigned_partner_id);
CREATE INDEX IF NOT EXISTS idx_tickets_status     ON public.support_tickets(status);

ALTER TABLE public.support_tickets ENABLE ROW LEVEL SECURITY;

-- Endkunde sieht nur eigene Tickets
CREATE POLICY "Kunde: eigene Tickets lesen"
  ON public.support_tickets FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Endkunde kann neue Tickets anlegen
CREATE POLICY "Kunde: Ticket erstellen"
  ON public.support_tickets FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Partner sieht zugewiesene Tickets, kann sie updaten
CREATE POLICY "Partner: zugewiesene Tickets verwalten"
  ON public.support_tickets FOR ALL
  TO authenticated
  USING (
    assigned_partner_id IN (
      SELECT id FROM public.user_profiles WHERE user_id = auth.uid()
    )
    OR EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = auth.uid() AND role = 'admin')
  );

-- Admin: voller Zugriff
CREATE POLICY "Admin: alle Tickets verwalten"
  ON public.support_tickets FOR ALL
  USING (EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = auth.uid() AND role = 'admin'));
```

- [ ] **Step 2: SQL im Supabase SQL Editor ausführen**

  Öffne [https://supabase.com/dashboard/project/focysklymhmcfwgxdtuk/sql](https://supabase.com/dashboard/project/focysklymhmcfwgxdtuk/sql), füge den Inhalt der Datei ein und klicke "Run". Erwartung: `CREATE TABLE`, `CREATE INDEX`, `CREATE POLICY` jeweils ohne Fehler.

- [ ] **Step 3: Commit**

```bash
git add "admin/sql/migration_registrierungen_tickets.sql"
git commit -m "feat: SQL-Migration registrierungen + support_tickets mit RLS

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

### Task 2: Öffentliche Registrierungsseite

**Files:**
- Create: `ehealth Alliance/registrieren.html`

**Interfaces:**
- Consumes: `berufsgruppen` Tabelle (SELECT `id`, `name` WHERE `aktiv = true`) — anon RLS erlaubt SELECT
- Consumes: `products` Tabelle (SELECT `id`, `produkt` WHERE `published = true`) — anon RLS erlaubt SELECT
- Consumes: `registrierungen` Tabelle INSERT (Task 1)
- Consumes: `send-email` Edge Function — POST `{ to, subject, html }` — URL: `https://focysklymhmcfwgxdtuk.supabase.co/functions/v1/send-email`
- Produces: Öffentliche Registrierungsseite für Endkunden

**Hinweis:** Die `send-email` Edge Function hat CORS-Origin `https://ehealth-sales.de`. Da alle Alliance-Seiten ebenfalls unter `ehealth-sales.de` gehostet sind, ist das kein Problem. Bei lokalem Test über file:// schlägt der CORS-Check fehl — nur auf dem Produktivserver testen.

- [ ] **Step 1: Erstelle `ehealth Alliance/registrieren.html`**

```html
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Registrierung – eHealth Alliance</title>
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<style>
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
  :root {
    --navy: #3C4A7C; --navy-dark: #2d3a63; --green: #6DC52D;
    --gray-50: #f8fafc; --gray-100: #f1f5f9; --gray-200: #e2e8f0;
    --gray-400: #94a3b8; --gray-500: #64748b; --gray-900: #0f172a;
  }
  body { font-family: 'Inter','Helvetica Neue',sans-serif; background: var(--gray-50); color: var(--gray-900); min-height: 100vh; display: flex; align-items: flex-start; justify-content: center; padding: 48px 16px; }
  .card { background: white; border-radius: 16px; border: 1px solid var(--gray-200); box-shadow: 0 2px 16px rgba(0,0,0,0.07); padding: 40px; width: 100%; max-width: 520px; }
  .card-logo { display: flex; align-items: center; gap: 12px; margin-bottom: 28px; }
  .card-logo img { height: 36px; }
  .card-logo h1 { font-family: Montserrat,sans-serif; font-size: 1.2rem; font-weight: 800; color: var(--navy); }
  h2 { font-family: Montserrat,sans-serif; font-size: 1.3rem; font-weight: 800; color: var(--navy); margin-bottom: 6px; }
  .sub { font-size: 0.85rem; color: var(--gray-500); margin-bottom: 28px; }
  .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
  .form-group { margin-bottom: 16px; }
  .form-group label { display: block; font-size: 0.78rem; font-weight: 700; color: var(--gray-500); margin-bottom: 6px; text-transform: uppercase; letter-spacing: 0.05em; }
  .form-group input, .form-group select, .form-group textarea {
    width: 100%; padding: 10px 14px; border: 1.5px solid var(--gray-200); border-radius: 9px;
    font-size: 0.88rem; font-family: inherit; color: var(--gray-900); background: white;
    outline: none; transition: border-color 0.15s;
  }
  .form-group input:focus, .form-group select:focus, .form-group textarea:focus { border-color: var(--navy); }
  .form-group textarea { resize: vertical; min-height: 90px; }
  .char-counter { font-size: 0.72rem; color: var(--gray-400); text-align: right; margin-top: 4px; }
  .char-counter.over { color: #ef4444; }
  .btn-submit {
    width: 100%; padding: 13px; background: var(--navy); color: white; border: none;
    border-radius: 10px; font-size: 0.95rem; font-weight: 700; cursor: pointer;
    font-family: inherit; transition: background 0.15s; margin-top: 8px;
  }
  .btn-submit:hover { background: var(--navy-dark); }
  .btn-submit:disabled { opacity: 0.6; cursor: default; }
  .msg { border-radius: 9px; padding: 12px 16px; font-size: 0.85rem; margin-bottom: 16px; display: none; }
  .msg.success { display: block; background: #d1fae5; color: #065f46; }
  .msg.error   { display: block; background: #fee2e2; color: #991b1b; }
  .success-box { display: none; text-align: center; padding: 24px 0; }
  .success-box .icon { font-size: 2.5rem; margin-bottom: 16px; }
  .success-box h3 { font-family: Montserrat,sans-serif; font-size: 1.2rem; font-weight: 800; color: var(--navy); margin-bottom: 8px; }
  .success-box p { font-size: 0.88rem; color: var(--gray-500); line-height: 1.6; }
  @media (max-width: 500px) { .form-row { grid-template-columns: 1fr; } .card { padding: 28px 20px; } }
</style>
</head>
<body>
<div class="card">
  <div class="card-logo">
    <img src="../ehs-logo.jpg" alt="eHealth Alliance" onerror="this.style.display='none'">
    <h1>eHealth Alliance</h1>
  </div>

  <div id="form-container">
    <h2>Jetzt registrieren</h2>
    <p class="sub">Fordern Sie Ihren Zugang zum eHealth Sales Kundenportal an. Wir schalten Sie nach Prüfung frei.</p>
    <div class="msg" id="msg"></div>

    <div class="form-row">
      <div class="form-group">
        <label>Vorname *</label>
        <input type="text" id="f-vorname" placeholder="Max" maxlength="100">
      </div>
      <div class="form-group">
        <label>Nachname *</label>
        <input type="text" id="f-nachname" placeholder="Mustermann" maxlength="100">
      </div>
    </div>
    <div class="form-group">
      <label>E-Mail-Adresse *</label>
      <input type="email" id="f-email" placeholder="max.mustermann@praxis.de" maxlength="200">
    </div>
    <div class="form-group">
      <label>Firma / Praxis *</label>
      <input type="text" id="f-firma" placeholder="Praxis Dr. Mustermann" maxlength="200">
    </div>
    <div class="form-group">
      <label>Berufsgruppe *</label>
      <select id="f-berufsgruppe">
        <option value="">Bitte wählen…</option>
      </select>
    </div>
    <div class="form-group">
      <label>Interesse an Produkt *</label>
      <select id="f-produkt">
        <option value="">Bitte wählen…</option>
      </select>
    </div>
    <div class="form-group">
      <label>Ihr Anliegen *</label>
      <textarea id="f-anliegen" placeholder="Beschreiben Sie kurz, wie wir Ihnen helfen können…" maxlength="500" oninput="updateCounter()"></textarea>
      <div class="char-counter" id="char-counter">0 / 500</div>
    </div>
    <button class="btn-submit" id="btn-submit" onclick="submit()">Registrierung absenden</button>
  </div>

  <div class="success-box" id="success-box">
    <div class="icon">✅</div>
    <h3>Vielen Dank!</h3>
    <p>Ihre Registrierungsanfrage ist bei uns eingegangen.<br>Sie erhalten eine E-Mail, sobald Ihr Zugang freigeschaltet wurde.</p>
  </div>
</div>

<script>
  const SUPABASE_URL  = 'https://focysklymhmcfwgxdtuk.supabase.co';
  const SUPABASE_ANON = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZvY3lza2x5bWhtY2Z3Z3hkdHVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc1NTY1NTUsImV4cCI6MjEwMzEzMjU1NX0.VxgHwrnFUd-_7Q3pZx0L-7xY5roBZ__rUnLc5W7lOgg';
  const sb = supabase.createClient(SUPABASE_URL, SUPABASE_ANON);

  async function init() {
    const [bgRes, prodRes] = await Promise.all([
      sb.from('berufsgruppen').select('id, name').eq('aktiv', true).order('name'),
      sb.from('products').select('id, produkt').eq('published', true).order('produkt'),
    ]);
    const bgSel = document.getElementById('f-berufsgruppe');
    (bgRes.data || []).forEach(b => {
      const o = document.createElement('option');
      o.value = b.id; o.textContent = b.name;
      bgSel.appendChild(o);
    });
    const prodSel = document.getElementById('f-produkt');
    (prodRes.data || []).forEach(p => {
      const o = document.createElement('option');
      o.value = p.id; o.textContent = p.produkt;
      prodSel.appendChild(o);
    });
  }

  function updateCounter() {
    const v = document.getElementById('f-anliegen').value.length;
    const el = document.getElementById('char-counter');
    el.textContent = v + ' / 500';
    el.className = 'char-counter' + (v > 500 ? ' over' : '');
  }

  function showMsg(text, type) {
    const el = document.getElementById('msg');
    el.textContent = text;
    el.className = 'msg ' + type;
  }

  async function sendEmail(to, subject, html) {
    await fetch(SUPABASE_URL + '/functions/v1/send-email', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ to, subject, html }),
    });
  }

  async function submit() {
    const vorname   = document.getElementById('f-vorname').value.trim();
    const nachname  = document.getElementById('f-nachname').value.trim();
    const email     = document.getElementById('f-email').value.trim();
    const firma     = document.getElementById('f-firma').value.trim();
    const bgId      = document.getElementById('f-berufsgruppe').value;
    const prodId    = document.getElementById('f-produkt').value;
    const anliegen  = document.getElementById('f-anliegen').value.trim();

    if (!vorname || !nachname || !email || !firma || !bgId || !prodId || !anliegen) {
      showMsg('Bitte füllen Sie alle Pflichtfelder aus.', 'error'); return;
    }
    if (anliegen.length > 500) {
      showMsg('Das Anliegen darf maximal 500 Zeichen enthalten.', 'error'); return;
    }

    const btn = document.getElementById('btn-submit');
    btn.disabled = true; btn.textContent = 'Wird gesendet…';

    // Uniqueness-Check
    const { data: existing } = await sb.from('registrierungen')
      .select('id').eq('email', email).eq('status', 'ausstehend').maybeSingle();
    if (existing) {
      showMsg('Für diese E-Mail-Adresse liegt bereits eine ausstehende Anfrage vor.', 'error');
      btn.disabled = false; btn.textContent = 'Registrierung absenden'; return;
    }

    const { error } = await sb.from('registrierungen').insert({
      vorname, nachname, email, firma,
      berufsgruppe_id: bgId || null,
      produkt_id: prodId || null,
      anliegen,
    });
    if (error) {
      showMsg('Fehler beim Speichern: ' + error.message, 'error');
      btn.disabled = false; btn.textContent = 'Registrierung absenden'; return;
    }

    // E-Mail an Endkunden
    await sendEmail(email,
      'Ihre Registrierungsanfrage bei eHealth Sales',
      `<p>Sehr geehrte/r ${vorname} ${nachname},</p>
       <p>vielen Dank für Ihre Registrierungsanfrage beim eHealth Sales Kundenportal. Wir haben Ihre Anfrage erhalten und werden diese in Kürze prüfen.</p>
       <p>Sie erhalten eine weitere E-Mail, sobald Ihr Zugang freigeschaltet wurde.</p>
       <p>Mit freundlichen Grüßen<br>Ihr eHealth Sales Team</p>`
    );

    // E-Mail an Admin
    await sendEmail('marco.alexandre@healoscope.de',
      `Neue Registrierungsanfrage: ${vorname} ${nachname}`,
      `<p>Eine neue Registrierungsanfrage ist eingegangen:</p>
       <ul>
         <li><strong>Name:</strong> ${vorname} ${nachname}</li>
         <li><strong>E-Mail:</strong> ${email}</li>
         <li><strong>Firma:</strong> ${firma}</li>
         <li><strong>Anliegen:</strong> ${anliegen}</li>
       </ul>
       <p><a href="https://ehealth-sales.de/admin/anfragen.html">Im Anfragecenter öffnen</a></p>`
    );

    document.getElementById('form-container').style.display = 'none';
    document.getElementById('success-box').style.display = 'block';
  }

  init();
</script>
</body>
</html>
```

- [ ] **Step 2: Manuelle Verifikation**

  Öffne die Seite im Browser. Lade die Dropdowns (Berufsgruppe, Produkt) — beide müssen Einträge zeigen. Fülle das Formular aus und sende es ab. Erwartung: Erfolgsmeldung erscheint, Eintrag in `registrierungen`-Tabelle mit `status = 'ausstehend'`.

- [ ] **Step 3: Commit**

```bash
git add "ehealth Alliance/registrieren.html"
git commit -m "feat: öffentliche Registrierungsseite für Endkunden

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

### Task 3: Edge Function admin-approve-registration

**Files:**
- Create: `supabase/functions/admin-approve-registration/index.ts`

**Interfaces:**
- Consumes: `registrierungen` (SELECT by id, UPDATE status)
- Consumes: `adminClient.auth.admin.createUser()` — erstellt Auth-Account
- Consumes: `user_profiles` INSERT, `user_roles` INSERT, `kunden` INSERT
- Consumes: `adminClient.auth.admin.generateLink({ type: 'magiclink', email })` — liefert `{ data: { properties: { action_link } } }`
- Produces: `{ success: true, kundenId, userId }` oder `{ error: string }`

- [ ] **Step 1: Erstelle `supabase/functions/admin-approve-registration/index.ts`**

```typescript
// Deploy: npx supabase functions deploy admin-approve-registration --project-ref focysklymhmcfwgxdtuk

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const json = (data: unknown, status = 200) =>
  new Response(JSON.stringify(data), { status, headers: { ...cors, 'Content-Type': 'application/json' } });

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response(null, { status: 204, headers: cors });
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405);

  const authHeader = req.headers.get('Authorization');
  if (!authHeader) return json({ error: 'Unauthorized' }, 401);

  const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
  const ANON_KEY     = Deno.env.get('SUPABASE_ANON_KEY')!;
  const SERVICE_KEY  = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
  const RESEND_KEY   = Deno.env.get('RESEND_API_KEY') ?? '';
  const FROM         = 'Anfragecenter <anfragecenter@ehealth-sales.de>';

  // Caller-Check: nur Admins
  const callerClient = createClient(SUPABASE_URL, ANON_KEY, {
    global: { headers: { Authorization: authHeader } },
  });
  const { data: { user }, error: userErr } = await callerClient.auth.getUser();
  if (userErr || !user) return json({ error: 'Unauthorized' }, 401);
  const { data: roleRow } = await callerClient.from('user_roles').select('role').eq('user_id', user.id).maybeSingle();
  if (roleRow?.role !== 'admin') return json({ error: 'Forbidden' }, 403);

  const body = await req.json().catch(() => ({})) as { registrierungId?: string };
  const { registrierungId } = body;
  if (!registrierungId) return json({ error: 'registrierungId erforderlich' }, 400);

  const adminClient = createClient(SUPABASE_URL, SERVICE_KEY);

  // Registrierung laden
  const { data: reg, error: regErr } = await adminClient
    .from('registrierungen')
    .select('id, vorname, nachname, email, firma, berufsgruppe_id, produkt_id, status')
    .eq('id', registrierungId)
    .maybeSingle();
  if (regErr || !reg) return json({ error: 'Registrierung nicht gefunden' }, 404);
  if (reg.status !== 'ausstehend') return json({ error: 'Registrierung hat nicht den Status "ausstehend"' }, 409);

  // Auth-Account anlegen
  const { data: newUser, error: createErr } = await adminClient.auth.admin.createUser({
    email: reg.email,
    email_confirm: true,
  });
  if (createErr) return json({ error: 'Auth-User-Anlage fehlgeschlagen: ' + createErr.message }, 400);
  const userId = newUser.user.id;

  // user_profiles anlegen
  const { error: profileErr } = await adminClient.from('user_profiles').insert({
    user_id: userId,
    email: reg.email,
    vorname: reg.vorname,
    nachname: reg.nachname,
    firma: reg.firma,
    rolle: 'kunde',
    password_set: false,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  });
  if (profileErr) return json({ error: 'user_profiles INSERT fehlgeschlagen: ' + profileErr.message }, 400);

  // user_roles anlegen
  await adminClient.from('user_roles').insert({ user_id: userId, role: 'kunde' });

  // kunden anlegen
  const { data: kunde, error: kundenErr } = await adminClient.from('kunden').insert({
    name: reg.vorname + ' ' + reg.nachname,
    firma: reg.firma,
    email: reg.email,
  }).select('id').maybeSingle();
  if (kundenErr) return json({ error: 'kunden INSERT fehlgeschlagen: ' + kundenErr.message }, 400);
  const kundenId = kunde?.id;

  // Magic-Link generieren
  const { data: linkData, error: linkErr } = await adminClient.auth.admin.generateLink({
    type: 'magiclink',
    email: reg.email,
  });
  const magicLink = linkData?.properties?.action_link ?? '';

  // Genehmigungs-E-Mail senden
  await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${RESEND_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      from: FROM,
      to: [reg.email],
      subject: 'Ihr Zugang zum eHealth Sales Kundenportal wurde freigeschaltet',
      html: `<p>Sehr geehrte/r ${reg.vorname} ${reg.nachname},</p>
             <p>Ihr Zugang zum eHealth Sales Kundenportal wurde freigeschaltet.</p>
             <p>Klicken Sie auf den folgenden Link, um sich einzuloggen und Ihr Passwort zu setzen:</p>
             <p><a href="${magicLink}" style="background:#3C4A7C;color:white;padding:12px 24px;border-radius:8px;text-decoration:none;font-weight:bold;display:inline-block;">Jetzt einloggen</a></p>
             <p>Der Link ist 24 Stunden gültig.</p>
             <p>Mit freundlichen Grüßen<br>Ihr eHealth Sales Team</p>`,
    }),
  });

  // Registrierung auf genehmigt setzen
  await adminClient.from('registrierungen').update({ status: 'genehmigt' }).eq('id', registrierungId);

  return json({ success: true, kundenId, userId });
});
```

- [ ] **Step 2: Edge Function deployen**

```bash
npx supabase functions deploy admin-approve-registration --project-ref focysklymhmcfwgxdtuk
```

  Erwartung: `Deployed Function admin-approve-registration` ohne Fehler.

- [ ] **Step 3: Commit**

```bash
git add supabase/functions/admin-approve-registration/
git commit -m "feat: Edge Function admin-approve-registration

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

### Task 4: Anfragecenter – Tab Registrierungen

**Files:**
- Modify: `admin/anfragen.html`

**Interfaces:**
- Consumes: `registrierungen` SELECT (Task 1)
- Consumes: `admin-approve-registration` Edge Function (Task 3) — `POST { registrierungId }`
- Consumes: `send-email` Edge Function für Ablehnungs-E-Mail
- Produces: Zweiter Tab "Registrierungen" mit Genehmigungs- und Ablehnungs-Flow

Lies `admin/anfragen.html` komplett bevor du editierst. Die folgenden Änderungen sind vorzunehmen:

- [ ] **Step 1: CSS für Tabs und Registrierungskarten ergänzen**

  Füge **vor** dem schließenden `</style>` in anfragen.html ein:

```css
  /* Tab-Navigation */
  .tabs { display: flex; gap: 4px; margin-bottom: 24px; border-bottom: 2px solid var(--gray-200); }
  .tab-btn {
    padding: 9px 18px; font-size: 0.85rem; font-weight: 600; cursor: pointer;
    border: none; background: none; color: var(--gray-500); border-bottom: 2px solid transparent;
    margin-bottom: -2px; font-family: inherit; transition: all 0.15s;
  }
  .tab-btn:hover { color: var(--navy); }
  .tab-btn.active { color: var(--navy); border-bottom-color: var(--navy); }
  .tab-badge {
    display: inline-block; background: var(--green); color: white;
    border-radius: 10px; font-size: 0.68rem; font-weight: 800;
    padding: 1px 7px; margin-left: 6px; vertical-align: middle;
  }
  .tab-panel { display: none; }
  .tab-panel.active { display: block; }

  /* Registrierungs-Karten */
  .reg-card {
    background: white; border-radius: 14px; border: 1.5px solid var(--gray-200);
    box-shadow: 0 1px 6px rgba(0,0,0,0.04); padding: 20px 22px; margin-bottom: 14px;
  }
  .reg-card.done { opacity: 0.6; }
  .reg-card-head { display: flex; align-items: flex-start; justify-content: space-between; gap: 16px; flex-wrap: wrap; margin-bottom: 12px; }
  .reg-name { font-weight: 700; font-size: 1rem; color: var(--navy); }
  .reg-meta { font-size: 0.8rem; color: var(--gray-500); margin-top: 3px; }
  .reg-body { font-size: 0.83rem; color: var(--gray-700); line-height: 1.6; margin-bottom: 14px; }
  .reg-actions { display: flex; gap: 8px; }

  /* Ablehnen-Modal */
  .overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.4); z-index: 200; align-items: center; justify-content: center; }
  .overlay.open { display: flex; }
  .modal { background: white; border-radius: 16px; padding: 28px; width: 100%; max-width: 440px; box-shadow: 0 8px 40px rgba(0,0,0,0.18); }
  .modal h3 { font-family: Montserrat,sans-serif; font-size: 1rem; font-weight: 800; color: var(--navy); margin-bottom: 14px; }
  .modal textarea { width: 100%; padding: 10px 12px; border: 1.5px solid var(--gray-200); border-radius: 9px; font-size: 0.85rem; font-family: inherit; resize: vertical; min-height: 80px; outline: none; }
  .modal textarea:focus { border-color: var(--navy); }
  .modal-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 14px; }
```

- [ ] **Step 2: Tab-HTML und Registrierungen-Container ergänzen**

  Ersetze im `<main>`-Bereich von anfragen.html den Block:
  ```html
    <div class="spinner" id="spinner">Anfragen werden geladen…</div>
    <div class="anfragen-list" id="anfragen-list"></div>
  ```
  durch:
  ```html
    <div class="tabs">
      <button class="tab-btn active" id="tab-anfragen" onclick="switchTab('anfragen')">Anfragen</button>
      <button class="tab-btn" id="tab-registrierungen" onclick="switchTab('registrierungen')" id="nav-group-admin-only" style="display:none">
        Registrierungen <span class="tab-badge" id="reg-badge" style="display:none">0</span>
      </button>
    </div>

    <div class="tab-panel active" id="panel-anfragen">
      <div class="spinner" id="spinner">Anfragen werden geladen…</div>
      <div class="anfragen-list" id="anfragen-list"></div>
    </div>

    <div class="tab-panel" id="panel-registrierungen">
      <div id="reg-spinner" style="color:var(--gray-400);font-size:0.85rem;padding:20px 0;">Wird geladen…</div>
      <div id="reg-list"></div>
    </div>

    <!-- Ablehnen-Modal -->
    <div class="overlay" id="ablehnen-overlay">
      <div class="modal">
        <h3>Registrierung ablehnen</h3>
        <p style="font-size:0.83rem;color:var(--gray-500);margin-bottom:12px;">Optional: Begründung für den Antragsteller</p>
        <textarea id="ablehnen-grund" placeholder="Ablehnungsgrund (optional)…"></textarea>
        <div class="modal-actions">
          <button class="btn btn-edit btn-sm" onclick="closeAblehnenModal()">Abbrechen</button>
          <button class="btn btn-danger btn-sm" onclick="confirmAblehnen()">Ablehnen bestätigen</button>
        </div>
      </div>
    </div>
  ```

- [ ] **Step 3: Tab-Logik, Registrierungen laden und Aktionen in JavaScript ergänzen**

  Suche im Script-Block die Zeile wo `userRole` gesetzt wird (z. B. `userRole = roleRow?.role`). Direkt danach, wo Admin-spezifische Sachen initialisiert werden, füge ein:

  ```js
  if (userRole === 'admin') {
    document.getElementById('tab-registrierungen').style.display = '';
    loadRegistrierungen();
  }
  ```

  Dann füge am Ende des Script-Blocks (vor `</script>`) folgende Funktionen ein:

```js
  function switchTab(tab) {
    document.getElementById('panel-anfragen').classList.toggle('active', tab === 'anfragen');
    document.getElementById('panel-registrierungen').classList.toggle('active', tab === 'registrierungen');
    document.getElementById('tab-anfragen').classList.toggle('active', tab === 'anfragen');
    document.getElementById('tab-registrierungen').classList.toggle('active', tab === 'registrierungen');
  }

  let allRegs = [];
  async function loadRegistrierungen() {
    const spinner = document.getElementById('reg-spinner');
    const { data, error } = await sb.from('registrierungen')
      .select('id, vorname, nachname, email, firma, anliegen, status, erstellt_am, berufsgruppen(name), products(produkt)')
      .order('erstellt_am', { ascending: false });
    spinner.style.display = 'none';
    if (error) { document.getElementById('reg-list').innerHTML = '<p style="color:#ef4444">Fehler: ' + esc(error.message) + '</p>'; return; }
    allRegs = data || [];
    const pending = allRegs.filter(r => r.status === 'ausstehend').length;
    const badge = document.getElementById('reg-badge');
    if (pending > 0) { badge.textContent = pending; badge.style.display = ''; }
    renderRegistrierungen();
  }

  function renderRegistrierungen() {
    const container = document.getElementById('reg-list');
    if (!allRegs.length) { container.innerHTML = '<p style="color:var(--gray-400);font-size:0.85rem;padding:20px 0;">Keine Registrierungsanfragen vorhanden.</p>'; return; }
    container.innerHTML = allRegs.map(r => {
      const isPending = r.status === 'ausstehend';
      const statusBadge = isPending
        ? '<span class="status-pill" style="background:#fef3c7;color:#92400e">⏳ Ausstehend</span>'
        : r.status === 'genehmigt'
          ? '<span class="status-pill status-aktiv">✓ Genehmigt</span>'
          : '<span class="status-pill status-inaktiv">✗ Abgelehnt</span>';
      return `<div class="reg-card ${isPending ? '' : 'done'}">
        <div class="reg-card-head">
          <div>
            <div class="reg-name">${esc(r.vorname)} ${esc(r.nachname)}</div>
            <div class="reg-meta">${esc(r.email)} · ${esc(r.firma)} · ${fmtDate(r.erstellt_am)}</div>
          </div>
          ${statusBadge}
        </div>
        <div class="reg-body">
          <strong>Berufsgruppe:</strong> ${esc(r.berufsgruppen?.name || '–')}<br>
          <strong>Produkt:</strong> ${esc(r.products?.produkt || '–')}<br>
          <strong>Anliegen:</strong> ${esc(r.anliegen || '–')}
        </div>
        ${isPending ? `<div class="reg-actions">
          <button class="btn btn-primary btn-sm" onclick="approveReg('${r.id}', this)">✓ Genehmigen</button>
          <button class="btn btn-danger btn-sm" onclick="openAblehnenModal('${r.id}', '${esc(r.vorname)}', '${esc(r.nachname)}', '${esc(r.email)}')">✗ Ablehnen</button>
        </div>` : ''}
      </div>`;
    }).join('');
  }

  async function approveReg(regId, btn) {
    btn.disabled = true; btn.textContent = 'Wird genehmigt…';
    const { data: { session } } = await sb.auth.getSession();
    const res = await fetch(SUPABASE_URL + '/functions/v1/admin-approve-registration', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + session.access_token },
      body: JSON.stringify({ registrierungId: regId }),
    });
    const result = await res.json();
    if (!res.ok || result.error) {
      alert('Fehler: ' + (result.error || 'Unbekannter Fehler'));
      btn.disabled = false; btn.textContent = '✓ Genehmigen'; return;
    }
    showMsg('Registrierung genehmigt. Einladungs-E-Mail wurde versendet.', 'success');
    loadRegistrierungen();
  }

  let ablehnenRegId = '', ablehnenVorname = '', ablehnenNachname = '', ablehnenEmail = '';
  function openAblehnenModal(regId, vorname, nachname, email) {
    ablehnenRegId = regId; ablehnenVorname = vorname; ablehnenNachname = nachname; ablehnenEmail = email;
    document.getElementById('ablehnen-grund').value = '';
    document.getElementById('ablehnen-overlay').classList.add('open');
  }
  function closeAblehnenModal() { document.getElementById('ablehnen-overlay').classList.remove('open'); }

  async function confirmAblehnen() {
    const grund = document.getElementById('ablehnen-grund').value.trim();
    await sb.from('registrierungen').update({ status: 'abgelehnt', ablehnungsgrund: grund || null }).eq('id', ablehnenRegId);

    // E-Mail an Endkunden
    const { data: { session } } = await sb.auth.getSession();
    await fetch(SUPABASE_URL + '/functions/v1/send-email', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + session.access_token },
      body: JSON.stringify({
        to: ablehnenEmail,
        subject: 'Ihre Registrierungsanfrage bei eHealth Sales',
        html: `<p>Sehr geehrte/r ${ablehnenVorname} ${ablehnenNachname},</p>
               <p>leider konnten wir Ihre Registrierungsanfrage zum eHealth Sales Kundenportal nicht genehmigen.</p>
               ${grund ? `<p><strong>Begründung:</strong> ${grund}</p>` : ''}
               <p>Bei Fragen stehen wir Ihnen gerne zur Verfügung.</p>
               <p>Mit freundlichen Grüßen<br>Ihr eHealth Sales Team</p>`,
      }),
    });

    closeAblehnenModal();
    showMsg('Registrierung abgelehnt.', 'success');
    loadRegistrierungen();
  }
```

  **Hinweis:** `showMsg()` und `fmtDate()` müssen bereits im Script vorhanden sein. Falls `showMsg` fehlt, füge hinzu:
  ```js
  function showMsg(text, type) {
    // Suche ob bereits eine .msg-Box existiert, sonst erzeuge eine temporäre
    const existing = document.querySelector('.msg');
    if (existing) { existing.textContent = text; existing.className = 'msg ' + type; setTimeout(() => { existing.className = 'msg'; }, 4000); }
    else { console.log('[' + type + '] ' + text); }
  }
  ```

- [ ] **Step 4: Manuell testen**

  Als Admin angemeldet: `admin/anfragen.html` aufrufen. Tab "Registrierungen" muss erscheinen. Eine Testregistrierung über die öffentliche Seite anlegen (Task 2), dann im Tab sehen und Genehmigungs-Button klicken. Erwartung: E-Mail mit Magic Link an Endkunden.

- [ ] **Step 5: Commit**

```bash
git add admin/anfragen.html
git commit -m "feat: Anfragecenter – Tab Registrierungen mit Genehmigungs- und Ablehnungs-Flow

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

### Task 5: admin/tickets.html

**Files:**
- Create: `admin/tickets.html`

**Interfaces:**
- Consumes: `support_tickets` SELECT/INSERT/UPDATE (Task 1)
- Consumes: `products` SELECT (für Ticket-Erstellung)
- Consumes: `send-email` Edge Function — Bestätigungs-E-Mail an Kunden bei neuem Ticket
- Produces: Rollenabhängige Seite: Kunde (eigene Tickets + Ticket erstellen) | Partner (zugewiesene Tickets + Status/Priorität/Notiz) | Admin (Redirect zu support.html)

- [ ] **Step 1: Erstelle `admin/tickets.html`**

  Kopiere die Struktur von `admin/anfragen.html` (Topbar, Sidebar, CSS-Variablen, `_setHeaderUser`, `setupNavRole`, `esc`, `toggleNavGroup`). Passe `<title>` auf `eHS Portal – Support-Tickets` und die `.active`-Klasse im Nav auf `tickets.html` an. Dann ersetze den gesamten `<main>`-Bereich und den Script-Block durch folgenden Inhalt:

  ```html
  <main class="main">
    <div class="page-header">
      <div>
        <h1 id="page-title">Support-Tickets</h1>
        <p class="page-sub" id="page-sub">–</p>
      </div>
      <button class="btn btn-primary" id="btn-new-ticket" style="display:none" onclick="openNewTicketModal()">+ Neues Ticket</button>
    </div>

    <div class="msg" id="msg"></div>

    <!-- Kunden-Ansicht: eigene Tickets -->
    <div id="view-kunde" style="display:none">
      <div id="ticket-list-kunde"></div>
    </div>

    <!-- Partner-Ansicht: zugewiesene Tickets -->
    <div id="view-partner" style="display:none">
      <div class="filter-bar">
        <input type="text" id="filter-search-partner" placeholder="Titel oder Kunde suchen…" oninput="filterPartnerTickets()">
        <select id="filter-status-partner" onchange="filterPartnerTickets()">
          <option value="">Alle Status</option>
          <option value="offen">Offen</option>
          <option value="in_bearbeitung">In Bearbeitung</option>
          <option value="geloest">Gelöst</option>
        </select>
      </div>
      <div id="ticket-list-partner"></div>
    </div>

    <div id="view-spinner" style="color:var(--gray-400);font-size:0.85rem;padding:40px 0 0;">Wird geladen…</div>

    <!-- Neues-Ticket-Modal (Kunden) -->
    <div class="overlay" id="new-ticket-overlay">
      <div class="modal" style="max-width:500px">
        <h3>Neues Support-Ticket</h3>
        <div class="form-group" style="margin-top:14px">
          <label style="font-size:0.78rem;font-weight:700;color:var(--gray-500);text-transform:uppercase;letter-spacing:.05em;display:block;margin-bottom:6px">Titel *</label>
          <input type="text" id="nt-titel" placeholder="Kurze Beschreibung des Problems" maxlength="200" style="width:100%;padding:10px 12px;border:1.5px solid var(--gray-200);border-radius:9px;font-size:0.88rem;font-family:inherit;outline:none">
        </div>
        <div class="form-group" style="margin-top:12px">
          <label style="font-size:0.78rem;font-weight:700;color:var(--gray-500);text-transform:uppercase;letter-spacing:.05em;display:block;margin-bottom:6px">Beschreibung *</label>
          <textarea id="nt-beschreibung" placeholder="Beschreiben Sie Ihr Anliegen ausführlich…" style="width:100%;padding:10px 12px;border:1.5px solid var(--gray-200);border-radius:9px;font-size:0.85rem;font-family:inherit;min-height:100px;resize:vertical;outline:none"></textarea>
        </div>
        <div class="form-group" style="margin-top:12px">
          <label style="font-size:0.78rem;font-weight:700;color:var(--gray-500);text-transform:uppercase;letter-spacing:.05em;display:block;margin-bottom:6px">Produkt</label>
          <select id="nt-produkt" style="width:100%;padding:10px 12px;border:1.5px solid var(--gray-200);border-radius:9px;font-size:0.85rem;font-family:inherit;outline:none">
            <option value="">Kein Produkt gewählt</option>
          </select>
        </div>
        <div class="modal-actions" style="display:flex;justify-content:flex-end;gap:10px;margin-top:16px">
          <button class="btn btn-edit btn-sm" onclick="closeNewTicketModal()">Abbrechen</button>
          <button class="btn btn-primary btn-sm" onclick="submitNewTicket()">Ticket einreichen</button>
        </div>
      </div>
    </div>

    <!-- Partner Detail-Modal -->
    <div class="overlay" id="partner-ticket-overlay">
      <div class="modal" style="max-width:560px">
        <h3 id="pt-titel-label">Ticket</h3>
        <p id="pt-beschreibung-label" style="font-size:0.85rem;color:var(--gray-500);margin:10px 0 16px;line-height:1.6"></p>
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:14px">
          <div>
            <label style="font-size:0.75rem;font-weight:700;color:var(--gray-400);text-transform:uppercase;display:block;margin-bottom:4px">Status</label>
            <select id="pt-status" style="width:100%;padding:8px 10px;border:1.5px solid var(--gray-200);border-radius:8px;font-size:0.85rem;font-family:inherit;outline:none">
              <option value="offen">Offen</option>
              <option value="in_bearbeitung">In Bearbeitung</option>
              <option value="geloest">Gelöst</option>
            </select>
          </div>
          <div>
            <label style="font-size:0.75rem;font-weight:700;color:var(--gray-400);text-transform:uppercase;display:block;margin-bottom:4px">Priorität</label>
            <select id="pt-prioritaet" style="width:100%;padding:8px 10px;border:1.5px solid var(--gray-200);border-radius:8px;font-size:0.85rem;font-family:inherit;outline:none">
              <option value="">Nicht gesetzt</option>
              <option value="niedrig">Niedrig</option>
              <option value="mittel">Mittel</option>
              <option value="hoch">Hoch</option>
              <option value="kritisch">Kritisch</option>
            </select>
          </div>
        </div>
        <div style="margin-bottom:14px">
          <label style="font-size:0.75rem;font-weight:700;color:var(--gray-400);text-transform:uppercase;display:block;margin-bottom:4px">Interne Notiz</label>
          <textarea id="pt-notiz" placeholder="Interne Anmerkungen (nicht für den Kunden sichtbar)…" style="width:100%;padding:10px 12px;border:1.5px solid var(--gray-200);border-radius:8px;font-size:0.85rem;font-family:inherit;min-height:80px;resize:vertical;outline:none"></textarea>
        </div>
        <div style="font-size:0.8rem;color:var(--gray-500);margin-bottom:16px" id="pt-kunde-info"></div>
        <div style="display:flex;justify-content:flex-end;gap:10px">
          <button class="btn btn-edit btn-sm" onclick="closePartnerModal()">Schließen</button>
          <button class="btn btn-primary btn-sm" onclick="savePartnerTicket()">Speichern</button>
        </div>
      </div>
    </div>
  </main>
  ```

- [ ] **Step 2: Script-Block für tickets.html schreiben**

  Füge nach `</main>` und vor `</body>` ein:

```html
<script>
  const SUPABASE_URL  = 'https://focysklymhmcfwgxdtuk.supabase.co';
  const SUPABASE_ANON = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZvY3lza2x5bWhtY2Z3Z3hkdHVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc1NTY1NTUsImV4cCI6MjEwMzEzMjU1NX0.VxgHwrnFUd-_7Q3pZx0L-7xY5roBZ__rUnLc5W7lOgg';
  const sb = supabase.createClient(SUPABASE_URL, SUPABASE_ANON, { auth: { flowType: 'implicit' } });

  let userRole = '', currentUserId = '', partnerProfileId = '';
  let allPartnerTickets = [], currentPartnerTicketId = '';

  function esc(s) { return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
  function showMsg(text, type) {
    const el = document.getElementById('msg'); el.textContent = text;
    el.className = 'msg ' + type; setTimeout(() => el.className = 'msg', 4000);
  }
  function fmtDate(s) { if (!s) return ''; return new Date(s).toLocaleDateString('de-DE',{day:'2-digit',month:'2-digit',year:'2-digit'}); }
  function statusLabel(s) {
    return { offen: 'Offen', in_bearbeitung: 'In Bearbeitung', geloest: 'Gelöst', geschlossen: 'Geschlossen' }[s] || s;
  }
  function prioBadge(p) {
    const map = { kritisch:'background:#fee2e2;color:#991b1b', hoch:'background:#fef3c7;color:#92400e', mittel:'background:#dbeafe;color:#1e40af', niedrig:'background:#f0fdf4;color:#166534' };
    return p ? `<span style="font-size:0.7rem;font-weight:700;padding:2px 8px;border-radius:12px;${map[p]||''}">${p.charAt(0).toUpperCase()+p.slice(1)}</span>` : '';
  }

  async function init() {
    const { data: { session } } = await sb.auth.getSession();
    if (!session) { window.location.href = 'index.html'; return; }
    currentUserId = session.user.id;
    _setHeaderUser(currentUserId);

    const { data: roleRow } = await sb.from('user_roles').select('role').eq('user_id', currentUserId).maybeSingle();
    userRole = roleRow?.role || 'kunde';

    if (userRole === 'admin') { window.location.href = 'support.html'; return; }

    setupNavRole(userRole).catch(console.warn);
    document.getElementById('view-spinner').style.display = 'none';

    if (userRole === 'kunde') {
      document.getElementById('page-sub').textContent = 'Ihre Support-Anfragen';
      document.getElementById('btn-new-ticket').style.display = '';
      document.getElementById('view-kunde').style.display = '';
      loadProductsForModal();
      loadKundeTickets();
    } else if (userRole === 'partner') {
      document.getElementById('page-sub').textContent = 'Ihnen zugewiesene Tickets';
      document.getElementById('view-partner').style.display = '';
      // Partner-Profil-ID holen
      const { data: pProfile } = await sb.from('user_profiles').select('id').eq('user_id', currentUserId).maybeSingle();
      partnerProfileId = pProfile?.id || '';
      loadPartnerTickets();
    }
  }

  async function loadProductsForModal() {
    const { data } = await sb.from('products').select('id, produkt').eq('published', true).order('produkt');
    const sel = document.getElementById('nt-produkt');
    (data || []).forEach(p => {
      const o = document.createElement('option'); o.value = p.id; o.textContent = p.produkt;
      sel.appendChild(o);
    });
  }

  async function loadKundeTickets() {
    const { data, error } = await sb.from('support_tickets')
      .select('id, titel, status, prioritaet, created_at, products(produkt)')
      .eq('user_id', currentUserId)
      .order('created_at', { ascending: false });
    const container = document.getElementById('ticket-list-kunde');
    if (error) { container.innerHTML = '<p style="color:#ef4444">Fehler: ' + esc(error.message) + '</p>'; return; }
    const rows = data || [];
    if (!rows.length) { container.innerHTML = '<p style="color:var(--gray-400);font-size:0.85rem;padding:20px 0;">Sie haben noch keine Support-Tickets erstellt.</p>'; return; }
    container.innerHTML = `<table style="width:100%;border-collapse:collapse;font-size:0.85rem">
      <thead><tr style="border-bottom:2px solid var(--gray-200)">
        <th style="text-align:left;padding:8px 12px;color:var(--gray-400);font-size:0.75rem;text-transform:uppercase;letter-spacing:.05em">Titel</th>
        <th style="text-align:left;padding:8px 12px;color:var(--gray-400);font-size:0.75rem;text-transform:uppercase;letter-spacing:.05em">Produkt</th>
        <th style="text-align:left;padding:8px 12px;color:var(--gray-400);font-size:0.75rem;text-transform:uppercase;letter-spacing:.05em">Status</th>
        <th style="text-align:left;padding:8px 12px;color:var(--gray-400);font-size:0.75rem;text-transform:uppercase;letter-spacing:.05em">Erstellt</th>
      </tr></thead>
      <tbody>
        ${rows.map(t => `<tr style="border-bottom:1px solid var(--gray-100)">
          <td style="padding:10px 12px;font-weight:600;color:var(--navy)">${esc(t.titel)}</td>
          <td style="padding:10px 12px;color:var(--gray-500)">${esc(t.products?.produkt || '–')}</td>
          <td style="padding:10px 12px">${statusLabel(t.status)}</td>
          <td style="padding:10px 12px;color:var(--gray-400)">${fmtDate(t.created_at)}</td>
        </tr>`).join('')}
      </tbody>
    </table>`;
  }

  function openNewTicketModal() { document.getElementById('new-ticket-overlay').classList.add('open'); }
  function closeNewTicketModal() { document.getElementById('new-ticket-overlay').classList.remove('open'); }

  async function submitNewTicket() {
    const titel = document.getElementById('nt-titel').value.trim();
    const beschreibung = document.getElementById('nt-beschreibung').value.trim();
    const produktId = document.getElementById('nt-produkt').value || null;
    if (!titel || !beschreibung) { showMsg('Bitte Titel und Beschreibung ausfüllen.', 'error'); return; }

    // kunden_id des eingeloggten Users
    const { data: kundenRow } = await sb.from('kunden').select('id').eq('email', (await sb.auth.getUser()).data.user?.email ?? '').maybeSingle();

    const { error } = await sb.from('support_tickets').insert({
      titel, beschreibung, user_id: currentUserId,
      kunden_id: kundenRow?.id || null,
      produkt_id: produktId,
    });
    if (error) { showMsg('Fehler: ' + error.message, 'error'); return; }

    // Bestätigungs-E-Mail
    const { data: { session } } = await sb.auth.getSession();
    await fetch(SUPABASE_URL + '/functions/v1/send-email', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + session.access_token },
      body: JSON.stringify({
        to: session.user.email,
        subject: 'Ihr Support-Ticket wurde erfolgreich erstellt',
        html: `<p>Sehr geehrte/r Kundin / Kunde,</p>
               <p>Ihr Support-Ticket <strong>"${titel}"</strong> wurde erfolgreich eingereicht. Wir werden uns so schnell wie möglich bei Ihnen melden.</p>
               <p>Mit freundlichen Grüßen<br>Ihr eHealth Sales Support-Team</p>`,
      }),
    });

    closeNewTicketModal();
    showMsg('Ticket erfolgreich erstellt.', 'success');
    loadKundeTickets();
  }

  async function loadPartnerTickets() {
    const { data: profile } = await sb.from('user_profiles').select('id').eq('user_id', currentUserId).maybeSingle();
    const pid = profile?.id;
    if (!pid) { document.getElementById('ticket-list-partner').innerHTML = '<p style="color:var(--gray-400);font-size:0.85rem;">Kein Partnerprofil gefunden.</p>'; return; }
    const { data, error } = await sb.from('support_tickets')
      .select('id, titel, beschreibung, status, prioritaet, notiz_intern, created_at, kunden_id, products(produkt), kunden(name, firma, email)')
      .eq('assigned_partner_id', pid)
      .order('created_at', { ascending: false });
    if (error) { document.getElementById('ticket-list-partner').innerHTML = '<p style="color:#ef4444">Fehler: ' + esc(error.message) + '</p>'; return; }
    allPartnerTickets = data || [];
    filterPartnerTickets();
  }

  function filterPartnerTickets() {
    const search = document.getElementById('filter-search-partner').value.toLowerCase();
    const statusF = document.getElementById('filter-status-partner').value;
    const filtered = allPartnerTickets.filter(t =>
      (!search || t.titel.toLowerCase().includes(search) || (t.kunden?.name || '').toLowerCase().includes(search)) &&
      (!statusF || t.status === statusF)
    );
    const container = document.getElementById('ticket-list-partner');
    if (!filtered.length) { container.innerHTML = '<p style="color:var(--gray-400);font-size:0.85rem;padding:20px 0;">Keine Tickets gefunden.</p>'; return; }
    container.innerHTML = filtered.map(t => `
      <div style="background:white;border:1.5px solid var(--gray-200);border-radius:14px;padding:18px 20px;margin-bottom:12px;cursor:pointer" onclick="openPartnerModal('${t.id}')">
        <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:12px;flex-wrap:wrap">
          <div>
            <div style="font-weight:700;color:var(--navy);font-size:0.95rem">${esc(t.titel)}</div>
            <div style="font-size:0.8rem;color:var(--gray-500);margin-top:3px">${esc(t.kunden?.name||'–')} · ${esc(t.kunden?.firma||'–')} · ${fmtDate(t.created_at)}</div>
          </div>
          <div style="display:flex;gap:6px;flex-wrap:wrap;align-items:center">
            ${prioBadge(t.prioritaet)}
            <span style="font-size:0.75rem;background:var(--gray-100);color:var(--gray-500);padding:3px 10px;border-radius:12px;font-weight:600">${statusLabel(t.status)}</span>
          </div>
        </div>
      </div>`).join('');
  }

  function openPartnerModal(ticketId) {
    currentPartnerTicketId = ticketId;
    const t = allPartnerTickets.find(x => x.id === ticketId);
    if (!t) return;
    document.getElementById('pt-titel-label').textContent = t.titel;
    document.getElementById('pt-beschreibung-label').textContent = t.beschreibung;
    document.getElementById('pt-status').value = t.status || 'offen';
    document.getElementById('pt-prioritaet').value = t.prioritaet || '';
    document.getElementById('pt-notiz').value = t.notiz_intern || '';
    document.getElementById('pt-kunde-info').innerHTML = t.kunden
      ? `<strong>Kunde:</strong> ${esc(t.kunden.name)} · ${esc(t.kunden.firma)} · <a href="mailto:${esc(t.kunden.email)}">${esc(t.kunden.email)}</a>`
      : '';
    document.getElementById('partner-ticket-overlay').classList.add('open');
  }
  function closePartnerModal() { document.getElementById('partner-ticket-overlay').classList.remove('open'); }

  async function savePartnerTicket() {
    const status = document.getElementById('pt-status').value;
    const prioritaet = document.getElementById('pt-prioritaet').value || null;
    const notiz_intern = document.getElementById('pt-notiz').value.trim() || null;
    const { error } = await sb.from('support_tickets')
      .update({ status, prioritaet, notiz_intern, updated_at: new Date().toISOString() })
      .eq('id', currentPartnerTicketId);
    if (error) { showMsg('Fehler: ' + error.message, 'error'); return; }
    closePartnerModal();
    showMsg('Ticket gespeichert.', 'success');
    loadPartnerTickets();
  }

  function toggleNavGroup(h) { h.closest('.nav-group').classList.toggle('open'); }

  async function setupNavRole(role) {
    if (role !== 'admin') {
      const k = document.getElementById('nav-item-kunden');
      if (k) k.style.display = 'none';
    }
    if (role === 'kunde') {
      ['nav-group-produkte','nav-link-anfragen','nav-link-kunden-mgmt','nav-link-rechner','nav-link-website'].forEach(id => {
        const el = document.getElementById(id); if (el) el.style.display = 'none';
      });
      const adminGroup = document.getElementById('nav-group-admin');
      if (adminGroup) adminGroup.style.display = 'none';
    }
    const supportLink = document.getElementById('nav-link-support');
    if (supportLink) supportLink.href = role === 'admin' ? 'support.html' : 'tickets.html';
  }

  async function _setHeaderUser(userId) {
    const [profileRes, roleRes] = await Promise.all([
      sb.from('user_profiles').select('vorname, nachname').eq('user_id', userId).maybeSingle(),
      sb.from('user_roles').select('role').eq('user_id', userId).maybeSingle(),
    ]);
    const p = profileRes.data;
    const el = document.getElementById('user-name');
    if (el) el.textContent = p ? [p.vorname, p.nachname].filter(Boolean).join(' ') : '–';
    const role = roleRes.data?.role || 'partner';
    const badge = document.getElementById('header-role-badge');
    if (badge) {
      badge.textContent = { admin:'Administrator', partner:'Partner', kunde:'Kunde' }[role] || role;
      badge.className = 'role-badge role-' + role;
      badge.style.display = '';
    }
  }

  async function logout() { await sb.auth.signOut(); window.location.href = 'index.html'; }

  init();
</script>
```

- [ ] **Step 3: Manuell testen**

  Als Kunde angemeldet: `admin/tickets.html` öffnen. Eigene Tickets-Liste erscheint. "Neues Ticket"-Button klicken, Formular ausfüllen, abschicken. Ticket erscheint in der Liste.

  Als Partner angemeldet: Liste zugewiesener Tickets erscheint. Klick auf Ticket öffnet Modal mit Status-/Prioritätswahl.

- [ ] **Step 4: Commit**

```bash
git add admin/tickets.html
git commit -m "feat: admin/tickets.html – Ticket-Ansicht für Kunden und Partner

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

### Task 6: admin/support.html

**Files:**
- Create: `admin/support.html`

**Interfaces:**
- Consumes: `support_tickets` SELECT/UPDATE (Task 1)
- Consumes: `user_profiles` SELECT (für Partner-Dropdown)
- Consumes: `send-email` Edge Function — E-Mail bei Zuweisung und Statusänderung
- Produces: Admin-Supportverwaltung mit Filter-Tabelle + Master-Detail-Panel

- [ ] **Step 1: Erstelle `admin/support.html`**

  Kopiere die Topbar/Sidebar-Struktur von `admin/kunden.html` (die `height:calc(100vh-60px)`, Master-Detail-Layout). Passe `<title>` auf `eHS Portal – Supportverwaltung` an. `main` erhält `display:flex;flex-direction:row;gap:0;overflow:hidden`. Dann ersetze den Main-Bereich mit:

```html
<main class="main" style="flex:1;display:flex;flex-direction:row;overflow:hidden;padding:0;gap:0">
  <!-- Linke Spalte: Tabelle -->
  <div id="list-col" style="width:55%;min-width:340px;border-right:1px solid var(--gray-200);display:flex;flex-direction:column;overflow:hidden">
    <div style="padding:20px 20px 12px;flex-shrink:0;border-bottom:1px solid var(--gray-100)">
      <h1 style="font-family:Montserrat,sans-serif;font-size:1.25rem;font-weight:800;color:var(--navy);margin-bottom:12px">Supportverwaltung</h1>
      <div class="filter-bar" style="flex-wrap:wrap;gap:8px">
        <input type="text" id="f-search" placeholder="Suche…" oninput="applyFilter()" style="min-width:160px;flex:1">
        <select id="f-status" onchange="applyFilter()">
          <option value="">Alle Status</option>
          <option value="offen">Offen</option>
          <option value="in_bearbeitung">In Bearbeitung</option>
          <option value="geloest">Gelöst</option>
          <option value="geschlossen">Geschlossen</option>
        </select>
        <select id="f-prio" onchange="applyFilter()">
          <option value="">Alle Prioritäten</option>
          <option value="kritisch">Kritisch</option>
          <option value="hoch">Hoch</option>
          <option value="mittel">Mittel</option>
          <option value="niedrig">Niedrig</option>
        </select>
        <select id="f-partner" onchange="applyFilter()">
          <option value="">Alle Partner</option>
          <option value="__unassigned">Nicht zugewiesen</option>
        </select>
      </div>
    </div>
    <div id="ticket-table" style="overflow-y:auto;flex:1;padding:8px 0"></div>
  </div>

  <!-- Rechte Spalte: Detail-Panel -->
  <div id="detail-col" style="flex:1;overflow-y:auto;padding:24px;display:none">
    <h2 id="d-titel" style="font-family:Montserrat,sans-serif;font-size:1.1rem;font-weight:800;color:var(--navy);margin-bottom:6px"></h2>
    <p id="d-beschreibung" style="font-size:0.85rem;color:var(--gray-500);line-height:1.6;margin-bottom:20px"></p>

    <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:16px">
      <div>
        <label class="field-label">Status</label>
        <select id="d-status" onchange="onStatusChange()" style="width:100%;padding:9px 12px;border:1.5px solid var(--gray-200);border-radius:9px;font-size:0.85rem;font-family:inherit;outline:none">
          <option value="offen">Offen</option>
          <option value="in_bearbeitung">In Bearbeitung</option>
          <option value="geloest">Gelöst</option>
          <option value="geschlossen">Geschlossen</option>
        </select>
      </div>
      <div>
        <label class="field-label">Priorität</label>
        <select id="d-prioritaet" style="width:100%;padding:9px 12px;border:1.5px solid var(--gray-200);border-radius:9px;font-size:0.85rem;font-family:inherit;outline:none">
          <option value="">Nicht gesetzt</option>
          <option value="niedrig">Niedrig</option>
          <option value="mittel">Mittel</option>
          <option value="hoch">Hoch</option>
          <option value="kritisch">Kritisch</option>
        </select>
      </div>
    </div>
    <div style="margin-bottom:16px">
      <label class="field-label">Partner zuweisen</label>
      <select id="d-partner" style="width:100%;padding:9px 12px;border:1.5px solid var(--gray-200);border-radius:9px;font-size:0.85rem;font-family:inherit;outline:none">
        <option value="">Nicht zugewiesen</option>
      </select>
    </div>
    <div style="margin-bottom:16px">
      <label class="field-label">Interne Notiz</label>
      <textarea id="d-notiz" style="width:100%;padding:10px 12px;border:1.5px solid var(--gray-200);border-radius:9px;font-size:0.85rem;font-family:inherit;min-height:80px;resize:vertical;outline:none"></textarea>
    </div>
    <div id="d-kunde-info" style="font-size:0.8rem;color:var(--gray-500);padding:12px;background:var(--gray-50);border-radius:9px;margin-bottom:16px"></div>
    <div class="msg" id="d-msg" style="margin-bottom:12px"></div>
    <button class="btn btn-primary btn-sm" onclick="saveTicket()">Änderungen speichern</button>
  </div>
</main>
```

  CSS ergänzen (vor `</style>`):
  ```css
  .field-label { display:block; font-size:0.75rem; font-weight:700; color:var(--gray-400); text-transform:uppercase; letter-spacing:.05em; margin-bottom:5px; }
  .ticket-row { padding:12px 16px; cursor:pointer; border-bottom:1px solid var(--gray-100); transition:background 0.12s; }
  .ticket-row:hover { background:var(--gray-50); }
  .ticket-row.selected { background:#eef0f7; }
  .msg { display:none; border-radius:9px; padding:10px 14px; font-size:0.82rem; }
  .msg.success { display:block; background:#d1fae5; color:#065f46; }
  .msg.error   { display:block; background:#fee2e2; color:#991b1b; }
  ```

- [ ] **Step 2: Script-Block für support.html schreiben**

```html
<script>
  const SUPABASE_URL  = 'https://focysklymhmcfwgxdtuk.supabase.co';
  const SUPABASE_ANON = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZvY3lza2x5bWhtY2Z3Z3hkdHVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc1NTY1NTUsImV4cCI6MjEwMzEzMjU1NX0.VxgHwrnFUd-_7Q3pZx0L-7xY5roBZ__rUnLc5W7lOgg';
  const sb = supabase.createClient(SUPABASE_URL, SUPABASE_ANON, { auth: { flowType: 'implicit' } });

  let allTickets = [], allPartners = [], currentTicketId = '', currentSession = null;

  function esc(s) { return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
  function fmtDate(s) { if (!s) return ''; return new Date(s).toLocaleDateString('de-DE',{day:'2-digit',month:'2-digit',year:'2-digit'}); }
  function prioBadge(p) {
    const map = { kritisch:'background:#fee2e2;color:#991b1b', hoch:'background:#fef3c7;color:#92400e', mittel:'background:#dbeafe;color:#1e40af', niedrig:'background:#f0fdf4;color:#166534' };
    return p ? `<span style="font-size:0.68rem;font-weight:700;padding:2px 8px;border-radius:12px;${map[p]||''}">${p.charAt(0).toUpperCase()+p.slice(1)}</span>` : '';
  }
  function statusLabel(s) { return {offen:'Offen',in_bearbeitung:'In Bearbeitung',geloest:'Gelöst',geschlossen:'Geschlossen'}[s]||s; }

  async function init() {
    const { data: { session } } = await sb.auth.getSession();
    if (!session) { window.location.href = 'index.html'; return; }
    currentSession = session;
    _setHeaderUser(session.user.id);
    const { data: roleRow } = await sb.from('user_roles').select('role').eq('user_id', session.user.id).maybeSingle();
    if (roleRow?.role !== 'admin') { window.location.href = 'tickets.html'; return; }
    document.getElementById('nav-group-admin').style.display = '';
    setupNavRole('admin').catch(console.warn);
    await loadPartners();
    await loadTickets();
  }

  async function loadPartners() {
    const { data } = await sb.from('user_profiles')
      .select('id, vorname, nachname, email')
      .eq('rolle', 'partner')
      .order('nachname');
    allPartners = data || [];
    const sel = document.getElementById('d-partner');
    const fSel = document.getElementById('f-partner');
    allPartners.forEach(p => {
      const label = [p.vorname, p.nachname].filter(Boolean).join(' ') || p.email;
      [sel, fSel].forEach(el => {
        const o = document.createElement('option'); o.value = p.id; o.textContent = label;
        el.appendChild(o);
      });
    });
  }

  async function loadTickets() {
    const { data, error } = await sb.from('support_tickets')
      .select('id, titel, beschreibung, status, prioritaet, notiz_intern, created_at, assigned_partner_id, kunden_id, user_id, kunden(name, firma, email, telefon), products(produkt)')
      .order('created_at', { ascending: false });
    if (error) { document.getElementById('ticket-table').innerHTML = '<p style="color:#ef4444;padding:16px">Fehler: ' + esc(error.message) + '</p>'; return; }
    allTickets = data || [];
    applyFilter();
  }

  function applyFilter() {
    const search = document.getElementById('f-search').value.toLowerCase();
    const statusF = document.getElementById('f-status').value;
    const prioF   = document.getElementById('f-prio').value;
    const partnerF = document.getElementById('f-partner').value;
    const filtered = allTickets.filter(t =>
      (!search || t.titel.toLowerCase().includes(search) || (t.kunden?.name||'').toLowerCase().includes(search) || (t.kunden?.firma||'').toLowerCase().includes(search)) &&
      (!statusF || t.status === statusF) &&
      (!prioF   || t.prioritaet === prioF) &&
      (!partnerF || (partnerF === '__unassigned' ? !t.assigned_partner_id : t.assigned_partner_id === partnerF))
    );
    const container = document.getElementById('ticket-table');
    if (!filtered.length) { container.innerHTML = '<p style="color:var(--gray-400);font-size:0.85rem;padding:20px 16px;">Keine Tickets gefunden.</p>'; return; }
    container.innerHTML = filtered.map(t => `
      <div class="ticket-row${currentTicketId===t.id?' selected':''}" onclick="selectTicket('${t.id}')">
        <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:8px;flex-wrap:wrap">
          <div style="min-width:0;flex:1">
            <div style="font-weight:700;color:var(--navy);font-size:0.88rem;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">${esc(t.titel)}</div>
            <div style="font-size:0.75rem;color:var(--gray-500);margin-top:2px">${esc(t.kunden?.name||'–')} · ${esc(t.kunden?.firma||'–')}</div>
          </div>
          <div style="display:flex;gap:5px;flex-wrap:wrap;align-items:center;flex-shrink:0">
            ${prioBadge(t.prioritaet)}
            <span style="font-size:0.72rem;background:var(--gray-100);padding:2px 8px;border-radius:10px;color:var(--gray-500);font-weight:600">${statusLabel(t.status)}</span>
          </div>
        </div>
        <div style="font-size:0.72rem;color:var(--gray-400);margin-top:3px">${fmtDate(t.created_at)}</div>
      </div>`).join('');
  }

  function selectTicket(id) {
    currentTicketId = id;
    const t = allTickets.find(x => x.id === id);
    if (!t) return;
    document.getElementById('detail-col').style.display = '';
    document.getElementById('d-titel').textContent = t.titel;
    document.getElementById('d-beschreibung').textContent = t.beschreibung;
    document.getElementById('d-status').value = t.status || 'offen';
    document.getElementById('d-prioritaet').value = t.prioritaet || '';
    document.getElementById('d-partner').value = t.assigned_partner_id || '';
    document.getElementById('d-notiz').value = t.notiz_intern || '';
    document.getElementById('d-msg').className = 'msg';
    const k = t.kunden;
    document.getElementById('d-kunde-info').innerHTML = k
      ? `<strong>Kunde:</strong> ${esc(k.name)} · ${esc(k.firma)} · <a href="mailto:${esc(k.email)}">${esc(k.email)}</a>${k.telefon ? ' · ' + esc(k.telefon) : ''}`
      : 'Kein Kundenprofil verknüpft.';
    applyFilter(); // Row-Highlight aktualisieren
  }

  function onStatusChange() {} // Platzhalter — Statusänderung erst bei "Speichern"

  async function saveTicket() {
    const t = allTickets.find(x => x.id === currentTicketId);
    if (!t) return;
    const newStatus    = document.getElementById('d-status').value;
    const newPrio      = document.getElementById('d-prioritaet').value || null;
    const newPartner   = document.getElementById('d-partner').value || null;
    const newNotiz     = document.getElementById('d-notiz').value.trim() || null;
    const statusChanged  = newStatus !== t.status;
    const partnerChanged = newPartner !== (t.assigned_partner_id || null);

    const { error } = await sb.from('support_tickets').update({
      status: newStatus, prioritaet: newPrio,
      assigned_partner_id: newPartner, notiz_intern: newNotiz,
      updated_at: new Date().toISOString(),
    }).eq('id', currentTicketId);
    if (error) { showDetailMsg('Fehler: ' + error.message, 'error'); return; }

    // E-Mail bei Partnerzuweisung
    if (partnerChanged && newPartner) {
      const partnerProfile = allPartners.find(p => p.id === newPartner);
      if (partnerProfile?.email) {
        await sendEmail(partnerProfile.email,
          `Support-Ticket zugewiesen: ${t.titel}`,
          `<p>Sehr geehrte/r ${partnerProfile.vorname||''} ${partnerProfile.nachname||''},</p>
           <p>Ihnen wurde ein Support-Ticket zugewiesen:</p>
           <ul><li><strong>Titel:</strong> ${t.titel}</li>
           <li><strong>Kunde:</strong> ${t.kunden?.name||'–'}, ${t.kunden?.firma||'–'}</li></ul>
           <p><a href="https://ehealth-sales.de/admin/tickets.html">Im Portal öffnen</a></p>
           <p>Mit freundlichen Grüßen<br>eHealth Sales Support-Team</p>`
        );
      }
    }

    // E-Mail bei Statusänderung (nicht bei "geschlossen")
    if (statusChanged && newStatus !== 'geschlossen') {
      const { data: up } = await sb.from('user_profiles').select('email, vorname, nachname').eq('user_id', t.user_id).maybeSingle();
      if (up?.email) {
        const statusLabels = { offen:'Offen', in_bearbeitung:'In Bearbeitung', geloest:'Gelöst' };
        await sendEmail(up.email,
          `Status Ihres Tickets geändert: ${t.titel}`,
          `<p>Sehr geehrte/r ${up.vorname||''} ${up.nachname||''},</p>
           <p>Der Status Ihres Support-Tickets <strong>"${t.titel}"</strong> wurde auf <strong>${statusLabels[newStatus]||newStatus}</strong> gesetzt.</p>
           <p>Sie können Ihre Tickets jederzeit im <a href="https://ehealth-sales.de/admin/tickets.html">Kundenportal</a> einsehen.</p>
           <p>Mit freundlichen Grüßen<br>eHealth Sales Support-Team</p>`
        );
      }
    }

    // Lokale Daten aktualisieren
    Object.assign(t, { status: newStatus, prioritaet: newPrio, assigned_partner_id: newPartner, notiz_intern: newNotiz });
    showDetailMsg('Gespeichert.', 'success');
    applyFilter();
  }

  async function sendEmail(to, subject, html) {
    await fetch(SUPABASE_URL + '/functions/v1/send-email', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + currentSession.access_token },
      body: JSON.stringify({ to, subject, html }),
    });
  }

  function showDetailMsg(text, type) {
    const el = document.getElementById('d-msg'); el.textContent = text;
    el.className = 'msg ' + type; setTimeout(() => el.className = 'msg', 3000);
  }

  function toggleNavGroup(h) { h.closest('.nav-group').classList.toggle('open'); }

  async function setupNavRole(role) {
    if (role !== 'admin') {
      const k = document.getElementById('nav-item-kunden'); if (k) k.style.display = 'none';
    }
    const supportLink = document.getElementById('nav-link-support');
    if (supportLink) supportLink.href = role === 'admin' ? 'support.html' : 'tickets.html';
  }

  async function _setHeaderUser(userId) {
    const [profileRes, roleRes] = await Promise.all([
      sb.from('user_profiles').select('vorname, nachname').eq('user_id', userId).maybeSingle(),
      sb.from('user_roles').select('role').eq('user_id', userId).maybeSingle(),
    ]);
    const p = profileRes.data;
    const el = document.getElementById('user-name');
    if (el) el.textContent = p ? [p.vorname,p.nachname].filter(Boolean).join(' ') : '–';
    const role = roleRes.data?.role||'partner';
    const badge = document.getElementById('header-role-badge');
    if (badge) {
      badge.textContent = {admin:'Administrator',partner:'Partner',kunde:'Kunde'}[role]||role;
      badge.className = 'role-badge role-'+role; badge.style.display='';
    }
  }

  async function logout() { await sb.auth.signOut(); window.location.href = 'index.html'; }
  init();
</script>
```

- [ ] **Step 3: Manuell testen**

  Als Admin angemeldet: `admin/support.html` aufrufen. Tabelle zeigt alle Tickets. Klick auf eine Zeile öffnet Detail-Panel. Status + Partner setzen, "Speichern" klicken. Erwartung: Änderung gespeichert, E-Mail an Partner (wenn zugewiesen) und an Kunden (wenn Status geändert).

- [ ] **Step 4: Commit**

```bash
git add admin/support.html
git commit -m "feat: admin/support.html – Admin-Supportverwaltung mit Filter und Master-Detail

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

### Task 7: Nav-Update alle Admin-Seiten

**Files:**
- Modify: alle 16 Dateien mit Standard-Sidebar:
  `admin/alliance-config.html`, `admin/anfragen.html`, `admin/berufsgruppen.html`, `admin/dashboard.html`, `admin/events.html`, `admin/finder-config.html`, `admin/knowledge.html`, `admin/kunden.html`, `admin/orders.html`, `admin/partners.html`, `admin/products.html`, `admin/profile.html`, `admin/rechner.html`, `admin/shop.html`, `admin/themengebiete.html`, `admin/users.html`
- **NICHT** modifizieren: `index.html`, `mfa-challenge.html`, `set-password.html`, `loesung.html` (kein Standard-Sidebar)
- `tickets.html` und `support.html` werden in Task 5 und 6 bereits mit korrektem Nav gebaut

**Interfaces:**
- Consumes: bestehende Nav-HTML-Struktur in jeder Datei (Task 5/6 bereits erledigt)
- Produces: Support-Nav-Link in allen 16 Seiten + Kunden-Nav-Hiding via `setupNavRole`

**Vorgehen pro Datei — drei Änderungen:**

**Änderung A — Support-Nav-Link einfügen:**
In jeder Datei: Suche den Block für den TI-Rechner-Link:
```html
    <a class="nav-link" href="rechner.html">
      <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 11h.01M12 11h.01M15 11h.01M4 19h16a2 2 0 002-2V7a2 2 0 00-2-2H4a2 2 0 00-2 2v10a2 2 0 002 2z"/></svg>
      TI-Rechner
    </a>
```
Füge danach ein:
```html
    <a class="nav-link" id="nav-link-support" href="support.html">
      <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v3a2 2 0 110 4v3a2 2 0 002 2h14a2 2 0 002-2v-3a2 2 0 110-4V7a2 2 0 00-2-2H5z"/></svg>
      Support
    </a>
```

**Änderung B — IDs für Kunden-Nav-Hiding:**
In jeder Datei (sofern vorhanden):
- `href="anfragen.html"` im Nav (ohne id) → füge `id="nav-link-anfragen"` hinzu
- `href="kunden.html"` im Hauptnav (die Kunden-Verwaltung, nicht der Produktfinder-Link) → `id="nav-link-kunden-mgmt"` hinzufügen
- `href="rechner.html"` → `id="nav-link-rechner"` hinzufügen
- `href="../index.html"` (Zur-Website-Link) → `id="nav-link-website"` hinzufügen

**Änderung C — `setupNavRole()` aktualisieren:**
Suche in jeder Datei die `setupNavRole`-Funktion. Füge am Anfang des Funktionskörpers (nach der öffnenden geschweiften Klammer) ein:
```js
    // Support-Link zielabhängig vom Benutzer
    const supportLink = document.getElementById('nav-link-support');
    if (supportLink) supportLink.href = roleArg === 'admin' ? 'support.html' : 'tickets.html';
    // Kunden sehen nur Dashboard, Support, Shop, Events, Community
    if (roleArg === 'kunde') {
      ['nav-group-produkte','nav-link-anfragen','nav-link-kunden-mgmt','nav-link-rechner','nav-link-website'].forEach(id => {
        const el = document.getElementById(id); if (el) el.style.display = 'none';
      });
      const adminGroup = document.getElementById('nav-group-admin');
      if (adminGroup) adminGroup.style.display = 'none';
    }
```

- [ ] **Step 1: alliance-config.html — alle drei Änderungen**

  Lies die Datei. Führe Änderungen A, B und C durch.

- [ ] **Step 2: anfragen.html — alle drei Änderungen**

  (Tab-Änderungen aus Task 4 bereits gemacht.) Füge Support-Link (A) und IDs (B) ein. `setupNavRole` existiert möglicherweise nicht — falls nicht, füge sie aus dem anfragen-Script-Block hinzu oder ergänze sie falls vorhanden (C).

- [ ] **Step 3: berufsgruppen.html — alle drei Änderungen**

- [ ] **Step 4: dashboard.html — alle drei Änderungen**

  Wichtig: `setupNavRole` in dashboard.html hat besondere Logik (Produktfinder-Subnav). Nur den neuen Code AM ANFANG der Funktion einfügen, Rest unangetastet lassen.

- [ ] **Step 5: events.html — alle drei Änderungen**

- [ ] **Step 6: finder-config.html — alle drei Änderungen**

- [ ] **Step 7: knowledge.html — alle drei Änderungen**

- [ ] **Step 8: kunden.html — alle drei Änderungen**

- [ ] **Step 9: orders.html — alle drei Änderungen**

- [ ] **Step 10: partners.html — alle drei Änderungen**

- [ ] **Step 11: products.html — alle drei Änderungen**

- [ ] **Step 12: profile.html — alle drei Änderungen**

- [ ] **Step 13: rechner.html — alle drei Änderungen**

- [ ] **Step 14: shop.html — alle drei Änderungen**

- [ ] **Step 15: themengebiete.html — alle drei Änderungen**

- [ ] **Step 16: users.html — alle drei Änderungen**

- [ ] **Step 17: Verifikation**

  Als Admin in `admin/dashboard.html`: "Support"-Link erscheint in der Sidebar. Klick öffnet `support.html`.
  Als Testbenutzer mit Rolle `kunde`: Nur Dashboard, Support, Shop, Events, Community sichtbar. Alle anderen Nav-Einträge ausgeblendet.

- [ ] **Step 18: Commit**

```bash
git add admin/alliance-config.html admin/anfragen.html admin/berufsgruppen.html admin/dashboard.html admin/events.html admin/finder-config.html admin/knowledge.html admin/kunden.html admin/orders.html admin/partners.html admin/products.html admin/profile.html admin/rechner.html admin/shop.html admin/themengebiete.html admin/users.html
git commit -m "feat: Support-Nav-Link + Kunden-Nav-Hiding in alle Admin-Seiten

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```
