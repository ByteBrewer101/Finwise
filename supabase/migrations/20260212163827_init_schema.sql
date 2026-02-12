-- Enable extension
create extension if not exists "pgcrypto";

--------------------------------------------------
-- PROFILES TABLE
--------------------------------------------------

create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  full_name text,
  created_at timestamp with time zone default now()
);

alter table public.profiles enable row level security;

create policy "Users can read own profile"
on public.profiles
for select
using (auth.uid() = id);

create policy "Users can update own profile"
on public.profiles
for update
using (auth.uid() = id);

--------------------------------------------------
-- BUDGETS TABLE
--------------------------------------------------

create table if not exists public.budgets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users on delete cascade,
  name text not null,
  amount numeric not null,
  category text not null,
  wallet text not null,
  recurrence text not null,
  start_date date not null,
  created_at timestamp with time zone default now()
);

alter table public.budgets enable row level security;

create policy "Users can read own budgets"
on public.budgets
for select
using (auth.uid() = user_id);

create policy "Users can insert own budgets"
on public.budgets
for insert
with check (auth.uid() = user_id);

create policy "Users can update own budgets"
on public.budgets
for update
using (auth.uid() = user_id);

create policy "Users can delete own budgets"
on public.budgets
for delete
using (auth.uid() = user_id);

--------------------------------------------------
-- TRANSACTIONS TABLE
--------------------------------------------------

create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users on delete cascade,
  title text not null,
  subtitle text,
  amount numeric not null,
  type text not null,
  category text,
  created_at timestamp with time zone default now()
);

alter table public.transactions enable row level security;

create policy "Users can read own transactions"
on public.transactions
for select
using (auth.uid() = user_id);

create policy "Users can insert own transactions"
on public.transactions
for insert
with check (auth.uid() = user_id);

create policy "Users can update own transactions"
on public.transactions
for update
using (auth.uid() = user_id);

create policy "Users can delete own transactions"
on public.transactions
for delete
using (auth.uid() = user_id);
