import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flashcards/ui/app.dart';

void main() {
  testWidgets('app starts in Dutch by default', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('nl')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const ProviderScope(child: FlashcardsApp()));
    await tester.pumpAndSettle();

    expect(find.text('Flitskaarten'), findsOneWidget);
    expect(find.text('Printtest'), findsOneWidget);
  });
}
