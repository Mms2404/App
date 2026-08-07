# MMS — 5-in-1 Flutter Practice App

> A showcase of one year of Flutter learning (March 2025 – 2026), built as five fully functional mini-apps inside a single shell. Every app deliberately uses a different state management approach, backend, and architecture — so the project itself is a map of the Flutter ecosystem.


<img width="1536" height="1024" alt="5 in 1" src="https://github.com/user-attachments/assets/198cb7d1-6e4d-45e7-980c-1a92850719a4" />


---

## What's inside

| # | App | State Management | Backend | Architecture |
|---|-----|-----------------|---------|--------------|
| 1 | **Search** | `setState` | Gemini API + YouTube Data API v3 | Single-screen, parallel futures |
| 2 | **Plant Shop** | `Provider` + `ChangeNotifier` | Django REST Framework + Razorpay | Repository pattern |
| 3 | **Expense Tracker** | `Riverpod` + `Freezed` | Django REST Framework (token auth) | Full Clean Architecture |
| 4 | **Chat** | `Bloc` (3 blocs) | Firebase Auth (Phone OTP) + Firestore | Full Clean Architecture |
| 5 | **Music** | `Cubit` | Supabase (Postgres + Storage) | Full Clean Architecture |

---

## Architecture overview

### Home shell
A single `app_home.dart` hosts all five apps with:
- An animated 3D perspective drawer (sidebar) built with `Matrix4` transforms
- A Rive-animated bottom navigation bar
- A `_setChromeVisible(bool)` callback system — child features can hide the nav bar and sidebar when they go deep into secondary screens (used by Chat detail screen and the entire Music feature)
- An `OrbBackground` ambient glow effect shared across the dark-themed apps

### Clean Architecture (Expense Tracker, Chat, Music)
```
feature/
├── data/           ← repository impl, models, mappers, external SDKs
├── domain/
│   ├── entities/   ← pure Dart, zero external imports
│   └── usecases/   ← one class per operation, wraps repository
└── presentation/
    ├── bloc/ or cubit/   ← state management
    └── screens/          ← pure UI, no business logic
```
The domain layer has zero Flutter or SDK imports — entities are plain Dart classes. Repositories map SDK types (Firestore `DocumentSnapshot`, Supabase rows) to domain entities before returning them upward. Blocs and Cubits depend only on use cases, never on repositories directly.

---

## App 1 — Search

**What it does:** enter any query → Gemini answers it + YouTube returns related videos, both fetched in parallel.

**Key concepts demonstrated:**
- `Future.wait([geminiSearch(prompt), youtubeSearch(prompt)])` — parallel async calls
- Full error-state machine: quota exceeded, network failure, timeout, safety block, YouTube-specific failures — each mapped to a friendly message
- `setState` as the right tool for isolated single-screen state with no shared data

**APIs used:**
- Google Gemini API (`google_generative_ai` package)
- YouTube Data API v3 (direct HTTP via `http` package)

---

## App 2 — Plant Shop

**What it does:** browse succulents and pots, add to cart, checkout with Razorpay online payment or Cash on Delivery, track order status by phone number. Admins can log in (double-tap the plant logo) to see all orders and update statuses.

**Key concepts demonstrated:**
- `Provider` + `ChangeNotifier` for shared cart state across screens
- Full Razorpay payment flow in 5 phases:
  1. Flutter sends cart to Django → Django creates `Order` (status `pending`) + Razorpay order server-side
  2. Flutter opens Razorpay payment sheet with `razorpay_order_id`
  3. Customer pays
  4. Flutter sends `payment_id` + `signature` to Django `/verify/`
  5. Django verifies HMAC signature → marks order `confirmed` + stores `payment_id`
- Razorpay webhook as safety net (handles Flutter crash mid-payment)
- Cash on Delivery path — skips Razorpay entirely, order goes straight to `pending_cod`
- Admin panel behind a double-tap gesture on the logo — uses Django token auth
- Customer order tracking by phone number — no auth needed
- `Dio` for HTTP, `TokenInterceptor` for auth headers

**Backend:** Django + Django REST Framework
- `myShop` app: `Succulent`, `Pot`, `Order`, `OrderItem` models
- Server-side total calculation (never trust client)
- `transaction.atomic()` wrapping order creation + Razorpay API call
- `OrderItem` stores price snapshot so history never breaks on price changes

---

## App 3 — Expense Tracker

**What it does:** log in with Django token auth, add/edit/delete personal expenses with title, amount, category, date, and description. Filter by category. View total or monthly summary.

**Key concepts demonstrated:**
- `Riverpod` for state management — `AsyncNotifier`, `StateNotifier`, scoped providers
- `Freezed` for immutable, code-generated state and model classes (`@freezed`, `copyWith`, `when`)
- Full Clean Architecture with 3 layers — domain has zero Flutter imports
- Token-based auth: login → store token → attach to every request via Dio interceptor
- Category dropdown with 11 categories, each with icon + color — handles legacy free-text category values gracefully via `categoryFor()` fallback
- Date picker wired to an `AbsorbPointer`-wrapped field
- Validators extracted into `AppValidators` utility class

