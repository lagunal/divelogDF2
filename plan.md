# Dive Log App - Project Plan

## Project Description
A mobile application for divers to register and track their diving sessions. The app allows users to log comprehensive dive details including client information, diving operator, location, dive type, equipment, water conditions, dive details, and safety information. It provides a professional dive logbook that helps divers maintain detailed records for certification, safety, and regulatory compliance.

## App Architecture

### Core Structure
- **main.dart**: App entry point with Material App configuration and Provider setup
- **theme.dart**: Centralized theme and color definitions
- **providers/**: State management providers
  - `dive_provider.dart`: Centralized state management for dive sessions with reactive updates

### Data Layer
- **models/**: Data models for dive sessions, diver profile, dive sites
  - `dive_session.dart`: Comprehensive dive session data model with all required fields (see Dive Session Fields below)
  - `user_profile.dart`: User/diver profile information
  - `dive_operator.dart`: Diving operator information

- **services/**: Business logic and data operations
  - `dive_service.dart`: CRUD operations for dive sessions
  - `storage_service.dart`: Local storage management
  - `user_service.dart`: User profile management

### Presentation Layer
- **screens/**: Main app screens
  - `splash_screen.dart`: Initial loading and auth state check
  - `login_screen.dart`: User login with email/password
  - `register_screen.dart`: New user registration
  - `forgot_password_screen.dart`: Password reset functionality
  - `home_screen.dart`: Dashboard with recent dives and quick actions
  - `dive_list_screen.dart`: List view of all logged dives
  - `add_edit_dive_screen.dart`: Form to add or edit dive sessions (includes export functionality)
  - `profile_screen.dart`: User profile and settings
  - `statistics_screen.dart`: Dive statistics and analytics
  - `main_navigation_screen.dart`: Main navigation structure with bottom tabs and drawer

- **widgets/**: Reusable UI components
  - `dive_card.dart`: Card widget to display dive summary
  - `stat_card.dart`: Widget for displaying statistics
  - `quick_action_card.dart`: Card widget for quick actions
  - `empty_state_card.dart`: Widget for empty states
  - `custom_text_field.dart`: Styled input fields

### Utilities
- **utils/**: Helper functions and constants
  - `constants.dart`: App-wide constants
  - `formatters.dart`: Data formatting utilities
  - `validators.dart`: Input validation functions

## Dive Session Fields

Each dive session will capture the following information:

### General Information
- **Cliente**: Client name
- **Operadora de Buceo**: Diving operator name
- **Dirección de la Operadora**: Operator address
- **Lugar de Buceo**: Dive location/site
- **Tipo de Buceo**: Dive type (Scuba, Asist. Superficie, Altura Geográfica, Saturación)
- **Nombre de Buzos**: Diver names (multiple divers can be registered)
- **Supervisor de Buceo**: Dive supervisor

### Equipment and Conditions
- **Tabla de Buceo**: Dive table used
- **Aparato Respiratorio**: Breathing apparatus type
- **Presión Cilindro**: Cylinder pressure
- **Tipo de Traje**: Suit type
- **Mezcla Utilizada**: Gas mixture used

### Water Conditions
- **Estado del Mar**: Sea state (Escala Beaufort)
- **Visibilidad**: Visibility
- **Temperatura Superior**: Surface temperature
- **Temperatura Agua**: Water temperature
- **Corriente Agua**: Water current
- **Tipo de Agua**: Water type (fresh, salt, etc.)

### Dive Details (Detalles de la Sesión)
- **Hora de Entrada**: Entry time
- **Máxima Profundidad**: Maximum depth
- **Tiempo de Intervalo en Superficie**: Surface interval time
- **Tiempo de Fondo**: Bottom time
- **Inicio de Descompresión**: Decompression start
- **Descompresión Completa**: Complete decompression
- **Tiempo Total de Inmersión**: Total immersion time
- **Hora de Salida**: Exit time

### Work and Safety
- **Descripción de Trabajo**: Work description
- **Descompresión Utilizada**: Decompression method used
- **Enfermedad o Lesión**: Illness or injury
- **Tiempo de Supervisión Acumulado**: Accumulated supervision time
- **Tiempo de Buceo Acumulado**: Accumulated dive time

## Tasks and Subtasks

### Phase 1: Project Setup and Data Models ✓
- [x] Initialize Flutter project
- [x] Set up theme configuration with ocean/diving color palette
- [x] Create data models
  - [x] Dive session model with toJson/fromJson
  - [x] User profile model
  - [x] Dive operator model
- [x] Set up local storage (sqflite dependency added)

### Phase 2: Core Services ✓
> **Status**: Phase 2 has been successfully migrated from `shared_preferences` to `sqflite` for better data persistence, querying capabilities, and scalability.

#### Completed ✓
- [x] Implement DiveService
  - [x] Create dive session
  - [x] Read dive sessions (all, by date, by location)
  - [x] Update dive session
  - [x] Delete dive session
  - [x] Load sample data
- [x] Implement UserService
  - [x] Create/update user profile
  - [x] Get user profile
  - [x] Track total dives, total bottom time
- [x] Implement StorageService
  - [x] Save/load data from local storage (shared_preferences)
  - [x] Data serialization/deserialization
  - [x] Error handling for corrupted data

#### Migration Tasks (shared_preferences → sqflite) ✓
- [x] **Database Setup**
  - [x] Add sqflite and path dependencies to pubspec.yaml
  - [x] Create DatabaseHelper class to manage SQLite database
  - [x] Define database version and upgrade paths
  - [x] Implement database initialization on app startup
  
- [x] **Database Schema Design**
  - [x] Create table schema for users
    - [x] Define columns: id, name, email, certificationLevel, certificationNumber, certificationDate, totalDives, totalBottomTime, deepestDive, createdAt, updatedAt
    - [x] Set up primary key and indexes
  - [x] Create table schema for dive_sessions
    - [x] Define columns for all DiveSession model fields
    - [x] Set up primary key (id) and foreign key (userId)
    - [x] Add indexes for frequently queried fields (userId, horaEntrada, lugarBuceo, operadoraBuceo)
  - [x] Create table schema for dive_details (optional, if separating detailed info)
    - [x] Define columns for detailed timing and depth measurements
    - [x] Set up one-to-one relationship with dive_sessions
  
- [x] **StorageService Migration**
  - [x] Refactor StorageService to use SQLite instead of shared_preferences
  - [x] Implement raw SQL queries or use sqflite query builders
  - [x] Add methods for:
    - [x] Open/close database connections
    - [x] Execute CREATE TABLE statements
    - [x] Handle database upgrades (onUpgrade callback)
    - [x] Transaction support for batch operations
  - [x] Remove shared_preferences dependencies from StorageService
  
- [x] **DiveService Migration**
  - [x] Update createDive() to use SQL INSERT
  - [x] Update getAllDives() to use SQL SELECT with ORDER BY
  - [x] Update getDivesByLocation() to use SQL WHERE clause
  - [x] Update getDivesByDateRange() to use SQL WHERE with date filtering
  - [x] Update updateDive() to use SQL UPDATE
  - [x] Update deleteDive() to use SQL DELETE
  - [x] Update search functionality to use SQL LIKE queries
  - [x] Refactor sample data loading to insert into SQLite tables
  
- [x] **UserService Migration**
  - [x] Update saveUserProfile() to use SQL INSERT or UPDATE (UPSERT)
  - [x] Update getUserProfile() to use SQL SELECT
  - [x] Update statistics calculations to use SQL aggregate functions (COUNT, SUM, MAX)
  - [x] Remove shared_preferences usage from UserService
  
- [x] **Data Migration Strategy**
  - [x] Create migration utility to read existing data from shared_preferences
  - [x] Parse JSON data from shared_preferences
  - [x] Insert parsed data into SQLite tables
  - [x] Validate migrated data integrity
  - [x] Clear shared_preferences after successful migration
  - [x] Handle edge cases (no existing data, corrupted data)
  
- [x] **Testing and Validation**
  - [x] Test all CRUD operations with SQLite
  - [x] Verify data persistence after app restart
  - [x] Test query performance with large datasets
  - [x] Validate foreign key constraints
  - [x] Test data migration from shared_preferences to SQLite
  - [x] Handle SQLite-specific errors (database locked, disk full, etc.)
  - [x] Verify is SQLite works for web App 

#### Testing (Phase 2) — Definition of Done
- [x] Unit: Model (DiveSession, UserProfile) JSON (lists, dates) round-trip ≥ 90%
- [x] Unit: Serialize/deserialize `nombreBuzos` as TEXT JSON and back
- [x] Unit: Statistics calculation from in-memory sample sessions
- [x] Widget: Add/Edit form validates required fields and shows error SnackBar
- [x] Widget: Diver list add/remove interactions reflected in UI
- [x] Lint clean: flutter analyze has 0 errors

### Phase 3: UI Implementation ✅ COMPLETE
- [x] **State Management Implementation** ✓
  - [x] Created DiveProvider with ChangeNotifier
  - [x] Wrapped app with ChangeNotifierProvider in main.dart
  - [x] All screens use Consumer<DiveProvider> for reactive updates
  - [x] Automatic UI refresh across all screens when dive data changes
  - [x] Eliminated manual refresh and navigation result patterns
- [x] Home Screen ✓
  - [x] Display recent dives (reactive with Provider)
  - [x] Show quick statistics (total dives, deepest dive, etc.)
  - [x] Quick action buttons
  - [x] Reusable widgets extracted (quick_action_card.dart, stat_card.dart, dive_card.dart, empty_state_card.dart)
  - [x] Automatic refresh when navigating back from other screens
- [x] Dive List Screen ✓
  - [x] Scrollable list of all dives (reactive with Provider)
  - [x] Search and filter functionality (search by location, operator, description)
  - [x] Sort options (date, depth, duration)
  - [x] Advanced filters (location, operator, date range)
  - [x] Active filter chips with removal
  - [x] Empty states for no dives and no results
  - [x] Automatic refresh when dive data changes
- [x] Add/Edit Dive Screen ✓
  - [x] General Information Section (Cliente, Operadora, Dirección, Lugar, Tipo de Buceo, Buzos, Supervisor)
  - [x] Equipment Section (Tabla, Aparato Respiratorio, Presión Cilindro, Tipo de Traje, Mezcla)
  - [x] Water Conditions Section (Estado del Mar, Visibilidad, Temperaturas, Corriente, Tipo de Agua)
  - [x] Dive Details Section (Horas, Profundidad, Tiempos, Descompresión)
  - [x] Work and Safety Section (Descripción, Enfermedad/Lesión, Tiempos Acumulados)
  - [x] Date/time pickers for entry/exit times
  - [x] Dropdown selectors for Tipo de Buceo, Estado del Mar, etc.
  - [x] Multiple diver name inputs with add/remove functionality
  - [x] Form validation for all required fields
  - [x] Save/Update functionality integrated with DiveProvider (reactive)
  - [x] Modern, scrollable form layout with organized sections
  - [x] Automatic UI refresh on all screens after save/update
  - [x] Export single dive session (PDF/CSV) ✓
    - [x] Add export button in app bar or floating action button
    - [x] Implement PDF export with dive details
    - [x] Implement CSV export with dive details
    - [x] Add file download/sharing functionality
- [x] Navigation Structure ✓
  - [x] Bottom Tab Navigation
    - [x] Home tab
    - [x] Dive List tab
    - [x] Statistics tab
    - [x] Profile tab
  - [x] Drawer Navigation
    - [x] User profile section with avatar and user info
    - [x] App navigation menu with selected state
    - [x] Settings menu item
    - [x] About dialog with app information
- [x] Profile Screen ✓
  - [x] User information
  - [x] Certifications
  - [x] Preferences/settings
- [x] Statistics Screen ✓
  - [x] Total dives count (reactive with Provider)
  - [x] Total bottom time
  - [x] Deepest dive
  - [x] Average depth
  - [x] Favorite dive sites by frequency
  - [x] Dive type distribution
  - [x] Recent activity timeline
  - [x] Automatic refresh when dive data changes

#### Testing (Phase 3) — Definition of Done ✅ COMPLETE
- [x] Widget: Home shows recent dives and empty state correctly
- [x] Widget: Dive List filters and chips work; empty states verified
- [x] Widget: Statistics renders totals and averages from provider state
- [x] Golden: DiveCard and StatCard light/dark mode snapshots
- [x] Accessibility: Primary actions have semantics labels

### Phase 4: Firebase Integration
- [x] Firebase Setup ✅ COMPLETE
  - [x] Connect Firebase project in Dreamflow (Project ID: lmhezq2u3og1a9fif4vfxxhpmdp6e1)
  - [x] Configure Firebase for target platforms (Android, iOS, Web)
  - [x] Add Firebase dependencies (firebase_core, firebase_auth, cloud_firestore)
  - [x] Create AuthManager service for Firebase authentication (FirebaseAuthManager)
  - [x] Initialize Firebase in main.dart with error handling
  - [x] Create firebase_options.dart with platform-specific configurations
- [x] Authentication Screens ✅ COMPLETE
  - [x] Auth Wrapper (AuthWrapper)
    - [x] Check authentication state on app launch using StreamBuilder
    - [x] Navigate to Login or Home based on auth state automatically
    - [x] Display loading indicator while checking auth state
  - [x] Login Screen (LoginScreen)
    - [x] Email/password input fields with proper styling
    - [x] Form validation (email format, password requirements)
    - [x] Login button with loading state
    - [x] "Forgot Password?" functionality integrated
    - [x] "Create Account" button for registration
    - [x] Error handling and user feedback with Spanish messages
    - [x] Unified login/registration interface
    - [x] Password visibility toggle
    - [x] Automatic user profile creation in Firestore on registration
  - [x] Register Screen (Integrated in LoginScreen)
    - [x] User information fields (email, password)
    - [x] Form validation (password length, email format, required fields)
    - [x] Register button with loading state
    - [x] Error handling and user feedback
    - [x] Creates user profile in Firestore with FirestoreUserService
  - [x] Forgot Password (Integrated in LoginScreen)
    - [x] Email input field (shared with login)
    - [x] Send reset email button
    - [x] Success confirmation message via SnackBar
    - [x] Error handling with Firebase-specific error messages
- [x] Firebase Authentication Backend ✅ COMPLETE
  - [x] Implement user registration with Firebase Auth (FirebaseAuthManager.createAccountWithEmail)
  - [x] Implement user login/logout (FirebaseAuthManager.signInWithEmail/signOut)
  - [x] Email/password authentication (FirebaseAuthManager with error handling)
  - [x] Password reset functionality (FirebaseAuthManager.resetPassword)
  - [x] Email verification (optional - FirebaseAuthManager.updateEmail with verification)
  - [x] Session management and persistence (Firebase Auth automatic persistence)
- [x] Cloud Firestore Database ✅ COMPLETE
  - [x] Migrate data models to Firestore (DiveSession.toFirestore/fromFirestore, UserProfile.toFirestore/fromFirestore)
  - [x] Update DiveService to use Firestore (Hybrid DiveService with offline-first + FirestoreDiveService)
  - [x] Update UserService to use Firestore (Hybrid UserService with offline-first + FirestoreUserService)
  - [x] Implement real-time sync (watchAllDiveSessions stream, watchUserProfile stream, automatic sync when online)
  - [x] Data security rules (firestore.rules with userId authentication and ownership checks)
- [x] Offline Support and Sync ✅ COMPLETE
  - [x] Use local SQLite database when offline or no internet connection (StorageService with SQLite for mobile, SharedPreferences for web)
  - [x] Detect internet connectivity status (connectivity_plus package with active listener)
  - [x] Queue dive sessions created/updated while offline (isSynced flag in DiveSession model)
  - [x] Automatically sync queued data to Firestore when internet connection is restored (ConnectivityListener triggers auto-sync on reconnection)
  - [x] Handle sync conflicts and merge strategies (Last-write-wins strategy with Firestore timestamps)
  - [x] Show sync status indicator in UI (SyncStatusIndicator widget in AppBar, SyncStatusBanner below AppBar)
  - [x] Maintain SQLite as offline cache even after Firebase integration (Hybrid offline-first architecture: SQLite/SharedPreferences + Firestore)
- [ ] Export Dive Logs (Mandatory)
  - [ ] Export single dive session to PDF format (from Add/Edit Dive Screen)
  - [ ] Export single dive session to CSV format (from Add/Edit Dive Screen)
  - [ ] Implement download functionality for exported files
- [ ] Additional Features (Optional)
  - [ ] Batch export from Dive List Screen (export filtered/all dives to PDF/CSV)
  - [ ] Share dive log functionality (share exported PDF/CSV via email, messaging apps, etc.)
  - [ ] Dive buddy tracking
  - [ ] GPS integration for dive sites
  - [ ] Dive planning tools
  - [ ] Safety stop timer
  - [ ] Decompression calculator
  - [ ] Supervisor signature functionality
    - [ ] Digital signature capture on Add/Edit Dive Screen
    - [ ] Store signature as image in dive session
    - [ ] Display supervisor signature in dive logs and exports
    - [ ] Signature validation and verification

#### Testing (Phase 4) — Definition of Done
- [ ] Auth: Mocked Firebase Auth flows (login/register/reset) pass widget tests
- [ ] Firestore: CRUD with emulator/mocks; offline cache verified
- [ ] Sync: Queue and merge strategy unit tests (conflict resolution)
- [ ] Security: Rules checks via emulator for authenticated access

### Phase 5: Enhanced Features
- [ ] Reusable Widgets
  - [ ] DiveCard component
  - [ ] StatCard component
  - [ ] Custom form fields
- [ ] Data Validation
  - [ ] Input validators
  - [ ] Safety checks (depth limits, etc.)
- [ ] Error Handling
  - [ ] User-friendly error messages
  - [ ] Logging with debugPrint

#### Testing (Phase 5) — Definition of Done
- [ ] Unit: Validators (depth limits, numeric formats) edge cases
- [ ] Widget: Error banners/sheets rendered on failures

### Phase 6: Polish and Optimization
- [ ] UI/UX refinement
  - [ ] Consistent styling
  - [ ] Smooth transitions
  - [ ] Loading states
  - [ ] Empty states
- [ ] Testing
  - [ ] Test all CRUD operations
  - [ ] Test data persistence
  - [ ] Test edge cases
- [ ] Performance optimization
  - [ ] Efficient list rendering
  - [ ] Optimize image loading
- [ ] Platform permissions
  - [ ] Camera access (for photos)
  - [ ] Storage access

#### Testing (Phase 6) — Definition of Done
- [ ] Performance: List scrolling jank < 1.5ms missed frames (profile run)
- [ ] Memory: No leaks across navigation loops (DevTools snapshot)
- [ ] Golden: Critical screens updated snapshots after visual polish

### Phase 7: Payments and Subscriptions
- [ ] Payment Integration Setup
  - [ ] Choose payment provider (Stripe recommended for Flutter)
  - [ ] Set up payment provider account and API keys
  - [ ] Add payment dependencies (e.g., stripe_flutter, in_app_purchase)
- [ ] Subscription Management
  - [ ] Define subscription tiers (e.g., Free, Pro, Premium)
  - [ ] Implement subscription model in data layer
  - [ ] Create subscription service for managing user subscriptions
  - [ ] Store subscription status in Firestore
- [ ] Payment UI
  - [ ] Create subscription plans screen
  - [ ] Implement payment checkout flow
  - [ ] Add payment method management screen
  - [ ] Display current subscription status in profile
- [ ] Payment Processing
  - [ ] Integrate Stripe payment processing
  - [ ] Handle successful payments
  - [ ] Handle failed payments and retries
  - [ ] Implement webhook handling for subscription events
- [ ] Feature Gating
  - [ ] Implement feature restrictions based on subscription tier
  - [ ] Add upgrade prompts for premium features
  - [ ] Handle subscription expiration and renewals
- [ ] Payment Security
  - [ ] Secure API key storage
  - [ ] Implement server-side payment validation
  - [ ] Add receipt verification

#### Testing (Phase 7) — Definition of Done
- [ ] Unit: SKU/entitlement logic and feature gating
- [ ] Widget: Checkout happy/failed paths with mocked provider
- [ ] E2E: Subscription state reflects paywall unlock/lock transitions

## SQLite Database Schema (Local Storage - Phases 1-3)

### Tables Structure

#### 1. **users** Table
Stores user profile information locally.

**Schema**:
```sql
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE,
  certification_level TEXT,
  certification_number TEXT,
  certification_date INTEGER,
  total_dives INTEGER DEFAULT 0,
  total_bottom_time REAL DEFAULT 0,
  deepest_dive REAL DEFAULT 0,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE INDEX idx_users_email ON users(email);
```

---

#### 2. **dive_sessions** Table
Stores dive session records.

**Schema**:
```sql
CREATE TABLE dive_sessions (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  
  -- General Information
  cliente TEXT NOT NULL,
  operadora_buceo TEXT NOT NULL,
  direccion_operadora TEXT,
  lugar_buceo TEXT NOT NULL,
  tipo_buceo TEXT NOT NULL,
  nombre_buzos TEXT NOT NULL,  -- JSON array stored as TEXT
  supervisor_buceo TEXT,
  
  -- Equipment
  tabla_buceo TEXT,
  aparato_respiratorio TEXT,
  presion_cilindro REAL,
  tipo_traje TEXT,
  mezcla_utilizada TEXT,
  
  -- Water Conditions
  estado_mar INTEGER,
  visibilidad REAL,
  temperatura_superior REAL,
  temperatura_agua REAL,
  corriente_agua TEXT,
  tipo_agua TEXT,
  
  -- Dive Times and Depth
  hora_entrada INTEGER NOT NULL,
  hora_salida INTEGER NOT NULL,
  maxima_profundidad REAL NOT NULL,
  tiempo_total_inmersion REAL NOT NULL,
  tiempo_fondo REAL NOT NULL,
  
  -- Work and Safety
  descripcion_trabajo TEXT,
  descompresion_utilizada TEXT,
  enfermedad_lesion TEXT,
  tiempo_supervision_acumulado REAL,
  tiempo_buceo_acumulado REAL,
  
  -- Metadata
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Indexes for efficient querying
CREATE INDEX idx_dive_sessions_user_id ON dive_sessions(user_id);
CREATE INDEX idx_dive_sessions_hora_entrada ON dive_sessions(hora_entrada DESC);
CREATE INDEX idx_dive_sessions_lugar_buceo ON dive_sessions(lugar_buceo);
CREATE INDEX idx_dive_sessions_operadora_buceo ON dive_sessions(operadora_buceo);
CREATE INDEX idx_dive_sessions_user_date ON dive_sessions(user_id, hora_entrada DESC);
```

---

#### 3. **dive_details** Table (Optional - for detailed timing info)
Stores additional dive detail measurements.

**Schema**:
```sql
CREATE TABLE dive_details (
  id TEXT PRIMARY KEY,
  dive_session_id TEXT NOT NULL UNIQUE,
  user_id TEXT NOT NULL,
  
  -- Timing Details
  hora_entrada INTEGER NOT NULL,
  hora_salida INTEGER NOT NULL,
  tiempo_intervalo_superficie REAL,
  tiempo_fondo REAL NOT NULL,
  tiempo_total_inmersion REAL NOT NULL,
  
  -- Depth and Decompression
  maxima_profundidad REAL NOT NULL,
  inicio_descompresion INTEGER,
  descompresion_completa INTEGER,
  
  -- Additional Notes
  observaciones TEXT,
  incidentes TEXT,
  
  -- Metadata
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  
  FOREIGN KEY (dive_session_id) REFERENCES dive_sessions(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_dive_details_session ON dive_details(dive_session_id);
```

---

### Data Types Mapping

| Flutter/Dart Type | SQLite Type | Notes |
|------------------|-------------|-------|
| String | TEXT | UTF-8 encoded |
| int | INTEGER | 64-bit signed integer |
| double | REAL | 64-bit floating point |
| bool | INTEGER | 0 = false, 1 = true |
| DateTime | INTEGER | Milliseconds since epoch |
| List<String> | TEXT | JSON array as string |
| Map<String, dynamic> | TEXT | JSON object as string |

---

### Common Queries (SQLite)

**1. Get all dives for a user (most recent first)**:
```dart
final List<Map<String, dynamic>> results = await db.query(
  'dive_sessions',
  where: 'user_id = ?',
  whereArgs: [userId],
  orderBy: 'hora_entrada DESC',
);
```

**2. Search dives by location**:
```dart
final results = await db.query(
  'dive_sessions',
  where: 'user_id = ? AND lugar_buceo LIKE ?',
  whereArgs: [userId, '%$searchTerm%'],
  orderBy: 'hora_entrada DESC',
);
```

**3. Get dives within date range**:
```dart
final results = await db.query(
  'dive_sessions',
  where: 'user_id = ? AND hora_entrada >= ? AND hora_entrada <= ?',
  whereArgs: [userId, startTimestamp, endTimestamp],
  orderBy: 'hora_entrada DESC',
);
```

**4. Get deepest dives**:
```dart
final results = await db.query(
  'dive_sessions',
  where: 'user_id = ?',
  whereArgs: [userId],
  orderBy: 'maxima_profundidad DESC',
  limit: 10,
);
```

**5. Calculate user statistics**:
```dart
final result = await db.rawQuery('''
  SELECT 
    COUNT(*) as total_dives,
    SUM(tiempo_fondo) as total_bottom_time,
    MAX(maxima_profundidad) as deepest_dive
  FROM dive_sessions
  WHERE user_id = ?
''', [userId]);
```

**6. Insert dive with transaction**:
```dart
await db.transaction((txn) async {
  // Insert dive session
  await txn.insert('dive_sessions', diveSessionData);
  
  // Insert dive details (if using separate table)
  await txn.insert('dive_details', diveDetailsData);
  
  // Update user statistics
  await txn.rawUpdate('''
    UPDATE users 
    SET total_dives = total_dives + 1,
        total_bottom_time = total_bottom_time + ?,
        updated_at = ?
    WHERE id = ?
  ''', [tiempoFondo, DateTime.now().millisecondsSinceEpoch, userId]);
});
```

---

## Firestore Database Schema (Cloud Storage - Phase 4+)

### Collections Structure

#### 1. **users** Collection
Stores user profile and authentication information.

**Document ID**: Firebase Auth UID (auto-generated by Firebase Auth)

**Fields**:
```
{
  "id": string,                      // Same as document ID (Firebase Auth UID)
  "name": string,                    // User's full name
  "email": string,                   // User's email address (unique)
  "certificationLevel": string?,     // Certification level (e.g., "Open Water", "Advanced", "Divemaster")
  "certificationNumber": string?,    // Certification ID number
  "certificationDate": timestamp?,   // Date of certification
  "totalDives": number,              // Total count of logged dives (calculated)
  "totalBottomTime": number,         // Total bottom time in minutes (calculated)
  "deepestDive": number,             // Deepest dive depth in meters (calculated)
  "createdAt": timestamp,            // Account creation timestamp
  "updatedAt": timestamp             // Last profile update timestamp
}
```

**Indexes**:
- `email` (ascending) - for user lookup by email
- `createdAt` (descending) - for user registration analytics

**Security Rules**:
- Users can only read/write their own document
- Email field is immutable after creation
- Authentication required for all operations

---

#### 2. **dive_sessions** Collection
Stores high-level dive session information and references to dive details.

**Document ID**: Auto-generated by Firestore

**Fields**:
```
{
  "id": string,                            // Same as document ID
  "userId": string,                        // Reference to users collection (Firebase Auth UID)
  
  // General Information
  "cliente": string,                       // Client name
  "operadoraBuceo": string,                // Diving operator name
  "direccionOperadora": string,            // Operator address
  "lugarBuceo": string,                    // Dive location/site name
  "tipoBuceo": string,                     // Dive type: "Scuba", "Asist. Superficie", "Altura Geográfica", "Saturación"
  "nombreBuzos": array<string>,            // List of diver names participating
  "supervisorBuceo": string,               // Dive supervisor name
  
  // Equipment
  "tablaBuceo": string,                    // Dive table used
  "aparatoRespiratorio": string,           // Breathing apparatus type
  "presionCilindro": number,               // Cylinder pressure in PSI or bar
  "tipoTraje": string,                     // Suit type
  "mezclaUtilizada": string,               // Gas mixture used
  
  // Water Conditions
  "estadoMar": number,                     // Sea state (Beaufort scale 0-12)
  "visibilidad": number,                   // Visibility in meters
  "temperaturaSuperior": number,           // Surface temperature in Celsius
  "temperaturaAgua": number,               // Water temperature in Celsius
  "corrienteAgua": string,                 // Water current description
  "tipoAgua": string,                      // Water type: "Dulce", "Salada", "Salobre"
  
  // Quick Stats (for list views without loading details)
  "horaEntrada": timestamp,                // Entry time (dive start)
  "horaSalida": timestamp,                 // Exit time (dive end)
  "maximaProfundidad": number,             // Maximum depth reached in meters
  "tiempoTotalInmersion": number,          // Total immersion time in minutes
  "tiempoFondo": number,                   // Bottom time in minutes
  
  // Work and Safety
  "descripcionTrabajo": string,            // Description of work performed
  "descompresionUtilizada": string,        // Decompression method used
  "enfermedadLesion": string?,             // Illness or injury notes (optional)
  "tiempoSupervisionAcumulado": number,    // Accumulated supervision time in hours
  "tiempoBuceoAcumulado": number,          // Accumulated dive time in hours
  
  // Metadata
  "createdAt": timestamp,                  // Record creation timestamp
  "updatedAt": timestamp                   // Last update timestamp
}
```

**Indexes**:
- `userId` (ascending) + `horaEntrada` (descending) - for user's dives sorted by date
- `userId` (ascending) + `lugarBuceo` (ascending) - for filtering by location
- `userId` (ascending) + `operadoraBuceo` (ascending) - for filtering by operator
- `userId` (ascending) + `tipoBuceo` (ascending) - for filtering by dive type
- `userId` (ascending) + `maximaProfundidad` (descending) - for deepest dives
- `horaEntrada` (descending) - for recent dives across all users (admin view)

**Security Rules**:
- Users can only read/write their own dive sessions (where userId == auth.uid)
- `userId` field is immutable after creation
- Authentication required for all operations

---

#### 3. **dive_details** Collection
Stores detailed dive measurements and timing information for each dive session.

**Document ID**: Same as the corresponding dive_session document ID (1-to-1 relationship)

**Fields**:
```
{
  "id": string,                            // Same as document ID (matches dive_session ID)
  "diveSessionId": string,                 // Reference to dive_sessions collection
  "userId": string,                        // Reference to users collection (denormalized for security rules)
  
  // Timing Details
  "horaEntrada": timestamp,                // Entry time (dive start)
  "horaSalida": timestamp,                 // Exit time (dive end)
  "tiempoIntervaloSuperficie": number,     // Surface interval time in minutes
  "tiempoFondo": number,                   // Bottom time in minutes
  "tiempoTotalInmersion": number,          // Total immersion time in minutes
  
  // Depth and Decompression
  "maximaProfundidad": number,             // Maximum depth reached in meters
  "inicioDescompresion": timestamp?,       // Decompression start time (optional)
  "descompresionCompleta": timestamp?,     // Decompression complete time (optional)
  
  // Additional Notes and Observations
  "observaciones": string?,                // Additional dive observations (optional)
  "incidentes": string?,                   // Any incidents or special events (optional)
  
  // Metadata
  "createdAt": timestamp,                  // Record creation timestamp
  "updatedAt": timestamp                   // Last update timestamp
}
```

**Indexes**:
- `userId` (ascending) + `diveSessionId` (ascending) - for retrieving details by session
- `diveSessionId` (ascending) - primary lookup index

**Security Rules**:
- Users can only read/write their own dive details (where userId == auth.uid)
- `userId` and `diveSessionId` fields are immutable after creation
- Authentication required for all operations

**Note**: This collection allows for detailed dive information to be loaded on-demand when viewing a specific dive, keeping the main dive_sessions queries lightweight and fast for list views.

---

#### 4. **dive_operators** Collection (Future Enhancement)
Stores diving operator information for autocomplete and data consistency.

**Document ID**: Auto-generated by Firestore

**Fields**:
```
{
  "id": string,                      // Same as document ID
  "name": string,                    // Operator business name
  "address": string,                 // Physical address
  "phone": string?,                  // Contact phone number
  "email": string?,                  // Contact email address
  "createdAt": timestamp,            // Record creation timestamp
  "updatedAt": timestamp             // Last update timestamp
}
```

**Indexes**:
- `name` (ascending) - for autocomplete search

**Security Rules**:
- Read: all authenticated users
- Write: admin only (or users can submit for approval)

---

### Data Relationships

```
users (1) ──< dive_sessions (many) ──── dive_details (1)
  │              │                           │
  │              └─ userId references user   └─ diveSessionId references dive_session
  │                                              userId references user (denormalized)
  │
  └─ userId field links users to their dive sessions
     Each dive_session has exactly one dive_details document (same ID)
```

**Relationship Types:**
- **users → dive_sessions**: One-to-Many (one user has many dive sessions)
- **dive_sessions → dive_details**: One-to-One (one session has one details document, linked by same document ID)

**Design Rationale:**
- **Separation of concerns**: List views only need dive_sessions data (faster queries)
- **On-demand loading**: Detailed timing/depth info loaded only when viewing a specific dive
- **Scalability**: Reduces document size and improves query performance for list operations
- **Flexibility**: Easy to add more detailed measurements without bloating session documents

### Query Patterns

**Common Queries:**

1. **Get all dives for a user (most recent first)** - For list views:
   ```dart
   collection('dive_sessions')
     .where('userId', isEqualTo: currentUserId)
     .orderBy('horaEntrada', descending: true)
   ```

2. **Get specific dive with its details** - For detail view:
   ```dart
   // Step 1: Get session
   final session = await collection('dive_sessions').doc(diveId).get();
   
   // Step 2: Get details
   final details = await collection('dive_details').doc(diveId).get();
   ```

3. **Get dives by location**:
   ```dart
   collection('dive_sessions')
     .where('userId', isEqualTo: currentUserId)
     .where('lugarBuceo', isEqualTo: location)
     .orderBy('horaEntrada', descending: true)
   ```

4. **Get dives within date range**:
   ```dart
   collection('dive_sessions')
     .where('userId', isEqualTo: currentUserId)
     .where('horaEntrada', isGreaterThanOrEqualTo: startDate)
     .where('horaEntrada', isLessThanOrEqualTo: endDate)
     .orderBy('horaEntrada', descending: true)
   ```

5. **Get deepest dives**:
   ```dart
   collection('dive_sessions')
     .where('userId', isEqualTo: currentUserId)
     .orderBy('maximaProfundidad', descending: true)
     .limit(10)
   ```

6. **Create dive session with details** - Batch write:
   ```dart
   final batch = FirebaseFirestore.instance.batch();
   
   // Create session
   final sessionRef = collection('dive_sessions').doc();
   batch.set(sessionRef, sessionData);
   
   // Create details with same ID
   final detailsRef = collection('dive_details').doc(sessionRef.id);
   batch.set(detailsRef, detailsData..['diveSessionId'] = sessionRef.id);
   
   await batch.commit();
   ```

7. **Search dives by text** (requires client-side filtering or Algolia integration):
   - Search in: `lugarBuceo`, `operadoraBuceo`, `descripcionTrabajo`

### Aggregate Calculations

**User Statistics** (calculated in real-time or cached in user document):
- `totalDives`: Count of dive_sessions where userId == currentUserId
- `totalBottomTime`: Sum of tiempoFondo for all user's dives
- `deepestDive`: Max of maximaProfundidad for all user's dives

**Update Strategy**:
- Option 1: Calculate on-demand when loading statistics screen
- Option 2: Update user document using Cloud Functions on dive_session write
- Option 3: Hybrid - cache in user doc, recalculate periodically

### Data Migration Notes

**From SQLite to Firestore**:
1. Read all dive sessions from SQLite database
2. For each dive session:
   - Link to authenticated user's UID (set userId field)
   - Convert SQLite INTEGER timestamps to Firestore Timestamp
   - Upload to `dive_sessions` collection
   - Upload corresponding `dive_details` if using separate collection
3. Update user profile statistics in Firestore
4. Mark local SQLite records as synced (do not delete - keep for offline support)
5. Set up bidirectional sync for future changes

**Timestamp Handling**:
- SQLite: Store as INTEGER (milliseconds since epoch) or TEXT (ISO 8601)
  - Save: `dateTime.millisecondsSinceEpoch` or `dateTime.toIso8601String()`
  - Read: `DateTime.fromMillisecondsSinceEpoch(value)` or `DateTime.parse(value)`
- Firestore: `Timestamp.fromDate(dateTime)` → Firestore Timestamp object
- Display: `timestamp.toDate()` → Dart DateTime

**SQLite Schema Design**:
- Use INTEGER for timestamps (more efficient than TEXT)
- Use TEXT for JSON fields if needed (equipment details, etc.)
- Use REAL for floating-point numbers (depth, temperature, pressure)
- Use INTEGER for boolean values (0 = false, 1 = true)
- Define proper foreign key constraints (userId references users table)

### Offline Support Strategy

1. **Firestore Offline Persistence**: Enable by default
   ```dart
   FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true);
   ```

2. **Write Queue**: Firestore automatically queues writes when offline

3. **Sync Indicator**: Listen to snapshot metadata
   ```dart
   snapshot.metadata.isFromCache // true if offline
   ```

4. **Conflict Resolution**: Last-write-wins (Firestore default)

---

## Technical Stack
- **Framework**: Flutter (latest version)
- **State Management**: Provider package (ChangeNotifier pattern) ✓
  - **DiveProvider**: Centralized state management for dive sessions
  - Reactive updates across all screens (Home, Dive List, Statistics)
  - Automatic UI refresh when data changes (create, update, delete)
  - Eliminates manual refresh and navigation result patterns
- **Local Storage**: Hybrid approach (Phase 1-3, 5-6)
  - **Mobile (Android/iOS)**: sqflite package for SQLite relational database
    - Complex data storage with SQL querying
    - Better querying, filtering, and data persistence than shared_preferences
    - Supports relational data with foreign keys
    - Easier migration path to cloud databases
  - **Web**: shared_preferences package for browser preview
    - Simple key-value storage for Dreamflow preview purposes
    - Automatic platform detection in StorageService
- **Cloud Backend**: Firebase (Phase 4)
  - Firebase Authentication for user management
  - Cloud Firestore for cloud database
- **Payments**: Stripe or In-App Purchases (Phase 7)
  - Subscription management
  - Payment processing
  - Receipt validation
- **Data Format**: SQLite (mobile), SharedPreferences (web), Firestore documents (cloud)
- **Platform Support**: Android, iOS, Web

## Design Guidelines
- Follow Material Design principles
- Use centralized theme colors
- Responsive layouts for different screen sizes
- Intuitive navigation with bottom navigation bar
- Ocean/diving themed color palette (blues, teals)
- Clear typography and adequate spacing
- Accessibility considerations

## Notes
- **Phases 1-3, 5-6**: Use hybrid local storage approach
  - **Mobile (Android/iOS)**: sqflite for SQLite database
    - Provides robust relational database with SQL querying
    - Better data persistence and scalability than shared_preferences
    - Supports complex data relationships and efficient filtering
  - **Web**: shared_preferences for browser storage
    - Enables Dreamflow preview functionality
    - Automatically detected by StorageService based on platform
- **Phase 2 Migration**: Successfully migrated from shared_preferences to hybrid approach (sqflite for mobile, shared_preferences for web)
- **Phase 4**: Migrate to Firebase for cloud storage and authentication
  - Similar schema structure makes migration easier
- Include sample dive data for demonstration (Phases 1-5)
- Focus on offline-first functionality initially
- Ensure data persistence across app restarts
- Follow DRY principles and create reusable components
- Firebase integration will require connecting Firebase project in Dreamflow UI before implementation

---

## Testing Strategy Overview

1) Layers and Scope
- Unit tests: Pure Dart (models, formatters, validators, statistics helpers)
- Widget tests: Forms, navigation, list filters, empty states, accessibility
- Integration tests (later): Backend emulators/mocks for Firebase flows

2) Tooling
- Use flutter_test for widget/unit tests
- Avoid platform channels in unit tests; prefer pure Dart logic or mocks

3) Minimum Coverage Targets
- Models/utilities: ≥ 90%
- Widgets critical paths: scenarios for success/validation/error

4) How to Run
- Run analyzer: `flutter analyze`
- Run tests: `flutter test -r expanded`

5) CI (future)
- Add GitHub Actions workflow to run `flutter analyze` and `flutter test`