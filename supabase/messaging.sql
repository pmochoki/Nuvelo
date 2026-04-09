-- Nuvelo 1:1 messaging (per listing + buyer/seller pair). Run after schema.sql in Supabase SQL Editor.
-- After applying: Dashboard → Database → Replication → enable for `messages` if you want realtime inserts in the UI.

-- ── THREADS ───────────────────────────────────────────
create table if not exists public.message_threads (
  id uuid primary key default gen_random_uuid(),
  listing_id text not null,
  listing_owner_id uuid not null references auth.users (id) on delete cascade,
  participant_low uuid not null references auth.users (id) on delete cascade,
  participant_high uuid not null references auth.users (id) on delete cascade,
  listing_title_snapshot text,
  listing_thumb_url text,
  last_message_at timestamptz,
  last_message_preview text,
  last_message_from uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint message_threads_owner_is_participant check (
    listing_owner_id = participant_low or listing_owner_id = participant_high
  ),
  constraint message_threads_participant_order check (participant_low < participant_high),
  constraint message_threads_unique_listing_pair unique (listing_id, participant_low, participant_high)
);

create index if not exists message_threads_user_low on public.message_threads (participant_low);
create index if not exists message_threads_user_high on public.message_threads (participant_high);
create index if not exists message_threads_last_at on public.message_threads (last_message_at desc nulls last);

alter table public.message_threads enable row level security;

drop policy if exists "message_threads_select_participants" on public.message_threads;
create policy "message_threads_select_participants"
  on public.message_threads for select
  using (auth.uid() = participant_low or auth.uid() = participant_high);

drop policy if exists "message_threads_insert_valid" on public.message_threads;
create policy "message_threads_insert_valid"
  on public.message_threads for insert
  with check (
    auth.uid() in (participant_low, participant_high)
    and listing_owner_id in (participant_low, participant_high)
  );

drop policy if exists "message_threads_update_participants" on public.message_threads;
create policy "message_threads_update_participants"
  on public.message_threads for update
  using (auth.uid() = participant_low or auth.uid() = participant_high)
  with check (auth.uid() = participant_low or auth.uid() = participant_high);

-- ── MESSAGES ──────────────────────────────────────────
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  thread_id uuid not null references public.message_threads (id) on delete cascade,
  sender_id uuid not null references auth.users (id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now(),
  constraint messages_body_len check (char_length(body) <= 8000)
);

create index if not exists messages_thread_created on public.messages (thread_id, created_at);

alter table public.messages enable row level security;

drop policy if exists "messages_select_thread_members" on public.messages;
create policy "messages_select_thread_members"
  on public.messages for select
  using (
    exists (
      select 1 from public.message_threads t
      where t.id = thread_id
        and (auth.uid() = t.participant_low or auth.uid() = t.participant_high)
    )
  );

drop policy if exists "messages_insert_self_in_thread" on public.messages;
create policy "messages_insert_self_in_thread"
  on public.messages for insert
  with check (
    sender_id = auth.uid()
    and exists (
      select 1 from public.message_threads t
      where t.id = thread_id
        and (auth.uid() = t.participant_low or auth.uid() = t.participant_high)
    )
  );

-- Bump parent thread when a message is posted
create or replace function public.bump_message_thread_on_insert()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.message_threads
  set
    last_message_at = new.created_at,
    last_message_preview = left(new.body, 220),
    last_message_from = new.sender_id,
    updated_at = now()
  where id = new.thread_id;
  return new;
end;
$$;

drop trigger if exists on_message_insert_bump_thread on public.messages;
create trigger on_message_insert_bump_thread
  after insert on public.messages
  for each row execute function public.bump_message_thread_on_insert();

create or replace function public.message_threads_set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists on_message_threads_touch on public.message_threads;
create trigger on_message_threads_touch
  before update on public.message_threads
  for each row execute function public.message_threads_set_updated_at();