**Backend:** Django REST Framework
- Per-user expense filtering (`filter(user=request.user)`)
- Auto-assigns ownership on create
- Token auth via `rest_framework.authtoken`

---

## App 4 — Chat

**What it does:** sign in with your phone number via Firebase Phone OTP → see your chat list → start a new conversation by searching users → real-time messaging with reply, delete, date separators, online/last-seen status, unread badge counts, and a "Notes to self" self-chat.

**Key concepts demonstrated:**
- `Bloc` with 3 separate blocs, each owning a distinct concern:
  - `AuthBloc` — OTP send, verify, session restore, logout
  - `ChatListBloc` — real-time Firestore chat list stream, user search, open/create chat
  - `MessagesBloc` — real-time message stream, send, delete, reply, mark-as-read
- Events and states defined as `part of` files for clean separation
- `BlocConsumer` for side effects (navigation) + UI rebuild separation
- `BlocListener` in gateway to subscribe/unsubscribe Firestore streams on auth state change
- `MultiRepositoryProvider` + `MultiBlocProvider` at the gateway level — all blocs survive navigation between list and detail
- Firebase Phone Auth with `verifyPhoneNumber`, auto-retrieval on Android, 6-digit OTP boxes with auto-focus and auto-submit
- Firestore structure: `users/{phone}`, `chats/{chatId}`, `chats/{chatId}/messages/{msgId}`
- Chat ID = sorted phone numbers joined by `_` — deterministic, no duplicates
- Batch writes for send (message + chat metadata update in one atomic operation)
- Swipe-to-reply (horizontal drag with 40px threshold), long-press delete (soft delete — "This message was deleted")
- Unread count per user stored in `unreadCounts` map on the chat doc, reset on `markAsRead`

**Clean Architecture mapping:**
- `data/chat_models.dart` — Firestore ↔ model, `.toEntity()` extension mappers
- `data/chat_repository.dart` — all Firebase calls, returns domain entities
- `domain/entities/chat_entities.dart` — `ChatUserEntity`, `MessageEntity`, `ChatEntity` — pure Dart
- `domain/usecases/chat_usecases.dart` — 10 use cases, one class each
- `presentation/auth/bloc/` — `AuthBloc`, `AuthEvent`, `AuthState`
- `presentation/chat_list/bloc/` — `ChatListBloc`, events, states
- `presentation/messages/bloc/` — `MessagesBloc`, events, states

---

## App 5 — Music (diveIn)

**What it does:** a dark-themed music player + voice recorder. Browse songs by category, play with full controls (play/pause, next, prev, seek, shuffle, repeat), record voice memos, upload both songs and recordings to Supabase. Anyone can add or delete — fully open, no auth.

**Key concepts demonstrated:**
- `Cubit` — simpler than Bloc, no event layer, direct method calls (`cubit.play()`, `cubit.seek()`, `cubit.toggleRepeat()`)
- `just_audio` for real audio streaming directly from Supabase public URLs — no file download
- `record` package for real microphone capture → `.m4a` file → uploaded to Supabase Storage
- `_isLoadingTrack` guard flag preventing `ProcessingState.completed` from firing `_next()` while a new track is loading (the "3rd song stops playing" bug fix)
- Optimistic UI — `togglePlayPause` emits new state before awaiting the player so icons update instantly
- Recording playback isolated from track playback via `playingRecordingId` state — prevents recording completion from triggering `_next()`
- `MiniPlayer` and `NowPlayingSheet` both use `BlocBuilder` reading live Cubit state — no prop-drilling of `isPlaying`/`progress`
- Per-category artwork gradients — `SongCategory.gradient` getter maps each category to its own `LinearGradient`
- Swipe-to-enter splash screen with `CustomPainter` ripple expanding from the exact touch point
- Gateway pattern: `MusicGateway` provides the `MusicCubit` above both `MusicSplashScreen` and `MusicScreenWithExit` so state survives navigation between them; chrome (nav bar + sidebar) shown on splash, hidden on music screen

**Supabase structure:**
- `songs` table: `id`, `title`, `artist`, `album`, `duration_secs`, `category`, `storage_path`, `is_recording`
- `recordings` table: `id`, `title`, `duration_secs`, `storage_path`, `created_at`
- Storage bucket: `songs` (public) — both regular tracks and voice recordings
- RLS: fully open — anyone can select/insert/delete

---

## Shared systems

### Custom notification system
`AppNotification` — overlay-based, no third-party package.
- Two themes: `dark` (solid `#1C1C1C`, for light-themed screens) and `light` (solid white, for music)
- Stays until manually dismissed via the `×` button — no auto-dismiss timer
- Slide-in + fade animation from top, dispatched via `Overlay`

### Custom `AppTextField`, `AppButton`
Reusable widgets matching the app's dark theme, used across all five apps. `AppButton` supports loading state, trailing icon, disabled state.

