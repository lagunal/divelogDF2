import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:divelogtest/screens/dive_list_screen.dart';
import 'package:divelogtest/models/dive_session.dart';
import 'package:divelogtest/services/dive_service.dart';
import 'package:divelogtest/widgets/dive_card.dart';

// Mock DiveService
class MockDiveService implements DiveService {
  List<DiveSession> _sessions = [];

  void setSessions(List<DiveSession> sessions) {
    _sessions = sessions;
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<List<DiveSession>> getDiveSessionsByUserId(String userId) async {
    return _sessions;
  }

  @override
  Future<List<DiveSession>> getAllDiveSessions() async {
    return _sessions;
  }

  @override
  Future<List<String>> getUniqueLocations(String userId) async {
    return _sessions.map((s) => s.lugarBuceo).toSet().toList();
  }

  @override
  Future<List<String>> getUniqueOperators(String userId) async {
    return _sessions.map((s) => s.operadoraBuceo).toSet().toList();
  }

  // Helper method to simulate loading time
  Future<void> simulateLoad() async {
    await Future.delayed(Duration.zero);
  }

  @override
  Future<DiveSession> createDiveSession(DiveSession session) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteDiveSession(String id, String userId) async {
    throw UnimplementedError();
  }

  @override
  Future<DiveSession?> getDiveSessionById(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<List<DiveSession>> getDiveSessionsByDateRange(
      DateTime start, DateTime end) async {
    throw UnimplementedError();
  }

  @override
  Future<List<DiveSession>> getDiveSessionsByLocation(String location) async {
    throw UnimplementedError();
  }

  @override
  Future<List<DiveSession>> getDiveSessionsByOperator(String operator) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getStatistics(String userId) async {
    throw UnimplementedError();
  }

  @override
  bool get isOnline => true;
  @override
  bool get isSyncing => false;
  @override
  int get pendingSyncCount => 0;
  @override
  Stream<SyncStatus> get syncStatusStream => const Stream.empty();
  @override
  Future<void> syncPendingDives() async {}
  @override
  Future<DiveSession> updateDiveSession(DiveSession session) async {
    throw UnimplementedError();
  }

  @override
  Future<void> syncFromFirestore(String userId) async {}
  @override
  void dispose() {}
}

void main() {
  late MockDiveService mockDiveService;

  setUp(() {
    mockDiveService = MockDiveService();
  });

  testWidgets('shows empty state when no dives', (WidgetTester tester) async {
    mockDiveService.setSessions([]);

    await tester.pumpWidget(
      MaterialApp(
        home: DiveListScreen(diveService: mockDiveService),
      ),
    );

    // Initial loading
    await tester.pump();
    // Data loaded
    await tester.pump(Duration.zero);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('No hay inmersiones registradas'), findsOneWidget);
  });

  testWidgets('has search field and filter button',
      (WidgetTester tester) async {
    mockDiveService.setSessions([]);

    await tester.pumpWidget(
      MaterialApp(
        home: DiveListScreen(diveService: mockDiveService),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.tune), findsOneWidget);
  });

  testWidgets('search field accepts input', (WidgetTester tester) async {
    mockDiveService.setSessions([]);

    await tester.pumpWidget(
      MaterialApp(
        home: DiveListScreen(diveService: mockDiveService),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Cozumel');
    expect(find.text('Cozumel'), findsOneWidget);
  });

  testWidgets('filter button opens filter bottom sheet',
      (WidgetTester tester) async {
    mockDiveService.setSessions([
      DiveSession(
        id: '1',
        userId: 'user1',
        lugarBuceo: 'Cozumel',
        operadoraBuceo: 'Blue Magic',
        horaEntrada: DateTime.now(),
        horaSalida: DateTime.now().add(const Duration(minutes: 45)),
        maximaProfundidad: 20,
        tiempoIntervaloSuperficie: 0,
        tiempoFondo: 45,
        tiempoTotalInmersion: 50,
        cliente: 'Test',
        direccionOperadora: '',
        tipoBuceo: 'Scuba',
        nombreBuzos: ['Me'],
        supervisorBuceo: 'Sup',
        estadoMar: 1,
        visibilidad: 20,
        temperaturaSuperior: 30,
        temperaturaAgua: 28,
        corrienteAgua: 'None',
        tipoAgua: 'Salt',
        descripcionTrabajo: 'Fun',
        descompresionUtilizada: 'None',
        tiempoSupervisionAcumulado: 0,
        tiempoBuceoAcumulado: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: DiveListScreen(diveService: mockDiveService),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    expect(find.text('Filtros y Orden'), findsOneWidget);
  });

  testWidgets('sort button shows sort options', (WidgetTester tester) async {
    // Only shows when there are items
    mockDiveService.setSessions([
      DiveSession(
        id: '1',
        userId: 'user1',
        lugarBuceo: 'Cozumel',
        operadoraBuceo: 'Blue Magic',
        horaEntrada: DateTime.now(),
        horaSalida: DateTime.now().add(const Duration(minutes: 45)),
        maximaProfundidad: 20,
        tiempoIntervaloSuperficie: 0,
        tiempoFondo: 45,
        tiempoTotalInmersion: 50,
        cliente: 'Test',
        direccionOperadora: '',
        tipoBuceo: 'Scuba',
        nombreBuzos: ['Me'],
        supervisorBuceo: 'Sup',
        estadoMar: 1,
        visibilidad: 20,
        temperaturaSuperior: 30,
        temperaturaAgua: 28,
        corrienteAgua: 'None',
        tipoAgua: 'Salt',
        descripcionTrabajo: 'Fun',
        descompresionUtilizada: 'None',
        tiempoSupervisionAcumulado: 0,
        tiempoBuceoAcumulado: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: DiveListScreen(diveService: mockDiveService),
      ),
    );

    // Initial pump to trigger initState and start _loadDives
    await tester.pump();

    // Process async gaps in _loadDives
    await tester.pump(const Duration(milliseconds: 100));

    // Final settlement including any state transitions
    await tester.pumpAndSettle();

    // Diagnostic check for loading state
    if (find.byType(CircularProgressIndicator).evaluate().isNotEmpty) {
      fail('Still loading after 100ms and pumpAndSettle');
    }

    // Diagnostic check for empty state
    if (find.text('No hay inmersiones registradas').evaluate().isNotEmpty) {
      fail('Empty state shown - data not loaded');
    }

    // Verify data is loaded
    expect(find.byType(DiveCard), findsOneWidget);

    // Opening filter/sort sheet (calls _showFilterSheet)
    final sortButton = find.byIcon(Icons.sort);
    expect(sortButton, findsOneWidget);
    await tester.tap(sortButton);
    await tester.pumpAndSettle();

    expect(find.text('Ordenar por'), findsOneWidget);
  });

  testWidgets('FAB has accessibility semantics', (WidgetTester tester) async {
    mockDiveService.setSessions([]);

    await tester.pumpWidget(
      MaterialApp(
        home: DiveListScreen(diveService: mockDiveService),
      ),
    );

    await tester.pumpAndSettle();

    final fab = find.byTooltip('Nueva Inmersión');
    expect(fab, findsOneWidget);
  });

  testWidgets('clear filters button appears when filters are active',
      (WidgetTester tester) async {
    mockDiveService.setSessions([]);

    await tester.pumpWidget(
      MaterialApp(
        home: DiveListScreen(diveService: mockDiveService),
      ),
    );

    await tester.pumpAndSettle();

    // Type in search to activate filters
    await tester.enterText(find.byType(TextField), 'Search');
    await tester.pump();

    // Check for clear button icon
    expect(find.byIcon(Icons.clear_all), findsOneWidget);
  });
}
