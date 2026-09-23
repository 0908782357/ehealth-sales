// Deploy: supabase functions deploy admin-set-password
// SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY are injected automatically.

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

  // Caller-Check: nur Admins dürfen diese Funktion aufrufen
  const callerClient = createClient(SUPABASE_URL, ANON_KEY, {
    global: { headers: { Authorization: authHeader } },
  });
  const { data: { user }, error: userErr } = await callerClient.auth.getUser();
  if (userErr || !user) return json({ error: 'Unauthorized' }, 401);

  const { data: roleRow } = await callerClient
    .from('user_roles')
    .select('role')
    .eq('user_id', user.id)
    .maybeSingle();
  if (roleRow?.role !== 'admin') return json({ error: 'Forbidden' }, 403);

  // Body parsen
  const body = await req.json().catch(() => ({})) as { authUserId?: string; password?: string };
  const { authUserId, password } = body;
  if (!authUserId || !password || password.length < 8) {
    return json({ error: 'authUserId und password (min. 8 Zeichen) erforderlich' }, 400);
  }

  const adminClient = createClient(SUPABASE_URL, SERVICE_KEY);

  // Passwort setzen
  const { error: pwErr } = await adminClient.auth.admin.updateUserById(authUserId, { password });
  if (pwErr) return json({ error: pwErr.message }, 400);

  // force_password_change direkt via REST setzen (zuverlässiger als SDK-Wrapper)
  const metaRes = await fetch(`${SUPABASE_URL}/auth/v1/admin/users/${authUserId}`, {
    method: 'PUT',
    headers: {
      'apikey': SERVICE_KEY,
      'Authorization': `Bearer ${SERVICE_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ user_metadata: { force_password_change: true } }),
  });
  if (!metaRes.ok) {
    const metaErr = await metaRes.text();
    return json({ error: `Passwort gesetzt, Metadaten-Update fehlgeschlagen: ${metaErr}` }, 400);
  }

  // password_set in user_profiles zurücksetzen
  await adminClient
    .from('user_profiles')
    .update({ password_set: false, updated_at: new Date().toISOString() })
    .eq('user_id', authUserId);

  return json({ success: true });
});
