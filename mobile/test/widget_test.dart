import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('smoke: MaterialApp builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Nuvelo test'),
        ),
      ),
    );
    expect(find.text('Nuvelo test'), findsOneWidget);
  });
}
