-- =========================================================
-- BUDGET SPENDING CALCULATION FUNCTION
-- =========================================================

create or replace function public.get_budget_spending(
  p_budget_id uuid
)
returns numeric
language plpgsql
security definer
as $$
declare
  v_total numeric := 0;
  v_category uuid;
  v_wallet uuid;
  v_start date;
  v_end date;
begin

  select category_id, wallet_id, start_date, coalesce(end_date, current_date)
  into v_category, v_wallet, v_start, v_end
  from public.budgets
  where id = p_budget_id;

  select coalesce(sum(amount), 0)
  into v_total
  from public.transactions
  where type = 'expense'
    and category_id = v_category
    and wallet_id = v_wallet
    and transaction_date between v_start and v_end;

  return v_total;

end;
$$;
