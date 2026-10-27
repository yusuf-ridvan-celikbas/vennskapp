-- M4: lending. request -> accepted -> active (handed over) -> returned,
-- with side exits declined / cancelled. Overdue is derived, never stored.
-- Every transition goes through an RPC that checks who is acting and the
-- current state; clients cannot write loans directly.

create type public.loan_status as enum
  ('requested', 'accepted', 'active', 'returned', 'declined', 'cancelled');

create table public.loans (
  id                          uuid primary key default gen_random_uuid(),
  -- Kept (as null) if the owner later removes the book, so history survives.
  library_item_id             uuid references public.library_items (id) on delete set null,
  book_id                     uuid not null references public.books (id),
  owner_id                    uuid not null references public.profiles (id) on delete cascade,
  borrower_id                 uuid not null references public.profiles (id) on delete cascade,
  status                      public.loan_status not null default 'requested',
  message                     text check (char_length(message) <= 300),
  decline_reason              text check (char_length(decline_reason) <= 200),
  duration_days               integer check (duration_days between 3 and 90),
  duration_source             text check (duration_source in ('auto', 'manual')),
  suggested_days              integer,
  owner_handover_confirmed    boolean not null default false,
  borrower_handover_confirmed boolean not null default false,
  accepted_at                 timestamptz,
  handover_at                 timestamptz,
  due_at                      timestamptz,
  returned_at                 timestamptz,
  extension_days_requested    integer check (extension_days_requested between 1 and 30),
  extension_status            text check (extension_status in ('pending', 'accepted', 'declined')),
  extensions_used             integer not null default 0,
  created_at                  timestamptz not null default now(),
  updated_at                  timestamptz not null default now(),
  check (owner_id <> borrower_id)
);
-- A copy can be promised to / held by only one borrower at a time...
create unique index loans_one_holder_idx on public.loans (library_item_id)
  where status in ('accepted', 'active');
-- ...and a borrower has at most one open request per copy.
create unique index loans_one_request_idx on public.loans (library_item_id, borrower_id)
  where status in ('requested', 'accepted', 'active');
create index loans_owner_idx on public.loans (owner_id);
create index loans_borrower_idx on public.loans (borrower_id);

create trigger loans_touch before update on public.loans
  for each row execute function public.touch_updated_at();

create table public.loan_events (
  id         uuid primary key default gen_random_uuid(),
  loan_id    uuid not null references public.loans (id) on delete cascade,
  actor_id   uuid references public.profiles (id) on delete set null,
  type       text not null,
  payload    jsonb not null default '{}',
  -- clock_timestamp so steps inside one transaction still sort correctly.
  created_at timestamptz not null default clock_timestamp()
);
create index loan_events_loan_idx on public.loan_events (loan_id, created_at);

-- A book that is promised or lent out cannot be removed from the shelf.
create or replace function public.prevent_delete_lent_item()
returns trigger language plpgsql as $$
begin
  if exists (select 1 from public.loans
             where library_item_id = old.id and status in ('accepted', 'active')) then
    raise exception 'book is lent out' using errcode = '55000';
  end if;
  -- Open requests for it simply end.
  update public.loans set status = 'cancelled'
  where library_item_id = old.id and status = 'requested';
  return old;
end $$;
create trigger library_items_no_delete_when_lent before delete on public.library_items
  for each row execute function public.prevent_delete_lent_item();

-- ---------------------------------------------------------------------------
-- Internal helpers
-- ---------------------------------------------------------------------------
create or replace function public.log_loan_event(p_loan uuid, p_type text, p_payload jsonb default '{}')
returns void language sql security definer set search_path = '' as $$
  insert into public.loan_events (loan_id, actor_id, type, payload)
  values (p_loan, auth.uid(), p_type, p_payload)
$$;

-- Load a loan for update and check the caller's role and its state.
create or replace function public.lock_loan(
  p_loan uuid, p_role text, p_states public.loan_status[])
