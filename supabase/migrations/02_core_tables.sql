-- =========================================================
-- PROFILES
-- =========================================================

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  avatar_url text,
  phone text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.profiles enable row level security;

drop policy if exists "Profiles: select own" on public.profiles;
create policy "Profiles: select own"
on public.profiles for select
using (auth.uid() = id);

drop policy if exists "Profiles: update own" on public.profiles;
create policy "Profiles: update own"
on public.profiles for update
using (auth.uid() = id);

-- =========================================================
-- WALLETS
-- =========================================================

create table if not exists public.wallets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  type text not null check (type in ('cash','bank','card','ewallet')),
  balance numeric not null default 0 check (balance >= 0),
  currency text not null default 'INR',
  is_active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists wallets_user_idx on public.wallets(user_id);

alter table public.wallets enable row level security;

drop policy if exists "Wallets: select own" on public.wallets;
create policy "Wallets: select own"
on public.wallets for select
using (auth.uid() = user_id);

drop policy if exists "Wallets: insert own" on public.wallets;
create policy "Wallets: insert own"
on public.wallets for insert
with check (auth.uid() = user_id);

drop policy if exists "Wallets: update own" on public.wallets;
create policy "Wallets: update own"
on public.wallets for update
using (auth.uid() = user_id);

drop policy if exists "Wallets: delete own" on public.wallets;
create policy "Wallets: delete own"
on public.wallets for delete
using (auth.uid() = user_id);

-- =========================================================
-- CATEGORIES
-- =========================================================

create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  type text not null check (type in ('income','expense')),
  icon text,
  is_default boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists categories_user_idx on public.categories(user_id);

alter table public.categories enable row level security;

drop policy if exists "Categories: select own" on public.categories;
create policy "Categories: select own"
on public.categories for select
using (auth.uid() = user_id or is_default = true);

drop policy if exists "Categories: insert own" on public.categories;
create policy "Categories: insert own"
on public.categories for insert
with check (auth.uid() = user_id);

drop policy if exists "Categories: update own" on public.categories;
create policy "Categories: update own"
on public.categories for update
using (auth.uid() = user_id);

drop policy if exists "Categories: delete own" on public.categories;
create policy "Categories: delete own"
on public.categories for delete
using (auth.uid() = user_id);

-- =========================================================
-- TRANSACTIONS
-- =========================================================

create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,

  wallet_id uuid references public.wallets(id) on delete set null,
  target_wallet_id uuid references public.wallets(id) on delete set null,

  category_id uuid references public.categories(id) on delete set null,

  type text not null check (type in ('income','expense','transfer')),
  amount numeric not null check (amount > 0),
  description text,
  transaction_date date not null,

  -- is_deleted boolean default false,

  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists transactions_user_idx on public.transactions(user_id);
create index if not exists transactions_wallet_idx on public.transactions(wallet_id);
create index if not exists transactions_date_idx on public.transactions(transaction_date);

alter table public.transactions enable row level security;

drop policy if exists "Transactions: select own" on public.transactions;
create policy "Transactions: select own"
on public.transactions for select
using (auth.uid() = user_id);

drop policy if exists "Transactions: insert own" on public.transactions;
create policy "Transactions: insert own"
on public.transactions for insert
with check (auth.uid() = user_id);

drop policy if exists "Transactions: update own" on public.transactions;
create policy "Transactions: update own"
on public.transactions for update
using (auth.uid() = user_id);

drop policy if exists "Transactions: delete own" on public.transactions;
create policy "Transactions: delete own"
on public.transactions for delete
using (auth.uid() = user_id);

-- =========================================================
-- BUDGETS
-- =========================================================

create table if not exists public.budgets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category_id uuid references public.categories(id) on delete cascade,
  wallet_id uuid references public.wallets(id) on delete set null,
  name text not null,
  amount numeric not null check (amount > 0),
  recurrence text not null check (recurrence in ('weekly','monthly','yearly')),
  start_date date not null,
  end_date date,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists budgets_user_idx on public.budgets(user_id);

alter table public.budgets enable row level security;

drop policy if exists "Budgets: select own" on public.budgets;
create policy "Budgets: select own"
on public.budgets for select
using (auth.uid() = user_id);

drop policy if exists "Budgets: insert own" on public.budgets;
create policy "Budgets: insert own"
on public.budgets for insert
with check (auth.uid() = user_id);

drop policy if exists "Budgets: update own" on public.budgets;
create policy "Budgets: update own"
on public.budgets for update
using (auth.uid() = user_id);

drop policy if exists "Budgets: delete own" on public.budgets;
create policy "Budgets: delete own"
on public.budgets for delete
using (auth.uid() = user_id);

-- =========================================================
-- GOALS
-- =========================================================

create table if not exists public.goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  target_amount numeric not null check (target_amount > 0),
  current_amount numeric not null default 0 check (current_amount >= 0),
  currency text default 'INR',
  start_date date,
  end_date date,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists goals_user_idx on public.goals(user_id);

alter table public.goals enable row level security;

drop policy if exists "Goals: select own" on public.goals;
create policy "Goals: select own"
on public.goals for select
using (auth.uid() = user_id);

drop policy if exists "Goals: insert own" on public.goals;
create policy "Goals: insert own"
on public.goals for insert
with check (auth.uid() = user_id);

drop policy if exists "Goals: update own" on public.goals;
create policy "Goals: update own"
on public.goals for update
using (auth.uid() = user_id);

drop policy if exists "Goals: delete own" on public.goals;
create policy "Goals: delete own"
on public.goals for delete
using (auth.uid() = user_id);

-- =========================================================
-- GOAL CONTRIBUTIONS
-- =========================================================

create table if not exists public.goal_contributions (
  id uuid primary key default gen_random_uuid(),
  goal_id uuid not null references public.goals(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  amount numeric not null check (amount > 0),
  contributed_at date not null,
  created_at timestamptz default now()
);

create index if not exists goal_contributions_goal_idx on public.goal_contributions(goal_id);

alter table public.goal_contributions enable row level security;

drop policy if exists "Goal Contributions: select own" on public.goal_contributions;
create policy "Goal Contributions: select own"
on public.goal_contributions for select
using (auth.uid() = user_id);

drop policy if exists "Goal Contributions: insert own" on public.goal_contributions;
create policy "Goal Contributions: insert own"
on public.goal_contributions for insert
with check (auth.uid() = user_id);

drop policy if exists "Goal Contributions: delete own" on public.goal_contributions;
create policy "Goal Contributions: delete own"
on public.goal_contributions for delete
using (auth.uid() = user_id);
