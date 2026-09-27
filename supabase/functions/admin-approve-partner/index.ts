// Deploy: npx supabase functions deploy admin-approve-partner --project-ref focysklymhmcfwgxdtuk

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const json = (data: unknown, status = 200) =>
  new Response(JSON.stringify(data), { status, headers: { ...cors, 'Content-Type': 'application/json' } });

const esc = (s: string) => s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');

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
    .select('id, vorname, nachname, email, firma, partner_status, anliegen, status, typ')
    .eq('id', registrierungId)
    .maybeSingle();
  if (regErr || !reg) return json({ error: 'Registrierung nicht gefunden' }, 404);
  if (reg.status !== 'ausstehend') return json({ error: 'Registrierung hat nicht den Status "ausstehend"' }, 409);
  if (reg.typ !== 'partner') return json({ error: 'Registrierung ist keine Partneranfrage' }, 400);

  // Auth-Account anlegen – oder bestehenden wiederverwenden wenn nur das Profil gelöscht wurde
  let userId: string;
  const { data: newUser, error: createErr } = await adminClient.auth.admin.createUser({
    email: reg.email,
    email_confirm: true,
  });

  if (createErr) {
    if (!createErr.message.toLowerCase().includes('already')) {
      return json({ error: 'Auth-User-Anlage fehlgeschlagen: ' + createErr.message }, 400);
    }
    // Auth-User existiert noch – prüfen ob bereits ein aktives Profil vorhanden ist
    const { data: existingProfile } = await adminClient
      .from('user_profiles').select('user_id').eq('email', reg.email).maybeSingle();
    if (existingProfile) {
      return json({ error: 'Es existiert bereits ein aktiver Account mit dieser E-Mail-Adresse.' }, 409);
    }
    // Kein Profil → Auth-User-ID ermitteln und wiederverwenden
    const { data: userList } = await adminClient.auth.admin.listUsers({ perPage: 1000 });
    const existing = userList?.users?.find((u: { email?: string; id: string }) => u.email === reg.email);
    if (!existing) return json({ error: 'Interner Fehler: Auth-User nicht auffindbar.' }, 500);
    userId = existing.id;
  } else {
    userId = newUser.user.id;
  }

  const rollback = async (reason: string) => {
    // Rollback nur wenn wir den User selbst angelegt haben (kein pre-existing user)
    if (!createErr) await adminClient.auth.admin.deleteUser(userId);
    return json({ error: reason }, 400);
  };

  // user_profiles anlegen
  const { error: profileErr } = await adminClient.from('user_profiles').insert({
    user_id: userId,
    email: reg.email,
    vorname: reg.vorname,
    nachname: reg.nachname,
    firma: reg.firma,
    rolle: 'partner',
    password_set: false,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  });
  if (profileErr) return rollback('user_profiles INSERT fehlgeschlagen: ' + profileErr.message);

  // user_roles anlegen (mit partner_tier)
  const { error: rolesErr } = await adminClient.from('user_roles').insert({
    user_id: userId,
    role: 'partner',
    partner_tier: reg.partner_status ?? null,
  });
  if (rolesErr) return rollback('user_roles INSERT fehlgeschlagen: ' + rolesErr.message);

  // Magic-Link generieren
  const { data: linkData, error: linkErr } = await adminClient.auth.admin.generateLink({
    type: 'magiclink',
    email: reg.email,
    options: { redirectTo: 'https://ehealth-sales.de/admin/set-password.html' },
  });
  if (linkErr || !linkData?.properties?.action_link) {
    return rollback('Magic-Link-Generierung fehlgeschlagen: ' + (linkErr?.message ?? 'kein Link'));
  }
  const magicLink = linkData.properties.action_link;

  const tierLabels: Record<string, string> = { standard: 'Standard', premium: 'Premium', strategisch: 'Strategisch' };
  const tierLabel = tierLabels[reg.partner_status ?? ''] ?? reg.partner_status ?? '';

  // Genehmigungs-E-Mail senden
  const emailRes = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${RESEND_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      from: FROM,
      to: [reg.email],
      subject: 'Ihr Partnerzugang zum eHealth Sales Portal wurde freigeschaltet',
      html: `<p>Sehr geehrte/r ${esc(reg.vorname)} ${esc(reg.nachname)},</p>
             <p>wir freuen uns, Ihnen mitteilen zu können, dass Ihre Partneranfrage genehmigt wurde.</p>
             ${tierLabel ? `<p>Ihr Partnerstatus: <strong>${esc(tierLabel)}</strong></p>` : ''}
             <p>Klicken Sie auf den folgenden Link, um sich einzuloggen und Ihr Passwort zu setzen:</p>
             <p><a href="${magicLink}" style="background:#3C4A7C;color:white;padding:12px 24px;border-radius:8px;text-decoration:none;font-weight:bold;display:inline-block;">Jetzt einloggen</a></p>
             <p>Der Link ist 24 Stunden gültig.</p>
             <p>Mit freundlichen Grüßen<br>Ihr eHealth Sales Team</p>`,
    }),
  });
  if (!emailRes.ok) {
    const emailBody = await emailRes.text().catch(() => '');
    return rollback('E-Mail-Versand fehlgeschlagen: ' + emailBody);
  }

  // Registrierung auf genehmigt setzen
  await adminClient.from('registrierungen').update({ status: 'genehmigt' }).eq('id', registrierungId);

  return json({ success: true, userId });
});
