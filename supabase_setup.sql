-- CODE ADVENTURE - CONFIGURACION SEGURA DE RECORD GLOBAL
-- Ejecuta este archivo UNA SOLA VEZ en Supabase > SQL Editor.
-- Crea SOLO una tabla nueva. No modifica, elimina ni renombra otras tablas del proyecto.

create table if not exists public.code_adventure_global_records_v1 (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  player_name text not null check (char_length(player_name) between 2 and 60),
  course text not null check (char_length(course) between 1 and 30),
  mode text not null check (mode in ('adventure','single')),
  score integer not null check (score between 0 and 100000),
  errors integer not null default 0 check (errors between 0 and 10000),
  grade text not null check (char_length(grade) between 1 and 40),
  completed integer not null default 0 check (completed between 0 and 10),
  route jsonb not null default '[]'::jsonb,
  constraint code_adventure_route_is_array check (jsonb_typeof(route) = 'array')
);

comment on table public.code_adventure_global_records_v1 is
'Record global independiente de Code Adventure. No pertenece a otras aplicaciones del proyecto.';

-- Seguridad: el navegador usa el rol anon a traves de la publishable key.
alter table public.code_adventure_global_records_v1 enable row level security;

-- Quitamos privilegios peligrosos SOLO de esta tabla.
revoke all on table public.code_adventure_global_records_v1 from anon;
grant select, insert on table public.code_adventure_global_records_v1 to anon;

-- Si el SQL se ejecuta otra vez, solo rehace las politicas de ESTA tabla.
drop policy if exists "code_adventure_public_read_v1" on public.code_adventure_global_records_v1;
drop policy if exists "code_adventure_public_insert_v1" on public.code_adventure_global_records_v1;

create policy "code_adventure_public_read_v1"
on public.code_adventure_global_records_v1
for select
to anon
using (true);

create policy "code_adventure_public_insert_v1"
on public.code_adventure_global_records_v1
for insert
to anon
with check (
  char_length(player_name) between 2 and 60
  and char_length(course) between 1 and 30
  and mode in ('adventure','single')
  and score between 0 and 100000
  and errors between 0 and 10000
  and char_length(grade) between 1 and 40
  and completed between 0 and 10
  and jsonb_typeof(route) = 'array'
);

-- NO se concede UPDATE ni DELETE al rol anon.
-- Por tanto, estudiantes/navegadores no pueden editar o borrar registros por la API publica.
