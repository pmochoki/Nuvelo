-- In-app notifications (see web/src/lib/notificationsApi.js)

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  message text not null,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists notifications_user_created on public.notifications (user_id, created_at desc);

alter table public.notifications enable row level security;

drop policy if exists "notifications_own_all" on public.notifications;
create policy "notifications_own_all"
  on public.notifications for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