returns public.loans
language plpgsql security definer set search_path = '' as $$
declare l public.loans;
begin
  select * into l from public.loans where id = p_loan for update;
  if l.id is null or auth.uid() not in (l.owner_id, l.borrower_id) then
    raise exception 'loan not found' using errcode = 'P0002';
  end if;
  if (p_role = 'owner' and auth.uid() <> l.owner_id)
     or (p_role = 'borrower' and auth.uid() <> l.borrower_id) then
    raise exception 'not allowed for your role' using errcode = '42501';
  end if;
  if not (l.status = any (p_states)) then
    raise exception 'loan is %', l.status using errcode = '55000';
  end if;
  return l;
end $$;

-- ---------------------------------------------------------------------------
-- Transitions
-- ---------------------------------------------------------------------------
create or replace function public.request_loan(item uuid, note text default null)
returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  i  public.library_items;
  v_id uuid;
begin
  if me is null then raise exception 'not signed in' using errcode = '42501'; end if;
  select * into i from public.library_items where id = item;
  if i.id is null or not public.can_see_item(me, i.owner_id, i.visibility) then
    raise exception 'book not found' using errcode = 'P0002';
  end if;
  if i.owner_id = me then raise exception 'this is your own book' using errcode = '22023'; end if;
  if not (i.lendable and i.owned) then
    raise exception 'not lendable' using errcode = '55000';
  end if;
  if exists (select 1 from public.loans where library_item_id = item and status in ('accepted', 'active')) then
    raise exception 'already lent out' using errcode = '55000';
  end if;
  if exists (select 1 from public.loans
             where library_item_id = item and borrower_id = me and status = 'requested') then
    raise exception 'already requested' using errcode = '55000';
  end if;

  insert into public.loans (library_item_id, book_id, owner_id, borrower_id, message)
  values (item, i.book_id, i.owner_id, me, nullif(btrim(note), ''))
  returning id into v_id;
  perform public.log_loan_event(v_id, 'requested');
  return v_id;
end $$;

create or replace function public.respond_loan(
  loan uuid, accept boolean, days integer default null, reason text default null)
returns void
language plpgsql security definer set search_path = '' as $$
declare l public.loans;
begin
  l := public.lock_loan(loan, 'owner', array['requested']::public.loan_status[]);
  if not accept then
    update public.loans set status = 'declined', decline_reason = nullif(btrim(reason), '')
    where id = loan;
    perform public.log_loan_event(loan, 'declined');
    return;
  end if;

  if days is null or days not between 3 and 90 then
    raise exception 'loan length must be 3-90 days' using errcode = '22023';
  end if;
  if exists (select 1 from public.loans
             where library_item_id = l.library_item_id and status in ('accepted', 'active')) then
    raise exception 'already lent out' using errcode = '55000';
  end if;
  update public.loans set
    status = 'accepted', accepted_at = now(), duration_days = days,
    duration_source = case when days = l.suggested_days then 'auto' else 'manual' end
  where id = loan;
  perform public.log_loan_event(loan, 'accepted', jsonb_build_object('days', days));

  -- Other people waiting for this copy are told it went to someone else.
  with others as (
    update public.loans set status = 'declined', decline_reason = null
    where library_item_id = l.library_item_id and status = 'requested' and id <> loan
    returning id)
  insert into public.loan_events (loan_id, actor_id, type, payload)
  select id, auth.uid(), 'declined', '{"reason":"lent_to_someone_else"}' from others;
end $$;

-- Borrower withdraws a request, or either side calls off before handover.
create or replace function public.cancel_loan(loan uuid)
returns void
language plpgsql security definer set search_path = '' as $$
declare l public.loans;
begin
  l := public.lock_loan(loan, 'any', array['requested', 'accepted']::public.loan_status[]);
  if l.status = 'requested' and auth.uid() <> l.borrower_id then
    raise exception 'owner declines instead of cancelling' using errcode = '42501';
  end if;
  update public.loans set status = 'cancelled' where id = loan;
  perform public.log_loan_event(loan, 'cancelled');
