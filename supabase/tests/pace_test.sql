begin;
create extension if not exists pgtap with schema extensions;
select plan(16);

-- The four worked examples from docs/PLAN.md section 6 ----------------------------
select is(public.loan_days_estimate(320, null, 0), 28, 'new user, 320 pages -> 28 days');
select is(public.loan_days_estimate(320, 40, 6), 14, 'steady reader, 320 pages -> 14 days');
select is(public.loan_days_estimate(600, 10, 4), 60, 'slow reader, 600 pages -> capped at 60');
select is(public.loan_days_estimate(120, 40, 6), 7, 'short book -> minimum 7 days');
select is(public.loan_days_estimate(null, null, 0), 28, 'unknown length counts as 300 pages');

-- Pace from real rows --------------------------------------------------------------
insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000c1', 'reader@pace.test'),
  ('00000000-0000-0000-0000-0000000000c2', 'newbie@pace.test'),
  ('00000000-0000-0000-0000-0000000000c3', 'sessions@pace.test');
insert into public.books (id, title, page_count, source) values
  ('40000000-0000-0000-0000-000000000001', 'Pace 400', 400, 'manual'),
  ('40000000-0000-0000-0000-000000000002', 'Pace 320', 320, 'manual'),
  ('40000000-0000-0000-0000-000000000003', 'Pace unknown', null, 'manual');

-- Six books of 400 pages read in 10 days each = 40 pages/day, plus one
-- implausible 400-pages-in-1-day outlier that must be ignored.
insert into public.finished_books (user_id, book_id, started_on, finished_on)
select '00000000-0000-0000-0000-0000000000c1', '40000000-0000-0000-0000-000000000001',
       current_date - (g * 20 + 9), current_date - g * 20
from generate_series(1, 6) g;
insert into public.finished_books (user_id, book_id, started_on, finished_on) values
  ('00000000-0000-0000-0000-0000000000c1', '40000000-0000-0000-0000-000000000001',
   current_date - 2, current_date - 2);

select is((select round(obs) from public.reading_pace('00000000-0000-0000-0000-0000000000c1')),
          40::numeric, 'pace is 40 pages/day; the outlier is ignored');
select is((select n from public.reading_pace('00000000-0000-0000-0000-0000000000c1')),
          6::numeric, 'six books count as evidence');
select is(public.suggest_loan_days('00000000-0000-0000-0000-0000000000c1',
                                   '40000000-0000-0000-0000-000000000002'),
          14, 'steady reader gets 14 days for 320 pages');
select is(public.suggest_loan_days('00000000-0000-0000-0000-0000000000c2',
                                   '40000000-0000-0000-0000-000000000002'),
          28, 'new user gets the cold-start 28 days');
select is(public.suggest_loan_days('00000000-0000-0000-0000-0000000000c2',
                                   '40000000-0000-0000-0000-000000000003'),
          28, 'book without page count uses 300 pages');

-- Sessions only: 30 pages a day for two weeks -> pace 30, partial evidence.
insert into public.reading_sessions (user_id, session_date, pages, minutes)
select '00000000-0000-0000-0000-0000000000c3', current_date - g, 30, 45 from generate_series(0, 13) g;
select is((select round(obs) from public.reading_pace('00000000-0000-0000-0000-0000000000c3')),
          30::numeric, 'session-only pace is pages per day');
select ok((select n between 1 and 2 from public.reading_pace('00000000-0000-0000-0000-0000000000c3')),
          'sessions give limited evidence (at most 2)');

-- Loans get the suggestion stored, and the owner cannot call the pace helpers --
insert into public.profile_locations (user_id, home_cell) values
  ('00000000-0000-0000-0000-0000000000c1', public.snap_to_cell(41.00, 28.78)),
  ('00000000-0000-0000-0000-0000000000c2', public.snap_to_cell(41.00, 28.79));
insert into public.library_items (id, owner_id, book_id, visibility) values
  ('50000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-0000000000c2',
   '40000000-0000-0000-0000-000000000002', 'neighbors');
insert into public.loans (id, library_item_id, book_id, owner_id, borrower_id) values
  ('60000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000001',
   '40000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-0000000000c2',
   '00000000-0000-0000-0000-0000000000c1');
select is((select suggested_days from public.loans where id = '60000000-0000-0000-0000-000000000001'),
          14, 'a new loan stores the borrower''s suggestion');

set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"00000000-0000-0000-0000-0000000000c2","role":"authenticated"}', true);
select throws_ok($$ select * from public.reading_pace('00000000-0000-0000-0000-0000000000c1') $$,
                 '42501', null, 'nobody can read another user''s pace');
reset role;

-- Promised loans expire after 7 days without handover ------------------------------
update public.loans set status = 'accepted', accepted_at = now() - interval '8 days'
where id = '60000000-0000-0000-0000-000000000001';
select is(public.expire_stale_loans(), 1, 'one stale promise expires');
select is((select status::text || '/' || (select type from public.loan_events
                                         where loan_id = l.id order by created_at desc limit 1)
           from public.loans l where id = '60000000-0000-0000-0000-000000000001'),
          'cancelled/expired', 'it is cancelled with an "expired" event');

select * from finish();
rollback;
