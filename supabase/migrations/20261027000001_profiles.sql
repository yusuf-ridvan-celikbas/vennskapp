-- M1: profiles, coarse home location, visibility enum.

create extension if not exists postgis with schema extensions;

-- Ordered: each level includes the audiences of the levels before it.
create type public.visibility as enum ('private', 'friends', 'neighbors', 'public');

-- ---------------------------------------------------------------------------
-- profiles: one row per auth user, created by trigger at sign-up.
-- username/display_name stay null until onboarding is finished.
-- ---------------------------------------------------------------------------
create table public.profiles (
  id                 uuid primary key references auth.users (id) on delete cascade,
  username           text unique
                     check (username ~ '^[a-z0-9_]{3,20}$'),
  display_name       text check (char_length(display_name) between 1 and 50),
  locale             text not null default 'en' check (locale in ('en', 'tr', 'nb')),
  area_name          text check (char_length(area_name) between 1 and 60),
  default_visibility public.visibility not null default 'neighbors',
  profile_visibility public.visibility not null default 'neighbors',
  adult_confirmed    boolean not null default false,
  thumbs_up          integer not null default 0,
  thumbs_down        integer not null default 0,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- profile_locations: the snapped ~1 km grid point. RLS is on with no policies,
-- so nobody can read it directly; only security definer functions use it.
-- ---------------------------------------------------------------------------
create table public.profile_locations (
  user_id    uuid primary key references public.profiles (id) on delete cascade,
  home_cell  extensions.geography(point, 4326) not null,
  updated_at timestamptz not null default now()
);
create index profile_locations_home_cell_idx
  on public.profile_locations using gist (home_cell);

-- ---------------------------------------------------------------------------
-- Shared helpers
-- ---------------------------------------------------------------------------
create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

create trigger profiles_touch before update on public.profiles
  for each row execute function public.touch_updated_at();

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, adult_confirmed)
  values (
    new.id,
    coalesce((new.raw_user_meta_data ->> 'adult_confirmed')::boolean, false)
  );
  return new;
end $$;

create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- Snap a coordinate to the centre of a ~1.1 km grid cell. Pure, so it is testable.
create or replace function public.snap_to_cell(lat double precision, lon double precision)
returns extensions.geography
language sql immutable set search_path = '' as $$
  with s as (select round(lat / 0.01) * 0.01 as lat_s)
  select extensions.st_setsrid(
           extensions.st_makepoint(
             round(lon / (0.01 / cos(radians(s.lat_s)))) * (0.01 / cos(radians(s.lat_s))),
             s.lat_s),
           4326)::extensions.geography
  from s
$$;

-- Called from onboarding/settings. Only the snapped cell is stored.
create or replace function public.set_home_location(
  lat double precision, lon double precision, area text)
returns void
language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if lat not between -85 and 85 or lon not between -180 and 180 then
    raise exception 'invalid coordinates' using errcode = '22023';
  end if;

  insert into public.profile_locations (user_id, home_cell)
  values (auth.uid(), public.snap_to_cell(lat, lon))
  on conflict (user_id) do update
    set home_cell = excluded.home_cell, updated_at = now();

  update public.profiles set area_name = btrim(area) where id = auth.uid();
end $$;

-- ---------------------------------------------------------------------------
-- Row-level security & privileges
-- ---------------------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.profile_locations enable row level security;

-- M1: users read their own profile. M3 replaces this with visibility rules.
create policy "read own profile" on public.profiles
  for select to authenticated using (id = (select auth.uid()));

create policy "update own profile" on public.profiles
  for update to authenticated
  using (id = (select auth.uid())) with check (id = (select auth.uid()));

-- Users may only change these columns; counters and age flag are server-owned.
revoke all on public.profiles from anon, authenticated;
grant select on public.profiles to authenticated;
grant update (username, display_name, locale, default_visibility, profile_visibility)
  on public.profiles to authenticated;

revoke all on public.profile_locations from anon, authenticated;

revoke execute on function public.set_home_location from public, anon;
grant execute on function public.set_home_location to authenticated;
