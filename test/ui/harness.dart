import 'package:flashcards/data/store/library.dart';
import 'package:flashcards/data/store/library_notifier.dart';
import 'package:flashcards/ui/app.dart';
import 'package:flashcards/ui/providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const wide = Size(1024, 768);
const narrow = Size(390, 844);

/// Runs the app in Dutch on an in-memory [library] (nothing is written to
/// disk) in a window of [size].
Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  Library? library,
  Size size = wide,
}) async {
  tester.platformDispatcher.localesTestValue = const [Locale('nl')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  setSize(tester, size);
  addTearDown(tester.view.reset);
  final container = ProviderContainer(
    overrides: [loadedLibraryProvider.overrideWithValue(library ?? Library())],
  );
  addTearDown(container.dispose);
  // Load the card font for real, outside the fake clock.
  await tester.runAsync(() => container.read(cardThemeProvider.future));
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const FlashcardsApp(),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void setSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
}

/// The text field with the VoiceOver label [label].
Finder field(String label) => find.descendant(
  of: find.byWidgetPredicate(
    (w) => w is Semantics && w.properties.label == label,
  ),
  matching: find.byType(EditableText),
);

bool hasFocus(WidgetTester tester, Finder finder) =>
    tester.widget<EditableText>(finder).focusNode.hasFocus;
