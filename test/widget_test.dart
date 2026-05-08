import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:transformx/main.dart';

void main() {
  testWidgets('shows converter UI and computes default conversion', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('TransformX'), findsOneWidget);
    expect(find.byKey(const Key('inputField')), findsOneWidget);
    expect(find.byKey(const Key('resultText')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('inputField')), '100');
    await tester.pump();

    expect(find.textContaining('212 F'), findsOneWidget);
  });
}
