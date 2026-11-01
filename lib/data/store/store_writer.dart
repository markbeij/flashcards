import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../domain/flashcard.dart';
import '../../domain/deck.dart';
import 'library.dart';
import 'library_files.dart';
import 'settings.dart';

/// Saves library changes: a short while after the last change, and right
/// away when the app goes to the background.
///
/// It remembers what each file last held and writes only the files whose
/// part of the [Library] changed since. All writes go through one queue.
class StoreWriter {
  StoreWriter(
    this._files,
    Library saved, {
    this.debounce = const Duration(milliseconds: 500),
  }) : _latest = saved,
       _decks = saved.decks,
       _settings = saved.settings,
       _cards = Map.of(saved.cards) {
    _lifecycle = AppLifecycleListener(onInactive: _flushNow, onHide: _flushNow);
  }

  final LibraryFiles _files;
  final Duration debounce;
  late final AppLifecycleListener _lifecycle;

  Library _latest;
  Timer? _timer;
  Future<void> _queue = Future.value();

  // What the files hold now.
  Map<String, Deck> _decks;
  Settings _settings;
  final Map<String, Map<String, Flashcard>> _cards;

  /// Call with every new library state.
  void changed(Library library) {
    _latest = library;
    _timer?.cancel();
    _timer = Timer(debounce, _flushNow);
  }

  /// Writes all changes now. Completes when they are on disk; fails if a
  /// write failed, in which case the next flush retries that file.
  Future<void> flush() {
    _timer?.cancel();
    final job = _queue.then((_) => _writeChanges(_latest));
    _queue = job.catchError((Object _) {});
    return job;
  }

  /// Completes when every queued write has finished.
  Future<void> get idle => _queue;

  void dispose() {
    _timer?.cancel();
    _lifecycle.dispose();
  }

  void _flushNow() {
    flush().catchError((Object error, StackTrace stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'store',
          context: ErrorDescription('while saving the library'),
        ),
      );
    });
  }

  // Order matters when the app is killed halfway through:
  // - decks.json first, so a card file never belongs to an unknown deck;
  // - files that gained cards before files that lost cards, so a moved card
  //   is never missing from both;
  // - card files of deleted decks, and of decks that lost their last card,
  //   last.
  Future<void> _writeChanges(Library next) async {
    if (!identical(next.decks, _decks)) {
      await _files.writeDecks(next.decks.values);
      _decks = next.decks;
    }

    final changed = [
      for (final MapEntry(key: deckId, value: cards) in next.cards.entries)
        if (!identical(cards, _cards[deckId])) deckId,
    ];
    bool gained(String deckId) {
      final saved = _cards[deckId] ?? const {};
      return next.cards[deckId]!.keys.any((uuid) => !saved.containsKey(uuid));
    }

    for (final deckId in [
      ...changed.where(gained),
      ...changed.where((deckId) => !gained(deckId)),
    ]) {
      final cards = next.cards[deckId]!;
      await _files.writeCards(deckId, cards.values);
      _cards[deckId] = cards;
    }

    if (!identical(next.settings, _settings)) {
      await _files.writeSettings(next.settings);
      _settings = next.settings;
    }

    for (final deckId in [
      for (final deckId in _cards.keys)
        if (!next.cards.containsKey(deckId)) deckId,
    ]) {
      await _files.deleteCards(deckId);
      _cards.remove(deckId);
    }
  }
}
