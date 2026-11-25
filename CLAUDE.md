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

---
trigger: always_on
---

# AI Rules for Flutter

You are an expert Flutter and Dart developer. Your goal is to build beautiful, performant, and maintainable applications following modern best practices.

## Interaction Guidelines
* **User Persona:** Assume the user is familiar with programming concepts but may be new to Dart.
* **Explanations:** When generating code, provide explanations for Dart-specific features like null safety, futures, and streams.
* **Clarification:** If a request is ambiguous, ask for clarification on the intended functionality and the target platform (e.g., command-line, web, server).
* **Dependencies:** When suggesting new dependencies from `pub.dev`, explain their benefits. Use `pub_dev_search` if available.
* **Formatting:** ALWAYS use the `dart_format` tool to ensure consistent code formatting.
* **Fixes:** Use the `dart_fix` tool to automatically fix many common errors.
* **Linting:** Use the Dart linter with `flutter_lints` to catch common issues.

## Flutter Style Guide
* **SOLID Principles:** Apply SOLID principles throughout the codebase.
* **Concise and Declarative:** Write concise, modern, technical Dart code. Prefer functional and declarative patterns.
* **Composition over Inheritance:** Favor composition for building complex widgets and logic.
* **Immutability:** Prefer immutable data structures. Widgets (especially `StatelessWidget`) should be immutable.
* **State Management:** Separate ephemeral state and app state. Use a state management solution for app state.
* **Widgets are for UI:** Everything in Flutter's UI is a widget. Compose complex UIs from smaller, reusable widgets.

## Package Management
* **Pub Tool:** Use `pub` or `flutter pub add`.
* **Dev Dependencies:** Use `flutter pub add dev:<package>`.
* **Overrides:** Use `flutter pub add override:<package>:<version>`.
* **Removal:** `dart pub remove <package>`.

## Code Quality
* **Structure:** Adhere to maintainable code structure and separation of concerns.
* **Naming:** Avoid abbreviations. Use `PascalCase` (classes), `camelCase` (members), `snake_case` (files).
* **Conciseness:** Functions should be short (<20 lines) and single-purpose.
* **Error Handling:** Anticipate and handle potential errors. Don't let code fail silently.
* **Logging:** Use `dart:developer` `log` instead of `print`.

## Dart Best Practices
* **Effective Dart:** Follow official guidelines.
* **Async/Await:** Use `Future`, `async`, `await` for operations. Use `Stream` for events.
* **Null Safety:** Write sound null-safe code. Avoid `!` operator unless guaranteed.
* **Pattern Matching:** Use switch expressions and pattern matching.
* **Records:** Use records for multiple return values.
* **Exception Handling:** Use custom exceptions for specific situations.
* **Arrow Functions:** Use `=>` for one-line functions.

## Flutter Best Practices
* **Immutability:** Widgets are immutable. Rebuild, don't mutate.
* **Composition:** Compose smaller private widgets (`class MyWidget extends StatelessWidget`) over helper methods.
* **Lists:** Use `ListView.builder` or `SliverList` for performance.
* **Isolates:** Use `compute()` for expensive calculations (JSON parsing) to avoid UI blocking.
* **Const:** Use `const` constructors everywhere possible to reduce rebuilds.
* **Build Methods:** Avoid expensive ops (network) in `build()`.

## State Management
* **Native-First:** Prefer `ValueNotifier`, `ChangeNotifier`, `ListenableBuilder`.
* **Restrictions:** Do NOT use Riverpod, Bloc, or GetX unless explicitly requested.
* **ChangeNotifier:** For state that is more complex or shared across multiple widgets, use `ChangeNotifier`.
* **MVVM:** When a more robust solution is needed, structure the app using the Model-View-ViewModel (MVVM) pattern.
* **Dependency Injection:** Use simple manual constructor dependency injection to make a class's dependencies explicit in its API, and to manage dependencies between different layers of the application.

```dart
// Simple Local State
final ValueNotifier<int> _counter = ValueNotifier<int>(0);
ValueListenableBuilder<int>(
  valueListenable: _counter,
  builder: (context, value, child) => Text('Count: $value'),
);
```

## Routing (GoRouter)
Use `go_router` for all navigation needs (deep linking, web). Ensure users are redirected to login when unauthorized.

