-- Per-user category interest weights for personalized trending (cross-device).

create table if not exists public.user_category_interests (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  weights jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

comment on table public.user_category_interests is
  'Private browse/view signals for homepage trending personalization.';
comment on column public.user_category_interests.weights is
  'Map of listing category id → weight (e.g. {"rentals": 12, "vehicles": 6}).';

alter table public.user_category_interests enable row level security;

drop policy if exists "Users read own category interests" on public.user_category_interests;
drop policy if exists "Users insert own category interests" on public.user_category_interests;
drop policy if exists "Users update own category interests" on public.user_category_interests;

create policy "Users read own category interests"
  on public.user_category_interests for select
  using (auth.uid() = user_id);

create policy "Users insert own category interests"
  on public.user_category_interests for insert
  with check (auth.uid() = user_id);

create policy "Users update own category interests"
  on public.user_category_interests for update
  using (auth.uid() = user_id);
