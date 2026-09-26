import 'package:cipher/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('bootstraps while settings load', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CipherApp()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
