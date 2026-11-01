import '../../domain/flashcard.dart';
import '../../domain/deck.dart';
import 'settings.dart';

/// The whole library in memory. Immutable: every change makes a new
/// [Library] that shares the unchanged maps, so a changed file can be found
/// by identity.
class Library {
  Library({
    Map<String, Deck> decks = const {},
    Map<String, Map<String, Flashcard>> cards = const {},
    Settings settings = const Settings(),
  }) : this._(_freezeDecks(decks), _freezeCards(cards), settings);

  const Library._(this.decks, this.cards, this.settings);

  /// By deck id.
  final Map<String, Deck> decks;

  /// Deck id → card uuid → card. A deck without cards has no entry.
  /// The inner maps must be unmodifiable.
  final Map<String, Map<String, Flashcard>> cards;

  final Settings settings;

  Map<String, Flashcard> cardsIn(String deckId) => cards[deckId] ?? const {};

  /// Maps that are not passed keep their identity.
  Library copyWith({
    Map<String, Deck>? decks,
    Map<String, Map<String, Flashcard>>? cards,
    Settings? settings,
  }) => Library._(
    decks == null ? this.decks : _freezeDecks(decks),
    cards == null ? this.cards : _freezeCards(cards),
    settings ?? this.settings,
  );
}

Map<String, Deck> _freezeDecks(Map<String, Deck> decks) =>
    Map.unmodifiable(decks);

Map<String, Map<String, Flashcard>> _freezeCards(
  Map<String, Map<String, Flashcard>> cards,
) => Map.unmodifiable({
  for (final MapEntry(:key, :value) in cards.entries)
    if (value.isNotEmpty) key: value,
});
