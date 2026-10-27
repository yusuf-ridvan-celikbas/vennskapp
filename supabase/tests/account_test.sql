begin;
create extension if not exists pgtap with schema extensions;
select plan(4);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000d1', 'o@account.test'),
  ('00000000-0000-0000-0000-0000000000d2', 'b@account.test');
update public.profiles set username = 'account_' || right(id::text, 2), display_name = 'A', area_name = 'X'
where id::text like '00000000-0000-0000-0000-0000000000d%';
insert into public.books (id, title, source) values ('20000000-0000-0000-0000-0000000000d1', 'Account book', 'manual');
insert into public.library_items (id, owner_id, book_id, visibility) values
  ('30000000-0000-0000-0000-0000000000d1', '00000000-0000-0000-0000-0000000000d1',
   '20000000-0000-0000-0000-0000000000d1', 'public');
insert into public.loans (id, library_item_id, book_id, owner_id, borrower_id, status)
values ('40000000-0000-0000-0000-0000000000d1', '30000000-0000-0000-0000-0000000000d1',
        '20000000-0000-0000-0000-0000000000d1', '00000000-0000-0000-0000-0000000000d1',
        '00000000-0000-0000-0000-0000000000d2', 'active');

create function pg_temp.act_as(uid text) returns void language sql as $$
  select set_config('request.jwt.claims',
                    json_build_object('sub', uid, 'role', 'authenticated')::text, true)
$$;
grant execute on function pg_temp.act_as to authenticated;
set local role authenticated;

select pg_temp.act_as('00000000-0000-0000-0000-0000000000d2');
select throws_ok($$ select public.delete_my_account() $$, '55000', null,
                 'cannot delete the account while borrowing a book');

reset role;
update public.loans set status = 'returned' where id = '40000000-0000-0000-0000-0000000000d1';
set local role authenticated;
select lives_ok($$ select public.delete_my_account() $$, 'deletes once loans are finished');

reset role;
select is((select count(*)::int from auth.users where id = '00000000-0000-0000-0000-0000000000d2'), 0,
          'the auth user is gone');
select is((select count(*)::int from public.profiles where id = '00000000-0000-0000-0000-0000000000d2'), 0,
          'and so is the profile (and everything that cascades from it)');

select * from finish();
rollback;
