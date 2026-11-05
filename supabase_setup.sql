-- DEC (Daily English Calendar) Supabase schema
-- Supabase Dashboard > SQL Editor > New query 에서 전체 실행하세요.
-- 사용자별 행은 RLS로 본인만 접근할 수 있습니다.

create table if not exists public.dec_sentences (
  id uuid primary key default gen_random_uuid(),
  user_id text not null,
  date date not null,
  sentences jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now(),
  constraint dec_sentences_user_date_unique unique (user_id, date)
);

create table if not exists public.dec_date_links (
  id uuid primary key default gen_random_uuid(),
  user_id text not null,
  date date not null,
  links jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now(),
  constraint dec_date_links_user_date_unique unique (user_id, date)
);

alter table public.dec_sentences enable row level security;
alter table public.dec_date_links enable row level security;

drop policy if exists "DEC users manage own sentences" on public.dec_sentences;
create policy "DEC users manage own sentences"
on public.dec_sentences
for all
to authenticated
using (user_id = auth.uid()::text)
with check (user_id = auth.uid()::text);

drop policy if exists "DEC users manage own date links" on public.dec_date_links;
create policy "DEC users manage own date links"
on public.dec_date_links
for all
to authenticated
using (user_id = auth.uid()::text)
with check (user_id = auth.uid()::text);

-- 기존 버전에서 UNIQUE 제약 없이 테이블을 만든 경우에도 upsert가 동작하도록 보장합니다.
-- 같은 사용자/날짜에 중복 행이 있다면 가장 나중의 ctid 외 행을 정리합니다.
delete from public.dec_sentences a
using public.dec_sentences b
where a.user_id = b.user_id
  and a.date = b.date
  and a.ctid < b.ctid;

delete from public.dec_date_links a
using public.dec_date_links b
where a.user_id = b.user_id
  and a.date = b.date
  and a.ctid < b.ctid;

create unique index if not exists dec_sentences_user_date_uidx
on public.dec_sentences (user_id, date);

create unique index if not exists dec_date_links_user_date_uidx
on public.dec_date_links (user_id, date);

-- Realtime publication 등록 (이미 등록되어 있으면 건너뜁니다)
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'dec_sentences'
  ) then
    alter publication supabase_realtime add table public.dec_sentences;
  end if;

  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'dec_date_links'
  ) then
    alter publication supabase_realtime add table public.dec_date_links;
  end if;
end $$;
