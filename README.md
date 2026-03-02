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

## Recent Reliability Fixes

- Removed duplicate Home transaction heading (single investment history section).
- Added strict user data isolation in local DB queries and sync.
- Logout now clears:
  - user-scoped local Hive data
  - pending sync queue for that user
  - cached auth tokens
  - sync session bootstrap markers
- Login flow hardened:
  - email/password format validation
  - request timeout handling
  - mounted-safe loading state reset
  - clearer auth/network error messages
- Sync service hardened with timeout + retry for Supabase push/pull calls.
- Added global crash logging hooks for Flutter and platform errors.

## QA Test Matrix

Authentication:
- Login with valid credentials -> navigates to Home.
- Login with invalid credentials -> error shown, loading stops.
- Login with no/slow network -> timeout message shown, loading stops.
- Logout -> redirected to auth flow and no prior user data remains in local cache.
- Login with second account after logout -> balances/portfolio/goals must not show first account data.

Portfolio/Data Isolation:
- Home total balance equals sum of current user wallets only.
- Budget and Goals tabs show only current user data.
- Categories list contains only current user categories.

Sync:
- Cold start with network -> initial sync completes, then data visible.
- App resume/background -> sync runs without crash.
- Temporary sync failures -> retry path logs warning and app remains responsive.

Performance:
- Goals screen opens from local cache without forced network call.
- No repeated loading loops when user has no goals.

## Production Hardening Backlog

Planned next items:
- Pull-to-refresh on Home/Budget/Goals.
- Session expiration UX handling.
- Offline indicator + queued operation status.
- Automated unit/integration tests in `test/`.
- Performance monitoring hooks and startup/load benchmarks.
