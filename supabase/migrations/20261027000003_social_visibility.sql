-- M3: friendships, blocks, visibility rules and discovery.
-- See docs/PLAN.md section 7 for the rules in plain language.

create type public.friendship_status as enum ('pending', 'accepted');

-- How the viewer relates to an owner, from weakest to strongest.
create type public.relationship as enum ('none', 'public_user', 'neighbor', 'friend', 'owner');

create table public.friendships (
  id           uuid primary key default gen_random_uuid(),
  requester_id uuid not null references public.profiles (id) on delete cascade,
  addressee_id uuid not null references public.profiles (id) on delete cascade,
  status       public.friendship_status not null default 'pending',
  created_at   timestamptz not null default now(),
  responded_at timestamptz,
  check (requester_id <> addressee_id)
);
-- One friendship row per pair, whichever direction it was sent in.
create unique index friendships_pair_idx on public.friendships
  (least(requester_id, addressee_id), greatest(requester_id, addressee_id));
create index friendships_addressee_idx on public.friendships (addressee_id);

create table public.blocks (
  blocker_id uuid not null references public.profiles (id) on delete cascade,
  blocked_id uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);
create index blocks_blocked_idx on public.blocks (blocked_id);

-- Neighborhood radius in metres (fixed for the prototype).
create or replace function public.neighbor_radius_m()
returns double precision language sql immutable as $$ select 5000::double precision $$;

-- ---------------------------------------------------------------------------
-- Relationship helpers. security definer so they can read blocks/locations,
-- which users cannot read directly.
-- ---------------------------------------------------------------------------
create or replace function public.is_blocked(a uuid, b uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.blocks
    where (blocker_id = a and blocked_id = b) or (blocker_id = b and blocked_id = a))
$$;

create or replace function public.are_friends(a uuid, b uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.friendships
    where status = 'accepted'
      and least(requester_id, addressee_id) = least(a, b)
      and greatest(requester_id, addressee_id) = greatest(a, b))
$$;

-- Distance between two users' snapped cells, or null if either has none.
create or replace function public.distance_m(a uuid, b uuid)
returns double precision language sql stable security definer set search_path = '' as $$
  select extensions.st_distance(la.home_cell, lb.home_cell)
  from public.profile_locations la, public.profile_locations lb
  where la.user_id = a and lb.user_id = b
$$;

create or replace function public.relationship_level(viewer uuid, owner uuid)
returns public.relationship
language sql stable security definer set search_path = '' as $$
  select case
    when viewer is null then 'none'
    when viewer = owner then 'owner'
    when public.is_blocked(viewer, owner) then 'none'
    when public.are_friends(viewer, owner) then 'friend'
    when public.distance_m(viewer, owner) <= public.neighbor_radius_m() then 'neighbor'
    else 'public_user'
  end::public.relationship
$$;

-- Who a visibility level is shared with.
create or replace function public.visibility_allows(vis public.visibility, rel public.relationship)
returns boolean language sql immutable as $$
  select case vis
    when 'private'   then rel = 'owner'
    when 'friends'   then rel in ('owner', 'friend')
    when 'neighbors' then rel in ('owner', 'friend', 'neighbor')
    when 'public'    then rel in ('owner', 'friend', 'neighbor', 'public_user')
  end
$$;

-- Distance shown to other people: 0 = "same area", whole km up to 50, else null.
create or replace function public.approx_km(meters double precision)
returns integer language sql immutable as $$
  select case
    when meters is null or meters > 50000 then null
    when meters < 1000 then 0
    else round(meters / 1000)::int
  end
$$;

