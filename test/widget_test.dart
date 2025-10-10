import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:napphy_services/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NapphyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}