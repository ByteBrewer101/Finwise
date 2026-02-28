# FinWise

FinWise is a Flutter personal finance app built with Riverpod and Supabase.

Current scope:
- Auth (email/password + Google via Supabase Auth)
- Onboarding and guarded routing
- Home summary (wallet balance + transactions)
- Budget creation and tracking
- Goals and contributions
- Basic profile tab (UI pending completion)

Out of scope for now:
- AI assistant/features (explicitly deferred)

## Design Source

UI implementation is based on provided Figma reference screenshots. Functionality should remain unchanged while UI is aligned progressively.

## Tech Stack

- Flutter
- Riverpod
- GoRouter
- Supabase (Auth + Postgres)
- SharedPreferences
- Hive (initialized; not primary persistence for domain data)

## Project Structure

`lib/`
- `core/` theme, router, providers, utils
- `features/` auth, home, budget, goals, analysis, profile
- `shared/` reusable widgets/components
- `services/` Supabase bootstrap/provider

`supabase/migrations/`
- SQL schema, policies, triggers, and RPC functions

## Runtime Flow

1. `main.dart` initializes Flutter, Hive, env, and Supabase.
2. Router checks:
   - first launch flag (`first_launch`) for onboarding
   - Supabase session for authenticated routes
3. App loads feature tabs: Home, Budget, Analysis, Goals, Profile.

## Environment

Environment files:
- `.env.dev`
- `.env.staging`
- `.env.prod`

Required keys:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

`main.dart` currently loads `.env.dev` by default.

## Database Overview (Supabase)

Core tables:
- `profiles`
- `wallets`
- `categories`
- `transactions`
- `budgets`
- `goals`
- `goal_contributions`

Important DB behavior:
- RLS policies for per-user access
- New-user trigger seeds profile, wallet, and default categories
- Wallet balance trigger syncs on transaction insert/delete
- Goal amount trigger syncs on contribution insert/delete
- Goal delete RPC (`delete_goal_atomic`) removes linked transactions safely
- Budget spending RPC supports both category-based and `budget_id`-linked expenses

## Development Notes

- Keep functionality unchanged during UI alignment.
- Use INR/rupee formatting consistently.
- Prefer `CurrencyFormatter` instead of hardcoded currency symbols where possible.

## Next Focus

Primary next milestone: complete Profile page (data + edit flow + logout + wallet/profile settings entry points).
