begin;
create extension if not exists pgtap with schema extensions;
select plan(25);

-- O lends a book to B; X is a stranger.
insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000c1', 'o@notify.test'),
  ('00000000-0000-0000-0000-0000000000c2', 'b@notify.test'),
  ('00000000-0000-0000-0000-0000000000c3', 'x@notify.test');
update public.profiles set username = 'notify_' || right(id::text, 2), display_name = 'N' || right(id::text, 1),
       area_name = 'X'
where id::text like '00000000-0000-0000-0000-0000000000c%';
insert into public.profile_locations (user_id, home_cell) values
  ('00000000-0000-0000-0000-0000000000c1', public.snap_to_cell(41.00, 28.78)),
  ('00000000-0000-0000-0000-0000000000c2', public.snap_to_cell(41.00, 28.80));
insert into public.books (id, title, page_count, source)
values ('20000000-0000-0000-0000-0000000000c1', 'Notify book', 300, 'manual');
insert into public.library_items (id, owner_id, book_id, visibility) values
  ('30000000-0000-0000-0000-0000000000c1', '00000000-0000-0000-0000-0000000000c1',
   '20000000-0000-0000-0000-0000000000c1', 'neighbors');

create function pg_temp.act_as(uid text) returns void language sql as $$
  select set_config('request.jwt.claims',
                    json_build_object('sub', uid, 'role', 'authenticated')::text, true)
$$;
grant execute on function pg_temp.act_as to authenticated;
create temp table t (name text primary key, id uuid);
grant all on t to authenticated;
set local role authenticated;

-- Loan events reach the other person ------------------------------------------
select pg_temp.act_as('00000000-0000-0000-0000-0000000000c2');
insert into t select 'loan', public.request_loan('30000000-0000-0000-0000-0000000000c1', 'hi');
select is((select count(*)::int from public.notifications), 0,
          'the borrower is not notified about their own request');

select pg_temp.act_as('00000000-0000-0000-0000-0000000000c1');
select results_eq(
  $$ select type, payload ->> 'title', payload ->> 'name', payload ->> 'role' from public.notifications $$,
  $$ values ('loan_requested', 'Notify book', 'N2', 'owner') $$,
  'the owner gets a request notification with title, name and role');

select public.respond_loan((select id from t where name = 'loan'), true, 14);
select public.confirm_handover((select id from t where name = 'loan'));
select pg_temp.act_as('00000000-0000-0000-0000-0000000000c2');
select results_eq(
  $$ select type, (payload ->> 'days')::int, (payload ->> 'started')::boolean
     from public.notifications order by created_at $$,
  $$ values ('loan_accepted', 14, null::boolean), ('loan_handover_confirmed', null, false) $$,
  'the borrower hears about acceptance and the owner''s handover confirmation');

select public.confirm_handover((select id from t where name = 'loan'));
select pg_temp.act_as('00000000-0000-0000-0000-0000000000c1');
select is((select (payload ->> 'started')::boolean from public.notifications
           where type = 'loan_handover_confirmed'), true,
          'the second confirmation tells the owner the loan started');
select is((select count(*)::int from public.notifications where type = 'loan_started'), 0,
          'no separate started notification');

-- Nobody else sees them, and clients cannot write them -------------------------
select pg_temp.act_as('00000000-0000-0000-0000-0000000000c3');
select is((select count(*)::int from public.notifications), 0, 'a stranger sees no notifications');
select throws_ok($$ insert into public.notifications (user_id, type)
                    values ('00000000-0000-0000-0000-0000000000c3', 'x') $$,
                 '42501', null, 'clients cannot insert notifications');
select throws_ok($$ select public.notify('00000000-0000-0000-0000-0000000000c1', 'x', '{}') $$,
                 '42501', null, 'clients cannot call notify()');
select throws_ok($$ select public.send_loan_reminders() $$,
                 '42501', null, 'clients cannot trigger reminders');

-- Marking as read ---------------------------------------------------------------
select pg_temp.act_as('00000000-0000-0000-0000-0000000000c1');
select public.mark_notifications_read(array[(select id from public.notifications
                                             where type = 'loan_requested')]);
select is((select count(*)::int from public.notifications where read_at is null), 1,
          'marking one as read leaves the other unread');