create or replace function public.can_see_profile(viewer uuid, target uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select public.visibility_allows(p.profile_visibility, public.relationship_level(viewer, target))
  from public.profiles p where p.id = target
$$;

create or replace function public.can_see_item(viewer uuid, item_owner uuid, item_visibility public.visibility)
returns boolean language sql stable security definer set search_path = '' as $$
  select public.visibility_allows(
           coalesce(item_visibility, p.default_visibility),
           public.relationship_level(viewer, item_owner))
  from public.profiles p where p.id = item_owner
$$;

-- ---------------------------------------------------------------------------
-- Replace the M1/M2 owner-only read policies with the visibility rules.
-- ---------------------------------------------------------------------------
drop policy "read own profile" on public.profiles;
create policy "read visible profiles" on public.profiles
  for select to authenticated
  using (id = (select auth.uid()) or public.can_see_profile((select auth.uid()), id));

drop policy "owner reads items" on public.library_items;
create policy "read visible items" on public.library_items
  for select to authenticated
  using (owner_id = (select auth.uid())
         or public.can_see_item((select auth.uid()), owner_id, visibility));

alter table public.friendships enable row level security;
alter table public.blocks enable row level security;

create policy "parties read friendship" on public.friendships
  for select to authenticated
  using ((select auth.uid()) in (requester_id, addressee_id));
create policy "blocker reads own blocks" on public.blocks
  for select to authenticated using (blocker_id = (select auth.uid()));

-- All writes go through the RPCs below.
revoke all on public.friendships, public.blocks from anon, authenticated;
grant select on public.friendships, public.blocks to authenticated;

-- ---------------------------------------------------------------------------
-- Friend requests
-- ---------------------------------------------------------------------------
create or replace function public.send_friend_request(target_username text)
returns public.friendship_status
language plpgsql security definer set search_path = '' as $$
declare
  me     uuid := auth.uid();
  target uuid;
  f      public.friendships;
begin
  if me is null then raise exception 'not signed in' using errcode = '42501'; end if;

  select id into target from public.profiles where username = lower(btrim(target_username));
  -- Blocked users look exactly like unknown usernames.
  if target is null or public.is_blocked(me, target) then
    raise exception 'user not found' using errcode = 'P0002';
  end if;
  if target = me then raise exception 'cannot befriend yourself' using errcode = '22023'; end if;

  select * into f from public.friendships
  where least(requester_id, addressee_id) = least(me, target)
    and greatest(requester_id, addressee_id) = greatest(me, target);

  if f.id is null then
    insert into public.friendships (requester_id, addressee_id) values (me, target);
    return 'pending';
  end if;
  -- They already asked me: sending back means yes.
  if f.status = 'pending' and f.addressee_id = me then
    update public.friendships set status = 'accepted', responded_at = now() where id = f.id;
    return 'accepted';
  end if;
  return f.status;
end $$;

create or replace function public.respond_friend_request(request_id uuid, accept boolean)
returns void
language plpgsql security definer set search_path = '' as $$
begin
  if accept then
    update public.friendships set status = 'accepted', responded_at = now()
    where id = request_id and addressee_id = auth.uid() and status = 'pending';
  else
    delete from public.friendships
    where id = request_id and addressee_id = auth.uid() and status = 'pending';
  end if;
  if not found then raise exception 'request not found' using errcode = 'P0002'; end if;
end $$;

-- Unfriend, cancel my request, or decline: removes the pair's row either way.
create or replace function public.remove_friendship(other_user uuid)
returns void
language sql security definer set search_path = '' as $$
  delete from public.friendships
  where least(requester_id, addressee_id) = least(auth.uid(), other_user)
    and greatest(requester_id, addressee_id) = greatest(auth.uid(), other_user)
$$;

create or replace function public.block_user(target uuid)
returns void
language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null or target = auth.uid() then
    raise exception 'invalid block' using errcode = '22023';
  end if;
  insert into public.blocks (blocker_id, blocked_id) values (auth.uid(), target)
  on conflict do nothing;
  perform public.remove_friendship(target);
end $$;

create or replace function public.unblock_user(target uuid)
returns void
language sql security definer set search_path = '' as $$
  delete from public.blocks where blocker_id = auth.uid() and blocked_id = target
$$;

-- ---------------------------------------------------------------------------
-- People cards. Name and username are shown to anyone who is not blocked (so
-- friend requests work); area and thumbs only when the profile is visible.
-- ---------------------------------------------------------------------------
create or replace function public.get_person(target uuid)
returns table (
  id uuid, username text, display_name text, area_name text,
  thumbs_up integer, relationship public.relationship, approx_km integer,
  profile_visible boolean, friendship_id uuid, friendship_status public.friendship_status,
  request_sent_by_me boolean, blocked_by_me boolean)
language sql stable security definer set search_path = '' as $$
  select p.id, p.username, p.display_name,
         case when v.visible then p.area_name end,
         case when v.visible then p.thumbs_up end,
         public.relationship_level(auth.uid(), p.id),
         case when v.visible then public.approx_km(public.distance_m(auth.uid(), p.id)) end,
         v.visible,
         f.id, f.status, f.requester_id = auth.uid(),
         exists (select 1 from public.blocks b where b.blocker_id = auth.uid() and b.blocked_id = p.id)
  from public.profiles p
  cross join lateral (select public.can_see_profile(auth.uid(), p.id) as visible) v
  left join public.friendships f
    on least(f.requester_id, f.addressee_id) = least(auth.uid(), p.id)
   and greatest(f.requester_id, f.addressee_id) = greatest(auth.uid(), p.id)
  where p.id = target
    and p.username is not null
    -- Hide people who blocked me; people I blocked stay visible so I can unblock.
    and not exists (select 1 from public.blocks b where b.blocker_id = p.id and b.blocked_id = auth.uid())
$$;

-- My friends, incoming/outgoing requests and blocked users in one list.
create or replace function public.my_people()
returns table (
  id uuid, username text, display_name text,
  kind text, -- 'friend' | 'incoming' | 'outgoing' | 'blocked'
  friendship_id uuid)
language sql stable security definer set search_path = '' as $$
  select p.id, p.username, p.display_name,
         case when f.status = 'accepted' then 'friend'
              when f.addressee_id = auth.uid() then 'incoming'
              else 'outgoing' end,
         f.id
  from public.friendships f
  join public.profiles p
    on p.id = case when f.requester_id = auth.uid() then f.addressee_id else f.requester_id end
  where auth.uid() in (f.requester_id, f.addressee_id)
  union all
  select p.id, p.username, p.display_name, 'blocked', null
  from public.blocks b join public.profiles p on p.id = b.blocked_id
  where b.blocker_id = auth.uid()
$$;

-- ---------------------------------------------------------------------------
-- Discovery
-- ---------------------------------------------------------------------------

-- Books that someone I can see owns, matching the query (empty = recent).
create or replace function public.discover_books(query text default '')
returns table (
  book_id uuid, title text, authors text[], cover_url text, page_count integer,
  published_year integer, friends integer, neighbors integer, others integer,
  lendable integer, latest timestamptz)
language sql stable security definer set search_path = '' as $$
  with visible as (
    select i.book_id, i.lendable, i.created_at,
           public.relationship_level(auth.uid(), i.owner_id) as rel,
           coalesce(i.visibility, p.default_visibility) as vis
    from public.library_items i
    join public.profiles p on p.id = i.owner_id
    where i.owner_id <> auth.uid() and i.owned
  )
  select b.id, b.title, b.authors, b.cover_url, b.page_count, b.published_year,
         count(*) filter (where v.rel = 'friend')::int,
         count(*) filter (where v.rel = 'neighbor')::int,
         count(*) filter (where v.rel = 'public_user')::int,
         count(*) filter (where v.lendable)::int,
         max(v.created_at)
  from visible v
  join public.books b on b.id = v.book_id
  where public.visibility_allows(v.vis, v.rel)
    and (btrim(coalesce(query, '')) = ''
         or b.title ilike '%' || btrim(query) || '%'
         or array_to_string(b.authors, ' ') ilike '%' || btrim(query) || '%'
         or b.isbn13 = regexp_replace(query, '[^0-9]', '', 'g'))
  group by b.id
  order by count(*) filter (where v.rel = 'friend') > 0 desc,
           count(*) filter (where v.rel = 'neighbor') > 0 desc,
           max(v.created_at) desc
  limit 50
$$;

-- Everyone I may see who has this book, closest relationship first.
create or replace function public.search_book_holders(target_book uuid)
returns table (
  item_id uuid, owner_id uuid, username text, display_name text, area_name text,
  relationship public.relationship, approx_km integer, lendable boolean,
  status public.reading_status, rating smallint, review text)
language sql stable security definer set search_path = '' as $$
  select i.id, p.id, p.username, p.display_name, p.area_name, r.rel,
         public.approx_km(public.distance_m(auth.uid(), p.id)),
         i.lendable, i.status, i.rating, i.review
  from public.library_items i
  join public.profiles p on p.id = i.owner_id
  cross join lateral (select public.relationship_level(auth.uid(), i.owner_id) as rel) r
  where i.book_id = target_book
    and i.owner_id <> auth.uid()
    and i.owned
    and public.visibility_allows(coalesce(i.visibility, p.default_visibility), r.rel)
  order by i.lendable desc,
           case r.rel when 'friend' then 0 when 'neighbor' then 1 else 2 end,
           public.distance_m(auth.uid(), p.id) nulls last
$$;

-- Internal helpers: only used inside other functions, never called by clients
-- (distance_m would otherwise reveal exact distances between grid cells).
do $$
declare fn text;
begin
  foreach fn in array array[
    'is_blocked(uuid,uuid)', 'are_friends(uuid,uuid)', 'distance_m(uuid,uuid)',
    'relationship_level(uuid,uuid)']
  loop
    execute format('revoke execute on function public.%s from public, anon, authenticated', fn);
  end loop;
end $$;

-- Only signed-in users may call these (the can_see_* pair is used by RLS).
do $$
declare fn text;
begin
  foreach fn in array array[
    'can_see_profile(uuid,uuid)', 'can_see_item(uuid,uuid,public.visibility)',
    'send_friend_request(text)', 'respond_friend_request(uuid,boolean)',
    'remove_friendship(uuid)', 'block_user(uuid)', 'unblock_user(uuid)',
    'get_person(uuid)', 'my_people()', 'discover_books(text)', 'search_book_holders(uuid)']
  loop
    execute format('revoke execute on function public.%s from public, anon', fn);
    execute format('grant execute on function public.%s to authenticated', fn);
  end loop;
end $$;
