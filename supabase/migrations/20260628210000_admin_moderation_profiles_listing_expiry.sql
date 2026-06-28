-- Admin dashboard tables + profiles + nuvelo_listings expiry.
-- Safe to re-run (IF NOT EXISTS / IF NOT EXISTS columns).

-- ── PROFILES (required for user_flags / verification_requests FK) ──
create table if not exists public.profiles (
  id uuid references auth.users (id) on delete cascade primary key,
  display_name text,
  role text default 'buyer',
  phone text,
  avatar_url text,
  is_suspended boolean not null default false,
  suspension_reason text,
  suspended_until timestamptz,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

drop policy if exists "Public profiles are viewable by everyone" on public.profiles;
drop policy if exists "Users can update own profile" on public.profiles;
drop policy if exists "Users can insert own profile" on public.profiles;

create policy "Public profiles are viewable by everyone"
  on public.profiles for select using (true);

create policy "Users can update own profile"
  on public.profiles for update using (auth.uid() = id);

create policy "Users can insert own profile"
  on public.profiles for insert with check (auth.uid() = id);

-- Backfill profiles for existing auth users (admin FK targets)
insert into public.profiles (id, display_name, role, created_at)
select
  u.id,
  coalesce(
    u.raw_user_meta_data->>'display_name',
    u.raw_user_meta_data->>'full_name',
    nullif(split_part(coalesce(u.email, ''), '@', 1), ''),
    'User'
  ),
  coalesce(u.raw_user_meta_data->>'role', 'buyer'),
  coalesce(u.created_at, now())
from auth.users u
on conflict (id) do nothing;

-- ── LISTINGS (API table) + expiry ─────────────────────────────────
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
    check (status in ('pending', 'approved', 'rejected', 'hidden', 'expired')),
  featured boolean not null default false,
  view_count int not null default 0,
  moderation_note text,
  moderated_at timestamptz,
  moderated_by text,
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.nuvelo_listings
  add column if not exists expires_at timestamptz;

-- widen status check if table existed without expired
alter table public.nuvelo_listings drop constraint if exists nuvelo_listings_status_check;
alter table public.nuvelo_listings
  add constraint nuvelo_listings_status_check
  check (status in ('pending', 'approved', 'rejected', 'hidden', 'expired'));

create index if not exists nuvelo_listings_user_id_idx on public.nuvelo_listings (user_id);
create index if not exists nuvelo_listings_status_idx on public.nuvelo_listings (status);
create index if not exists nuvelo_listings_expires_at_idx on public.nuvelo_listings (expires_at);

alter table public.nuvelo_listings enable row level security;

-- ── Moderation reports ────────────────────────────────────────────
create table if not exists public.moderation_reports (
  id uuid primary key default gen_random_uuid(),
  reporter_user_id uuid references public.profiles (id) on delete set null,
  reporter_label text,
  target_type text not null check (target_type in ('listing', 'user')),
  target_id text not null,
  reason text not null default '',
  status text not null default 'open' check (status in ('open', 'in_review', 'resolved', 'dismissed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists moderation_reports_target_idx on public.moderation_reports (target_type, target_id);
create index if not exists moderation_reports_status_idx on public.moderation_reports (status);

-- ── Flagged users ────────────────────────────────────────────────
create table if not exists public.user_flags (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  flagged_by text,
  reason text not null default '',
  status text not null default 'open' check (status in ('open', 'reviewing', 'cleared', 'actioned')),
  created_at timestamptz not null default now()
);

create index if not exists user_flags_user_idx on public.user_flags (user_id);

-- ── Verification queue ───────────────────────────────────────────
create table if not exists public.verification_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  notes text not null default '',
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  created_at timestamptz not null default now()
);

create index if not exists verification_requests_user_idx on public.verification_requests (user_id);

-- ── Appeals ──────────────────────────────────────────────────────
create table if not exists public.moderation_appeals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles (id) on delete set null,
  subject text not null default '',
  body text not null default '',
  status text not null default 'open' check (status in ('open', 'in_review', 'accepted', 'rejected')),
  created_at timestamptz not null default now()
);

-- ── Boost / revenue ──────────────────────────────────────────────
create table if not exists public.boost_purchases (
  id uuid primary key default gen_random_uuid(),
  user_id text not null default '',
  listing_id text not null default '',
  amount_huf int not null default 0,
  status text not null default 'paid' check (status in ('paid', 'refunded', 'pending')),
  purchased_at timestamptz not null default now()
);

create index if not exists boost_purchases_date_idx on public.boost_purchases (purchased_at desc);

-- ── Payout requests ──────────────────────────────────────────────
create table if not exists public.payout_requests (
  id uuid primary key default gen_random_uuid(),
  user_id text not null default '',
  amount_huf int not null default 0,
  status text not null default 'pending' check (status in ('pending', 'processing', 'paid', 'rejected')),
  requested_at timestamptz not null default now()
);

-- ── Marketplace categories / locations (admin) ───────────────────
create table if not exists public.admin_marketplace_categories (
  slug text primary key,
  label text not null,
  sort_order int not null default 0,
  is_active boolean not null default true,
  updated_at timestamptz not null default now()
);

create table if not exists public.admin_marketplace_locations (
  id bigserial primary key,
  slug text not null unique,
  label text not null,
  region text not null default '',
  is_active boolean not null default true,
  updated_at timestamptz not null default now()
);

-- RLS + open policies for admin UI (anon key reads/writes — tighten for production)
alter table public.moderation_reports enable row level security;
alter table public.user_flags enable row level security;
alter table public.verification_requests enable row level security;
alter table public.moderation_appeals enable row level security;
alter table public.boost_purchases enable row level security;
alter table public.payout_requests enable row level security;
alter table public.admin_marketplace_categories enable row level security;
alter table public.admin_marketplace_locations enable row level security;

drop policy if exists "moderation_reports_all" on public.moderation_reports;
drop policy if exists "user_flags_all" on public.user_flags;
drop policy if exists "verification_requests_all" on public.verification_requests;
drop policy if exists "moderation_appeals_all" on public.moderation_appeals;
drop policy if exists "boost_purchases_all" on public.boost_purchases;
drop policy if exists "payout_requests_all" on public.payout_requests;
drop policy if exists "admin_marketplace_categories_all" on public.admin_marketplace_categories;
drop policy if exists "admin_marketplace_locations_all" on public.admin_marketplace_locations;

create policy "moderation_reports_all" on public.moderation_reports for all using (true) with check (true);
create policy "user_flags_all" on public.user_flags for all using (true) with check (true);
create policy "verification_requests_all" on public.verification_requests for all using (true) with check (true);
create policy "moderation_appeals_all" on public.moderation_appeals for all using (true) with check (true);
create policy "boost_purchases_all" on public.boost_purchases for all using (true) with check (true);
create policy "payout_requests_all" on public.payout_requests for all using (true) with check (true);
create policy "admin_marketplace_categories_all" on public.admin_marketplace_categories for all using (true) with check (true);
create policy "admin_marketplace_locations_all" on public.admin_marketplace_locations for all using (true) with check (true);

insert into public.admin_marketplace_categories (slug, label, sort_order)
values ('electronics', 'Electronics', 10), ('vehicles', 'Vehicles', 20), ('services', 'Services', 30)
on conflict (slug) do nothing;

insert into public.admin_marketplace_locations (slug, label, region)
values ('budapest', 'Budapest', 'Central Hungary'), ('debrecen', 'Debrecen', 'Eastern Hungary')
on conflict (slug) do nothing;

-- Default listing lifetime: 90 days from creation when approved (optional backfill)
update public.nuvelo_listings
set expires_at = created_at + interval '90 days'
where expires_at is null and status = 'approved';
