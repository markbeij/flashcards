import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/flashcard.dart';
import '../../domain/deck.dart';
import 'library.dart';
import 'settings.dart';

const formatVersion = 1;

/// `Application Support/library/`, which iCloud Backup includes.
Future<Directory> libraryDirectory() async =>
    Directory('${(await getApplicationSupportDirectory()).path}/library');

/// Reads and writes the library files under [root]:
/// `decks.json`, `cards/<deckId>.json` and `settings.json`.
class LibraryFiles {
  LibraryFiles(this.root);

  final Directory root;

  File get _decks => File('${root.path}/decks.json');
  File get _settings => File('${root.path}/settings.json');
  File _cards(String deckId) => File('${root.path}/cards/$deckId.json');

  /// Loads everything. Missing files mean an empty library or default
  /// settings. Card files of unknown decks are ignored.
  Future<Library> load() async {
    final decks = <String, Deck>{
      for (final deck in (await _readList(_decks, 'decks')).map(Deck.fromJson))
        deck.id: deck,
    };
    final cards = <String, Map<String, Flashcard>>{};
    for (final deckId in decks.keys) {
      final list = await _readList(_cards(deckId), 'cards');
      if (list.isEmpty) continue;
      cards[deckId] = Map.unmodifiable({
        for (final card in list.map(Flashcard.fromJson)) card.uuid: card,
      });
    }
    final settingsJson = await _readFile(_settings);
    return Library(
      decks: decks,
      cards: cards,
      settings: settingsJson == null
          ? const Settings()
          : Settings.fromJson(settingsJson),
    );
  }

  Future<void> writeDecks(Iterable<Deck> decks) => _write(_decks, {
    'decks': [for (final deck in decks) deck.toJson()],
  });

  Future<void> writeCards(String deckId, Iterable<Flashcard> cards) =>
      _write(_cards(deckId), {
        'cards': [
          for (final card
              in cards.toList()..sort((a, b) => a.seq.compareTo(b.seq)))
            card.toJson(),
        ],
      });

  Future<void> deleteCards(String deckId) async {
    final file = _cards(deckId);
    if (await file.exists()) await file.delete();
  }

  Future<void> writeSettings(Settings settings) =>
      _write(_settings, settings.toJson());

  Future<void> _write(File file, Map<String, Object?> body) => writeAtomically(
    file,
    utf8.encode(jsonEncode({'formatVersion': formatVersion, ...body})),
  );

  Future<Map<String, Object?>?> _readFile(File file) async {
    if (!await file.exists()) return null;
    final json = jsonDecode(await file.readAsString()) as Map<String, Object?>;
    final version = json['formatVersion'];
    if (version != formatVersion) {
      throw FormatException('${file.path}: unsupported formatVersion $version');
    }
    return json;
  }

  Future<List<Map<String, Object?>>> _readList(File file, String key) async {
    final json = await _readFile(file);
    if (json == null) return const [];
    return [
      for (final item in json[key] as List<Object?>)
        item as Map<String, Object?>,
    ];
  }
}

/// Replaces [file] with [bytes] so that it holds either the old or the new
/// content, never a mix: write a temp file, flush it to disk, then rename it
/// over [file].
Future<void> writeAtomically(
  File file,
  List<int> bytes, {
  @visibleForTesting Future<void> Function()? beforeRename,
}) async {
  await file.parent.create(recursive: true);
  final temp = File('${file.path}.tmp');
  final raf = await temp.open(mode: FileMode.write);
  try {
    await raf.writeFrom(bytes);
    await raf.flush();
  } finally {
    await raf.close();
  }
  await beforeRename?.call();
  await temp.rename(file.path);
}
