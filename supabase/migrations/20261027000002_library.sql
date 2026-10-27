-- M2: shared book catalog and each user's copies (library items).

create type public.reading_status as enum ('unread', 'reading', 'read');

-- ---------------------------------------------------------------------------
-- books: one row per edition, shared by everyone. Written only via upsert_book
-- so ISBN duplicates are merged. Metadata is stored as-is, in any language.
-- ---------------------------------------------------------------------------
create table public.books (
  id             uuid primary key default gen_random_uuid(),
  isbn13         text unique check (isbn13 ~ '^[0-9]{13}$'),
  title          text not null check (char_length(btrim(title)) between 1 and 300),
  authors        text[] not null default '{}',
  page_count     integer check (page_count between 1 and 20000),
  cover_url      text check (cover_url ~ '^https://'),
  language       text,
  published_year integer check (published_year between 0 and 2100),
  source         text not null check (source in ('openlibrary', 'google', 'manual')),
  external_id    text,
  created_by     uuid references public.profiles (id) on delete set null,
  created_at     timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- library_items: a user's copy of a book plus their personal notes about it.
-- visibility null means "use my profile default".
-- ---------------------------------------------------------------------------
create table public.library_items (
  id             uuid primary key default gen_random_uuid(),
  owner_id       uuid not null default auth.uid()
                 references public.profiles (id) on delete cascade,
  book_id        uuid not null references public.books (id) on delete restrict,
  owned          boolean not null default true,
  status         public.reading_status not null default 'unread',
  rating         smallint check (rating between 1 and 5),
  review         text check (char_length(review) <= 500),
  lendable       boolean not null default true,
  visibility     public.visibility,
  condition_note text check (char_length(condition_note) <= 200),
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  unique (owner_id, book_id)
);
create index library_items_book_idx on public.library_items (book_id);

create trigger library_items_touch before update on public.library_items
  for each row execute function public.touch_updated_at();

-- ---------------------------------------------------------------------------
-- upsert_book: returns the id of the catalog row for this book. With an ISBN,
-- an existing row is reused and its missing fields are filled in.
-- ---------------------------------------------------------------------------
create or replace function public.upsert_book(book jsonb)
returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  v_isbn text := nullif(book ->> 'isbn13', '');
  v_id   uuid;
begin
  if auth.uid() is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;

  if v_isbn is not null then
    update public.books b set
      page_count     = coalesce(b.page_count, (book ->> 'page_count')::int),
      cover_url      = coalesce(b.cover_url, book ->> 'cover_url'),
      published_year = coalesce(b.published_year, (book ->> 'published_year')::int),
      language       = coalesce(b.language, book ->> 'language'),
      authors        = case when cardinality(b.authors) = 0
                            then coalesce(array(select jsonb_array_elements_text(book -> 'authors')), '{}')
                            else b.authors end
    where b.isbn13 = v_isbn
    returning b.id into v_id;
    if v_id is not null then
      return v_id;
    end if;
  end if;

  insert into public.books (isbn13, title, authors, page_count, cover_url,
                            language, published_year, source, external_id, created_by)
  values (
    v_isbn,
    btrim(book ->> 'title'),
    coalesce(array(select jsonb_array_elements_text(book -> 'authors')), '{}'),
    (book ->> 'page_count')::int,
    book ->> 'cover_url',
    book ->> 'language',
    (book ->> 'published_year')::int,
    coalesce(book ->> 'source', 'manual'),
    book ->> 'external_id',
    auth.uid()
  )
  on conflict (isbn13) do update set isbn13 = excluded.isbn13 -- lost a race: reuse
  returning id into v_id;
  return v_id;
end $$;

-- ---------------------------------------------------------------------------
-- Row-level security & privileges
-- ---------------------------------------------------------------------------
alter table public.books enable row level security;
alter table public.library_items enable row level security;

-- The catalog itself is not personal data; who owns a copy is (see below).
create policy "catalog is readable" on public.books
  for select to authenticated using (true);

-- M2: owners manage their own items. M3 adds read access by visibility.
create policy "owner reads items" on public.library_items
  for select to authenticated using (owner_id = (select auth.uid()));
create policy "owner adds items" on public.library_items
  for insert to authenticated with check (owner_id = (select auth.uid()));
create policy "owner updates items" on public.library_items
  for update to authenticated
  using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy "owner removes items" on public.library_items
  for delete to authenticated using (owner_id = (select auth.uid()));

revoke all on public.books from anon, authenticated;
grant select on public.books to authenticated;

revoke all on public.library_items from anon, authenticated;
grant select, delete on public.library_items to authenticated;
grant insert (book_id, owned, status, rating, review, lendable, visibility, condition_note)
  on public.library_items to authenticated;
grant update (owned, status, rating, review, lendable, visibility, condition_note)
  on public.library_items to authenticated;

revoke execute on function public.upsert_book from public, anon;
grant execute on function public.upsert_book to authenticated;
