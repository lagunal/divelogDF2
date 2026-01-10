import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:divelogtest/widgets/stat_card.dart';
import '../utils/test_theme.dart';

void main() {
  group('StatCard Widget Tests', () {
    testWidgets('displays icon, value, and label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: testTheme,
          home: const Scaffold(
            body: StatCard(
              icon: Icons.scuba_diving,
              value: '42',
              label: 'Total Dives',
              color: Colors.blue,
            ),
          ),
        ),
      );

      // Verify icon is shown
      expect(find.byIcon(Icons.scuba_diving), findsOneWidget);
      
      // Verify value is shown
      expect(find.text('42'), findsOneWidget);
      
      // Verify label is shown
      expect(find.text('Total Dives'), findsOneWidget);
    });

    testWidgets('applies custom color', (WidgetTester tester) async {
      const testColor = Colors.red;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: testTheme,
          home: const Scaffold(
            body: StatCard(
              icon: Icons.warning,
              value: 'Alert',
              label: 'Status',
              color: testColor,
            ),
          ),
        ),
      );

      // Verify icon color
      final icon = tester.widget<Icon>(find.byIcon(Icons.warning));
      expect(icon.color, testColor);
      
      // Verify container decoration uses color
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(StatCard),
          matching: find.byType(Container),
        ).first,
      );
      
      final decoration = container.decoration as BoxDecoration;
      // Background should be with opacity 0.1
      expect(decoration.color, testColor.withValues(alpha: 0.1));
      // Border should be with opacity 0.3
      expect(decoration.border!.top.color, testColor.withValues(alpha: 0.3));
    });

    testWidgets('handles long labels gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: testTheme,
          home: const Scaffold(
            body: SizedBox(
              width: 150,
              child: StatCard(
                icon: Icons.info,
                value: '100',
                label: 'Very Long Label That Should Truncate',
                color: Colors.green,
              ),
            ),
          ),
        ),
      );

      // Verify label text exists and handles overflow
      final textFinder = find.text('Very Long Label That Should Truncate');
      expect(textFinder, findsOneWidget);
      
      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.overflow, TextOverflow.ellipsis);
      expect(textWidget.maxLines, 1);
    });
  });
}