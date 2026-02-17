-- =========================================================
-- GOALS FINANCIAL INTEGRATION (PRODUCTION SAFE)
-- =========================================================

-- =========================================================
-- 1️⃣ LINK GOAL CONTRIBUTIONS TO TRANSACTIONS
-- =========================================================

alter table public.goal_contributions
add column if not exists transaction_id uuid
references public.transactions(id)
on delete cascade;

create index if not exists goal_contributions_transaction_idx
on public.goal_contributions(transaction_id);



-- =========================================================
-- 2️⃣ PREVENT OVERFUNDING A GOAL
-- =========================================================

create or replace function public.prevent_goal_overfunding()
returns trigger
language plpgsql
security definer
as $$
declare
  total_after numeric;
  target numeric;
begin

  select current_amount, target_amount
  into total_after, target
  from public.goals
  where id = new.goal_id
  for update;

  if total_after + new.amount > target then
    raise exception 'Contribution exceeds goal target amount';
  end if;

  return new;
end;
$$;

drop trigger if exists prevent_goal_overfunding_trigger
on public.goal_contributions;

create trigger prevent_goal_overfunding_trigger
before insert
on public.goal_contributions
for each row execute procedure public.prevent_goal_overfunding();



-- =========================================================
-- 3️⃣ SYNC GOAL CURRENT_AMOUNT
-- =========================================================

create or replace function public.sync_goal_amount()
returns trigger
language plpgsql
security definer
as $$
begin

  if (tg_op = 'INSERT') then

    update public.goals
    set current_amount = current_amount + new.amount
    where id = new.goal_id;

  elsif (tg_op = 'DELETE') then

    update public.goals
    set current_amount = current_amount - old.amount
    where id = old.goal_id;

  end if;

  return null;
end;
$$;

drop trigger if exists goal_amount_trigger
on public.goal_contributions;

create trigger goal_amount_trigger
after insert or delete
on public.goal_contributions
for each row execute procedure public.sync_goal_amount();



-- =========================================================
-- 4️⃣ ENSURE GOAL AMOUNT NEVER NEGATIVE (SAFE VERSION)
-- =========================================================

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'goals_current_amount_check'
  ) then
    alter table public.goals
    add constraint goals_current_amount_check
    check (current_amount >= 0);
  end if;
end
$$;



-- =========================================================
-- DONE
-- =========================================================
