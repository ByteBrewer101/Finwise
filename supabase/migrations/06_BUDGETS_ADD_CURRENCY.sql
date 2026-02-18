-- =========================================================
-- 06_BUDGETS_ADD_CURRENCY
-- Add currency column to budgets (Production Safe)
-- =========================================================

-- 1️⃣ Add currency column only if it does not exist
alter table public.budgets
add column if not exists currency text default 'INR';

-- 2️⃣ Ensure currency never null
update public.budgets
set currency = 'INR'
where currency is null;

alter table public.budgets
alter column currency set not null;

-- 3️⃣ Optional: add check constraint for allowed currencies
do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'budgets_currency_check'
  ) then
    alter table public.budgets
    add constraint budgets_currency_check
    check (currency in ('INR', 'USD', 'EUR'));
  end if;
end
$$;

-- =========================================================
-- DONE
-- =========================================================
