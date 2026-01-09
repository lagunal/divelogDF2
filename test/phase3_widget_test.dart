import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:divelogtest/providers/dive_provider.dart';
import 'package:divelogtest/screens/home_screen.dart';
import 'package:divelogtest/screens/profile_screen.dart';
import 'package:divelogtest/models/dive_session.dart';
import 'package:divelogtest/models/user_profile.dart';
import 'package:divelogtest/services/user_service.dart';
import 'package:divelogtest/services/dive_service.dart';
import 'package:divelogtest/auth/firebase_auth_manager.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

// Mocks
class FakeDiveProvider extends ChangeNotifier implements DiveProvider {
  @override
  List<DiveSession> get allDives => [];

  @override
  List<DiveSession> get recentDives => [];

  @override
  Map<String, dynamic> get statistics => {
    'totalDives': 10,
    'totalBottomTime': 500.0,
    'deepestDive': 30.0,
    'averageDepth': 15.0,
  };

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  bool get isInitialized => true;

  @override
  Future<void> initialize(String userId) async {}

  @override
  Future<void> refreshData(String userId) async {}

  @override
  Future<void> createDive(DiveSession session) async {}

  @override
  Future<void> updateDive(DiveSession session) async {}

  @override
  Future<void> deleteDive(String id, String userId) async {}

  @override
  Future<List<String>> getUniqueLocations() async => ['Cozumel', 'Cancun'];

  @override
  Future<List<String>> getUniqueOperators() async => ['Dive Shop'];

  @override
  DiveSession? getDiveById(String id) => null;

  @override
  bool get isOnline => true;

  @override
  bool get isSyncing => false;

  @override
  int get pendingSyncCount => 0;

  @override
  SyncStatus get syncStatus => SyncStatus.completed;

  @override
  Future<void> manualSync() async {}

  @override
  void dispose() {}
}

class MockUserService implements UserService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> initializeWithFirebaseUser(dynamic user) async {}

  @override
  String? getCurrentUserId() => 'test_user_id';

  @override
  bool get hasUserProfile => true;

  @override
  Future<UserProfile?> getUserProfile() async {
    return UserProfile(
      id: 'test_user_id',
      name: 'Test User',
      email: 'test@example.com',
      certificationLevel: 'Open Water',
      certificationNumber: '12345',
      certificationDate: DateTime(2023, 1, 1),
      totalDives: 10,
      totalBottomTime: 500.0,
      deepestDive: 30.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<UserProfile> createUserProfile({
    required String name,
    required String email,
    String? certificationLevel,
    String? certificationNumber,
    DateTime? certificationDate,
  }) async {
    return UserProfile(
      id: 'test_user_id',
      name: name,
      email: email,
      certificationLevel: certificationLevel,
      certificationNumber: certificationNumber,
      certificationDate: certificationDate,
      totalDives: 0,
      totalBottomTime: 0.0,
      deepestDive: 0.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<UserProfile> updateUserProfile({
    String? name,
    String? email,
    String? certificationLevel,
    String? certificationNumber,
    DateTime? certificationDate,
  }) async {
    return UserProfile(
      id: 'test_user_id',
      name: name ?? 'Test User',
      email: email ?? 'test@example.com',
      certificationLevel: certificationLevel,
      certificationNumber: certificationNumber,
      certificationDate: certificationDate,
      totalDives: 10,
      totalBottomTime: 500.0,
      deepestDive: 30.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<UserProfile> updateUserStatistics() async {
    return getUserProfile().then((p) => p!);
  }

  @override
  Future<void> createDefaultUserIfNeeded() async {}

  @override
  Future<void> deleteUserProfile() async {}
}

class MockAuthManager extends FirebaseAuthManager {
  @override
  firebase_auth.User? get currentUser => null; // Mock user if needed

  @override
  Future signOut() async {}
}

void main() {
  testWidgets('Home Screen renders correctly with Provider', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<DiveProvider>.value(value: FakeDiveProvider()),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Verify app bar title
    expect(find.text('Bitácora de Buceo'), findsOneWidget);
    
    // Verify tabs are present (Home, Logbook, Stats, Profile)
    // Note: HomeScreen might just be the dashboard part if used inside MainNavigationScreen
    // Checking HomeScreen implementation: It's the dashboard.
    
    // Check for "Resumen" or similar
    // Check for Quick Actions
    expect(find.text('Nueva Inmersión'), findsOneWidget);
    
    // Check for statistics
    expect(find.text('10'), findsOneWidget); // Total dives from fake provider
  });

  testWidgets('Profile Screen renders user info', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(
          userService: MockUserService(),
          authManager: MockAuthManager(),
        ),
      ),
    );

    // Allow FutureBuilder/initState to complete
    await tester.pumpAndSettle();

    // Verify user name
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('Open Water'), findsOneWidget);
    
    // Verify stats on profile
    expect(find.text('10'), findsOneWidget); // Total dives
  });
}
