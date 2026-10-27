-- M6: in-app notifications (live via Realtime), daily loan reminders,
-- reporting users and thumbs up/down after a returned loan.

-- ---------------------------------------------------------------------------
-- Notifications. The payload holds ids and parameters, never translated text:
-- the app renders the message in the reader's language.
-- ---------------------------------------------------------------------------
create table public.notifications (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.profiles (id) on delete cascade,
  type       text not null,
  payload    jsonb not null default '{}',
  -- Set for scheduled reminders so the same reminder is never sent twice.
  dedupe_key text,
  read_at    timestamptz,
  created_at timestamptz not null default clock_timestamp()
);
create index notifications_user_idx on public.notifications (user_id, created_at desc);
create unique index notifications_dedupe_idx on public.notifications (user_id, dedupe_key)
  where dedupe_key is not null;

alter table public.notifications enable row level security;
create policy "users read own notifications" on public.notifications
  for select to authenticated using ((select auth.uid()) = user_id);
revoke all on public.notifications from anon, authenticated;
grant select on public.notifications to authenticated;

-- Realtime delivers new rows to the app as they are inserted (RLS applies).
alter publication supabase_realtime add table public.notifications;

create or replace function public.notify(p_user uuid, p_type text, p_payload jsonb)
returns void language sql security definer set search_path = '' as $$
  insert into public.notifications (user_id, type, payload) values (p_user, p_type, p_payload)
$$;

-- Mark some (or, with null, all) of my notifications as read.
create or replace function public.mark_notifications_read(ids uuid[] default null)
returns void language sql security definer set search_path = '' as $$
  update public.notifications set read_at = now()
  where user_id = auth.uid() and read_at is null and (ids is null or id = any (ids))
$$;

-- ---------------------------------------------------------------------------
-- Loan events notify the other person (both, for automatic events).
-- ---------------------------------------------------------------------------
create or replace function public.notify_loan_event()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  l public.loans;
  b public.books;
  actor_name text;
  recipient uuid;
  extra jsonb := '{}';
begin
  -- 'started' always follows a handover confirmation, which already says so.
  if new.type = 'started' then return null; end if;

  select * into l from public.loans where id = new.loan_id;
  select * into b from public.books where id = l.book_id;
  select display_name into actor_name from public.profiles where id = new.actor_id;

  foreach recipient in array array[l.owner_id, l.borrower_id] loop
    continue when recipient = new.actor_id;
    extra := '{}';
    if new.type = 'handover_confirmed' then
      -- The recipient confirmed earlier, so this confirmation starts the loan.
      extra := jsonb_build_object('started',
        case when recipient = l.owner_id then l.owner_handover_confirmed
             else l.borrower_handover_confirmed end);
    end if;
    perform public.notify(recipient, 'loan_' || new.type,
      jsonb_build_object(
        'loan_id', l.id, 'title', b.title,
        'person_id', new.actor_id, 'name', actor_name,
        'role', case when recipient = l.owner_id then 'owner' else 'borrower' end)
      || new.payload || extra);
  end loop;
  return null;
end $$;
create trigger loan_events_notify after insert on public.loan_events
  for each row execute function public.notify_loan_event();

-- ---------------------------------------------------------------------------
-- Friend requests.
-- ---------------------------------------------------------------------------
create or replace function public.notify_friendship()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  sender uuid;
  recipient uuid;
  kind text;
begin
  if tg_op = 'DELETE' then
    -- A withdrawn or declined request should not linger as unread.
    if old.status = 'pending' then
      delete from public.notifications
      where user_id = old.addressee_id and type = 'friend_request' and read_at is null
        and payload ->> 'person_id' = old.requester_id::text;
    end if;
    return null;
  end if;

  if tg_op = 'INSERT' and new.status = 'pending' then
    sender := new.requester_id; recipient := new.addressee_id; kind := 'friend_request';
  elsif tg_op = 'UPDATE' and old.status = 'pending' and new.status = 'accepted' then
    sender := new.addressee_id; recipient := new.requester_id; kind := 'friend_accepted';
  else
    return null;
  end if;
  perform public.notify(recipient, kind, jsonb_build_object(
    'person_id', sender,
    'name', (select display_name from public.profiles where id = sender)));
  return null;
