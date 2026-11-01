import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/card_content.dart';
import '../../domain/flashcard.dart';
import '../../domain/deck.dart';
import 'library.dart';
import 'library_files.dart';
import 'settings.dart';
import 'store_writer.dart';

/// The library as loaded at startup; overridden by [openLibrary].
final loadedLibraryProvider = Provider<Library>(
  (ref) => throw UnimplementedError('Use openLibrary() to load the library'),
);

final libraryProvider = NotifierProvider<LibraryNotifier, Library>(
  LibraryNotifier.new,
);

/// Loads the library from [root] (default: [libraryDirectory]) and returns a
/// container whose library changes are saved by a [StoreWriter].
Future<(ProviderContainer, StoreWriter)> openLibrary({Directory? root}) async {
  final files = LibraryFiles(root ?? await libraryDirectory());
  final library = await files.load();
  final writer = StoreWriter(files, library);
  final container = ProviderContainer(
    overrides: [loadedLibraryProvider.overrideWithValue(library)],
  );
  container.listen(libraryProvider, (_, next) => writer.changed(next));
  return (container, writer);
}

/// All changes to the library, including the rules that keep the files
/// consistent with each other.
class LibraryNotifier extends Notifier<Library> {
  static const _uuid = Uuid();

  @override
  Library build() => ref.watch(loadedLibraryProvider);

  // Decks

  /// Creates a deck. [map], [submap] and [title] are required.
  Deck createDeck({
    required String map,
    required String submap,
    required String title,
  }) {
    final deck = Deck(id: _uuid.v4(), map: map, submap: submap, title: title);
    _checkRequired(deck);
    state = state.copyWith(decks: {...state.decks, deck.id: deck});
    return deck;
  }

  /// Replaces a deck's map, submap, title or last entry choices. A new map or
  /// submap moves the deck there.
  void updateDeck(Deck deck) {
    _deck(deck.id);
    _checkRequired(deck);
    state = state.copyWith(decks: {...state.decks, deck.id: deck});
  }

  /// Deletes a deck and its cards, and forgets them in the settings.
  void deleteDeck(String deckId) {
    _deck(deckId);
    final doomedCards = state.cardsIn(deckId).keys.toSet();
    final settings = state.settings;
    final selection = settings.lastPrintSelection;
    final cleaned = settings.copyWith(
      lastDeckId: settings.lastDeckId == deckId ? null : settings.lastDeckId,
      lastCardId: doomedCards.contains(settings.lastCardId)
          ? null
          : settings.lastCardId,
      lastPrintSelection: selection == null
          ? null
          : PrintSelection(
              deckIds: [
                for (final id in selection.deckIds)
                  if (id != deckId) id,
              ],
            ),
    );
    state = state.copyWith(
      decks: {...state.decks}..remove(deckId),
      cards: {...state.cards}..remove(deckId),
      settings: cleaned == settings ? null : cleaned,
    );
  }

  // Cards

  Flashcard addCard(String deckId, CardContent content) {
    _deck(deckId);
    final now = DateTime.now().toUtc();
    final card = Flashcard(
      uuid: _uuid.v4(),
      seq: nextSeq(state.cardsIn(deckId).values),
      content: content,
      createdAt: now,
      updatedAt: now,
    );
    _putCards({
      deckId: {...state.cardsIn(deckId), card.uuid: card},
    });
    return card;
  }

  void updateCard(String deckId, String uuid, CardContent content) {
    final card = _card(deckId, uuid);
    // Keep updatedAt for a commit that changes nothing, e.g. on focus loss.
    if (content == card.content) return;
    final updated = card.copyWith(
      content: content,
      updatedAt: DateTime.now().toUtc(),
    );
    _putCards({
      deckId: {...state.cardsIn(deckId), uuid: updated},
    });
  }

  void deleteCard(String deckId, String uuid) {
    _card(deckId, uuid);
    _putCards(
      {
        deckId: {...state.cardsIn(deckId)}..remove(uuid),
      },
      settings: state.settings.lastCardId == uuid
          ? state.settings.copyWith(lastCardId: null)
          : null,
    );
  }

  /// Moves a card to another deck, where it gets the next number (so it
  /// counts as changed). Both card files change in one state update, so the
  /// writer saves them in one queued job.
  void moveCard(String uuid, {required String from, required String to}) {
    final card = _card(from, uuid);
    _deck(to);
    if (from == to) return;
    final moved = card.copyWith(
      seq: nextSeq(state.cardsIn(to).values),
      updatedAt: DateTime.now().toUtc(),
    );
    _putCards({
      from: {...state.cardsIn(from)}..remove(uuid),
      to: {...state.cardsIn(to), uuid: moved},
    });
  }

  // Settings

  void updateSettings(Settings settings) {
    state = state.copyWith(settings: settings);
  }

  Deck _deck(String id) =>
      state.decks[id] ??
      (throw ArgumentError.value(id, 'deckId', 'No such deck'));

  static void _checkRequired(Deck deck) {
    for (final (name, value) in [
      ('map', deck.map),
      ('submap', deck.submap),
      ('title', deck.title),
    ]) {
      if (value.trim().isEmpty) {
        throw ArgumentError.value(value, name, 'Must not be blank');
      }
    }
  }

  Flashcard _card(String deckId, String uuid) =>
      state.cardsIn(deckId)[uuid] ??
      (throw ArgumentError.value(uuid, 'uuid', 'No such card in $deckId'));

  void _putCards(
    Map<String, Map<String, Flashcard>> changed, {
    Settings? settings,
  }) {
    state = state.copyWith(
      cards: {
        ...state.cards,
        for (final MapEntry(:key, :value) in changed.entries)
          key: Map.unmodifiable(value),
      },
      settings: settings,
    );
  }
}