end $$;

-- Both people tap "we met"; the loan starts when the second one does.
create or replace function public.confirm_handover(loan uuid)
returns public.loan_status
language plpgsql security definer set search_path = '' as $$
declare l public.loans;
begin
  l := public.lock_loan(loan, 'any', array['accepted']::public.loan_status[]);
  if auth.uid() = l.owner_id then
    l.owner_handover_confirmed := true;
  else
    l.borrower_handover_confirmed := true;
  end if;
  perform public.log_loan_event(loan, 'handover_confirmed');

  if l.owner_handover_confirmed and l.borrower_handover_confirmed then
    update public.loans set
      owner_handover_confirmed = true, borrower_handover_confirmed = true,
      status = 'active', handover_at = now(),
      due_at = now() + make_interval(days => l.duration_days)
    where id = loan;
    perform public.log_loan_event(loan, 'started');
    return 'active';
  end if;
  update public.loans set
    owner_handover_confirmed = l.owner_handover_confirmed,
    borrower_handover_confirmed = l.borrower_handover_confirmed
  where id = loan;
  return 'accepted';
end $$;

-- One extension per loan.
create or replace function public.request_extension(loan uuid, days integer)
returns void
language plpgsql security definer set search_path = '' as $$
declare l public.loans;
begin
  l := public.lock_loan(loan, 'borrower', array['active']::public.loan_status[]);
  if days is null or days not between 1 and 30 then
    raise exception 'extension must be 1-30 days' using errcode = '22023';
  end if;
  if l.extensions_used > 0 or l.extension_status = 'pending' then
    raise exception 'extension already used' using errcode = '55000';
  end if;
  update public.loans set extension_days_requested = days, extension_status = 'pending'
  where id = loan;
  perform public.log_loan_event(loan, 'extension_requested', jsonb_build_object('days', days));
end $$;

create or replace function public.respond_extension(loan uuid, accept boolean)
returns void
language plpgsql security definer set search_path = '' as $$
declare l public.loans;
begin
  l := public.lock_loan(loan, 'owner', array['active']::public.loan_status[]);
  if l.extension_status is distinct from 'pending' then
    raise exception 'no extension requested' using errcode = '55000';
  end if;
  if accept then
    update public.loans set
      extension_status = 'accepted', extensions_used = extensions_used + 1,
      due_at = due_at + make_interval(days => l.extension_days_requested)
    where id = loan;
  else
    update public.loans set extension_status = 'declined', extensions_used = extensions_used + 1
    where id = loan;
  end if;
  perform public.log_loan_event(loan,
    case when accept then 'extension_accepted' else 'extension_declined' end);
end $$;

-- The owner confirms they have their book back.
create or replace function public.confirm_return(loan uuid)
returns void
language plpgsql security definer set search_path = '' as $$
begin
  perform public.lock_loan(loan, 'owner', array['active']::public.loan_status[]);
  update public.loans set status = 'returned', returned_at = now() where id = loan;
  perform public.log_loan_event(loan, 'returned');
end $$;

-- ---------------------------------------------------------------------------
-- Reading loans: my loans with the book and the other person's name.
-- ---------------------------------------------------------------------------
create or replace function public.my_loans(only_loan uuid default null)
returns table (
  id uuid, role text, status public.loan_status, overdue boolean,
  book_id uuid, title text, authors text[], cover_url text, page_count integer,
  other_id uuid, other_name text, other_username text,
  message text, decline_reason text, duration_days integer, duration_source text,
  suggested_days integer, my_handover_confirmed boolean, their_handover_confirmed boolean,
  handover_at timestamptz, due_at timestamptz, returned_at timestamptz,
  extension_days_requested integer, extension_status text, extensions_used integer,
  created_at timestamptz, updated_at timestamptz)
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
         l.created_at, l.updated_at
  from public.loans l
  join public.books b on b.id = l.book_id
  join public.profiles p
    on p.id = case when l.owner_id = auth.uid() then l.borrower_id else l.owner_id end
  where auth.uid() in (l.owner_id, l.borrower_id)
    and (only_loan is null or l.id = only_loan)
  order by l.updated_at desc
