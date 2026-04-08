-- Run in Supabase SQL Editor (Dashboard → SQL).
-- Also create Storage bucket "listing-images" (public) if you use file uploads later.

-- ── PROFILES ──────────────────────────────────────────
create table public.profiles (
  id uuid references auth.users(id) on delete cascade primary key,
  display_name text,
  role text check (role in ('buyer','tenant','seller','agent','landlord')) default 'buyer',
  phone text,
  avatar_url text,
  created_at timestamptz default now()
);

alter table public.profiles enable row level security;

create policy "Public profiles are viewable by everyone"
  on public.profiles for select using (true);

create policy "Users can update own profile"
  on public.profiles for update using (auth.uid() = id);

create policy "Users can insert own profile"
  on public.profiles for insert with check (auth.uid() = id);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, display_name, role, phone)
  values (
    new.id,
    coalesce(
      new.raw_user_meta_data->>'display_name',
      new.raw_user_meta_data->>'full_name',
      split_part(coalesce(new.email, ''), '@', 1),
      'User'
    ),
    coalesce(new.raw_user_meta_data->>'role', 'buyer'),
    nullif(trim(new.raw_user_meta_data->>'phone'), '')
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ── LISTINGS ──────────────────────────────────────────
create table public.listings (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  title text not null,
  description text,
  category text not null,
  price numeric,
  currency text default 'HUF',
  condition text check (condition in ('new','used','other')) default 'used',
  location text,
  images text[] default '{}',
  category_fields jsonb default '{}'::jsonb,
  view_count int not null default 0,
  is_featured boolean default false,
  is_active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.listings enable row level security;

create policy "Active listings are publicly readable"
  on public.listings for select using (is_active = true);

create policy "Users can insert own listings"
  on public.listings for insert with check (auth.uid() = user_id);

create policy "Users can update own listings"
  on public.listings for update using (auth.uid() = user_id);

create policy "Users can delete own listings"
  on public.listings for delete using (auth.uid() = user_id);

create or replace function public.handle_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger on_listing_updated
  before update on public.listings
  for each row execute function public.handle_updated_at();
