begin;
create extension if not exists pgtap with schema extensions;
select plan(9);

-- Two users; the trigger creates their profiles.
insert into auth.users (id, email, raw_user_meta_data)
values ('11111111-1111-1111-1111-111111111111', 'a@test.local', '{"adult_confirmed": true}'),
       ('22222222-2222-2222-2222-222222222222', 'b@test.local', '{}');

select is((select count(*)::int from public.profiles where id in ('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222')), 2, 'trigger creates a profile per user');
select is((select adult_confirmed from public.profiles
           where id = '11111111-1111-1111-1111-111111111111'),
          true, 'adult flag is copied from sign-up metadata');

-- Snapping: latitude to 0.01 deg, point lands on the grid.
select is(round(extensions.st_y(public.snap_to_cell(59.92345, 10.75812)::extensions.geometry)::numeric, 5),
          59.92, 'latitude snaps to 0.01 deg');
select ok(extensions.st_distance(public.snap_to_cell(59.92345, 10.75812),
                                 public.snap_to_cell(59.92349, 10.75815)) = 0,
          'nearby points share a cell');
select ok(extensions.st_distance(public.snap_to_cell(59.92345, 10.75812),
                                 extensions.st_setsrid(extensions.st_makepoint(10.75812, 59.92345), 4326)::extensions.geography) < 800,
          'snapped point stays within the cell');

-- Act as user A.
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}', true);

select lives_ok($$ select public.set_home_location(59.92345, 10.75812, ' Grünerløkka ') $$,
                'user can set home location');
select is((select area_name from public.profiles), 'Grünerløkka',
          'area name is stored trimmed, and only own profile is visible');
select throws_ok($$ select * from public.profile_locations $$, '42501', null,
                 'raw location is not readable by users');
select throws_ok($$ update public.profiles set thumbs_up = 99 $$, '42501', null,
                 'server-owned counters cannot be changed');

select * from finish();
rollback;
