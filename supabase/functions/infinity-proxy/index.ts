const INFINITY_BASE = 'https://portal.managed-infinity.de/api/v1';

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

async function infinityGet(path: string, token: string, cookie = '') {
  const res = await fetch(`${INFINITY_BASE}${path}`, {
    headers: {
      Authorization: `Bearer ${token}`,
      ...(cookie ? { Cookie: cookie } : {}),
    },
  });
  if (!res.ok) {
    const body = await res.text().catch(() => '');
    throw new Error(`${res.status}: ${body.slice(0, 200)}`);
  }
  return res.json();
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response(null, { status: 204, headers: cors });
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405);

  let body: Record<string, string>;
  try { body = await req.json(); } catch { return json({ error: 'Invalid JSON' }, 400); }

  const { action, username, password, totp, infinityToken, partialToken } = body;

  // ── LOGIN: step 1 (username + password) ──────────────────────────────────
  if (action === 'login') {
    if (!username || !password) return json({ error: 'username and password required' }, 400);
    const res = await fetch(`${INFINITY_BASE}/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ username, password }),
    });
    const data = await res.json();
    if (!res.ok) return json({ error: data.message ?? 'Login failed', details: data }, res.status);
    const cookies = res.headers.get('set-cookie') ?? '';
    // Always require TOTP confirmation if account has it set up;
    // treat as partial unless server explicitly confirms full auth
    const needsTotp = data.isOnlyFirstFactorToken !== false || !data.accessToken;
    return json({
      needsTotp,
      partialToken: data.accessToken ?? data.token ?? null,
      partialCookie: cookies,
      fullToken: needsTotp ? null : (data.accessToken ?? data.token),
      fullCookie: needsTotp ? null : cookies,
      _debug: { isOnlyFirstFactorToken: data.isOnlyFirstFactorToken, keys: Object.keys(data) },
    });
  }

  // ── LOGIN: step 2 (confirm with TOTP) ─────────────────────────────────────
  if (action === 'confirm') {
    if (!totp || !partialToken) return json({ error: 'totp and partialToken required' }, 400);
    const incomingCookie = (body as Record<string, string>).sessionCookie ?? '';
    const res = await fetch(`${INFINITY_BASE}/login/bestaetigen`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${partialToken}`,
        ...(incomingCookie ? { Cookie: incomingCookie } : {}),
      },
      body: JSON.stringify({ totp }),
    });
    const data = await res.json();
    if (!res.ok) return json({ error: data.message ?? 'TOTP confirmation failed', details: data }, res.status);
    const cookies = res.headers.get('set-cookie') ?? incomingCookie;
    return json({ token: data.accessToken ?? data.token ?? null, sessionCookie: cookies });
  }

  // ── REALM DATA ────────────────────────────────────────────────────────────
  if (action === 'realm') {
    if (!infinityToken) return json({ error: 'infinityToken required' }, 400);
    const sessionCookie = (body as Record<string, string>).sessionCookie ?? '';
    try {
      // Date range: last 30 days → today
      const to   = new Date().toISOString().slice(0, 10);
      const from = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().slice(0, 10);

      const results = await Promise.allSettled([
        infinityGet('/benutzer-profil', infinityToken, sessionCookie),
        infinityGet('/leistungserbringer', infinityToken, sessionCookie),
        infinityGet(`/berichte/reseller?subjectType=KONNEKTOR&from=${from}&to=${to}`, infinityToken, sessionCookie),
        infinityGet(`/berichte/reseller?subjectType=VPN&from=${from}&to=${to}`, infinityToken, sessionCookie),
        infinityGet('/reseller-kontingente', infinityToken, sessionCookie),
        infinityGet('/firmen', infinityToken, sessionCookie),
      ]);

      const [profil, leistungserbringer, berichtKonnektor, berichtVpn, resellerKontingente, firmen] = results;

      const r = (p: PromiseSettledResult<unknown>) =>
        p.status === 'fulfilled' ? { data: p.value } : { error: (p as PromiseRejectedResult).reason?.message };

      return json({
        benutzerProfil:      r(profil),
        leistungserbringer:  r(leistungserbringer),
        berichtKonnektor:    r(berichtKonnektor),
        berichtVpn:          r(berichtVpn),
        resellerKontingente: r(resellerKontingente),
        firmen:              r(firmen),
        _dateRange:          { from, to },
      });
    } catch (e) {
      return json({ error: String(e) }, 500);
    }
  }

  return json({ error: 'Unknown action' }, 400);
});
