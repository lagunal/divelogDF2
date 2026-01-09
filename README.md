# Dive Log App (Dreamflow)

A professional cross-platform mobile application (Android/iOS/Web) designed for divers to log, track, and manage their diving sessions efficiently. This app combines offline-first capabilities with cloud synchronization to ensure your dive data is always safe and accessible.

## 📱 Features

-   **Digital Logbook:** Create detailed records of your dives, including:
    -   General info (Location, Operator, Supervisor).
    -   Dive data (Depth, Times, Gas mixtures).
    -   Environmental conditions (Visibility, Temperature, Sea state).
    -   Equipment used.
-   **Offline-First:** Fully functional without an internet connection. Data is stored locally and synced when online.
-   **Cloud Synchronization:** Seamlessly syncs data across devices using Firebase.
-   **Statistics:** Visual insights into your diving history (Total bottom time, Max depth, Dive counts).
-   **Export:** Generate professional reports of your dive logs in PDF or CSV formats.
-   **Authentication:** Secure user accounts via Firebase Authentication.

## 🛠️ Tech Stack

-   **Framework:** [Flutter](https://flutter.dev/) (Dart)
-   **State Management:** [Provider](https://pub.dev/packages/provider)
-   **Navigation:** [GoRouter](https://pub.dev/packages/go_router)
-   **Backend:** [Firebase](https://firebase.google.com/)
    -   Authentication
    -   Cloud Firestore (NoSQL Database)
-   **Local Storage:**
    -   Mobile: [sqflite](https://pub.dev/packages/sqflite) (SQLite)
    -   Web: [shared_preferences](https://pub.dev/packages/shared_preferences) (Fallback/Preview)
-   **Exporting:** [pdf](https://pub.dev/packages/pdf), [csv](https://pub.dev/packages/csv), [printing](https://pub.dev/packages/printing)

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

## 🏗️ Architecture

The app follows a **Hybrid Repository Pattern**:
1.  **UI Layer:** Widgets and Screens consume Providers.
2.  **Provider Layer:** Manages application state and business logic.
3.  **Service Layer:**
    -   `DiveService`: Orchestrates data flow between local storage and cloud.
    -   `DatabaseHelper`: Manages local SQLite database.
    -   `FirestoreDiveService`: Handles Firebase interactions.

## 📝 Development

-   **Format Code:** `dart format .`
-   **Analyze Code:** `flutter analyze`
-   **Run Tests:** `flutter test`

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.