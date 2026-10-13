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
  if (!res.ok) throw new Error(`${path} → ${res.status}`);
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
    // Check if full token or partial (needs 2FA)
    const needsTotp = data.isOnlyFirstFactorToken === true || !data.accessToken;
    return json({
      needsTotp,
      partialToken: data.accessToken ?? data.token ?? null,
      fullToken: needsTotp ? null : (data.accessToken ?? data.token),
    });
  }

  // ── LOGIN: step 2 (confirm with TOTP) ─────────────────────────────────────
  if (action === 'confirm') {
    if (!totp || !partialToken) return json({ error: 'totp and partialToken required' }, 400);
    const res = await fetch(`${INFINITY_BASE}/login/bestaetigen`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${partialToken}`,
      },
      body: JSON.stringify({ totp }),
    });
    const data = await res.json();
    if (!res.ok) return json({ error: data.message ?? 'TOTP confirmation failed', details: data }, res.status);
    return json({ token: data.accessToken ?? data.token ?? null });
  }

  // ── REALM DATA ────────────────────────────────────────────────────────────
  if (action === 'realm') {
    if (!infinityToken) return json({ error: 'infinityToken required' }, 400);
    try {
      // Fetch all data in parallel
      const [konnektoren, firmen, firmenProfil] = await Promise.allSettled([
        infinityGet('/konnektoren', infinityToken),
        infinityGet('/firmen', infinityToken),
        infinityGet('/firmen-profil', infinityToken),
      ]);

      // Try reseller-specific endpoints
      const [resellerKontingente, leistungserbringer] = await Promise.allSettled([
        infinityGet('/reseller-kontingente', infinityToken),
        infinityGet('/leistungserbringer', infinityToken),
      ]);

      return json({
        konnektoren:          konnektoren.status === 'fulfilled' ? konnektoren.value : null,
        firmen:               firmen.status === 'fulfilled' ? firmen.value : null,
        firmenProfil:         firmenProfil.status === 'fulfilled' ? firmenProfil.value : null,
        resellerKontingente:  resellerKontingente.status === 'fulfilled' ? resellerKontingente.value : null,
        leistungserbringer:   leistungserbringer.status === 'fulfilled' ? leistungserbringer.value : null,
      });
    } catch (e) {
      return json({ error: String(e) }, 500);
    }
  }

  return json({ error: 'Unknown action' }, 400);
});
