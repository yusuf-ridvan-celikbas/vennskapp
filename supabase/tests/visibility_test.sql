begin;
create extension if not exists pgtap with schema extensions;
select plan(27);

-- Cast: O owner, F friend (far away), N neighbor (~2 km), P public user (far),
-- B a neighbor that O blocks.
insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-00000000000a', 'o@test.local'),
  ('00000000-0000-0000-0000-00000000000f', 'f@test.local'),
  ('00000000-0000-0000-0000-00000000000e', 'n@test.local'),
  ('00000000-0000-0000-0000-00000000000b', 'p@test.local'),
  ('00000000-0000-0000-0000-00000000000c', 'b@test.local');
update public.profiles set
  username = case id
    when '00000000-0000-0000-0000-00000000000a' then 'owner'
    when '00000000-0000-0000-0000-00000000000f' then 'friend'
    when '00000000-0000-0000-0000-00000000000e' then 'neighbor'
    when '00000000-0000-0000-0000-00000000000b' then 'faraway'
    else 'blocked' end,
  display_name = 'Test', area_name = 'Somewhere'
where id::text like '00000000-0000-0000-0000-00000000000%';
insert into public.profile_locations (user_id, home_cell) values
  ('00000000-0000-0000-0000-00000000000a', public.snap_to_cell(41.00, 28.78)),
  ('00000000-0000-0000-0000-00000000000e', public.snap_to_cell(41.00, 28.80)),
  ('00000000-0000-0000-0000-00000000000c', public.snap_to_cell(41.00, 28.79)),
  ('00000000-0000-0000-0000-00000000000f', public.snap_to_cell(59.92, 10.75)),
  ('00000000-0000-0000-0000-00000000000b', public.snap_to_cell(59.93, 10.72));
insert into public.friendships (requester_id, addressee_id, status) values
  ('00000000-0000-0000-0000-00000000000a', '00000000-0000-0000-0000-00000000000f', 'accepted');
insert into public.blocks values
  ('00000000-0000-0000-0000-00000000000a', '00000000-0000-0000-0000-00000000000c');

-- O owns five books, one per visibility (null = profile default 'neighbors').
insert into public.books (id, title, source) values
  ('10000000-0000-0000-0000-000000000001', 'Private book', 'manual'),
  ('10000000-0000-0000-0000-000000000002', 'Friends book', 'manual'),
  ('10000000-0000-0000-0000-000000000003', 'Neighbors book', 'manual'),
  ('10000000-0000-0000-0000-000000000004', 'Public book', 'manual'),
  ('10000000-0000-0000-0000-000000000005', 'Default book', 'manual');
insert into public.library_items (owner_id, book_id, visibility) values
  ('00000000-0000-0000-0000-00000000000a', '10000000-0000-0000-0000-000000000001', 'private'),
  ('00000000-0000-0000-0000-00000000000a', '10000000-0000-0000-0000-000000000002', 'friends'),
  ('00000000-0000-0000-0000-00000000000a', '10000000-0000-0000-0000-000000000003', 'neighbors'),
  ('00000000-0000-0000-0000-00000000000a', '10000000-0000-0000-0000-000000000004', 'public'),
  ('00000000-0000-0000-0000-00000000000a', '10000000-0000-0000-0000-000000000005', null);

create function pg_temp.act_as(uid text) returns void language sql as $$
  select set_config('request.jwt.claims',
                    json_build_object('sub', uid, 'role', 'authenticated')::text, true)
$$;
grant execute on function pg_temp.act_as to authenticated;
set local role authenticated;

-- Item visibility matrix -----------------------------------------------------
select pg_temp.act_as('00000000-0000-0000-0000-00000000000a');
select is((select count(*)::int from public.library_items), 5, 'owner sees all own books');
select pg_temp.act_as('00000000-0000-0000-0000-00000000000f');
select is((select count(*)::int from public.library_items), 4, 'friend sees all but private');
select pg_temp.act_as('00000000-0000-0000-0000-00000000000e');
select is((select count(*)::int from public.library_items), 3, 'neighbor sees neighbors, public and default');
select pg_temp.act_as('00000000-0000-0000-0000-00000000000b');
select is((select count(*)::int from public.library_items), 1, 'far-away user sees only public');
select pg_temp.act_as('00000000-0000-0000-0000-00000000000c');
select is((select count(*)::int from public.library_items), 0, 'blocked user sees nothing');

