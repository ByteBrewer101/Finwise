-- =========================================================
-- 15_FINANCIAL_INTEGRITY_EDIT_GUARDS
-- Protect goals and budgets from invalid target reductions.
-- =========================================================

-- ---------------------------------------------------------
-- GOALS: target_amount must not be below current_amount
-- ---------------------------------------------------------

update public.goals
set target_amount = current_amount
where target_amount < current_amount;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'goals_target_not_below_current_check'
  ) then
    alter table public.goals
    add constraint goals_target_not_below_current_check
    check (target_amount >= current_amount);
  end if;
end
$$;

-- ---------------------------------------------------------
-- BUDGETS: amount must not be below already spent amount
-- ---------------------------------------------------------

create or replace function public.validate_budget_amount_not_below_spent()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_spent numeric := 0;
begin
  select coalesce(sum(t.amount), 0)
  into v_spent
  from public.transactions t
  where t.type = 'expense'
    and t.budget_id = new.id
    and (new.wallet_id is null or t.wallet_id = new.wallet_id)
    and t.transaction_date between new.start_date and coalesce(new.end_date, current_date);

  if new.amount < v_spent then
    raise exception 'New target cannot be less than already invested amount.';
  end if;

  return new;
end;
$$;

drop trigger if exists validate_budget_amount_not_below_spent_trigger
on public.budgets;

create trigger validate_budget_amount_not_below_spent_trigger
before insert or update
on public.budgets
for each row execute procedure public.validate_budget_amount_not_below_spent();

