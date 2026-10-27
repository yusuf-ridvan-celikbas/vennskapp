begin;
create extension if not exists pgtap with schema extensions;
select plan(10);

insert into auth.users (id, email)
values ('11111111-1111-1111-1111-111111111111', 'a@test.local'),
       ('22222222-2222-2222-2222-222222222222', 'b@test.local');

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}', true);

-- upsert_book dedupes by ISBN and fills missing fields.
create temp table ids (name text, id uuid) on commit drop;
grant all on ids to authenticated;
insert into ids select 'first', public.upsert_book(
  '{"isbn13":"9780000000002","title":"Pride and Prejudice","authors":["Jane Austen"],"source":"openlibrary"}');
insert into ids select 'second', public.upsert_book(
  '{"isbn13":"9780000000002","title":"Pride & Prejudice","page_count":480,"source":"google"}');

select is((select count(distinct id)::int from ids), 1, 'same ISBN gives the same catalog row');
select is((select page_count from public.books where isbn13 = '9780000000002'), 480,
          'missing page count is filled in by a later lookup');
select is((select title from public.books where isbn13 = '9780000000002'), 'Pride and Prejudice',
          'existing title is kept');

insert into ids select 'manual1', public.upsert_book('{"title":"Grandma''s recipes","source":"manual"}');
insert into ids select 'manual2', public.upsert_book('{"title":"Grandma''s recipes","source":"manual"}');
select is((select count(*)::int from public.books where isbn13 is null), 2,
          'manual books without ISBN are separate rows');

select throws_ok($$ insert into public.books (title, source) values ('x', 'manual') $$,
                 '42501', null, 'books cannot be inserted directly');

-- Library items: owner can add, update, and the pair is unique.
select lives_ok($$ insert into public.library_items (book_id, status, rating)
                   select id, 'read', 5 from ids where name = 'first' $$,
                'owner adds a copy');
select throws_ok($$ insert into public.library_items (book_id) select id from ids where name = 'first' $$,
                 '23505', null, 'same book cannot be added twice');
select throws_ok($$ insert into public.library_items (book_id, owner_id)
                    select id, '22222222-2222-2222-2222-222222222222' from ids where name = 'manual1' $$,
                 '42501', null, 'cannot add a copy for someone else');

-- User B cannot see or change A's copy (until visibility rules arrive in M3).
select set_config('request.jwt.claims', '{"sub":"22222222-2222-2222-2222-222222222222","role":"authenticated"}', true);
select is((select count(*)::int from public.library_items where owner_id = '11111111-1111-1111-1111-111111111111'), 0, 'other users do not see private shelves');
update public.library_items set rating = 1;
select set_config('request.jwt.claims', '{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}', true);
select is((select rating::int from public.library_items where owner_id = '11111111-1111-1111-1111-111111111111'), 5, 'other users cannot change my copy');

select * from finish();
rollback;
