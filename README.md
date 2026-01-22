# Dive Log App (v2)

A professional cross-platform mobile application (Android/iOS/Web) designed for divers to log, track, and manage their diving sessions efficiently. This app combines **offline-first** capabilities with seamless **cloud synchronization** (Firebase) to ensure your dive data is always safe, accessible, and accurately recorded.

## 📱 Features

-   **Professional Logbook:** Capture detailed dive data including:
    -   **General:** Location, Operator, Supervisor, Buddy list.
    -   **Technical:** Depth, Bottom Time, Gas Mixtures (Nitrox/Trimix), Decompression stops.
    -   **Conditions:** Visibility, Temperature (Water/Surface), Current, Sea State (Beaufort).
    -   **Equipment:** Suit type, Tank pressure, Weights.
-   **Offline-First Architecture:**
    -   Full functionality without internet access using local SQLite storage.
    -   Automatic data queuing and background synchronization when connectivity is restored.
-   **Cloud Sync & Backup:**
    -   Real-time synchronization across multiple devices via Google Cloud Firestore.
    -   Secure user authentication and data protection.
-   **Premium UI/UX:**
    -   Modern "Ocean" theme with glassmorphism effects and dynamic gradients.
    -   Smooth Hero animations and intuitive navigation.
-   **Statistics & Analytics:**
    -   Visual insights: Total dives, cumulative bottom time, max depth.
    -   Recent activity timeline.
-   **Safety & Validation:**
    -   Built-in safety checks for depth limits and no-decompression limits (NDL) warnings.
    -   Robust error handling with user-friendly feedback.
-   **Export & Sharing:**
    -   Generate professional PDF dive logs.
    -   Export data to CSV for external analysis.

## 🛠️ Tech Stack

-   **Framework:** [Flutter](https://flutter.dev/) (Dart)
-   **Architecture:** Hybrid Repository Pattern (Local + Cloud)
-   **State Management:** [Provider](https://pub.dev/packages/provider)
-   **Navigation:** [GoRouter](https://pub.dev/packages/go_router)
-   **Backend:** [Firebase](https://firebase.google.com/)
    -   **Auth:** Secure email/password authentication.
    -   **Firestore:** NoSQL cloud database for sync.
-   **Local Storage:**
    -   **Mobile:** [sqflite](https://pub.dev/packages/sqflite) (Structured SQL data).
    -   **Web:** [shared_preferences](https://pub.dev/packages/shared_preferences) (Fallback).
-   **Utilities:** `connectivity_plus` (Sync logic), `logging`, `pdf`, `printing`.

## 🏗️ Architecture

The application follows a strict **Offline-First Hybrid Repository** pattern to ensure reliability:

1.  **UI Layer:** Reactive widgets consume `DiveProvider` for state.
2.  **Provider Layer:** `DiveProvider` manages business logic and notifies UI of changes.
3.  **Service Layer:**
    -   `DiveService`: The central coordinator. It saves to Local Storage *first*, then attempts Cloud Sync.
    -   `DatabaseHelper`: Manages raw SQLite commands (Insert/Query/Update/Delete).
    -   `FirestoreDiveService`: Handles remote data synchronization and conflict resolution (Last-Write-Wins).

## 🚀 Getting Started

### Prerequisites

-   [Flutter SDK](https://docs.flutter.dev/get-started/install) (Latest stable)
-   Dart SDK
-   Android Studio / VS Code
-   Firebase Account (for backend setup)

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/yourusername/divelogDF2.git
    cd divelogDF2
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Firebase Setup:**
    -   This project relies on Firebase. You will need `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) files.
    -   Place `google-services.json` in `android/app/`.
    -   Place `GoogleService-Info.plist` in `ios/Runner/`.
    -   (Optional) Configure via [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/).

4.  **Run the App:**
    ```bash
    flutter run
    ```

## 📝 Development Guidelines

-   **Language:** Code in **English**, UI Text in **Spanish**.
-   **Routing:** Always use `GoRouter` (`context.go` / `context.push`).
-   **Styling:** Use `Theme.of(context)` and `lib/theme.dart` constants.
-   **Code Quality:** Run `flutter analyze` before committing.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.