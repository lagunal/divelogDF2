import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:divelogtest/providers/dive_provider.dart';
import 'package:divelogtest/screens/home_screen.dart';
import 'package:divelogtest/models/dive_session.dart';
import 'package:divelogtest/services/dive_service.dart';

// Mock DiveProvider with sample data
class MockDiveProviderWithDives extends ChangeNotifier implements DiveProvider {
  @override
  List<DiveSession> get allDives => _createMockDives();

  @override
  List<DiveSession> get recentDives => _createMockDives().take(3).toList();

  @override
  Map<String, dynamic> get statistics => {
    'totalDives': 5,
    'totalBottomTime': 250.0,
    'deepestDive': 30.0,
    'averageDepth': 18.5,
  };

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  bool get isInitialized => true;

  @override
  bool get isOnline => true;

  @override
  bool get isSyncing => false;

  @override
  int get pendingSyncCount => 0;

  @override
  SyncStatus get syncStatus => SyncStatus.completed;

  @override
  Future<void> initialize(String userId) async {}

  @override
  Future<void> manualSync() async {}

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
  Future<List<String>> getUniqueOperators() async => ['Dive Shop A'];

  @override
  DiveSession? getDiveById(String id) => null;

  @override
  void dispose() {}

  List<DiveSession> _createMockDives() {
    return List.generate(5, (i) => DiveSession(
      id: 'dive-$i',
      userId: 'user-1',
      cliente: 'Cliente $i',
      operadoraBuceo: 'Operadora $i',
      direccionOperadora: 'Dirección $i',
      lugarBuceo: 'Lugar $i',
      tipoBuceo: 'Scuba',
      nombreBuzos: ['Buzo A', 'Buzo B'],
      supervisorBuceo: 'Supervisor',
      estadoMar: 2,
      visibilidad: 20,
      temperaturaSuperior: 25,
      temperaturaAgua: 24,
      corrienteAgua: 'Leve',
      tipoAgua: 'Salada',
      horaEntrada: DateTime.now().subtract(Duration(days: i)),
      maximaProfundidad: 20.0 + i,
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

// Mock DiveProvider with no dives (empty state)
class MockDiveProviderEmpty extends ChangeNotifier implements DiveProvider {
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
  group('HomeScreen Widget Tests', () {
    testWidgets('shows recent dives correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<DiveProvider>.value(
            value: MockDiveProviderWithDives(),
            child: const HomeScreen(),
          ),
        ),
      );

      // Wait for widget to build
      await tester.pumpAndSettle();

      // Verify app bar title
      expect(find.text('Bitácora de Buceo'), findsOneWidget);
      
      // Verify quick action buttons exist
      expect(find.text('Nueva Inmersión'), findsOneWidget);
      expect(find.text('Ver Todas'), findsOneWidget);

      // Verify statistics are shown
      expect(find.text('5'), findsOneWidget); // Total dives
      expect(find.text('30.0m'), findsOneWidget); // Deepest dive

      // Verify recent dives section exists
      expect(find.text('Inmersiones Recientes'), findsOneWidget);
      
      // Should show at least one dive card
      expect(find.text('Lugar 0'), findsOneWidget);
    });

    testWidgets('shows empty state correctly when no dives', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<DiveProvider>.value(
            value: MockDiveProviderEmpty(),
            child: const HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify empty state message is shown
      expect(find.text('No hay inmersiones registradas'), findsOneWidget);
      
      // Quick actions should still be available
      expect(find.text('Nueva Inmersión'), findsOneWidget);
      
      // Statistics should show zeros
      expect(find.text('0'), findsWidgets); // Multiple zeros in stats
    });

    testWidgets('quick action buttons have semantics', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<DiveProvider>.value(
            value: MockDiveProviderWithDives(),
            child: const HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find buttons by text and verify they are tappable
      final newDiveButton = find.widgetWithText(ElevatedButton, 'Nueva Inmersión');
      expect(newDiveButton, findsOneWidget);
      
      final viewAllButton = find.widgetWithText(OutlinedButton, 'Ver Todas');
      expect(viewAllButton, findsOneWidget);

      // Verify buttons are enabled (can be tapped)
      final newDiveWidget = tester.widget<ElevatedButton>(newDiveButton);
      expect(newDiveWidget.enabled, isTrue);
    });
  });
}
