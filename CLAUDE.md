# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**DiveDataPro** (package name: `divedatapro`) is a professional cross-platform mobile app (Android/iOS/Web) for divers to log, track, and manage diving sessions. It uses an **offline-first hybrid repository pattern** with local SQLite storage (mobile) / shared_preferences (web) and Firebase Firestore for cloud sync.

- **Framework**: Flutter (Dart SDK ^3.6.0)
- **State Management**: Provider (ChangeNotifier)
- **Navigation**: GoRouter
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Local Storage**: sqflite (mobile), shared_preferences (web fallback)
- **Payments**: RevenueCat (purchases_flutter)

## Key Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run tests
flutter test                    # All tests
flutter test test/unit/         # Unit tests only
flutter test test/widgets/      # Widget tests only
flutter test test/screens/      # Screen tests only
flutter test test/models/       # Model tests only

# Static analysis
flutter analyze

# Format code
dart format .

# Fix lint issues
dart fix --apply

# Build for platforms
flutter build apk               # Android APK
flutter build ios               # iOS (requires Xcode)
flutter build web               # Web

# Generate app icons (after updating pubspec.yaml)
flutter pub run flutter_launcher_icons:main

# Firebase deploy (if configured)
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
firebase deploy --only hosting
```

## Architecture

### Layer Structure

```
lib/
├── main.dart                      # App entry, providers, theme, error boundary
├── theme.dart                     # Centralized theming (Material 3, light/dark)
├── firebase_options.dart          # Auto-generated Firebase config
├── config/                        # App configuration (Stripe, etc.)
├── auth/                          # Authentication abstraction layer
│   ├── auth_manager.dart          # Abstract auth interface + mixins
│   └── firebase_auth_manager.dart # Firebase implementation
├── models/                        # Data models
│   ├── dive_session.dart          # Core dive model (serialization: JSON, Firestore)
│   ├── user_profile.dart          # User profile model
│   └── dive_operator.dart         # Operator reference model
├── providers/
│   └── dive_provider.dart         # Main state (ChangeNotifier), orchestrates services
├── screens/                       # UI screens (GoRouter destinations)
├── services/                      # Business logic & data layer
│   ├── dive_service.dart          # Central coordinator (Offline-First sync logic)
│   ├── database_helper.dart       # SQLite CRUD (singleton, migrations v1-v5)
│   ├── database_helper_stub.dart  # Web stub for database_helper
│   ├── storage_service.dart       # Platform-agnostic storage (SQLite + Web)
│   ├── storage_service_web.dart   # Web shared_preferences implementation
│   ├── firestore_dive_service.dart# Firestore CRUD + queries (singleton)
│   ├── firestore_user_service.dart# Firestore user profile ops
│   ├── firebase_storage_service.dart # Firebase Storage (images)
│   ├── user_service.dart          # User profile coordination
│   ├── subscription_service.dart  # RevenueCat integration
│   └── export_service.dart        # PDF/CSV export
├── widgets/                       # Reusable UI components
└── utils/
    └── validators.dart            # Form validation helpers
