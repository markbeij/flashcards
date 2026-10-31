import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../domain/flashcard.dart';
import '../../domain/folder.dart';
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
       _folders = saved.folders,
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
  Map<String, Folder> _folders;
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
  // - folders.json first, so a card file never belongs to an unknown folder;
  // - files that gained cards before files that lost cards, so a moved card
  //   is never missing from both;
  // - card files of deleted folders last.
  Future<void> _writeChanges(Library next) async {
    if (!identical(next.folders, _folders)) {
      await _files.writeFolders(next.folders.values);
      _folders = next.folders;
    }

    final changed = [
      for (final MapEntry(key: folderId, value: cards) in next.cards.entries)
        if (!identical(cards, _cards[folderId])) folderId,
    ];
    bool gained(String folderId) {
      final saved = _cards[folderId] ?? const {};
      return next.cards[folderId]!.keys.any((uuid) => !saved.containsKey(uuid));
    }

    for (final folderId in [
      ...changed.where(gained),
      ...changed.where((folderId) => !gained(folderId)),
    ]) {
      final cards = next.cards[folderId]!;
      await _files.writeCards(folderId, cards.values);
      _cards[folderId] = cards;
    }

    if (!identical(next.settings, _settings)) {
      await _files.writeSettings(next.settings);
      _settings = next.settings;
    }

    for (final folderId in [
      for (final folderId in _cards.keys)
        if (!next.cards.containsKey(folderId)) folderId,
    ]) {
      await _files.deleteCards(folderId);
      _cards.remove(folderId);
    }
  }
}
