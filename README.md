# Finwise

Finwise is a Flutter personal finance app built with Riverpod, Supabase, and a local-first data flow. The app uses local storage for day-to-day reads/writes and syncs with Supabase in the background, so the UI stays responsive and user data remains isolated per account.

AI features are intentionally out of scope for now.

## Current Status

Implemented:
- Onboarding flow with animated bottom-panel interaction
- Email/password auth
- Google OAuth auth for mobile deep link flow
- Auth-guarded routing with first-launch handling
- Home dashboard
- Add transaction flow
- Full budget flow
- Full goals flow
- Analysis screen with Income / Expenses / Saving tabs
- Profile screen with edit profile and change password
- Local-first persistence with background Supabase sync

In progress / not implemented:
- AI assistant features
- Some secondary actions still show `Feature coming soon`
- Automated test coverage is still minimal compared to the app surface

## Tech Stack

- Flutter
- Riverpod
- GoRouter
- Supabase Auth + Postgres
- Hive for local persistence
- SharedPreferences
- fl_chart

## Architecture

The app follows the existing feature-based structure and clean layering already present in the codebase:

- `lib/core/`
  - routing, theme, global providers, utilities
- `lib/features/`
  - `auth`
  - `home`
  - `budget`
  - `goals`
  - `analysis`
  - `profile`
- `lib/services/`
  - local database
  - Supabase bootstrap
  - sync manager / sync service
- `supabase/migrations/`
  - schema, triggers, guards, policies, and RPCs

## Local-First Workflow

This app no longer relies on direct Supabase reads from every screen interaction.

Actual runtime pattern:
- App starts
- Hive and local database initialize
- Supabase initializes
- Sync bootstrap runs
- Feature providers read from local storage first
- If local data is missing or stale, sync pulls from Supabase
- CRUD flows update local state and use the existing sync path

Important behavior:
- User-scoped local data is isolated per authenticated user
- Logout clears user-scoped local cached data and sync state
- Providers read from the same local-first repository/provider pattern across Home, Budget, Goals, Analysis, and Profile

## App Flow

1. `main.dart` initializes Flutter bindings, Hive, local DB, env, Supabase, and shared preferences.
2. Router checks:
   - `first_launch`
   - current Supabase session
3. User sees:
   - onboarding on first launch
   - login/register when unauthenticated
   - tab shell when authenticated
4. Main tabs:
   - Home
   - Budget
   - Analysis
   - Goals
   - Profile

## Feature Summary

### Auth

- Email/password login and registration
- Google sign-in via Supabase OAuth mobile callback
- Guarded navigation with onboarding and auth redirects
- Improved timeout/error handling in login flow

Important mobile OAuth detail:
- Redirect URL used by app: `io.supabase.flutter://login-callback`

### Home

- Wallet-backed total balance
- Portfolio card based on transaction data
- Latest transactions
- Pull-to-refresh style data refresh logic via sync + provider reloads

### Budget

- Create and edit budgets
- Budget detail view
- Budget progress based on linked spending logic
- Completion state handling
- Financial edit guards to stop invalid target reductions

### Goals

- Create and edit goals
- Goal preview / detail flow
- Goal contribution tracking
- Goal completion handling
- Financial edit guards to stop invalid target reductions

### Analysis

- Income tab
  - total income
  - monthly chart
  - latest income history
  - See More navigation
- Expenses tab
  - total expense
  - category breakdown
  - monthly chart
  - latest expense history
  - See More navigation
- Saving tab
  - saved balance
  - completed target summary based on real goals data
  - goals progress preview with See More
  - budget control preview with See More

### Profile

- View current profile
- Edit profile
- Change password
- Logout

## Environment Setup

Environment files in project root:
- `.env.dev`
- `.env.staging`
- `.env.prod`

Required keys:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Current default:
- `main.dart` loads `.env.dev`

## Supabase Database Overview

Primary tables:
- `profiles`
- `wallets`
- `categories`
- `transactions`
- `budgets`
- `goals`
- `goal_contributions`

Database behavior already implemented through migrations:
- per-user RLS policies
- profile insert policy alignment
- new-user bootstrap behavior
- wallet balance trigger support
- wallet trigger update support
- goal amount tracking
- goal-to-transaction linkage
- budget-to-transaction linkage
- delete-goal atomic flow
- financial integrity guards for edit/update flows

Current migration set:
- `01_extensions.sql`
- `02_core_tables.sql`
- `03_triggers_and_wallet.sql`
- `04_goals_financial.sql`
- `05_budget_functions.sql`
- `06_schema_alignment.sql`
- `07_goal_transaction_link.sql`
- `08_goal_transaction_link.sql`
- `09_fix_goal_transaction_cascade.sql`
- `11_delete_goal_atomic.sql`
- `12_budget_transaction_link.sql`
- `13_profiles_insert_policy.sql`
- `14_wallet_trigger_update_support.sql`
- `15_financial_integrity_edit_guards.sql`

## Important Reliability Rules

These are part of the current workflow and should be preserved when making changes:

- Do not bypass providers with direct UI-side Supabase calls
- Keep aggregation logic in provider/domain layers, not inside widgets
- Use `CurrencyFormatter` for amounts
- Keep latest-first ordering consistent for transactions/history views
- Respect provider invalidation patterns after CRUD
- Preserve user isolation in local DB and sync logic
- Do not reintroduce stale-user leakage across logins

## Development Workflow

Typical local workflow:

1. Update feature/domain/provider code
2. Run:
   - `flutter analyze`
   - `flutter test`
3. If schema changes are needed:
   - add a new migration in `supabase/migrations/`
   - do not edit old migrations retroactively
4. Verify:
   - local-first reads still work
   - sync path still works
   - provider invalidation is correct
   - logout/login does not leak old user data

## Key UX / Product Decisions

- Rupee / INR formatting is the default display behavior unless another currency is stored on the record
- Figma screenshot references are being implemented progressively without changing working business logic
- Some non-critical buttons intentionally remain placeholders until backend/product scope is ready

## Known Gaps

- README-level setup for iOS app naming is not documented because iOS runner files are not currently present in this workspace state
- Some screens still rely on placeholder actions for non-core features like notifications, rebalance, and support flows
- Test coverage should be expanded for financial integrity, sync edge cases, and auth/device scenarios

## Recommended Checks Before Release

- Login/logout across multiple accounts
- Cold start sync on fresh install
- Budget progress correctness
- Goal completion correctness
- Transaction ordering latest-first
- Keyboard-safe auth screens
- Analysis tab summaries matching local data
- Google OAuth redirect behavior on Android

