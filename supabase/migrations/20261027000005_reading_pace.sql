-- M5: reading log, personal reading pace and suggested loan length
-- (docs/PLAN.md section 6), plus two M4 follow-ups:
--   * promised loans with no handover for 7 days are cancelled automatically
--   * loan partners see each other's profile until 30 days after the loan ends

-- ---------------------------------------------------------------------------
-- Reading log (always private to its owner)
-- ---------------------------------------------------------------------------
create table public.reading_sessions (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  book_id      uuid references public.books (id) on delete set null,
  session_date date not null default current_date,
  pages        integer not null check (pages between 1 and 2000),
  minutes      integer not null check (minutes between 1 and 1440),
  created_at   timestamptz not null default now()
);
create index reading_sessions_user_idx on public.reading_sessions (user_id, session_date desc);

create table public.finished_books (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  book_id        uuid not null references public.books (id) on delete cascade,
  started_on     date not null,
  finished_on    date not null,
  pages_override integer check (pages_override between 1 and 20000),
  created_at     timestamptz not null default now(),
  check (finished_on >= started_on),
  check (finished_on <= current_date + 1)
);
create index finished_books_user_idx on public.finished_books (user_id, finished_on desc);

alter table public.reading_sessions enable row level security;
alter table public.finished_books enable row level security;

create policy "own sessions" on public.reading_sessions for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "own finished books" on public.finished_books for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

revoke all on public.reading_sessions, public.finished_books from anon, authenticated;
grant select, delete on public.reading_sessions, public.finished_books to authenticated;
grant insert (book_id, session_date, pages, minutes) on public.reading_sessions to authenticated;
grant insert (book_id, started_on, finished_on, pages_override) on public.finished_books to authenticated;

-- ---------------------------------------------------------------------------
-- Pace model. All constants live here so they are easy to tune.
--   p0 = 20 pages/day prior, k = 2 books of prior strength.
-- ---------------------------------------------------------------------------

-- Loan length for a book of `pages` pages, given an observed pace `obs`
-- (pages per calendar day) backed by `n` units of evidence. Pure function.
create or replace function public.loan_days_estimate(pages integer, obs numeric, n numeric)
returns integer language plpgsql immutable as $$
declare
  p0     constant numeric := 20;
  k      constant numeric := 2;
  p      numeric := coalesce(pages, 300);
  ppd    numeric;
  buffer numeric;
  days   integer;
begin
  n   := greatest(coalesce(n, 0), 0);
  obs := coalesce(obs, p0);
  ppd    := (k * p0 + n * obs) / (k + n);          -- shrink toward the prior
  buffer := 1.20 + 0.30 * k / (k + n);             -- 1.5 when new, ~1.25 with history
  days   := ceil(p / ppd * buffer)::int + 2;       -- +2 days for handover/return
  if days > 14 then
    days := ceil(days / 7.0)::int * 7;             -- whole weeks for longer loans
  end if;
  return least(greatest(days, 7), 60);
end $$;

-- A user's observed pace: weighted median of their last 5 finished books
-- (pages / days, newest weighted most), or recent sessions when they have
-- finished fewer than 2 books. Returns (obs, n); obs is null with no data.
create or replace function public.reading_pace(p_user uuid, out obs numeric, out n numeric)
language plpgsql stable security definer set search_path = '' as $$
declare
  cum        numeric := 0;
  r          record;
  sess_pages numeric;
  sess_first date;
  sess_weeks integer;
begin
  n := 0;
  -- Weighted median: walk the rates in ascending order until half the weight.
  for r in
    with valid as (
      select f.finished_on,
             coalesce(f.pages_override, b.page_count)::numeric
               / greatest(1, f.finished_on - f.started_on + 1) as rate
      from public.finished_books f
      join public.books b on b.id = f.book_id
      where f.user_id = p_user
        and f.finished_on >= current_date - 365
        and f.finished_on - f.started_on <= 365
        and coalesce(f.pages_override, b.page_count) is not null
    ),
    plausible as (select * from valid where rate <= 250),   -- drop outliers
    recent as (
      select rate, 6 - row_number() over (order by finished_on desc) as w
      from plausible order by finished_on desc limit 5)
    select rate, w, sum(w) over () as total_w,
           (select least(count(*), 10) from plausible) as books
    from recent order by rate
  loop
    n := r.books;
    cum := cum + r.w;
    if obs is null and cum >= r.total_w / 2 then
      obs := r.rate;
    end if;
  end loop;

  if n < 2 then
    select sum(pages), min(session_date), count(distinct date_trunc('week', session_date))
      into sess_pages, sess_first, sess_weeks
    from public.reading_sessions
    where user_id = p_user and session_date > current_date - 28;
    if sess_pages is not null then
      obs := sess_pages / greatest(7, current_date - sess_first + 1);
      n := least(n + sess_weeks / 2.0, 2);
    end if;
  end if;