-- Profile visibility (O's profile_visibility defaults to 'neighbors') -------
select pg_temp.act_as('00000000-0000-0000-0000-00000000000f');
select is((select count(*)::int from public.profiles where username = 'owner'), 1, 'friend sees profile');
select pg_temp.act_as('00000000-0000-0000-0000-00000000000e');
select is((select count(*)::int from public.profiles where username = 'owner'), 1, 'neighbor sees profile');
select pg_temp.act_as('00000000-0000-0000-0000-00000000000b');
select is((select count(*)::int from public.profiles where username = 'owner'), 0, 'far-away user does not');
select pg_temp.act_as('00000000-0000-0000-0000-00000000000c');
select is((select count(*)::int from public.profiles where username = 'owner'), 0, 'blocked user does not');

-- Location never leaks --------------------------------------------------------
select throws_ok($$ select public.distance_m('00000000-0000-0000-0000-00000000000a',
                                             '00000000-0000-0000-0000-00000000000e') $$,
                 '42501', null, 'distance helper is not callable by users');
select throws_ok($$ select * from public.profile_locations $$, '42501', null,
                 'locations are not readable');

-- Discovery -------------------------------------------------------------------
select pg_temp.act_as('00000000-0000-0000-0000-00000000000e');
select is((select array_agg(title order by title) from public.discover_books('')),
          array['Default book', 'Neighbors book', 'Public book'], 'neighbor discovers 3 books');
select is((select count(*)::int from public.discover_books('neighb')), 1, 'title search filters');
select is((select relationship::text from public.search_book_holders('10000000-0000-0000-0000-000000000003')),
          'neighbor', 'holder list shows relationship');
select is((select approx_km from public.search_book_holders('10000000-0000-0000-0000-000000000003')),
          2, 'holder list shows rounded distance');
select is((select count(*)::int from public.search_book_holders('10000000-0000-0000-0000-000000000002')),
          0, 'friends-only copy is hidden from a neighbor');
select pg_temp.act_as('00000000-0000-0000-0000-00000000000f');
select is((select friends from public.discover_books('Friends')), 1, 'friend copy is counted as a friend');
select pg_temp.act_as('00000000-0000-0000-0000-00000000000c');
select is((select count(*)::int from public.discover_books('')), 0, 'blocked user discovers nothing');

-- Friend requests ---------------------------------------------------------------
select pg_temp.act_as('00000000-0000-0000-0000-00000000000e');
select is(public.send_friend_request('FarAway '), 'pending', 'request by username (case/space-insensitive)');
select pg_temp.act_as('00000000-0000-0000-0000-00000000000b');
select is((select kind from public.my_people() where username = 'neighbor'), 'incoming', 'addressee sees incoming request');
select is(public.send_friend_request('neighbor'), 'accepted', 'asking back accepts the request');
select pg_temp.act_as('00000000-0000-0000-0000-00000000000e');
select is((select kind from public.my_people() where username = 'faraway'), 'friend', 'both are now friends');
select is((select count(*)::int from public.library_items), 3, 'new friendship does not change O''s items for N');

-- Blocking ----------------------------------------------------------------------
select pg_temp.act_as('00000000-0000-0000-0000-00000000000c');
select throws_ok($$ select public.send_friend_request('owner') $$, 'P0002', null,
                 'blocked user cannot send a request (looks like unknown user)');
select is((select count(*)::int from public.get_person('00000000-0000-0000-0000-00000000000a')), 0,
          'blocked user cannot see the blocker''s card');
select pg_temp.act_as('00000000-0000-0000-0000-00000000000a');
select is((select blocked_by_me from public.get_person('00000000-0000-0000-0000-00000000000c')), true,
          'blocker still sees the card, to unblock');
select public.block_user('00000000-0000-0000-0000-00000000000f');
select is((select count(*)::int from public.friendships
           where '00000000-0000-0000-0000-00000000000a' in (requester_id, addressee_id)), 0,
          'blocking removes the friendship');

select * from finish();
rollback;
