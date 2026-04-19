-- Columns for web admin + mobile UX (rejection reasons, featured listings, account suspension).
-- Admin sets these; Flutter apps read via API/Supabase as wired.

alter table public.listings
  add column if not exists admin_note text,
  add column if not exists is_featured boolean not null default false;

alter table public.profiles
  add column if not exists is_suspended boolean not null default false,
  add column if not exists suspension_reason text,
  add column if not exists suspended_until timestamptz;

comment on column public.listings.admin_note is 'Reason shown to seller when listing is rejected/banned.';
comment on column public.listings.is_featured is 'Homepage/feature placement flag (admin).';
comment on column public.profiles.is_suspended is 'When true, mobile should restrict post/message per master rules.';
comment on column public.profiles.suspension_reason is 'Optional detail for admin; may surface in support flows.';
comment on column public.profiles.suspended_until is 'If set, suspension may auto-expire at this time (optional product logic).';
