-- =========================================================
-- 13_PROFILES_INSERT_POLICY
-- Allow users to create their own profile row if missing.
-- =========================================================

drop policy if exists "Profiles: insert own" on public.profiles;
create policy "Profiles: insert own"
on public.profiles for insert
with check (auth.uid() = id);