```

### Offline-First Sync Pattern (Critical)

**DiveService** (`lib/services/dive_service.dart`) is the central coordinator implementing the hybrid repository pattern:

1. **Local-First Writes**: All create/update/delete operations hit SQLite/storage_service first, marking `isSynced=false`
2. **Background Sync**: If online, immediately attempts Firestore sync; on success, updates local `isSynced=true`, `lastSyncedAt`
3. **Connectivity Listener**: Uses `connectivity_plus` to detect online/offline transitions; auto-triggers `syncPendingDives()` on reconnect
4. **Conflict Resolution**: Last-Write-Wins (server timestamp wins); `syncFromFirestore()` pulls remote data on startup/login
5. **Sync Status Stream**: Exposes `syncStatusStream` (SyncStatus enum: syncing, completed, error, offline, reconnected) for UI indicators

**Key Classes**:
- `DiveService` (singleton): Coordinates local + remote, manages connectivity
- `DatabaseHelper` (singleton): Raw SQLite with migrations (version 5)
- `StorageService`: Platform abstraction (`kIsWeb` → `WebStorageService` : `DatabaseHelper`)
- `FirestoreDiveService` (singleton): Firestore CRUD, queries, real-time streams

### Data Models

**DiveSession** (`lib/models/dive_session.dart`) - 48 fields covering:
- General: client, vessel, operator, location, dive type, buddy list, supervisor
- Conditions: Beaufort sea state (0-12), visibility, water/surface temp, current, water type
- Technical: entry/exit time, max depth, surface interval, bottom time, deco stops, total time
- Work/Safety: job description, deco method, injury/illness, cumulative supervision/bottom time
- Sync metadata: `isSynced`, `lastSyncedAt`, `createdAt`, `updatedAt`

Serialization: `toJson()` (local/SQLite), `toFirestore()` (cloud), `fromJson()`, `fromFirestore()`, `copyWith()`

### Authentication

Abstract `AuthManager` with mixins for each provider (Email, Anonymous, Apple, Google, JWT, Phone, Facebook, Microsoft, GitHub). Concrete implementation: `FirebaseAuthManager` (`lib/auth/firebase_auth_manager.dart`).

Auth flow: `AuthWrapper` → `LoginScreen` / `MainNavigationScreen` (based on `authStateChanges`).

### Navigation

GoRouter configured in `lib/screens/main_navigation_screen.dart` with:
- `/` → HomeScreen (dashboard)
- `/dives` → DiveListScreen
- `/dives/add` → AddEditDiveScreen
- `/dives/edit/:id` → AddEditDiveScreen
- `/statistics` → StatisticsScreen
- `/profile` → ProfileScreen
- `/paywall` → PaywallScreen
- `/privacy` → PrivacyPolicyScreen
- `/login` → LoginScreen

### Theming

`theme.dart` defines:
- `AppSpacing` / `AppRadius` constants
- `LightModeColors` / `DarkModeColors` (ocean/diving palette)
- `FontSizes` constants
- `lightTheme` / `darkTheme` (Material 3, ColorScheme.fromSeed, GoogleFonts.inter)
- `AppEffects` for glassmorphism/shadows

Use `Theme.of(context)` and extensions (`context.textStyles`, `style.bold`, etc.)

### State Management

Single `DiveProvider` (ChangeNotifier) wraps `DiveService`:
- Loads data via `initialize(userId)` (called from auth wrapper)
- Exposes: `allDives`, `recentDives`, `statistics`, `userProfile`, `isPremium`
- Sync status via `syncStatus`, `isOnline`, `isSyncing`, `pendingSyncCount`
- CRUD: `createDive()`, `updateDive()`, `deleteDive()`, `refreshData()`, `manualSync()`

### Testing Structure

```
test/
├── unit/           # Pure Dart logic (models, services, validators)
├── widgets/        # Widget tests (components)
├── screens/        # Screen/widget integration tests
├── models/         # Model serialization tests
├── utils/          # Utility function tests
└── flutter_test_config.dart  # Test configuration
```

Run specific test file: `flutter test test/unit/dive_session_test.dart`

### Firebase Configuration

- Project: `divedatapro` (northamerica-south1)
- `firebase.json` configures: Firestore rules/indexes, Storage rules, Hosting
- **Important**: Current `firestore.rules` are **open for testing** (expire 2026-07-23). Must write proper security rules before expiry.
- Required files (not in repo): `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`

### Platform-Specific Notes

- **Web**: Uses `database_helper_stub.dart` + `storage_service_web.dart` (shared_preferences)
- **Mobile**: Uses `sqflite` via `DatabaseHelper`
- Conditional imports via `dart.library.html` and `kIsWeb`

### Development Guidelines (from README)

- **Language**: Code in English, UI text in Spanish
- **Routing**: Always use GoRouter (`context.go` / `context.push`)
- **Styling**: Use `Theme.of(context)` and `lib/theme.dart` constants
- **Code Quality**: Run `flutter analyze` before committing
- **Logging**: Use `logging` package (see `main.dart` setup), not `print`

### Plan-Driven Workflow

`plan.md` in the repo root is the source of truth for phases, tasks, and subtasks.

- Always follow the implementation plan described in `plan.md`.
- Always update `plan.md` to track phases, tasks, and subtasks as work progresses.
- Always run the Testing phase after every phase, as described in `plan.md`.

### Common Patterns

**Adding a new screen**:
1. Create in `lib/screens/`
2. Add route in `main_navigation_screen.dart`
3. Use `context.push('/route')` or `context.go('/route')`

**Adding a new model field**:
1. Update `DiveSession` (all 4 factory constructors + `copyWith` + `toJson` + `toFirestore`)
2. Update `DatabaseHelper._onCreate` (if new column) + `_onUpgrade` migration
3. Update `FirestoreDiveService` queries if needed

**Working with async services**: Services use singleton pattern (`factory ClassName() => _instance`). Call `initialize(userId)` before use.

**Sync status UI**: Listen to `provider.syncStatus` (SyncStatus enum) and `provider.isOnline`/`provider.pendingSyncCount`