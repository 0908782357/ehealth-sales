const RESEND_API_KEY  = Deno.env.get('RESEND_API_KEY') ?? '';
const SUPABASE_URL    = Deno.env.get('SUPABASE_URL') ?? '';
const SERVICE_KEY     = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
const FROM            = 'TI Monitoring <anfragecenter@ehealth-sales.de>';
const RATE_LIMIT_MS   = 30 * 60 * 1000; // Fallback: max. 1 Mail alle 30 Min.

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, 'Content-Type': 'application/json' },
  });
}

const PORTAL_URL = 'https://ehealth-sales.de/admin/ti-lagebild.html';

function emailWrapper(headerBg: string, headerTitle: string, body: string): string {
  return `<!DOCTYPE html>
<html lang="de">
<head><meta charset="UTF-8"></head>
<body style="font-family:Inter,Helvetica Neue,sans-serif;background:#f8fafc;padding:0;margin:0;">
  <div style="max-width:560px;margin:32px auto;background:white;border-radius:12px;overflow:hidden;border:1px solid #e2e8f0;">
    <div style="background:${headerBg};padding:24px 28px;">
      <h1 style="color:white;font-family:Montserrat,sans-serif;font-size:1.1rem;margin:0;">${headerTitle}</h1>
      <p style="color:rgba(255,255,255,0.75);font-size:0.82rem;margin:6px 0 0;">eHealth Sales Alliance Portal</p>
    </div>
    <div style="padding:28px;">
      ${body}
      <a href="${PORTAL_URL}" style="display:inline-block;background:#3C4A7C;color:white;padding:10px 20px;border-radius:8px;text-decoration:none;font-weight:600;font-size:0.85rem;">
        Zum TI Lagebild →
      </a>
    </div>
    <div style="background:#f8fafc;border-top:1px solid #e2e8f0;padding:16px 28px;">
      <p style="color:#94a3b8;font-size:0.72rem;margin:0;">
        Diese Benachrichtigung wurde automatisch gesendet.
        Um Alerts zu deaktivieren, öffne das TI Lagebild und klicke auf den Alert-Button.
      </p>
    </div>
  </div>
</body>
</html>`;
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response(null, { status: 204, headers: cors });
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405);

  // Nutzer aus JWT verifizieren
  const authHeader = req.headers.get('Authorization') ?? '';
  if (!authHeader.startsWith('Bearer ')) return json({ error: 'Unauthorized' }, 401);
  const token = authHeader.slice(7);

  const userRes = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
    headers: { Authorization: `Bearer ${token}`, apikey: SERVICE_KEY },
  });
  if (!userRes.ok) return json({ error: 'Unauthorized' }, 401);
  const { id: userId } = await userRes.json();
  if (!userId) return json({ error: 'Unauthorized' }, 401);

  // Subscription aus DB lesen
  const subRes = await fetch(
    `${SUPABASE_URL}/rest/v1/ti_alert_subscriptions?user_id=eq.${userId}&select=*`,
    { headers: { Authorization: `Bearer ${SERVICE_KEY}`, apikey: SERVICE_KEY } },
  );
  const subs = await subRes.json();
  const sub = Array.isArray(subs) ? subs[0] : null;

  if (!sub?.active) return json({ ok: false, reason: 'no_active_subscription' });

  // Payload lesen
  const { type = 'disruption', email: testEmail, services = [], timestamp = '' } = await req.json().catch(() => ({}));

  // Test-Mail: direkt senden, kein DB-Lookup, kein Rate-Limit
  if (type === 'test') {
    const to = testEmail || sub?.email;
    if (!to) return json({ error: 'No email address' }, 400);
    const testHtml = emailWrapper(
      '#3C4A7C',
      '🔔 Test-Alert – TI Monitoring',
      `<p style="color:#0f172a;font-size:0.92rem;margin-bottom:16px;">
        Dies ist eine <strong>Test-Benachrichtigung</strong> des TI Störungs-Alerts.
        Wenn du diese Mail erhalten hast, funktioniert der Alert korrekt.
      </p>
      <p style="color:#64748b;font-size:0.78rem;margin-bottom:20px;">Zeitpunkt: ${timestamp}</p>`,
    );
    const r = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: { Authorization: `Bearer ${RESEND_API_KEY}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ from: FROM, to: [to], subject: '🔔 Test: TI Störungs-Alert', html: testHtml }),
    });
    const rb = await r.text();
    return new Response(rb, { status: r.status, headers: { ...cors, 'Content-Type': 'application/json' } });
  }

  // Rate-Limiting als Fallback (z.B. Seiten-Reload während aktiver Störung)
  // Entwarnung (recovery) ist immer erlaubt
  if (type !== 'recovery' && sub.last_alerted_at) {
    const diff = Date.now() - new Date(sub.last_alerted_at).getTime();
    if (diff < RATE_LIMIT_MS) return json({ ok: false, reason: 'rate_limited' });
  }

  // last_alerted_at sofort setzen (verhindert Doppel-Mails bei parallelen Tabs)
  await fetch(`${SUPABASE_URL}/rest/v1/ti_alert_subscriptions?user_id=eq.${userId}`, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${SERVICE_KEY}`,
      apikey: SERVICE_KEY,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ last_alerted_at: new Date().toISOString() }),
  });

  // E-Mail je nach Typ zusammenbauen
  let subject: string;
  let html: string;

  if (type === 'recovery') {
    subject = '✅ TI-Störung behoben – Alle Dienste wieder betriebsbereit';
    html = emailWrapper(
      '#15803d',
      '✅ TI-Störung behoben',
      `<p style="color:#0f172a;font-size:0.92rem;margin-bottom:16px;">
        Die TI-Dienste sind wieder vollständig <strong>betriebsbereit</strong>. Es liegen keine aktiven Störungen vor.
      </p>
      <p style="color:#64748b;font-size:0.78rem;margin-bottom:20px;">Zeitpunkt: ${timestamp}</p>`,
    );
  } else {
    const listItems = (services as { label: string; status: string }[])
      .map(s => `<li style="margin:4px 0;"><strong>${s.label}</strong>: ${s.status}</li>`)
      .join('');
    const affected = (services as { label: string }[]).map(s => s.label).join(', ');
    subject = `⚠️ TI-Störung: ${affected}`;
    html = emailWrapper(
      '#3C4A7C',
      '⚠️ TI Störungs-Alert',
      `<p style="color:#0f172a;font-size:0.92rem;margin-bottom:16px;">
        Folgende TI-Dienste haben aktuell <strong>Störungen oder Einschränkungen</strong>:
      </p>
      <ul style="background:#fef2f2;border:1px solid #fecaca;border-radius:8px;padding:12px 16px 12px 28px;color:#dc2626;font-size:0.9rem;margin:0 0 20px;">
        ${listItems}
      </ul>
      <p style="color:#64748b;font-size:0.78rem;margin-bottom:20px;">Zeitpunkt: ${timestamp}</p>`,
    );
  }

  const mailRes = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: { Authorization: `Bearer ${RESEND_API_KEY}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ from: FROM, to: [sub.email], subject, html }),
  });

  const mailBody = await mailRes.text();
  return new Response(mailBody, {
    status: mailRes.status,
    headers: { ...cors, 'Content-Type': 'application/json' },
  });
});
