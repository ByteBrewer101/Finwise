-- =========================================================
-- 14_WALLET_TRIGGER_UPDATE_SUPPORT
-- Add UPDATE support to wallet balance trigger by reversing OLD
-- effect and then applying NEW effect atomically.
-- =========================================================

create or replace function public.sync_wallet_balance()
returns trigger
language plpgsql
security definer
as $$
declare
  current_balance numeric;
begin

  if tg_op = 'INSERT' then

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

  elsif tg_op = 'DELETE' then

    if old.type = 'income' then
      update public.wallets
      set balance = balance - old.amount
      where id = old.wallet_id;

    elsif old.type = 'expense' then
      update public.wallets
      set balance = balance + old.amount
      where id = old.wallet_id;

    elsif old.type = 'transfer' then
      update public.wallets
      set balance = balance + old.amount
      where id = old.wallet_id;

      update public.wallets
      set balance = balance - old.amount
      where id = old.target_wallet_id;
    end if;

  elsif tg_op = 'UPDATE' then
    -- Reverse OLD effect first.
    if old.type = 'income' then
      update public.wallets
      set balance = balance - old.amount
      where id = old.wallet_id;

    elsif old.type = 'expense' then
      update public.wallets
      set balance = balance + old.amount
      where id = old.wallet_id;

    elsif old.type = 'transfer' then
      update public.wallets
      set balance = balance + old.amount
      where id = old.wallet_id;

      update public.wallets
      set balance = balance - old.amount
      where id = old.target_wallet_id;
    end if;

    -- Apply NEW effect.
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

  end if;

  return null;
end;
$$;

drop trigger if exists wallet_balance_trigger on public.transactions;

create trigger wallet_balance_trigger
after insert or update or delete
on public.transactions
for each row execute procedure public.sync_wallet_balance();

