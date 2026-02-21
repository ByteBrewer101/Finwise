-- =========================================================
-- LINK GOAL CONTRIBUTIONS TO TRANSACTIONS (CASCADE SAFE)
-- =========================================================

alter table public.goal_contributions
add column if not exists transaction_id uuid
references public.transactions(id)
on delete cascade;

create index if not exists goal_contributions_transaction_idx
on public.goal_contributions(transaction_id);