-- =========================================================
-- 05_BUDGET_FUNCTIONS
-- =========================================================
-- This file contains only budget calculation logic.
-- It does NOT mutate wallet or transactions.
-- It is safe and side-effect free.
-- =========================================================


-- =========================================================
-- GET BUDGET SPENDING
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

  -- If budget not found, return 0
  if v_category is null then
    return 0;
  end if;

  -- Calculate expense transactions within date range
  select coalesce(sum(amount), 0)
  into v_total
  from public.transactions
  where type = 'expense'
    and category_id = v_category
    and (v_wallet is null or wallet_id = v_wallet)
    and transaction_date between v_start and v_end;

  return v_total;

end;
$$;

-- =========================================================
-- DONE
-- =========================================================