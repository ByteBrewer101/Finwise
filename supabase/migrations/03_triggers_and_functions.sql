-- =========================================================
-- HANDLE NEW USER
-- =========================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin

  insert into public.profiles (id, full_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1))
  );

  insert into public.wallets (user_id, name, type, balance, currency)
  values (new.id, 'Cash', 'cash', 0, 'INR');

  insert into public.categories (user_id, name, type, is_default)
  values
    (new.id, 'Food', 'expense', true),
    (new.id, 'Pets', 'expense', true),
    (new.id, 'Fashion', 'expense', true),
    (new.id, 'Salary', 'income', true);

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();


-- =========================================================
-- WALLET BALANCE SYNC
-- =========================================================

create or replace function public.sync_wallet_balance()
returns trigger
language plpgsql
security definer
as $$
declare
  current_balance numeric;
begin

  if (tg_op = 'INSERT') then

    if new.type = 'income' then
      update public.wallets
      set balance = balance + new.amount
      where id = new.wallet_id;

    elsif new.type = 'expense' then
      select balance into current_balance
      from public.wallets
      where id = new.wallet_id
      for update;

      if current_balance - new.amount < 0 then
        raise exception 'Insufficient wallet balance';
      end if;

      update public.wallets
      set balance = balance - new.amount
      where id = new.wallet_id;

    elsif new.type = 'transfer' then
      select balance into current_balance
      from public.wallets
      where id = new.wallet_id
      for update;

      if current_balance - new.amount < 0 then
        raise exception 'Insufficient wallet balance for transfer';
      end if;

      update public.wallets
      set balance = balance - new.amount
      where id = new.wallet_id;

      update public.wallets
      set balance = balance + new.amount
      where id = new.target_wallet_id;
    end if;

  elsif (tg_op = 'DELETE') then

    if old.type = 'income' then
      select balance into current_balance
      from public.wallets
      where id = old.wallet_id
      for update;

      if current_balance - old.amount < 0 then
        raise exception 'Cannot revert income. Balance would go negative.';
      end if;

      update public.wallets
      set balance = balance - old.amount
      where id = old.wallet_id;

    elsif old.type = 'expense' then
      update public.wallets
      set balance = balance + old.amount
      where id = old.wallet_id;

    elsif old.type = 'transfer' then
      select balance into current_balance
      from public.wallets
      where id = old.target_wallet_id
      for update;

      if current_balance - old.amount < 0 then
        raise exception 'Cannot revert transfer. Target wallet insufficient.';
      end if;

      update public.wallets
      set balance = balance + old.amount
      where id = old.wallet_id;

      update public.wallets
      set balance = balance - old.amount
      where id = old.target_wallet_id;
    end if;

  end if;

  return null;
end;
$$;



drop trigger if exists wallet_balance_trigger on public.transactions;

create trigger wallet_balance_trigger
after insert or delete
on public.transactions
for each row execute procedure public.sync_wallet_balance();
