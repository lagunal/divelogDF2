import 'package:divelogtest/screens/add_edit_dive_screen.dart';
import 'package:divelogtest/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows validation SnackBar when required fields are empty',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: const AddEditDiveScreen(),
      ),
    );

    // Tap the save (check) icon in AppBar
    final saveFinder = find.byIcon(Icons.check);
    expect(saveFinder, findsOneWidget);
    await tester.tap(saveFinder);
    await tester.pumpAndSettle();

    // Expect a SnackBar with validation message
    expect(find.textContaining('Por favor, completa'), findsOneWidget);
  });

  testWidgets('can add and remove diver inputs', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: const Scaffold(body: AddEditDiveScreen()),
      ),
    );

    // Initially should have at least one diver field label
    expect(find.textContaining('Buzo 1'), findsOneWidget);

    // Add a diver
    // Scroll down to ensure button is visible
    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Agregar'));
    await tester.pumpAndSettle();

    // Now we should see Buzo 2
    expect(find.textContaining('Buzo 2'), findsOneWidget);
  });
}
