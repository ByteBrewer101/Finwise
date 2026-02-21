-- =========================================================
-- 12_BUDGET_TRANSACTION_LINK
-- =========================================================
-- Adds budget_id to transactions
-- Upgrades get_budget_spending to support budget-linked logic
-- Backward compatible with old category-based transactions
-- =========================================================


-- =========================================================
-- ADD budget_id COLUMN
-- =========================================================

alter table public.transactions
add column if not exists budget_id uuid
references public.budgets(id)
on delete set null;

create index if not exists transactions_budget_idx
on public.transactions(budget_id);


-- =========================================================
-- UPGRADE GET_BUDGET_SPENDING FUNCTION
-- =========================================================

create or replace function public.get_budget_spending(
  p_budget_id uuid
)
returns numeric
language plpgsql
security definer
set search_path = public
as $$
declare
  v_total numeric := 0;
  v_category uuid;
  v_wallet uuid;
  v_start date;
  v_end date;
begin

  -- Get budget details
  select category_id,
         wallet_id,
         start_date,
         coalesce(end_date, current_date)
  into v_category,
       v_wallet,
       v_start,
       v_end
  from public.budgets
  where id = p_budget_id;

  if v_category is null then
    return 0;
  end if;

  select coalesce(sum(amount), 0)
  into v_total
  from public.transactions t
  where t.type = 'expense'
    and (
          t.budget_id = p_budget_id
          OR (
               t.budget_id is null
               and t.category_id = v_category
             )
        )
    and (v_wallet is null or t.wallet_id = v_wallet)
    and t.transaction_date between v_start and v_end;

  return v_total;

end;
$$;


-- =========================================================
-- DONE
-- =========================================================