### `OrbBackground`
Ambient radial glow background used across auth screens, expense tracker, plant shop — parameterised `blurIntensity` and `brightness`.

### `AppValidators`
Static validators for phone, email, amount, date (YYYY-MM-DD), required, min-length — used across `Form` widgets in signup and expense tracker.

### `AppLogger` (logger package)
Structured logging with `log.d()`, `log.i()`, `log.e()` — used in search and chat flows.

---

## Authentication summary

| App | Auth method | Where stored |
|-----|------------|--------------|
| Expense Tracker | Django token auth | In-memory via Riverpod |
| Chat | Firebase Phone OTP | Firebase session (restored on restart) |
| Plant Shop admin | Django token auth | In-memory (session only) |
| Search | No auth | — |
| Music | No auth | — |

---

## Backend summary

### Django project (`Expense_Tracker/`)
Single Django project, two apps:

**`Expense_Tracker_app`**
- `GET/POST /api/expenses/` — list and create (token auth, per-user)
- `PUT/DELETE /api/expenses/<id>/` — update and delete
- `POST /api/register/` — create user
- `POST /api-token-auth/` — get token

**`myShop`**
- `GET /api/shop/succulents/`, `/pots/` — catalogue
- `POST /api/shop/checkout/` — create order + Razorpay order (or COD)
- `POST /api/shop/payment/verify/` — HMAC verification
- `POST /api/shop/razorpay/webhook/` — Razorpay safety net
- `GET /api/shop/orders/?phone=` — customer order tracking
- `GET /api/shop/admin/orders/` — admin list (token auth)
- `PATCH /api/shop/admin/orders/<id>/` — admin status update (token auth)

### Firebase
- Authentication: Phone provider (SMS OTP)
- Firestore: `users`, `chats`, `chats/{id}/messages` collections

### Supabase
- Postgres: `songs`, `recordings` tables
- Storage: `songs` bucket (public)
- RLS: fully open (no auth in music app by design)

---

## Packages used

```yaml
# State management
flutter_riverpod / riverpod
freezed / freezed_annotation / build_runner / json_serializable
flutter_bloc / bloc

# Firebase
firebase_core / firebase_auth / cloud_firestore

# Supabase
supabase_flutter

# Audio
just_audio
record

# Networking
dio
http

# APIs
google_generative_ai   # Gemini
razorpay_flutter

# UI
flutter_screenutil
rive
flutter_animate
file_picker
geolocator / geocoding
app_settings

# Utilities
logger
path_provider
```

---

## Project structure

```
lib/
├── api/
│   └── keys.dart                    ← API keys (gitignored)
├── core/
│   ├── constants/
│   │   ├── colors.dart
│   │   ├── background.dart          ← OrbBackground
│   │   └── api_config.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── logger.dart
│   │   └── enum.dart
│   └── widgets/
│       ├── buttons.dart             ← AppButton
│       ├── textField.dart           ← AppTextField
│       └── app_notification.dart   ← custom overlay notifications
├── features/
│   ├── authentication/              ← intro, login, signup, verification (UI only)
│   ├── search/                      ← setState + Gemini + YouTube
│   ├── purchase/                    ← Provider + Django + Razorpay
│   │   ├── data/
│   │   ├── providers/
│   │   └── screens/
│   ├── expense_tracker/             ← Riverpod + Clean Arch + Django
│   │   └── expense_tracker/
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   ├── chat/                        ← Bloc + Clean Arch + Firebase
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── auth/bloc/
│   │       ├── chat_list/bloc/
│   │       └── messages/bloc/
│   └── music/                       ← Cubit + Clean Arch + Supabase
│       ├── data/
│       ├── domain/
│       ├── presentation/
│       │   ├── cubit/
│       │   └── screens/
│       └── widgets/
├── app_home.dart                    ← shell: sidebar + Rive bottom nav
└── main.dart
```

---

## What this project taught me

Starting from zero Flutter in March 2025, this project covers:

- Four different state management solutions and **when** to use each one — `setState` for isolated UI, `Provider` for shared widget-tree state, `Riverpod` for complex dependency injection and async, `Bloc`/`Cubit` for event-driven and stream-based flows
- Clean Architecture in practice — not just as a diagram but as code that compiles and ships
- Real payment integration (Razorpay) with server-side verification and webhook fallback
- Real-time data with Firestore streams inside Bloc — `StreamSubscription` management, avoiding leaks on logout
- Audio playback and recording with `just_audio` and `record`, including the subtle bugs (completed-state re-entrancy, optimistic UI for instant feedback)
- Two different backend approaches — Django REST for structured relational data, Supabase for rapid open-access storage
- Firebase Phone Auth end-to-end on Android including SHA-1 fingerprint setup
- Custom Flutter animations: `Matrix4` perspective transforms, `CustomPainter` ripple, `Rive` bottom nav, letter-by-letter text animation
- Building reusable widget systems (`AppButton`, `AppTextField`, `OrbBackground`, `AppNotification`) that work across five visually distinct apps

---

*Built March 2025 – 2026 · Flutter · Dart*
