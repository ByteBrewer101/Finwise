-- =========================================================
-- ATOMIC GOAL DELETE (WITH WALLET RESTORE)
-- =========================================================

create or replace function public.delete_goal_atomic(p_goal_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid;
begin

  -- Get current user
  v_user_id := auth.uid();

  if v_user_id is null then
    raise exception 'User not authenticated';
  end if;

  -- Ensure goal belongs to user
  if not exists (
    select 1
    from public.goals
    where id = p_goal_id
      and user_id = v_user_id
  ) then
    raise exception 'Goal not found or unauthorized';
  end if;

  -- Delete related transactions FIRST
  delete from public.transactions
  where id in (
    select transaction_id
    from public.goal_contributions
    where goal_id = p_goal_id
  );

  -- Now delete goal (goal_contributions cascade automatically)
  delete from public.goals
  where id = p_goal_id
    and user_id = v_user_id;

end;
$$;