end $$;
create trigger friendships_notify after insert or update or delete on public.friendships
  for each row execute function public.notify_friendship();

-- ---------------------------------------------------------------------------
-- Daily reminders: due within 2 days (borrower) and overdue (both). Each is
-- sent once per due date, so an extension earns a fresh reminder.
-- ---------------------------------------------------------------------------
create or replace function public.send_loan_reminders()
returns integer language plpgsql security definer set search_path = '' as $$
declare sent integer;
begin
  with due as (
    select l.*, b.title,
           case when now() > l.due_at then 'overdue' else 'due_soon' end as kind
    from public.loans l join public.books b on b.id = l.book_id
    where l.status = 'active' and l.due_at <= now() + interval '2 days'),
  targets as (
    select d.*, d.borrower_id as recipient, d.owner_id as other, 'borrower' as role from due d
    union all
    select d.*, d.owner_id, d.borrower_id, 'owner' from due d where d.kind = 'overdue')
  insert into public.notifications (user_id, type, payload, dedupe_key)
  select t.recipient, 'loan_' || t.kind,
         jsonb_build_object('loan_id', t.id, 'title', t.title, 'role', t.role,
                            'person_id', t.other, 'name', p.display_name, 'due_at', t.due_at),
         t.kind || ':' || t.id || ':' || (t.due_at at time zone 'utc')::date
  from targets t join public.profiles p on p.id = t.other
  on conflict (user_id, dedupe_key) where dedupe_key is not null do nothing;
  get diagnostics sent = row_count;

  -- Keep the table small: read notifications go after 90 days.
  delete from public.notifications where read_at < now() - interval '90 days';
  return sent;
end $$;

select cron.schedule('loan-reminders', '0 7 * * *', 'select public.send_loan_reminders()');

-- ---------------------------------------------------------------------------
-- Reports, kept for manual review. Nobody can read them through the API.
-- ---------------------------------------------------------------------------
create table public.reports (
  id          uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles (id) on delete cascade,
  reported_id uuid not null references public.profiles (id) on delete cascade,
  loan_id     uuid references public.loans (id) on delete set null,
  reason      text not null check (reason in
                ('not_returned', 'damaged', 'no_show', 'inappropriate', 'spam', 'other')),
  details     text check (char_length(details) <= 1000),
  status      text not null default 'open' check (status in ('open', 'reviewed', 'dismissed')),
  created_at  timestamptz not null default now(),
  check (reporter_id <> reported_id)
);
-- One open report per person and reason; repeats just refresh the details.
create unique index reports_open_idx on public.reports (reporter_id, reported_id, reason)
  where status = 'open';
alter table public.reports enable row level security;
revoke all on public.reports from anon, authenticated;

create or replace function public.report_user(
  target uuid, reason text, details text default null, loan uuid default null)
returns void language plpgsql security definer set search_path = '' as $$
#variable_conflict use_column
declare me uuid := auth.uid();
begin
  if me is null or target is null or target = me
     or not exists (select 1 from public.profiles where id = target) then
    raise exception 'user not found' using errcode = 'P0002';
  end if;
  if loan is not null and not exists (
      select 1 from public.loans l where l.id = loan
        and ((l.owner_id = me and l.borrower_id = target)
          or (l.owner_id = target and l.borrower_id = me))) then
    raise exception 'loan not found' using errcode = 'P0002';
  end if;
  insert into public.reports (reporter_id, reported_id, loan_id, reason, details)
  values (me, target, loan, report_user.reason, nullif(btrim(report_user.details), ''))
  on conflict (reporter_id, reported_id, reason) where status = 'open'
  do update set details = coalesce(excluded.details, reports.details),
                loan_id = coalesce(excluded.loan_id, reports.loan_id);
end $$;

