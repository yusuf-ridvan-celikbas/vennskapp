begin;
create extension if not exists pgtap with schema extensions;
select plan(26);

-- O owns a book; N and M are neighbors who want it; F is far away.
insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000a1', 'o@loan.test'),
  ('00000000-0000-0000-0000-0000000000a2', 'n@loan.test'),
  ('00000000-0000-0000-0000-0000000000a3', 'm@loan.test'),
  ('00000000-0000-0000-0000-0000000000a4', 'f@loan.test');
update public.profiles set username = 'loan_' || right(id::text, 2), display_name = 'T', area_name = 'X'
where id::text like '00000000-0000-0000-0000-0000000000a%';
insert into public.profile_locations (user_id, home_cell) values
  ('00000000-0000-0000-0000-0000000000a1', public.snap_to_cell(41.00, 28.78)),
  ('00000000-0000-0000-0000-0000000000a2', public.snap_to_cell(41.00, 28.80)),
  ('00000000-0000-0000-0000-0000000000a3', public.snap_to_cell(41.01, 28.79)),
  ('00000000-0000-0000-0000-0000000000a4', public.snap_to_cell(59.92, 10.75));
insert into public.books (id, title, page_count, source)
values ('20000000-0000-0000-0000-000000000001', 'Loan book', 300, 'manual');
insert into public.library_items (id, owner_id, book_id, visibility) values
  ('30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-0000000000a1',
   '20000000-0000-0000-0000-000000000001', 'neighbors');

create function pg_temp.act_as(uid text) returns void language sql as $$
  select set_config('request.jwt.claims',
                    json_build_object('sub', uid, 'role', 'authenticated')::text, true)
$$;
grant execute on function pg_temp.act_as to authenticated;
create temp table t (name text primary key, id uuid);
grant all on t to authenticated;
set local role authenticated;

-- Requesting -------------------------------------------------------------------
select pg_temp.act_as('00000000-0000-0000-0000-0000000000a4');
select throws_ok($$ select public.request_loan('30000000-0000-0000-0000-000000000001') $$,
                 'P0002', null, 'someone who cannot see the book cannot request it');
select pg_temp.act_as('00000000-0000-0000-0000-0000000000a1');
select throws_ok($$ select public.request_loan('30000000-0000-0000-0000-000000000001') $$,
                 '22023', null, 'owner cannot borrow own book');

select pg_temp.act_as('00000000-0000-0000-0000-0000000000a2');
insert into t select 'n', public.request_loan('30000000-0000-0000-0000-000000000001', ' Hi neighbor! ');
select is((select message from public.loans where id = (select id from t where name = 'n')),
          'Hi neighbor!', 'neighbor requests with a trimmed note');
select throws_ok($$ select public.request_loan('30000000-0000-0000-0000-000000000001') $$,
                 '55000', null, 'cannot request the same copy twice');
select pg_temp.act_as('00000000-0000-0000-0000-0000000000a3');
insert into t select 'm', public.request_loan('30000000-0000-0000-0000-000000000001');
select is((select count(*)::int from public.loans where book_id = '20000000-0000-0000-0000-000000000001'), 1, 'each person only sees their own loans');

-- Responding -------------------------------------------------------------------
select pg_temp.act_as('00000000-0000-0000-0000-0000000000a2');
select throws_ok(format('select public.respond_loan(%L, true, 14)', (select id from t where name = 'n')),
                 '42501', null, 'borrower cannot accept own request');
select pg_temp.act_as('00000000-0000-0000-0000-0000000000a1');
select throws_ok(format('select public.respond_loan(%L, true, 200)', (select id from t where name = 'n')),
                 '22023', null, 'loan length is limited to 3-90 days');
select lives_ok(format('select public.respond_loan(%L, true, 14)', (select id from t where name = 'n')),
                'owner accepts');
select is((select status::text from public.loans where id = (select id from t where name = 'm')),
          'declined', 'the other request is declined automatically');
select is((select duration_source from public.loans where id = (select id from t where name = 'n')),
          'manual', 'typed length is recorded as manual');
select is((select count(*)::int from public.loans where status = 'requested' and book_id = '20000000-0000-0000-0000-000000000001'), 0, 'no open requests left');

select pg_temp.act_as('00000000-0000-0000-0000-0000000000a3');
select throws_ok($$ select public.request_loan('30000000-0000-0000-0000-000000000001') $$,
                 '55000', null, 'a promised copy cannot be requested');

-- Handover -----------------------------------------------------------------------
select pg_temp.act_as('00000000-0000-0000-0000-0000000000a1');
select is(public.confirm_handover((select id from t where name = 'n')), 'accepted',
          'one confirmation is not enough');
select throws_ok($$ delete from public.library_items where id = '30000000-0000-0000-0000-000000000001' $$,
                 '55000', null, 'a promised book cannot be removed from the shelf');
select pg_temp.act_as('00000000-0000-0000-0000-0000000000a2');
select is(public.confirm_handover((select id from t where name = 'n')), 'active',
          'loan starts when both confirm');
select ok((select due_at between now() + interval '14 days' - interval '1 minute'
                             and now() + interval '14 days' + interval '1 minute'
           from public.loans where id = (select id from t where name = 'n')),
          'due date is handover + 14 days');
select throws_ok(format('select public.confirm_handover(%L)', (select id from t where name = 'n')),
                 '55000', null, 'handover cannot be confirmed again');

-- Extension ----------------------------------------------------------------------
select lives_ok(format('select public.request_extension(%L, 7)', (select id from t where name = 'n')),
                'borrower asks for 7 more days');
select throws_ok(format('select public.request_extension(%L, 3)', (select id from t where name = 'n')),
                 '55000', null, 'only one extension request at a time');
select pg_temp.act_as('00000000-0000-0000-0000-0000000000a1');
select lives_ok(format('select public.respond_extension(%L, true)', (select id from t where name = 'n')),
                'owner accepts the extension');
select ok((select due_at > now() + interval '20 days'
           from public.loans where id = (select id from t where name = 'n')),
          'due date moved by 7 days');
select pg_temp.act_as('00000000-0000-0000-0000-0000000000a2');
select throws_ok(format('select public.request_extension(%L, 3)', (select id from t where name = 'n')),
                 '55000', null, 'extension can only be used once');

-- Return -------------------------------------------------------------------------
select throws_ok(format('select public.confirm_return(%L)', (select id from t where name = 'n')),
                 '42501', null, 'borrower cannot mark as returned');
select throws_ok(format('update public.loans set status = ''returned'' where id = %L',
                        (select id from t where name = 'n')),
                 '42501', null, 'loans cannot be changed directly');
select pg_temp.act_as('00000000-0000-0000-0000-0000000000a1');
select lives_ok(format('select public.confirm_return(%L)', (select id from t where name = 'n')),
                'owner confirms return');
select is((select array_agg(type order by created_at, type) from public.loan_events
           where loan_id = (select id from t where name = 'n')),
          array['requested', 'accepted', 'handover_confirmed', 'handover_confirmed', 'started',
                'extension_requested', 'extension_accepted', 'returned'],
          'every step is in the timeline');

select * from finish();
rollback;