select public.mark_notifications_read();
select is((select count(*)::int from public.notifications where read_at is null), 0,
          'mark all as read');

-- Reminders (move the due date instead of the clock) ---------------------------
reset role;
update public.loans set due_at = now() + interval '1 day' where id = (select id from t where name = 'loan');
select is(public.send_loan_reminders(), 1, 'due soon: one reminder for the borrower');
select is(public.send_loan_reminders(), 0, 'the same reminder is not sent twice');
update public.loans set due_at = now() - interval '1 hour' where id = (select id from t where name = 'loan');
select is(public.send_loan_reminders(), 2, 'overdue: both people are reminded');
select is(public.send_loan_reminders(), 0, 'overdue is sent once per due date');
select results_eq(
  $$ select type, payload ->> 'role' from public.notifications
     where user_id = '00000000-0000-0000-0000-0000000000c1' and type like 'loan_overdue' $$,
  $$ values ('loan_overdue', 'owner') $$,
  'the owner''s overdue reminder says they are the owner');
set local role authenticated;

-- Feedback ----------------------------------------------------------------------
select pg_temp.act_as('00000000-0000-0000-0000-0000000000c2');
select throws_ok(format('select public.leave_loan_feedback(%L, true)', (select id from t where name = 'loan')),
                 '55000', null, 'no feedback before the book is returned');
select pg_temp.act_as('00000000-0000-0000-0000-0000000000c1');
select public.confirm_return((select id from t where name = 'loan'));
select public.leave_loan_feedback((select id from t where name = 'loan'), true);
select throws_ok(format('select public.leave_loan_feedback(%L, false)', (select id from t where name = 'loan')),
                 '55000', null, 'feedback only once per side');
select is((select my_feedback from public.my_loans((select id from t where name = 'loan'))), 'up',
          'my_loans shows my feedback');
select pg_temp.act_as('00000000-0000-0000-0000-0000000000c2');
select public.leave_loan_feedback((select id from t where name = 'loan'), false);
select pg_temp.act_as('00000000-0000-0000-0000-0000000000c3');
select throws_ok(format('select public.leave_loan_feedback(%L, true)', (select id from t where name = 'loan')),
                 'P0002', null, 'outsiders cannot leave feedback');
reset role;
select results_eq(
  $$ select thumbs_up, thumbs_down from public.profiles
     where id in ('00000000-0000-0000-0000-0000000000c1', '00000000-0000-0000-0000-0000000000c2')
     order by id $$,
  $$ values (0, 1), (1, 0) $$,
  'thumbs are counted on the other person''s profile');
set local role authenticated;

-- Friend requests ---------------------------------------------------------------
select pg_temp.act_as('00000000-0000-0000-0000-0000000000c3');
select public.send_friend_request('notify_c1');
select public.remove_friendship('00000000-0000-0000-0000-0000000000c1');
select public.send_friend_request('notify_c2');
select pg_temp.act_as('00000000-0000-0000-0000-0000000000c1');
select is((select count(*)::int from public.notifications where type = 'friend_request'), 0,
          'a withdrawn friend request disappears from notifications');
select pg_temp.act_as('00000000-0000-0000-0000-0000000000c2');
select public.respond_friend_request(
  (select id from public.friendships where requester_id = '00000000-0000-0000-0000-0000000000c3'), true);
select pg_temp.act_as('00000000-0000-0000-0000-0000000000c3');
select results_eq(
  $$ select type, payload ->> 'name' from public.notifications $$,
  $$ values ('friend_accepted', 'N2') $$,
  'the requester hears that the request was accepted');

-- Reports -----------------------------------------------------------------------
select public.report_user('00000000-0000-0000-0000-0000000000c1', 'spam', 'first');
select public.report_user('00000000-0000-0000-0000-0000000000c1', 'spam', 'second');
select throws_ok(format('select public.report_user(%L, %L, null, %L)',
                        '00000000-0000-0000-0000-0000000000c1', 'damaged', (select id from t where name = 'loan')),
                 'P0002', null, 'cannot attach a loan you were not part of');
reset role;
select results_eq(
  $$ select reason, details from public.reports where reporter_id = '00000000-0000-0000-0000-0000000000c3' $$,
  $$ values ('spam', 'second') $$,
  'repeated reports update the open one instead of piling up');

select * from finish();
rollback;
