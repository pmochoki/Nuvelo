-- Run in Supabase SQL Editor after the base schema exists.
-- Lets users with profiles.role = 'admin' read/update/delete any listing.

-- 1) Allow "admin" role on profiles
alter table public.profiles drop constraint if exists profiles_role_check;
alter table public.profiles add constraint profiles_role_check
  check (role in ('buyer','tenant','seller','agent','landlord','admin'));

-- 2) Admin policies on listings (OR with existing owner/public policies)
drop policy if exists "Admins read all listings" on public.listings;
create policy "Admins read all listings"
  on public.listings for select
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

drop policy if exists "Admins update any listing" on public.listings;
create policy "Admins update any listing"
  on public.listings for update
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  )
  with check (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

drop policy if exists "Admins delete any listing" on public.listings;
create policy "Admins delete any listing"
  on public.listings for delete
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- 3) Promote your user (replace with your auth user id from Authentication → Users)
-- update public.profiles set role = 'admin' where id = 'YOUR-USER-UUID';
