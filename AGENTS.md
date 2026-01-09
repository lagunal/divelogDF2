# Dive Log App (Registro de Buceo) - Developer Guide

## 1. Project Overview
**Dive Log App** is a cross-platform mobile application (Android/iOS/Web) designed for divers to log and track their diving sessions. It provides a professional logbook for certification and safety purposes.

**Tech Stack:**
- **Framework:** Flutter (Latest)
- **Language:** Dart
- **State Management:** Provider (`ChangeNotifier`)
- **Navigation:** GoRouter
- **Local Database (Mobile):** SQflite (SQLite)
- **Local Database (Web):** SharedPreferences (Legacy/Preview support)
- **Cloud Backend:** Firebase (Auth, Firestore) - *Phase 4 Integration*

## 2. Architecture & Patterns

### Layered Architecture
1.  **Presentation Layer (`lib/screens`, `lib/widgets`)**: UI components. Reactive updates via `Consumer<DiveProvider>`.
2.  **State Layer (`lib/providers`)**: `ChangeNotifier` classes that hold app state and expose business logic methods.
3.  **Service Layer (`lib/services`)**: Business logic and data abstraction.
4.  **Data Layer (`lib/models`, `lib/services/database_helper.dart`)**: Data definitions and raw database access.

### State Management (Provider)
- Use `DiveProvider` for global state (dive sessions, statistics).
- `DiveProvider.initialize(userId)` loads data on startup.
- Screens listen to providers to rebuild automatically on data changes.
- **Pattern:** Action -> Service Call -> Update Local State -> `notifyListeners()`.

### Navigation
- **Library:** `go_router`.
- **Rule:** **ALWAYS** use `context.go()` or `context.push()`. **NEVER** use `Navigator.push()` or `Navigator.pop()`.
- Routes are defined in `lib/screens/main_navigation_screen.dart` (or `main.dart`).

## 3. Important Directories

| Directory | Purpose |
|-----------|---------|
| `lib/models/` | Data models (`DiveSession`, `UserProfile`). Contains `fromJson`/`toJson` logic. |
| `lib/services/` | `DatabaseHelper` (SQLite), `DiveService` (CRUD), `AuthManager`. |
| `lib/providers/` | State management (`DiveProvider`). |
| `lib/screens/` | Full-page screens (`AddEditDiveScreen`, `DiveListScreen`). |
| `lib/widgets/` | Reusable UI components (`DiveCard`, `StatCard`). |
| `lib/theme.dart` | Centralized theme configuration (Colors, TextStyles). |

## 4. Coding Guidelines & Conventions

### Language
- **Code (Variables, Functions, Comments):** English.
- **UI Text (Labels, Titles, Messages):** Spanish (Español).
  - Example: `final TextEditingController _lugarBuceoController;` // Code: Mixed/English, UI context: Spanish.

### Data Layer Rules (CRITICAL)
- **Hybrid Storage:**
    - **Mobile:** Uses `sqflite` (`divelogtest.db`).
    - **Web:** Uses `shared_preferences` (Limited capability).
- **SQLite Data Types:**
    - SQLite does NOT support `List` or `Map` directly.
    - **Rule:** When storing complex objects (e.g., `List<String> nombreBuzos`), you MUST serialize them to a JSON String before inserting and deserialize them when reading.
    - See `DatabaseHelper` for implementation examples.
- **Database Migrations:**
    - If you modify a Model, you **MUST** update the `CREATE TABLE` schema in `DatabaseHelper`.
    - You may need to increment the DB version and handle `onUpgrade`.

### Error Handling
- Use `try/catch` blocks for all async operations.
- Log errors using `debugPrint('Error: $e')`.
- Show user-friendly feedback via `ScaffoldMessenger` (SnackBars).

### Styling
- Use `Theme.of(context)` to access colors and text styles.
- Do NOT hardcode hex colors; use `lib/theme.dart`.

## 5. Common Implementation Patterns

### Adding a New Screen
1.  Create the screen file in `lib/screens/`.
2.  Add a route definition in the GoRouter configuration.
3.  Use `Consumer<DiveProvider>` if the screen needs access to dive data.

### Modifying the Dive Session Model
1.  Update `lib/models/dive_session.dart` (add field, update `fromJson`/`toJson`).
2.  Update `lib/services/database_helper.dart`:
    - Add column to `CREATE TABLE` in `_onCreate`.
    - Handle migration in `_onUpgrade` if the app is already live/deployed (or ask user to reinstall for dev).
3.  Update `lib/screens/add_edit_dive_screen.dart` to include the new form field.

## 6. Project Constraints
- **Dreamflow Compatibility:** The app runs in a web-based preview (Dreamflow). Ensure `StorageService` handles the Web platform gracefully (using SharedPreferences fallback) so the preview doesn't crash, even if SQLite is the primary mobile storage.
- **Firebase:** Ensure all Firebase interactions are guarded or correctly initialized (`initialize(userId)`), as the app supports offline-first/local-first behavior.
- ** Always follow implementation plan described on plan.md file on root folder. 
- ** Always update plan.md file to track phases , tasks and subtasks. 
- ** Always perform Testing phase after every phase, as described on plan.md file on root folder. 

