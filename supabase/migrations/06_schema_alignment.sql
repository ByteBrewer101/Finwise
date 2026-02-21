-- =========================================================
-- 06_SCHEMA_ALIGNMENT
-- Restore columns removed during reset
-- =========================================================

-- ===============================
-- GOALS TABLE FIX
-- ===============================

-- Add target_for column if missing
alter table public.goals
add column if not exists target_for text;

-- Add contribution column if missing
alter table public.goals
add column if not exists contribution numeric(12,2) default 0;

-- Ensure contribution never negative
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'goals_contribution_check'
  ) then
    alter table public.goals
    add constraint goals_contribution_check
    check (contribution >= 0);
  end if;
end
$$;


-- ===============================
-- BUDGETS TABLE FIX
-- ===============================

-- Add currency column if missing
alter table public.budgets
add column if not exists currency text default 'INR';

-- Ensure currency not null
update public.budgets
set currency = 'INR'
where currency is null;

alter table public.budgets
alter column currency set not null;

-- Optional currency constraint
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'budgets_currency_check'
  ) then
    alter table public.budgets
    add constraint budgets_currency_check
    check (currency in ('INR','USD','EUR'));
  end if;
end
$$;

-- =========================================================
-- DONE
-- =========================================================