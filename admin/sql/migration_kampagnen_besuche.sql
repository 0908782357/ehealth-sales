-- Kampagnen-Report: anonyme Zählung für Kampagnen-Landingpages (z. B. computer-konkret.html / ivoris)
-- Keine IP, kein User-Agent, keine Cookies. Ausgeführt in Supabase am 2026-11-06.
create table if not exists public.kampagnen_besuche (
  id         bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  kampagne   text not null check (kampagne ~ '^[a-z0-9-]{1,30}$'),
  kanal      text not null check (kanal ~ '^[a-z0-9-]{1,20}$'),
  ereignis   text not null check (ereignis in ('besuch','finder_start'))
);
create index if not exists kampagnen_besuche_kampagne_idx on public.kampagnen_besuche (kampagne, created_at);

alter table public.kampagnen_besuche enable row level security;

create policy "Kampagnen-Zählung eintragen" on public.kampagnen_besuche
  for insert to anon, authenticated with check (true);

create policy "Admin: liest Kampagnen-Zählung" on public.kampagnen_besuche
  for select to authenticated using (
    exists (select 1 from public.user_roles where user_roles.user_id = auth.uid() and user_roles.role = 'admin')
  );

grant insert on public.kampagnen_besuche to anon, authenticated;
grant select on public.kampagnen_besuche to authenticated;
