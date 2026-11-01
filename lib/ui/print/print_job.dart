import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/store/library.dart';
import '../../data/store/library_notifier.dart';
import '../../data/store/settings.dart';
import '../../domain/card_content.dart';
import '../../domain/deck.dart';
import '../../render/grid.dart';
import '../../render/overflow.dart';
import '../../render/sheet.dart';
import '../providers.dart';

/// What the print set-up page has chosen.
class PrintJob {
  const PrintJob({
    this.deckIds = const {},
    this.swap = false,
    this.printAnyway = const {},
  });

  final Set<String> deckIds;

  /// Print each card's back as its front.
  final bool swap;

  /// Overflowing cards the user chose not to skip.
  final Set<String> printAnyway;

  PrintJob copyWith({
    Set<String>? deckIds,
    bool? swap,
    Set<String>? printAnyway,
  }) => PrintJob(
    deckIds: deckIds ?? this.deckIds,
    swap: swap ?? this.swap,
    printAnyway: printAnyway ?? this.printAnyway,
  );
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

  void toggleSwap() => state = state.copyWith(swap: !state.swap);

  void setSkip(String cardId, {required bool skip}) {
    state = state.copyWith(
      printAnyway: skip
          ? ({...state.printAnyway}..remove(cardId))
          : {...state.printAnyway, cardId},
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

/// The cards of the ticked decks in Library order, and which of them
/// overflow.
class PrintPlan {
  const PrintPlan({required this.cards, required this.overflowing});

  /// Every card of the ticked decks, overflowing ones included.
  final List<PrintCard> cards;

  /// Cards that don't fit, by uuid.
  final Set<String> overflowing;

  /// The cards that go on paper: overflowing cards are skipped unless the
  /// user chose to print them anyway.
  List<PrintCard> printed(PrintJob job) => [
    for (final c in cards)
      if (!overflowing.contains(c.card.uuid) ||
          job.printAnyway.contains(c.card.uuid))
        c,
  ];

  /// Target languages of the vocabulary cards, for the direction line.
  Set<VocabLanguage> get languages => {
    for (final c in cards)
      if (c.card.content case VocabularyContent(:final language)) language,
  };
}

final printPlanProvider = Provider<PrintPlan>((ref) {
  final job = ref.watch(printJobProvider);
  final library = ref.watch(libraryProvider);
  final OverflowChecker? checker = ref.watch(overflowCheckerProvider);
  final cards = <PrintCard>[];
  for (final deck in orderedDecks(library.decks.values)) {
    if (!job.deckIds.contains(deck.id)) continue;
    final inDeck = library.cardsIn(deck.id).values.toList()
      ..sort((a, b) => a.seq.compareTo(b.seq));
    cards.addAll([for (final card in inDeck) PrintCard(card, deck.title)]);
  }
  return PrintPlan(
    cards: cards,
    overflowing: {
      for (final c in cards)
        if (checker?.overflows(c.card.content) ?? false) c.card.uuid,
    },
  );
});

/// The sheet grid with the printer calibration.
SheetGrid gridFor(Settings settings) => SheetGrid(
  backDxMm: settings.calibration?.backDxMm ?? 0,
  backDyMm: settings.calibration?.backDyMm ?? 0,
);
