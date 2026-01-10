import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:divelogtest/widgets/custom_text_field.dart';

void main() {
  testWidgets('CustomTextField renders with label and handles input', (WidgetTester tester) async {
    final controller = TextEditingController();
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomTextField(
            controller: controller,
            label: 'Test Field',
          ),
        ),
      ),
    );

    expect(find.text('Test Field'), findsOneWidget);
    
    await tester.enterText(find.byType(CustomTextField), 'Hello');
    expect(controller.text, 'Hello');
  });

  testWidgets('CustomTextField shows error validation', (WidgetTester tester) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: CustomTextField(
              controller: controller,
              label: 'Required Field',
              required: true,
            ),
          ),
        ),
      ),
    );

    // Trigger validation
    formKey.currentState!.validate();
    await tester.pump();

    expect(find.text('Campo requerido'), findsOneWidget);
  });
}