-- ---------------------------------------------------------------------------
-- Thumbs up/down after a returned loan, once per side.
-- ---------------------------------------------------------------------------
alter table public.loans
  add column owner_feedback    text check (owner_feedback in ('up', 'down')),
  add column borrower_feedback text check (borrower_feedback in ('up', 'down'));

create or replace function public.leave_loan_feedback(loan uuid, up boolean)
returns void language plpgsql security definer set search_path = '' as $$
declare
  l public.loans;
  other uuid;
  vote text := case when up then 'up' else 'down' end;
begin
  l := public.lock_loan(loan, 'any', array['returned']::public.loan_status[]);
  if up is null then raise exception 'choose up or down' using errcode = '22023'; end if;
  if auth.uid() = l.owner_id then
    if l.owner_feedback is not null then
      raise exception 'feedback already given' using errcode = '55000';
    end if;
    update public.loans set owner_feedback = vote where id = loan;
    other := l.borrower_id;
  else
    if l.borrower_feedback is not null then
      raise exception 'feedback already given' using errcode = '55000';
    end if;
    update public.loans set borrower_feedback = vote where id = loan;
    other := l.owner_id;
  end if;
  update public.profiles set
    thumbs_up = thumbs_up + (case when up then 1 else 0 end),
    thumbs_down = thumbs_down + (case when up then 0 else 1 end)
  where id = other;
end $$;

-- my_loans now also says whether I already gave feedback.
drop function public.my_loans(uuid);
create function public.my_loans(only_loan uuid default null)
returns table (
  id uuid, role text, status public.loan_status, overdue boolean,
  book_id uuid, title text, authors text[], cover_url text, page_count integer,
  other_id uuid, other_name text, other_username text,
  message text, decline_reason text, duration_days integer, duration_source text,
  suggested_days integer, my_handover_confirmed boolean, their_handover_confirmed boolean,
  handover_at timestamptz, due_at timestamptz, returned_at timestamptz,
  extension_days_requested integer, extension_status text, extensions_used integer,
  created_at timestamptz, updated_at timestamptz, my_feedback text)
language sql stable security definer set search_path = '' as $$
  select l.id,
         case when l.owner_id = auth.uid() then 'owner' else 'borrower' end,
         l.status, l.status = 'active' and now() > l.due_at,
         b.id, b.title, b.authors, b.cover_url, b.page_count,
         p.id, p.display_name, p.username,
         l.message, l.decline_reason, l.duration_days, l.duration_source, l.suggested_days,
         case when l.owner_id = auth.uid() then l.owner_handover_confirmed else l.borrower_handover_confirmed end,
         case when l.owner_id = auth.uid() then l.borrower_handover_confirmed else l.owner_handover_confirmed end,
         l.handover_at, l.due_at, l.returned_at,
         l.extension_days_requested, l.extension_status, l.extensions_used,
         l.created_at, l.updated_at,
         case when l.owner_id = auth.uid() then l.owner_feedback else l.borrower_feedback end
  from public.loans l
  join public.books b on b.id = l.book_id
  join public.profiles p
    on p.id = case when l.owner_id = auth.uid() then l.borrower_id else l.owner_id end
  where auth.uid() in (l.owner_id, l.borrower_id)
    and (only_loan is null or l.id = only_loan)
  order by l.updated_at desc
$$;

-- ---------------------------------------------------------------------------
-- Privileges
-- ---------------------------------------------------------------------------
do $$
declare fn text;
begin
  foreach fn in array array['notify(uuid,text,jsonb)', 'notify_loan_event()',
                            'notify_friendship()', 'send_loan_reminders()']
  loop
    execute format('revoke execute on function public.%s from public, anon, authenticated', fn);
  end loop;
  foreach fn in array array['mark_notifications_read(uuid[])', 'report_user(uuid,text,text,uuid)',
                            'leave_loan_feedback(uuid,boolean)', 'my_loans(uuid)']
  loop
    execute format('revoke execute on function public.%s from public, anon', fn);
    execute format('grant execute on function public.%s to authenticated', fn);
  end loop;
end $$;