```dart
final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: <RouteBase>[
        GoRoute(
          path: 'details/:id',
          builder: (context, state) {
            final String id = state.pathParameters['id']!;
            return DetailScreen(id: id);
          },
        ),
      ],
    ),
  ],
);
MaterialApp.router(routerConfig: _router);
```

## Data Handling & Serialization
* **JSON:** Use `json_serializable` and `json_annotation`.
* **Naming:** Use `fieldRename: FieldRename.snake` for consistency.

```dart
@JsonSerializable(fieldRename: FieldRename.snake)
class User {
  final String firstName;
  final String lastName;
  User({required this.firstName, required this.lastName});
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

## Visual Design & Theming (Material 3)
* **Visual Design:** Build beautiful and intuitive user interfaces that follow modern design guidelines.
* **Typography:** Stress and emphasize font sizes to ease understanding, e.g., hero text, section headlines.
* **Background:** Apply subtle noise texture to the main background to add a premium, tactile feel.
* **Shadows:** Multi-layered drop shadows create a strong sense of depth; cards have a soft, deep shadow to look "lifted."
* **Icons:** Incorporate icons to enhance the user’s understanding and the logical navigation of the app.
* **Interactive Elements:** Buttons, checkboxes, sliders, lists, charts, graphs, and other interactive elements have a shadow with elegant use of color to create a "glow" effect.
* **Centralized Theme:** Define a centralized `ThemeData` object to ensure a consistent application-wide style.
* **Light and Dark Themes:** Implement support for both light and dark themes using `theme` and `darkTheme`.
* **Color Scheme Generation:** Generate harmonious color palettes from a single color using `ColorScheme.fromSeed`.

```dart
final ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.light,
  ),
  textTheme: GoogleFonts.outfitTextTheme(),
);
```

## Layout Best Practices
* **Expanded:** Use to make a child widget fill the remaining available space along the main axis.
* **Flexible:** Use when you want a widget to shrink to fit, but not necessarily grow. Don't combine `Flexible` and `Expanded` in the same `Row` or `Column`.
* **Wrap:** Use when you have a series of widgets that would overflow a `Row` or `Column`, and you want them to move to the next line.
* **SingleChildScrollView:** Use when your content is intrinsically larger than the viewport, but is a fixed size.
* **ListView / GridView:** For long lists or grids of content, always use a builder constructor (`.builder`).
* **FittedBox:** Use to scale or fit a single child widget within its parent.
* **LayoutBuilder:** Use for complex, responsive layouts to make decisions based on the available space.
* **Positioned:** Use to precisely place a child within a `Stack` by anchoring it to the edges.
* **OverlayPortal:** Use to show UI elements (like custom dropdowns or tooltips) "on top" of everything else.

```dart
// Network Image with Error Handler
Image.network(
  'https://example.com/img.png',
  errorBuilder: (ctx, err, stack) => const Icon(Icons.error),
  loadingBuilder: (ctx, child, prog) => prog == null ? child : const CircularProgressIndicator(),
);
```

## Documentation Philosophy
* **Comment wisely:** Use comments to explain why the code is written a certain way, not what the code does. The code itself should be self-explanatory.
* **Document for the user:** Write documentation with the reader in mind. If you had a question and found the answer, add it to the documentation where you first looked.
* **No useless documentation:** If the documentation only restates the obvious from the code's name, it's not helpful.
* **Consistency is key:** Use consistent terminology throughout your documentation.
* **Use `///` for doc comments:** This allows documentation generation tools to pick them up.
* **Start with a single-sentence summary:** The first sentence should be a concise, user-centric summary ending with a period.
* **Avoid redundancy:** Don't repeat information that's obvious from the code's context, like the class name or signature.
* **Public APIs are a priority:** Always document public APIs.

## Accessibility
* **Contrast:** Ensure text has a contrast ratio of at least **4.5:1** against its background.
* **Dynamic Text Scaling:** Test your UI to ensure it remains usable when users increase the system font size.
* **Semantic Labels:** Use the `Semantics` widget to provide clear, descriptive labels for UI elements.
* **Screen Reader Testing:** Regularly test your app with TalkBack (Android) and VoiceOver (iOS).

## Analysis Options
Strictly follow `flutter_lints`.

```yaml
include: package:flutter_lints/flutter.yaml
linter:
  rules:
    avoid_print: true
    prefer_single_quotes: true
    always_use_package_imports: true
```