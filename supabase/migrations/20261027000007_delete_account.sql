-- M7: users can delete their own account. Everything about them goes with it
-- (profiles and all user tables cascade from auth.users). Books that are
-- promised or lent out must be finished first, so nobody is left holding a
-- loan with a vanished partner.
create or replace function public.delete_my_account()
returns void language plpgsql security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'not signed in' using errcode = '42501'; end if;
  if exists (select 1 from public.loans
             where me in (owner_id, borrower_id) and status in ('accepted', 'active')) then
    raise exception 'finish your open loans first' using errcode = '55000';
  end if;
  delete from auth.users where id = me;
end $$;

revoke execute on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;
