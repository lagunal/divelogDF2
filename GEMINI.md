# Dive Log App (divelogDF2) - Developer Context

## Project Overview
**Dive Log App** is a cross-platform mobile application (Android/iOS/Web) designed for divers to log and track their diving sessions. It features a professional logbook for certification and safety, with offline-first capabilities and cloud synchronization.

## Current Status
**Active Phase:** Phase 5 (Enhanced Features) - Starting.
- **Completed:**
    - Phase 1: Project Setup & Models.
    - Phase 2: Core Services (SQflite migration).
    - Phase 3: UI Implementation.
    - Phase 4: Firebase Setup, Auth, Firestore DB, Offline Support & Sync, Export Dive Logs (PDF/CSV).
- **Pending (Immediate Focus):**
    - **Phase 5:** Enhanced Features (Reusable widgets, Data Validation, Error Handling).

## Architecture & Tech Stack
- **Framework:** Flutter (Latest stable)
- **Language:** Dart
- **State Management:** Provider (`ChangeNotifier`, specifically `DiveProvider`).
- **Navigation:** GoRouter (`context.go()`, `context.push()`).
- **Backend:** Firebase (Authentication, Cloud Firestore).
- **Local Storage (Offline-First):**
    - **Mobile:** `sqflite` (SQLite) - Primary storage.
    - **Web:** `shared_preferences` - Fallback/Preview support.
- **UI Language:** Spanish (Español).
- **Code Language:** English.

## Key Commands
- **Run App:** `flutter run`
- **Run Tests:** `flutter test`
- **Analyze Code:** `flutter analyze`
- **Format Code:** `dart format .`
- **Fix Issues:** `dart fix --apply`

## Development Guidelines

### 1. Language Conventions
- **Code:** Write variable names, functions, and comments in **English**.
- **UI:** Write all user-facing text (labels, buttons, messages) in **Spanish**.

### 2. Data & Storage
- **Hybrid Pattern:** The app uses a hybrid repository pattern. Data is saved locally first (SQLite/Prefs) and then synced to Firestore.
- **Serialization:** SQLite does not support complex types (Lists/Maps). Serialize these to JSON Strings before insertion.
- **Migration:** Changes to models require updates to:
    1. The Model class (`fromJson`/`toJson`).
    2. The `DatabaseHelper` schema (`CREATE TABLE`).
    3. Firestore serialization (`toFirestore`/`fromFirestore`).

### 3. Navigation
- Use **GoRouter** exclusively.
- **Do:** `context.go('/home')` or `context.push('/details')`.
- **Don't:** `Navigator.push(...)`.

### 4. Testing
- Run tests after every phase completion.
- Focus on Widget tests for UI flows and Unit tests for Models/Services.

## Key Files
- **Plan & Status:** `plan.md` (Source of truth for tasks).
- **Entry Point:** `lib/main.dart`
- **State:** `lib/providers/dive_provider.dart`
- **Data Layer:**
    - `lib/models/dive_session.dart`
    - `lib/services/database_helper.dart` (Local)
    - `lib/services/firestore_dive_service.dart` (Cloud)
- **Theme:** `lib/theme.dart`
