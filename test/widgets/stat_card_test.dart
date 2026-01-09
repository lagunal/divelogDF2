import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:divelogtest/widgets/stat_card.dart';
import 'package:divelogtest/theme.dart';

void main() {
  group('StatCard Widget Tests', () {
    testWidgets('displays icon, value, and label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: const Scaffold(
            body: StatCard(
              icon: Icons.scuba_diving,
              value: '25',
              label: 'Total Dives',
              color: Colors.blue,
            ),
          ),
        ),
      );

      // Verify icon is shown
      expect(find.byIcon(Icons.scuba_diving), findsOneWidget);
      
      // Verify value is shown
      expect(find.text('25'), findsOneWidget);
      
      // Verify label is shown
      expect(find.text('Total Dives'), findsOneWidget);
    });

    testWidgets('uses correct text styles', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: const Scaffold(
            body: StatCard(
              icon: Icons.arrow_downward,
              value: '30.5m',
              label: 'Deepest Dive',
              color: Colors.red,
            ),
          ),
        ),
      );

      // Find the value text widget
      final valueText = tester.widget<Text>(find.text('30.5m'));
      
      // Verify value uses headline style (large text)
      expect(valueText.style?.fontWeight, FontWeight.bold);
      
      // Find the label text widget
      final labelText = tester.widget<Text>(find.text('Deepest Dive'));
      
      // Verify label uses body style (smaller text)
      expect(labelText.style, isNotNull);
    });

    testWidgets('applies custom color to icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: const Scaffold(
            body: StatCard(
              icon: Icons.schedule,
              value: '500',
              label: 'Bottom Time',
              color: Colors.green,
            ),
          ),
        ),
      );

      // Find the icon widget
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.schedule));
      
      // Verify color is applied
      expect(iconWidget.color, Colors.green);
      
      // Verify icon size
      expect(iconWidget.size, 24);
    });

    testWidgets('renders correctly in light theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: const Scaffold(
            body: StatCard(
              icon: Icons.trending_up,
              value: '18.5m',
              label: 'Average Depth',
              color: Colors.orange,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify card renders without errors
      expect(find.byType(StatCard), findsOneWidget);
      expect(find.text('18.5m'), findsOneWidget);
      expect(find.text('Average Depth'), findsOneWidget);
    });

    testWidgets('renders correctly in dark theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: const Scaffold(
            body: StatCard(
              icon: Icons.trending_up,
              value: '18.5m',
              label: 'Average Depth',
              color: Colors.orange,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify card renders without errors in dark mode
      expect(find.byType(StatCard), findsOneWidget);
      expect(find.text('18.5m'), findsOneWidget);
      
      // Verify container decoration exists
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(StatCard),
          matching: find.byType(Container),
        ).first,
      );
      
      expect(container.decoration, isNotNull);
    });

    testWidgets('displays large numeric values correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: const Scaffold(
            body: StatCard(
              icon: Icons.schedule,
              value: '1,234.5',
              label: 'Total Time',
              color: Colors.purple,
            ),
          ),
        ),
      );

      // Verify large value is displayed
      expect(find.text('1,234.5'), findsOneWidget);
    });

    testWidgets('handles various icon types', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: const Scaffold(
            body: Column(
              children: [
                StatCard(
                  icon: Icons.scuba_diving,
                  value: '10',
                  label: 'Dives',
                  color: Colors.blue,
                ),
                StatCard(
                  icon: Icons.arrow_downward,
                  value: '30m',
                  label: 'Depth',
                  color: Colors.red,
                ),
                StatCard(
                  icon: Icons.schedule,
                  value: '500',
                  label: 'Time',
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ),
      );

      // Verify all icons are rendered
      expect(find.byIcon(Icons.scuba_diving), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('has proper padding and structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: const Scaffold(
            body: StatCard(
              icon: Icons.star,
              value: '100',
              label: 'Rating',
              color: Colors.amber,
            ),
          ),
        ),
      );

      // Verify Column structure
      expect(find.byType(Column), findsWidgets);
      
      // Verify SizedBox spacers exist (for spacing between elements)
      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}
