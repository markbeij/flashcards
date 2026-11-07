import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/store/library_notifier.dart';
import '../domain/card_content.dart';
import '../domain/deck.dart';
import '../render/fonts.dart';
import '../render/overflow.dart';

/// The PDF theme with the card font.
final cardThemeProvider = FutureProvider<pw.ThemeData>(
  (ref) => loadCardTheme(),
);

/// Measures cards for overflow; null until the card font has loaded.
final overflowCheckerProvider = Provider<OverflowChecker?>((ref) {
  final theme = ref.watch(cardThemeProvider).value;
  return theme == null ? null : OverflowChecker(theme);
});

/// Whether [content] doesn't fit on the card. False until measured.
bool overflows(Ref ref, CardContent content) =>
    ref.watch(overflowCheckerProvider)?.overflows(content) ?? false;

/// What is typed in the Library's search field. Lives above the layout
/// switch, so a resize keeps it.
class LibrarySearch extends Notifier<String> {
  @override
  String build() => '';

  void set(String query) => state = query;
}

final librarySearchProvider = NotifierProvider<LibrarySearch, String>(
  LibrarySearch.new,
);

final decksProvider = Provider<Map<String, Deck>>(
  (ref) => ref.watch(libraryProvider.select((l) => l.decks)),
);

final deckProvider = Provider.family<Deck?, String>(
  (ref, id) => ref.watch(libraryProvider.select((l) => l.decks[id])),
);

/// The selected card in the deck that is shown. Lives above the layout
/// switch, so it survives a change between one and two columns.
class CardSelection extends Notifier<String?> {
  /// At startup, the card that was opened last.
  @override
  String? build() => ref.read(loadedLibraryProvider).settings.lastCardId;

  void select(String? cardId) => state = cardId;
}

final cardSelectionProvider = NotifierProvider<CardSelection, String?>(
  CardSelection.new,
);

/// The cards ticked in select mode; null when select mode is off.
class SelectMode extends Notifier<Set<String>?> {
  @override
  Set<String>? build() => null;

  void start() => state = const {};
  void stop() => state = null;

  void toggle(String cardId) {
    final current = state;
    if (current == null) return;
    state = current.contains(cardId)
        ? ({...current}..remove(cardId))
        : {...current, cardId};
  }
}

final selectModeProvider = NotifierProvider<SelectMode, Set<String>?>(
  SelectMode.new,
);
