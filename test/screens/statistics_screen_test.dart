import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:divelogtest/providers/dive_provider.dart';
import 'package:divelogtest/screens/statistics_screen.dart';
import 'package:divelogtest/models/dive_session.dart';
import 'package:divelogtest/services/dive_service.dart';
import 'package:divelogtest/services/user_service.dart';
import 'package:divelogtest/models/user_profile.dart';

// Mock UserService
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
  Future<UserProfile?> getUserProfile() async => null;

  @override
  Future<UserProfile> createUserProfile({required String name, required String email, String? certificationLevel, String? certificationNumber, DateTime? certificationDate}) async {
    throw UnimplementedError();
  }

  @override
  Future<UserProfile> updateUserProfile({String? name, String? email, String? certificationLevel, String? certificationNumber, DateTime? certificationDate}) async {
    throw UnimplementedError();
  }

  @override
  Future<UserProfile> updateUserStatistics() async {
    throw UnimplementedError();
  }

  @override
  Future<void> createDefaultUserIfNeeded() async {}

  @override
  Future<void> deleteUserProfile() async {}
}

// Mock DiveProvider with statistics data
class MockDiveProviderWithStats extends ChangeNotifier implements DiveProvider {
  @override
  List<DiveSession> get allDives => _createMockDives();

  @override
  List<DiveSession> get recentDives => _createMockDives().take(3).toList();

  @override
  Map<String, dynamic> get statistics => {
    'totalDives': 10,
    'totalBottomTime': 500.0,
    'deepestDive': 35.5,
    'averageDepth': 22.3,
    'favoriteSites': {'Cozumel': 5, 'Cancun': 3, 'Playa del Carmen': 2},
    'diveTypes': {'Scuba': 7, 'Asist. Superficie': 2, 'Altura Geográfica': 1},
    'totalDiveTime': 600.0,
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

  List<DiveSession> _createMockDives() {
    return List.generate(10, (i) => DiveSession(
      id: 'dive-$i',
      userId: 'user-1',
      cliente: 'Cliente $i',
      operadoraBuceo: 'Operadora $i',
      direccionOperadora: 'Dirección $i',
      lugarBuceo: i < 4 ? 'Cozumel' : (i < 7 ? 'Cancun' : 'Playa del Carmen'),
      tipoBuceo: i < 7 ? 'Scuba' : (i < 9 ? 'Asist. Superficie' : 'Altura Geográfica'),
      nombreBuzos: ['Buzo A'],
      supervisorBuceo: 'Supervisor',
      estadoMar: 2,
      visibilidad: 20,
      temperaturaSuperior: 25,
      temperaturaAgua: 24,
      corrienteAgua: 'Leve',
      tipoAgua: 'Salada',
      horaEntrada: DateTime.now().subtract(Duration(days: i)),
      maximaProfundidad: 15.0 + i * 2,
      tiempoIntervaloSuperficie: 60,
      tiempoFondo: 45.0 + i * 5,
      tiempoTotalInmersion: 50.0 + i * 5,
      horaSalida: DateTime.now().subtract(Duration(days: i)).add(const Duration(hours: 1)),
      descripcionTrabajo: 'Trabajo $i',
      descompresionUtilizada: 'Ninguna',
      tiempoSupervisionAcumulado: 2.0,
      tiempoBuceoAcumulado: 1.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  }
}

// Mock DiveProvider with no data (empty state)
class MockDiveProviderEmptyStats extends ChangeNotifier implements DiveProvider {
  @override
  List<DiveSession> get allDives => [];

  @override
  List<DiveSession> get recentDives => [];

  @override
  Map<String, dynamic> get statistics => {
    'totalDives': 0,
    'totalBottomTime': 0.0,
    'deepestDive': 0.0,
    'averageDepth': 0.0,
    'favoriteSites': {},
    'diveTypes': {},
    'totalDiveTime': 0.0,
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
  Future<List<String>> getUniqueLocations() async => [];

  @override
  Future<List<String>> getUniqueOperators() async => [];

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

void main() {
  group('StatisticsScreen Widget Tests', () {
    testWidgets('renders totals and averages from provider state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<DiveProvider>.value(
            value: MockDiveProviderWithStats(),
            child: StatisticsScreen(userService: MockUserService()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify app bar title
      expect(find.text('Estadísticas'), findsOneWidget);

      // Verify main statistics are displayed
      expect(find.text('10'), findsOneWidget); // Total dives
      expect(find.text('35.5m'), findsOneWidget); // Deepest dive
      expect(find.text('22.3m'), findsOneWidget); // Average depth
      
      // Verify bottom time is shown (formatted)
      expect(find.textContaining('600m'), findsOneWidget); // Total bottom time
    });

    testWidgets('shows favorite dive sites', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<DiveProvider>.value(
            value: MockDiveProviderWithStats(),
            child: StatisticsScreen(userService: MockUserService()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify favorite sites section exists
      expect(find.text('Lugares Más Visitados'), findsOneWidget);
      
      // Verify top sites are shown
      expect(find.text('Cozumel'), findsWidgets);
      expect(find.text('Cancun'), findsWidgets);
    });

    testWidgets('shows dive type distribution', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<DiveProvider>.value(
            value: MockDiveProviderWithStats(),
            child: StatisticsScreen(userService: MockUserService()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify dive types section exists
      expect(find.text('Tipos de Buceo'), findsOneWidget);
      
      // Verify dive types are shown
      expect(find.text('Scuba'), findsOneWidget);
      expect(find.text('Asist. Superficie'), findsOneWidget);
    });

    testWidgets('shows empty state when no dives', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<DiveProvider>.value(
            value: MockDiveProviderEmptyStats(),
            child: StatisticsScreen(userService: MockUserService()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show zeros for statistics
      expect(find.text('0'), findsWidgets); // Multiple zeros
      
      // Should show empty state message
      expect(find.text('No hay datos disponibles'), findsWidgets);
    });

    testWidgets('shows recent activity timeline', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<DiveProvider>.value(
            value: MockDiveProviderWithStats(),
            child: StatisticsScreen(userService: MockUserService()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify recent activity section exists
      expect(find.text('Actividad Reciente'), findsOneWidget);
      
      // Should show some recent dives
      expect(find.text('Cozumel'), findsWidgets); // At least one location shown
    });

    testWidgets('stat cards have proper structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<DiveProvider>.value(
            value: MockDiveProviderWithStats(),
            child: StatisticsScreen(userService: MockUserService()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify stat cards exist (should have icons and values)
      expect(find.byIcon(Icons.water), findsWidgets);
      expect(find.byIcon(Icons.arrow_downward), findsWidgets);
      expect(find.byIcon(Icons.schedule), findsWidgets);
    });
  });
}