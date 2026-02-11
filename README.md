# FinWise AI — Enterprise Flutter Fintech App

FinWise AI is an **enterprise-grade Flutter fintech application** built with a strong focus on **scalability, maintainability, security, and production safety**.

---

## ✅ Core Engineering Principles

- Clean Architecture over shortcuts
- Strict separation of concerns
- Feature isolation
- Centralized networking
- Predictable navigation
- Error-first design
- Offline safety
- Environment separation
- Test readiness
- Production logging
- Minimal future rewrites

---

## 🧱 Architecture Overview

The application follows a **strict unidirectional data flow**:

UI → Provider → UseCase → Repository → DataSource → API

yaml


### Why this matters
- Business logic is testable
- UI remains presentation-only
- Networking is centralized
- Storage is abstracted
- Features do not leak into each other

---

## 📁 Folder Structure (Authoritative)

lib/
├── core/
│ ├── theme/ # Design system (colors, text, spacing, radius)
│ ├── router/ # GoRouter config & route guards
│ ├── network/ # Dio client, interceptors, auth handling
│ ├── storage/ # Hive & secure local storage
│ ├── errors/ # App-wide error & failure models
│ ├── utils/ # Environment, helpers
│ └── widgets/ # Reusable UI components
│
├── features/
│ ├── auth/
│ ├── dashboard/
│ ├── budget/
│ ├── analytics/
│ └── assistant/
│
│ Each feature contains:
│ ├── data/
│ │ ├── datasource/
│ │ └── repository/
│ ├── domain/
│ │ ├── models/
│ │ └── usecases/
│ └── presentation/
│ ├── screens/
│ ├── widgets/
│ └── providers/
│
├── shared/
│ ├── models/ # Cross-feature models
│ └── services/ # Cross-feature services
│
└── main.dart

yaml


This structure is **non-negotiable**.

---

## 🧰 Tech Stack (Locked)

| Concern | Technology |
|------|-----------|
| State Management | Riverpod |
| Navigation | GoRouter |
| Networking | Dio |
| Models | Freezed + JSON Serializable |
| Local Storage | Hive |
| Charts | fl_chart |
| Icons | flutter_svg |
| Fonts | google_fonts |
| Formatting | intl |
| Logging | logger |
| Architecture | Clean Architecture + Feature-first |

Stack changes require architectural justification.

---

## 🔐 Authentication (IMPLEMENTED)

### Strategy
- JWT-based authentication
- Access token (short-lived, memory)
- Refresh token (long-lived, Hive)
- Automatic token refresh via Dio interceptor
- Auth state restored on app restart

### Token Lifecycle

Login API
→ accessToken (memory)
→ refreshToken (Hive)
→ AuthState.authenticated

API Request
→ Authorization header injected automatically

401 Response
→ refresh-token API called
→ new tokens saved
→ original request retried

Refresh Failure
→ tokens cleared
→ AuthState.unauthenticated

yaml


### Rules
- UI never handles tokens
- UI never calls refresh APIs
- Tokens are managed centrally
- Logout clears both memory and storage

---

## 📡 Networking Architecture (IMPLEMENTED)

### API Client
- Single centralized Dio instance
- Environment-based base URL
- Timeouts configured
- Logging enabled only in development

### Interceptors
- **AuthInterceptor**
  - Injects access token
  - Handles 401 responses
  - Refreshes tokens safely
  - Retries failed requests
  - Prevents refresh storms

### Networking Rules
- Features never create their own Dio instances
- All HTTP traffic flows through `ApiClient`
- Interceptors handle auth, logging, and retries

---

## 🗄️ Local Storage (IMPLEMENTED)

### Hive Usage
Hive is used for:
- Refresh token persistence
- Session restoration on app restart

### Storage Rules
- Hive is accessed **only** inside `core/storage`
- Providers and UI never open Hive boxes
- Storage is abstracted via `TokenStorage`

---

## 🔀 Routing & Guards (IMPLEMENTED)

- GoRouter used for navigation
- Centralized route definitions
- `SplashGate` controls initial routing
- Auth-aware redirection:
  - authenticated → dashboard
  - unauthenticated → login

Screens never perform navigation decisions.

---

## 🌍 Environment Configuration

Supported environments:

.env.dev
.env.staging
.env.prod

yaml


Each environment defines:
- API base URL
- log level
- runtime behavior

Environment files are **never committed**.

---

## 🔗 API Endpoints (Current Backend Assumptions)

> These are backend contract assumptions and may change once finalized.

POST /auth/login
POST /auth/refresh
POST /auth/logout

csharp


### Expected Request Payloads

```json
// login
{
  "email": "string",
  "password": "string"
}

// refresh
{
  "refreshToken": "string"
}
Expected Response
json

{
  "accessToken": "string",
  "refreshToken": "string"
}
🧪 Test Readiness
The architecture supports:

Provider unit tests

Repository tests

Model serialization tests

Test folder mirrors the lib/ structure.

🚫 Non-Negotiable Coding Rules
NEVER
Call APIs in widgets

Access Hive outside core/storage

Handle tokens in UI

Perform navigation inside screens

Duplicate Dio instances

Hardcode styles or dimensions

Bypass provider layer

ALWAYS
Keep UI presentation-only

Centralize business logic

Respect feature boundaries

Use shared infrastructure

Write predictable, testable code