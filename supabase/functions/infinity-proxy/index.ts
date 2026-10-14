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

async function infinityGet(path: string, token: string) {
  const res = await fetch(`${INFINITY_BASE}${path}`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  if (!res.ok) {
    const body = await res.text().catch(() => '');
    throw new Error(`${res.status}: ${body.slice(0, 200)}`);
  }
  return res.json();
}

async function refreshAccessToken(refreshToken: string): Promise<{ accessToken: string; refreshToken: string } | null> {
  const params = new URLSearchParams();
  params.set('client_id', 'portal');
  params.set('grant_type', 'refresh_token');
  params.set('refresh_token', refreshToken);

  const res = await fetch(`${INFINITY_BASE}/oauth2/token`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: params.toString(),
  });

  if (!res.ok) return null;
  const data = await res.json();
  if (!data.access_token) return null;
  return { accessToken: data.access_token, refreshToken: data.refresh_token ?? refreshToken };
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response(null, { status: 204, headers: cors });
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405);

  let body: Record<string, string>;
  try { body = await req.json(); } catch { return json({ error: 'Invalid JSON' }, 400); }

  const { action, username, password, totp, infinityToken, infinityRefreshToken } = body;
  const partialToken        = body.partialToken        ?? '';
  const partialRefreshToken = body.partialRefreshToken ?? '';
  const sessionCookie       = body.sessionCookie       ?? '';

  // ── LOGIN: step 1 (username + password) ──────────────────────────────────
  if (action === 'login') {
    if (!username || !password) return json({ error: 'username and password required' }, 400);
    const res = await fetch(`${INFINITY_BASE}/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ username, password }),
    });
    // Capture any session cookies set by the login endpoint
    const setCookie = res.headers.get('set-cookie') ?? '';
    const data = await res.json();
    if (!res.ok) return json({ error: data.message ?? 'Login failed', details: data }, res.status);
    // API omits isOnlyFirstFactorToken when TOTP is required; only explicitly false = no TOTP
    const needsTotp = data.isOnlyFirstFactorToken !== false;
    return json({
      needsTotp,
      partialToken:        data.accessToken ?? data.token ?? null,
      partialRefreshToken: data.refreshToken ?? null,
      partialCookie:       setCookie || null,
      fullToken:           needsTotp ? null : (data.accessToken ?? data.token),
      fullRefreshToken:    needsTotp ? null : data.refreshToken,
      _debug: { isOnlyFirstFactorToken: data.isOnlyFirstFactorToken, keys: Object.keys(data), hasCookie: !!setCookie },
    });
  }

  // ── LOGIN: step 2 (confirm with TOTP) ─────────────────────────────────────
  if (action === 'confirm') {
    if (!totp || !partialToken) return json({ error: 'totp and partialToken required' }, 400);
    const confirmHeaders: Record<string, string> = {
      'Content-Type': 'application/json',
      'Accept': 'application/json, text/plain, */*',
      'Origin': 'https://portal.managed-infinity.de',
      'Referer': 'https://portal.managed-infinity.de/',
      Authorization: `Bearer ${partialToken}`,
    };
    if (sessionCookie) confirmHeaders['Cookie'] = sessionCookie;
    const res = await fetch(`${INFINITY_BASE}/login/bestaetigen`, {
      method: 'POST',
      headers: confirmHeaders,
      body: JSON.stringify({ totp }),
    });
    const rawText = await res.text();
    let data: Record<string, unknown> = {};
    try { data = JSON.parse(rawText); } catch { data = { raw: rawText }; }
    if (!res.ok) return json({ error: data.message ?? `TOTP ${res.status}`, details: data, sentBody: { totp, hasCookie: !!sessionCookie }, tokenPreview: partialToken ? (partialToken.substring(0, 20) + '...') : 'EMPTY' }, res.status);
    // Capture cookies from confirmation response too
    const confirmCookie = res.headers.get('set-cookie') ?? '';
    return json({
      token:        (data.accessToken ?? data.token) as string ?? null,
      refreshToken: data.refreshToken as string ?? null,
      sessionCookie: confirmCookie || null,
    });
  }

  // ── REALM DATA ────────────────────────────────────────────────────────────
  if (action === 'realm') {
    if (!infinityToken) return json({ error: 'infinityToken required' }, 400);

    let token        = infinityToken;
    let newRefreshToken: string | null = null;

    // Try to get data; if 401, refresh the access token once
    const tryRealm = async (t: string) => {
      const to   = new Date().toISOString().slice(0, 10);
      const from = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().slice(0, 10);

      const results = await Promise.allSettled([
        infinityGet('/benutzer-profil', t),
        infinityGet('/leistungserbringer', t),
        infinityGet(`/berichte/reseller?subjectType=KONNEKTOR&from=${from}&to=${to}`, t),
        infinityGet(`/berichte/reseller?subjectType=VPN&from=${from}&to=${to}`, t),
        infinityGet('/reseller-kontingente', t),
        infinityGet('/firmen', t),
      ]);

      const [profil, leistungserbringer, berichtKonnektor, berichtVpn, resellerKontingente, firmen] = results;
      const r = (p: PromiseSettledResult<unknown>) =>
        p.status === 'fulfilled' ? { data: p.value } : { error: (p as PromiseRejectedResult).reason?.message };

      return { profil, leistungserbringer, berichtKonnektor, berichtVpn, resellerKontingente, firmen, dateRange: { from, to } };
    };

    // If profil returns 401 and we have a refresh token, refresh first
    const firstTry = await (async () => {
      try {
        const to   = new Date().toISOString().slice(0, 10);
        const from = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().slice(0, 10);

        if (infinityRefreshToken) {
          // Preemptively check if token is near expiry by trying the profile endpoint
          const profilRes = await fetch(`${INFINITY_BASE}/benutzer-profil`, {
            headers: { Authorization: `Bearer ${token}` },
          });
          if (profilRes.status === 401) {
            // Token expired — refresh it
            const refreshed = await refreshAccessToken(infinityRefreshToken);
            if (refreshed) {
              token = refreshed.accessToken;
              newRefreshToken = refreshed.refreshToken;
            }
          }
        }

        const results = await Promise.allSettled([
          infinityGet('/benutzer-profil', token),
          infinityGet('/leistungserbringer', token),
          infinityGet(`/berichte/reseller?subjectType=KONNEKTOR&from=${from}&to=${to}`, token),
          infinityGet(`/berichte/reseller?subjectType=VPN&from=${from}&to=${to}`, token),
          infinityGet('/reseller-kontingente', token),
          infinityGet('/firmen', token),
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
          _newToken:           newRefreshToken ? token : null,
          _newRefreshToken:    newRefreshToken,
        });
      } catch (e) {
        return json({ error: String(e) }, 500);
      }
    })();

    return firstTry;
  }

  // ── REFRESH TOKEN ─────────────────────────────────────────────────────────
  if (action === 'refresh') {
    const rt = body.refreshToken;
    if (!rt) return json({ error: 'refreshToken required' }, 400);
    const refreshed = await refreshAccessToken(rt);
    if (!refreshed) return json({ error: 'Token refresh failed' }, 401);
    return json({ token: refreshed.accessToken, refreshToken: refreshed.refreshToken });
  }

  return json({ error: 'Unknown action' }, 400);
});
