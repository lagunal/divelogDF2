import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:divelogtest/widgets/dive_card.dart';
import 'package:divelogtest/models/dive_session.dart';
import '../utils/test_theme.dart';

void main() {
  group('DiveCard Widget Tests', () {
    late DiveSession testDiveSession;

    setUp(() {
      testDiveSession = DiveSession(
        id: 'test-1',
        userId: 'user-1',
        cliente: 'Test Client',
        operadoraBuceo: 'Test Operator',
        direccionOperadora: 'Test Address',
        lugarBuceo: 'Cozumel',
        tipoBuceo: 'Scuba',
        nombreBuzos: ['Diver 1', 'Diver 2'],
        supervisorBuceo: 'Supervisor',
        estadoMar: 2,
        visibilidad: 20,
        temperaturaSuperior: 26,
        temperaturaAgua: 25,
        corrienteAgua: 'Leve',
        tipoAgua: 'Salada',
        horaEntrada: DateTime(2024, 1, 15, 10, 0),
        maximaProfundidad: 25.5,
        tiempoIntervaloSuperficie: 60,
        tiempoFondo: 45.0,
        tiempoTotalInmersion: 50.0,
        horaSalida: DateTime(2024, 1, 15, 11, 0),
        descripcionTrabajo: 'Test Work',
        descompresionUtilizada: 'Ninguna',
        tiempoSupervisionAcumulado: 2.0,
        tiempoBuceoAcumulado: 1.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    testWidgets('displays dive location and operator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: testTheme,
          home: Scaffold(
            body: DiveCard(
              dive: testDiveSession,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify location is shown
      expect(find.text('Cozumel'), findsOneWidget);
      
      // Verify operator is shown
      expect(find.text('Test Operator'), findsOneWidget);
    });

    testWidgets('displays dive statistics (depth, time, temperature)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: testTheme,
          home: Scaffold(
            body: DiveCard(
              dive: testDiveSession,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify depth is shown
      expect(find.text('25.5m'), findsOneWidget);
      
      // Verify time is shown
      expect(find.text('45min'), findsOneWidget);
      
      // Verify temperature is shown
      expect(find.text('25°C'), findsOneWidget);
    });

    testWidgets('has location icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: testTheme,
          home: Scaffold(
            body: DiveCard(
              dive: testDiveSession,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify location icon exists
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      
      // Verify chevron icon exists (indicates card is tappable)
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: testTheme,
          home: Scaffold(
            body: DiveCard(
              dive: testDiveSession,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Tap the card
      await tester.tap(find.byType(DiveCard));
      await tester.pump();

      // Verify callback was triggered
      expect(tapped, isTrue);
    });

    testWidgets('renders correctly in light theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: testTheme,
          home: Scaffold(
            body: DiveCard(
              dive: testDiveSession,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify card renders without errors
      expect(find.byType(DiveCard), findsOneWidget);
      expect(find.text('Cozumel'), findsOneWidget);
    });

    testWidgets('renders correctly in dark theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(), // Use default dark theme
          home: Scaffold(
            body: DiveCard(
              dive: testDiveSession,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify card renders without errors in dark mode
      expect(find.byType(DiveCard), findsOneWidget);
      expect(find.text('Cozumel'), findsOneWidget);
      
      // Verify dark theme colors are applied (card should use dark surface color)
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(DiveCard),
          matching: find.byType(Container),
        ).first,
      );
      
      // Verify container exists with decoration
      expect(container.decoration, isNotNull);
    });

    testWidgets('truncates long location names with ellipsis', (WidgetTester tester) async {
      final longNameDive = testDiveSession.copyWith(
        lugarBuceo: 'Very Long Location Name That Should Be Truncated With Ellipsis',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: testTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 350,
                child: DiveCard(
                  dive: longNameDive,
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      // Verify text widget has overflow handling
      final textWidget = tester.widget<Text>(
        find.text('Very Long Location Name That Should Be Truncated With Ellipsis'),
      );
      
      expect(textWidget.overflow, TextOverflow.ellipsis);
      expect(textWidget.maxLines, 1);
    });
  });
}
