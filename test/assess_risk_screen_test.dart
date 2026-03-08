import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diapredict/screens/assess_risk_screen.dart';

void main() {

  testWidgets('AssessRiskScreen loads first step', (WidgetTester tester) async {

    await tester.pumpWidget(
      const MaterialApp(
        home: AssessRiskScreen(
          userName: 'Test',
          email: 'test@test.com',
        ),
      ),
    );

    expect(find.text('Age'), findsOneWidget);

  });

}