$$;

-- ---------------------------------------------------------------------------
-- Holders now also say whether a copy is lent out and whether I asked for it.
-- ---------------------------------------------------------------------------
drop function public.search_book_holders(uuid);
create function public.search_book_holders(target_book uuid)
returns table (
  item_id uuid, owner_id uuid, username text, display_name text, area_name text,
  relationship public.relationship, approx_km integer, lendable boolean,
  status public.reading_status, rating smallint, review text,
  on_loan boolean, my_loan_id uuid, my_loan_status public.loan_status)
language sql stable security definer set search_path = '' as $$
  select i.id, p.id, p.username, p.display_name, p.area_name, r.rel,
         public.approx_km(public.distance_m(auth.uid(), p.id)),
         i.lendable, i.status, i.rating, i.review,
         exists (select 1 from public.loans x
                 where x.library_item_id = i.id and x.status in ('accepted', 'active')),
         mine.id, mine.status
  from public.library_items i
  join public.profiles p on p.id = i.owner_id
  cross join lateral (select public.relationship_level(auth.uid(), i.owner_id) as rel) r
  left join lateral (
    select x.id, x.status from public.loans x
    where x.library_item_id = i.id and x.borrower_id = auth.uid()
      and x.status in ('requested', 'accepted', 'active')
    limit 1) mine on true
  where i.book_id = target_book
    and i.owner_id <> auth.uid()
    and i.owned
    and public.visibility_allows(coalesce(i.visibility, p.default_visibility), r.rel)
  order by i.lendable desc,
           case r.rel when 'friend' then 0 when 'neighbor' then 1 else 2 end,
           public.distance_m(auth.uid(), p.id) nulls last
$$;

-- A counterpart in a loan can always see the other's profile basics.
create or replace function public.can_see_profile(viewer uuid, target uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select public.visibility_allows(p.profile_visibility, public.relationship_level(viewer, target))
      or exists (select 1 from public.loans l
                 where (l.owner_id = viewer and l.borrower_id = target)
                    or (l.owner_id = target and l.borrower_id = viewer))
  from public.profiles p where p.id = target
$$;

-- ---------------------------------------------------------------------------
-- Security
-- ---------------------------------------------------------------------------
alter table public.loans enable row level security;
alter table public.loan_events enable row level security;

create policy "parties read loans" on public.loans
  for select to authenticated using ((select auth.uid()) in (owner_id, borrower_id));
create policy "parties read loan events" on public.loan_events
  for select to authenticated using (exists (
    select 1 from public.loans l
    where l.id = loan_id and (select auth.uid()) in (l.owner_id, l.borrower_id)));

revoke all on public.loans, public.loan_events from anon, authenticated;
grant select on public.loans, public.loan_events to authenticated;

do $$
declare fn text;
begin
  foreach fn in array array['log_loan_event(uuid,text,jsonb)', 'lock_loan(uuid,text,public.loan_status[])']
  loop
    execute format('revoke execute on function public.%s from public, anon, authenticated', fn);
  end loop;
  foreach fn in array array[
    'request_loan(uuid,text)', 'respond_loan(uuid,boolean,integer,text)', 'cancel_loan(uuid)',
    'confirm_handover(uuid)', 'request_extension(uuid,integer)', 'respond_extension(uuid,boolean)',
    'confirm_return(uuid)', 'my_loans(uuid)', 'search_book_holders(uuid)']
  loop
    execute format('revoke execute on function public.%s from public, anon', fn);
    execute format('grant execute on function public.%s to authenticated', fn);
  end loop;
end $$;
