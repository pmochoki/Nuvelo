-- Nuvelo Vercel `/api/listings` persistence (Postgres via Supabase service role).
-- Apply with: Supabase CLI (`supabase db push`) or Dashboard → SQL Editor.
-- Distinct from legacy `public.listings` in ../schema.sql (different columns / RLS for direct client access).

create table if not exists public.nuvelo_listings (
  id uuid primary key default gen_random_uuid(),
  user_id text not null,
  category_id text not null,
  title text not null,
  description text not null default '',
  price numeric,
  currency text not null default 'HUF',
  condition text not null default 'other',
  location text not null default 'Hungary',
  images jsonb not null default '[]'::jsonb,
  category_fields jsonb not null default '{}'::jsonb,
  status text not null default 'pending'
    check (status in ('pending', 'approved', 'rejected', 'hidden')),
  featured boolean not null default false,
  view_count int not null default 0,
  moderation_note text,
  moderated_at timestamptz,
  moderated_by text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists nuvelo_listings_user_id_idx on public.nuvelo_listings (user_id);
create index if not exists nuvelo_listings_status_idx on public.nuvelo_listings (status);
create index if not exists nuvelo_listings_category_id_idx on public.nuvelo_listings (category_id);
create index if not exists nuvelo_listings_created_at_idx on public.nuvelo_listings (created_at desc);

comment on table public.nuvelo_listings is 'Marketplace listings for Nuvelo serverless API; accessed only with SUPABASE_SERVICE_ROLE_KEY.';

alter table public.nuvelo_listings enable row level security;

-- No GRANT to anon/authenticated: callers use the service role from Vercel (bypasses RLS).

create or replace function public.nuvelo_listings_set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists nuvelo_listings_set_updated_at on public.nuvelo_listings;
create trigger nuvelo_listings_set_updated_at
  before update on public.nuvelo_listings
  for each row execute function public.nuvelo_listings_set_updated_at();
