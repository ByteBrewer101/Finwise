# FinWise AI — Flutter Fintech Application

FinWise AI is an **enterprise-grade Flutter fintech application** built with long-term scalability, maintainability, and production safety as first-class goals.

This project follows **Clean Architecture + Feature-first design** and is structured to support future growth without architectural rewrites.


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

The app follows a **layered, unidirectional flow**:

UI → Provider → UseCase → Repository → DataSource → API



### Why this matters:
- Business logic is testable
- UI remains dumb & replaceable
- Networking is centralized
- Storage is abstracted
- Features don’t leak into each other

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


---

## 🧰 Tech Stack (Locked)

| Concern | Technology |
|------|-----------|
| State management | Riverpod |
| Navigation | GoRouter |
| Networking | Dio |
| Models | Freezed + JSON Serializable |
| Local storage | Hive |
| Charts | fl_chart |
| Icons | flutter_svg |
| Fonts | google_fonts |
| Formatting | intl |
| Logging | logger |
| Architecture | Clean Architecture + Feature-first |

> Stack changes require architectural justification.

---

## 🔐 Authentication Strategy

- **JWT-based authentication**
- Access token: short-lived (memory)
- Refresh token: long-lived (Hive)
- Auto-refresh handled via Dio interceptor
- Auth state managed centrally via Riverpod
- UI never handles tokens directly

---

## 🌍 Environment Configuration

Supported environments:

.env.dev
.env.staging
.env.prod



Each environment defines:
- API base URL
- log level
- runtime behavior

No hardcoded URLs.  
No secrets in code.

---

## 🚦 Navigation Rules

- All navigation is centralized via GoRouter
- Route guards are auth-aware
- Screens never decide navigation logic
- SplashGate is the single entry decision point

---

## 🧠 State Management Rules

- Providers contain business logic
- UI consumes state only
- No API calls in widgets
- No storage access in UI
- No navigation inside providers (except via router logic)

---

## 📡 Networking Rules

- Features never call Dio directly
- All API access goes through repositories
- Interceptors handle:
  - auth headers
  - token refresh
  - retries
  - logging
  - error mapping

---

## ❗ Error Handling Philosophy

Every async operation supports:

- Loading
- Success
- Empty
- Error

No silent failures.  
No swallowed exceptions.

---

## 💾 Offline & Storage Strategy

- Hive is used for:
  - auth persistence
  - session cache
  - user preferences
  - offline fallback
- Hive access is restricted to `core/storage`

---

## 🧪 Test Readiness

The architecture supports:
- provider unit tests
- repository tests
- model serialization tests

Test folder mirrors `lib/` structure.

---

## 🛑 Coding Rules (Non-Negotiable)

### NEVER:
- Mix UI and business logic
- Call APIs inside widgets
- Access Hive outside core/storage
- Hardcode styles or dimensions
- Bypass provider layer
- Add random packages

### ALWAYS:
- Keep files small & focused
- Follow feature boundaries
- Use centralized systems
- Write predictable code
- Think production-first

---

## 🚀 Development Workflow

1. Architecture first
2. Domain logic second
3. UI last
4. Test continuously
5. No blind releases

---

## 🧭 Status

- Foundation: ✅ Completed
- Environment setup: ✅ Completed
- Routing: ✅ Completed
- Auth architecture: 🟡 In progress
- UI: ⏳ Pending (Figma)

---
