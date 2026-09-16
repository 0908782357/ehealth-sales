const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY') ?? '';
const FROM = 'Anfragecenter <anfragecenter@ehealth-sales.de>';

const cors = {
  'Access-Control-Allow-Origin': 'https://ehealth-sales.de',
  'Access-Control-Allow-Headers': 'authorization, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: cors });
  }

  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), {
      status: 405, headers: { ...cors, 'Content-Type': 'application/json' },
    });
  }

  const data = await req.json().catch(() => null);
  if (!data?.to || !data?.subject || !data?.html) {
    return new Response(JSON.stringify({ error: 'Missing required fields' }), {
      status: 400, headers: { ...cors, 'Content-Type': 'application/json' },
    });
  }

  const res = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${RESEND_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      from: FROM,
      to: Array.isArray(data.to) ? data.to : [data.to],
      subject: data.subject,
      html: data.html,
    }),
  });

  const body = await res.text();
  return new Response(body, {
    status: res.status,
    headers: { ...cors, 'Content-Type': 'application/json' },
  });
});
