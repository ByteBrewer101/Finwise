-- =========================================================
-- FIX: Ensure goal_contributions.transaction_id has ON DELETE CASCADE
-- =========================================================

-- Drop existing foreign key
alter table public.goal_contributions
drop constraint if exists goal_contributions_transaction_id_fkey;

-- Recreate foreign key with CASCADE
alter table public.goal_contributions
add constraint goal_contributions_transaction_id_fkey
foreign key (transaction_id)
references public.transactions(id)
on delete cascade;