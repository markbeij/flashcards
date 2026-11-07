import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/store/library.dart';
import '../../data/store/library_notifier.dart';
import '../../data/store/settings.dart';
import '../../domain/deck.dart';
import '../../render/grid.dart';
import '../../render/sheet.dart';

/// What the print set-up page has chosen.
class PrintJob {
  const PrintJob({this.deckIds = const {}});

  final Set<String> deckIds;

  PrintJob copyWith({Set<String>? deckIds}) =>
      PrintJob(deckIds: deckIds ?? this.deckIds);
}

class PrintJobNotifier extends Notifier<PrintJob> {
  @override
  PrintJob build() => const PrintJob();

  /// Starts with [deckId] ticked, or with the last selection.
  void open({String? deckId}) {
    final library = ref.read(libraryProvider);
    final Set<String> ids = deckId != null
        ? {deckId}
        : {
            for (final id
                in library.settings.lastPrintSelection?.deckIds ?? const [])
              if (library.decks.containsKey(id)) id,
          };
    state = PrintJob(deckIds: ids);
  }

  void setDecks(Iterable<String> deckIds, {required bool ticked}) {
    state = state.copyWith(
      deckIds: ticked
          ? {...state.deckIds, ...deckIds}
          : ({...state.deckIds}..removeAll(deckIds)),
    );
  }

  /// Remembers the ticked decks for the next print from the Library.
  void remember() {
    final notifier = ref.read(libraryProvider.notifier);
    final settings = ref.read(libraryProvider).settings;
    final selection = PrintSelection(
      deckIds: _ordered(ref.read(libraryProvider)),
    );
    if (settings.lastPrintSelection == selection) return;
    notifier.updateSettings(settings.copyWith(lastPrintSelection: selection));
  }

  List<String> _ordered(Library library) => [
    for (final deck in orderedDecks(library.decks.values))
      if (state.deckIds.contains(deck.id)) deck.id,
  ];
}

final printJobProvider = NotifierProvider<PrintJobNotifier, PrintJob>(
  PrintJobNotifier.new,
);

/// All decks in Library order: map, submap, title.
List<Deck> orderedDecks(Iterable<Deck> decks) => [
  for (final map in mapsOf(decks))
    for (final submap in submapsOf(map, decks)) ...decksIn(map, submap, decks),
];

/// The cards of the ticked decks in Library order.
final printCardsProvider = Provider<List<PrintCard>>((ref) {
  final job = ref.watch(printJobProvider);
  final library = ref.watch(libraryProvider);
  final cards = <PrintCard>[];
  for (final deck in orderedDecks(library.decks.values)) {
    if (!job.deckIds.contains(deck.id)) continue;
    final inDeck = library.cardsIn(deck.id).values.toList()
      ..sort((a, b) => a.seq.compareTo(b.seq));
    cards.addAll([for (final card in inDeck) PrintCard(card, deck.title)]);
  }
  return cards;
});

/// The sheet grid with the printer calibration.
SheetGrid gridFor(Settings settings) => SheetGrid(
  backDxMm: settings.calibration?.backDxMm ?? 0,
  backDyMm: settings.calibration?.backDyMm ?? 0,
);
