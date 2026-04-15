-- Site-wide settings for Nuvelo admin dashboard (optional).
-- WARNING: Policies below allow anon read/write for the single config row — suitable only
-- for demos or if you replace with service-role-only writes in production.

create table if not exists public.site_config (
  id int primary key default 1 check (id = 1),
  site_name text not null default 'Nuvelo',
  site_url text not null default 'https://nuvelo.one',
  support_email text not null default 'support@nuvelo.one',
  maintenance_mode boolean not null default false,
  listings_require_approval boolean not null default true,
  max_photos_per_listing int not null default 8,
  max_active_listings_free int not null default 5,
  featured_price_huf int not null default 0,
  boost_7d_price_huf int not null default 0,
  boost_30d_price_huf int not null default 0,
  updated_at timestamptz not null default now()
);

alter table public.site_config enable row level security;

drop policy if exists "site_config_select" on public.site_config;
drop policy if exists "site_config_all" on public.site_config;

create policy "site_config_select" on public.site_config for select using (true);

-- Demo / admin SPA: tighten this in production (e.g. auth.role() = 'admin' only).
create policy "site_config_all" on public.site_config for all using (true) with check (true);