end $$;

-- Suggested loan length for this borrower and book. Internal: owners only ever
-- see the resulting number (stored on the loan), never the borrower's pace.
create or replace function public.suggest_loan_days(p_borrower uuid, p_book uuid)
returns integer language sql stable security definer set search_path = '' as $$
  select public.loan_days_estimate(b.page_count, pace.obs, pace.n)
  from public.books b, public.reading_pace(p_borrower) pace
  where b.id = p_book
$$;

-- Fill the suggestion when a loan is requested.
create or replace function public.set_suggested_days()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  new.suggested_days := public.suggest_loan_days(new.borrower_id, new.book_id);
  return new;
end $$;
create trigger loans_suggest before insert on public.loans
  for each row execute function public.set_suggested_days();

-- The signed-in user's own stats for the Me tab.
create or replace function public.my_reading_stats()
returns table (
  pages_per_hour numeric, pace_pages_per_day numeric, pace_confidence numeric,
  books_this_year integer, pages_last_30_days integer, minutes_last_30_days integer,
  sessions_count integer, example_days_300 integer)
language sql stable security definer set search_path = '' as $$
  select
    (select round(sum(pages) * 60.0 / nullif(sum(minutes), 0), 1)
       from public.reading_sessions where user_id = auth.uid()),
    round((2 * 20 + pace.n * coalesce(pace.obs, 20)) / (2 + pace.n), 1),
    round(pace.n / (2 + pace.n), 2),
    (select count(*)::int from public.finished_books
      where user_id = auth.uid() and extract(year from finished_on) = extract(year from current_date)),
    (select coalesce(sum(pages), 0)::int from public.reading_sessions
      where user_id = auth.uid() and session_date > current_date - 30),
    (select coalesce(sum(minutes), 0)::int from public.reading_sessions
      where user_id = auth.uid() and session_date > current_date - 30),
    (select count(*)::int from public.reading_sessions where user_id = auth.uid()),
    public.loan_days_estimate(300, pace.obs, pace.n)
  from public.reading_pace(auth.uid()) pace
$$;

-- ---------------------------------------------------------------------------
-- M4 follow-up: expire promised loans that were never handed over.
-- ---------------------------------------------------------------------------
create or replace function public.expire_stale_loans()
returns integer language plpgsql security definer set search_path = '' as $$
declare expired integer;
begin
  with stale as (
    update public.loans set status = 'cancelled'
    where status = 'accepted' and accepted_at < now() - interval '7 days'
    returning id)
  insert into public.loan_events (loan_id, actor_id, type)
  select id, null, 'expired' from stale;
  get diagnostics expired = row_count;
  return expired;
end $$;

create extension if not exists pg_cron;
select cron.schedule('expire-stale-loans', '15 * * * *', 'select public.expire_stale_loans()');

-- ---------------------------------------------------------------------------
-- M4 follow-up: loan partners see each other's profile only while the loan is
-- open and for 30 days after it ended.
-- ---------------------------------------------------------------------------
create or replace function public.can_see_profile(viewer uuid, target uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select public.visibility_allows(p.profile_visibility, public.relationship_level(viewer, target))
      or exists (
        select 1 from public.loans l
        where ((l.owner_id = viewer and l.borrower_id = target)
            or (l.owner_id = target and l.borrower_id = viewer))
          and not public.is_blocked(viewer, target)
          and (l.status in ('requested', 'accepted', 'active')
               or coalesce(l.returned_at, l.updated_at) > now() - interval '30 days'))
  from public.profiles p where p.id = target
$$;

-- ---------------------------------------------------------------------------
-- Privileges
-- ---------------------------------------------------------------------------
do $$
declare fn text;
begin
  foreach fn in array array['reading_pace(uuid)', 'suggest_loan_days(uuid,uuid)',
                            'set_suggested_days()', 'expire_stale_loans()']
  loop
    execute format('revoke execute on function public.%s from public, anon, authenticated', fn);
  end loop;
  revoke execute on function public.my_reading_stats() from public, anon;
  grant execute on function public.my_reading_stats() to authenticated;
end $$;
