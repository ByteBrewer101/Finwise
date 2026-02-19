-- =========================================================
-- 05_GOALS_SCHEMA_UPGRADE
-- =========================================================

-- 1️⃣ Add target_for column
alter table public.goals
add column if not exists target_for text;

-- 2️⃣ Add contribution column
alter table public.goals
add column if not exists contribution numeric(12,2) default 0
check (contribution >= 0);

-- 3️⃣ Ensure target_amount positive
alter table public.goals
drop constraint if exists goals_target_amount_check;

alter table public.goals
add constraint goals_target_amount_check
check (target_amount > 0);

-- 4️⃣ Ensure current_amount never negative
alter table public.goals
drop constraint if exists goals_current_amount_check;

alter table public.goals
add constraint goals_current_amount_check
check (current_amount >= 0);
