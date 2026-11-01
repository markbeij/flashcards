import 'dart:convert';
import 'dart:io';

import 'package:flashcards/data/store/library.dart';
import 'package:flashcards/data/store/library_files.dart';
import 'package:flashcards/data/store/library_notifier.dart';
import 'package:flashcards/data/store/settings.dart';
import 'package:flashcards/data/store/store_writer.dart';
import 'package:flashcards/domain/card_content.dart';
import 'package:flashcards/domain/deck.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _word = VocabularyContent(
  language: VocabLanguage.latin,
  nlSingular: 'meisje',
  targetSingular: 'puella',
  gender: Gender.feminine,
  genitive: 'puellae',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory root;
  final opened = <(ProviderContainer, StoreWriter)>[];

  setUp(() async {
    root = await Directory.systemTemp.createTemp('library_');
  });

  tearDown(() async {
    for (final (container, writer) in opened) {
      await writer.idle;
      writer.dispose();
      container.dispose();
    }
    opened.clear();
    await root.delete(recursive: true);
  });

  /// Opens the library as the app does at startup.
  Future<(LibraryNotifier, StoreWriter, ProviderContainer)> open() async {
    final (container, writer) = await openLibrary(root: root);
    opened.add((container, writer));
    return (container.read(libraryProvider.notifier), writer, container);
  }

  File cardFile(String deckId) => File('${root.path}/cards/$deckId.json');

  Map<String, Object?> readJson(File file) =>
      jsonDecode(file.readAsStringSync()) as Map<String, Object?>;

  List<int> seqsOnDisk(String deckId) => [
    for (final card in readJson(cardFile(deckId))['cards'] as List<Object?>)
      (card as Map<String, Object?>)['seq'] as int,
  ];

  Deck deck(LibraryNotifier notifier, String title) =>
      notifier.createDeck(map: 'VWO 4', submap: 'Latijn', title: title);

  group('atomic write', () {
    test('an interrupted save leaves the old file intact', () async {
      final file = File('${root.path}/decks.json');
      await writeAtomically(
        file,
        utf8.encode('{"formatVersion":1,"decks":[]}'),
      );

      await expectLater(
        writeAtomically(
          file,
          utf8.encode(
            '{"formatVersion":1,"decks":[{"id":"x","map":"m","submap":"s","title":"t"}]}',
          ),
          beforeRename: () => throw const FileSystemException('killed'),
        ),
        throwsA(isA<FileSystemException>()),
      );

      expect(file.readAsStringSync(), '{"formatVersion":1,"decks":[]}');
      final library = await LibraryFiles(root).load();
      expect(library.decks, isEmpty);
    });

    test('a leftover temp file is ignored and later replaced', () async {
      final (notifier, writer, _) = await open();
      final h3 = deck(notifier, 'Woordjes H3');
      notifier.addCard(h3.id, _word);
      await writer.flush();
      File('${cardFile(h3.id).path}.tmp').writeAsStringSync('{"formatVer');

      final library = await LibraryFiles(root).load();
      expect(library.cardsIn(h3.id), hasLength(1));

      notifier.addCard(h3.id, _word);
      await writer.flush();
      expect(seqsOnDisk(h3.id), [1, 2]);
      expect(File('${cardFile(h3.id).path}.tmp').existsSync(), isFalse);
    });
  });

  group('writer', () {
    test('saves a short while after a change', () async {
      final (notifier, _, _) = await open();
      deck(notifier, 'Woordjes H3');
      expect(File('${root.path}/decks.json').existsSync(), isFalse);

      await Future<void>.delayed(const Duration(milliseconds: 800));
      expect(File('${root.path}/decks.json').existsSync(), isTrue);
    });

    test('saves right away when the app goes to the background', () async {
      final files = LibraryFiles(root);
      final library = await files.load();
      final writer = StoreWriter(
        files,
        library,
        debounce: const Duration(hours: 1),
      );
      final container = ProviderContainer(
        overrides: [loadedLibraryProvider.overrideWithValue(library)],
      );
      container.listen(libraryProvider, (_, next) => writer.changed(next));
      opened.add((container, writer));
      final binding = TestWidgetsFlutterBinding.instance;
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

      deck(container.read(libraryProvider.notifier), 'Woordjes H3');
      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await writer.idle;

      expect(File('${root.path}/decks.json').existsSync(), isTrue);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    });

    test('writes only changed files', () async {
      final (notifier, writer, _) = await open();
      final a = deck(notifier, 'A');
      final b = deck(notifier, 'B');
      notifier.addCard(a.id, _word);
      notifier.addCard(b.id, _word);
      await writer.flush();
      final before = cardFile(b.id).lastModifiedSync();

      await Future<void>.delayed(const Duration(milliseconds: 20));
      notifier.addCard(a.id, _word);
      await writer.flush();

      expect(seqsOnDisk(a.id), [1, 2]);
      expect(cardFile(b.id).lastModifiedSync(), before);
    });
  });

  test('reload after restart gives the same library', () async {
    final (notifier, writer, container) = await open();
    final h3 = deck(notifier, 'Woordjes H3');
    notifier.updateDeck(
      h3.copyWith(
        lastCardType: CardType.vocabulary,
        lastLanguage: VocabLanguage.latin,
      ),
    );
    final h4 = deck(notifier, 'Woordjes H4');
    final card = notifier.addCard(h3.id, _word);
    notifier.addCard(
      h3.id,
      ParadigmContent(
        heading: 'amare',
        rows: const [ParadigmRow(label: 'perf.', value: 'amāvī')],
      ),
    );
    notifier.updateSettings(
      const Settings(
        calibration: Calibration(backDyMm: 1),
        cuttingGuideShown: true,
      ).copyWith(
        lastDeckId: h3.id,
        lastCardId: card.uuid,
        lastPrintSelection: PrintSelection(deckIds: [h3.id, h4.id]),
      ),
    );
    await writer.flush();
    final before = container.read(libraryProvider);

    final (_, _, reopened) = await open();
    final after = reopened.read(libraryProvider);

    expect(after.decks, before.decks);
    expect(after.cards, before.cards);
    expect(after.settings, before.settings);
    for (final name in ['decks.json', 'settings.json', 'cards/${h3.id}.json']) {
      expect(readJson(File('${root.path}/$name'))['formatVersion'], 1);
    }
  });

  test('an unknown formatVersion is refused', () async {
    File('${root.path}/decks.json')
      ..createSync(recursive: true)
      ..writeAsStringSync('{"formatVersion":2,"decks":[]}');
    expect(LibraryFiles(root).load(), throwsFormatException);
  });

  group('decks', () {
    test('deleting a deck removes its card file and forgets it', () async {
      final (notifier, writer, container) = await open();
      final h3 = deck(notifier, 'Woordjes H3');
      final h4 = deck(notifier, 'Woordjes H4');
      final h3Card = notifier.addCard(h3.id, _word);
      notifier.addCard(h4.id, _word);
      notifier.updateSettings(
        container
            .read(libraryProvider)
            .settings
            .copyWith(
              lastDeckId: h3.id,
              lastCardId: h3Card.uuid,
              lastPrintSelection: PrintSelection(deckIds: [h3.id, h4.id]),
            ),
      );
      await writer.flush();
      expect(cardFile(h3.id).existsSync(), isTrue);

      notifier.deleteDeck(h3.id);
      await writer.flush();

      final library = container.read(libraryProvider);
      expect(library.decks.keys, [h4.id]);
      expect(library.cards.keys, [h4.id]);
      expect(cardFile(h3.id).existsSync(), isFalse);
      expect(cardFile(h4.id).existsSync(), isTrue);
      expect(library.settings.lastDeckId, isNull);
      expect(library.settings.lastCardId, isNull);
      expect(library.settings.lastPrintSelection!.deckIds, [h4.id]);

      final reloaded = await LibraryFiles(root).load();
      expect(reloaded.decks.keys, [h4.id]);
    });

    test('editing the map or submap moves the deck', () async {
      final (notifier, _, container) = await open();
      final h3 = deck(notifier, 'Woordjes H3');
      final card = notifier.addCard(h3.id, _word);

      notifier.updateDeck(h3.copyWith(map: 'VWO 5', submap: 'Grieks'));

      final library = container.read(libraryProvider);
      expect(mapsOf(library.decks.values), ['VWO 5']);
      expect(submapsOf('VWO 5', library.decks.values), ['Grieks']);
      expect(library.cardsIn(h3.id).keys, [card.uuid]);
    });

    test('map, submap and title are required', () async {
      final (notifier, _, container) = await open();
      expect(
        () => notifier.createDeck(map: ' ', submap: 'Latijn', title: 'H3'),
        throwsArgumentError,
      );
      expect(
        () => notifier.createDeck(map: 'VWO 4', submap: '', title: 'H3'),
        throwsArgumentError,
      );
      final h3 = deck(notifier, 'Woordjes H3');
      expect(
        () => notifier.updateDeck(h3.copyWith(title: '')),
        throwsArgumentError,
      );
      expect(container.read(libraryProvider).decks.values, [h3]);
    });
  });

  group('cards', () {
    test('numbers keep their gaps after a delete', () async {
      final (notifier, _, container) = await open();
      final h1 = deck(notifier, 'H1');
      final cards = [
        for (var i = 0; i < 3; i++) notifier.addCard(h1.id, _word),
      ];
      expect(cards.map((c) => c.seq), [1, 2, 3]);

      notifier.deleteCard(h1.id, cards[1].uuid);
      final next = notifier.addCard(h1.id, _word);
      expect(next.seq, 4);
      expect(
        container.read(libraryProvider).cardsIn(h1.id).values.map((c) => c.seq),
        unorderedEquals([1, 3, 4]),
      );
    });

    test('an update that changes nothing keeps the same state', () async {
      final (notifier, _, container) = await open();
      final h1 = deck(notifier, 'H1');
      final card = notifier.addCard(h1.id, _word);
      final before = container.read(libraryProvider);

      notifier.updateCard(h1.id, card.uuid, _word);
      expect(identical(container.read(libraryProvider), before), isTrue);

      const changed = BegripContent(term: 't', explanation: 'e');
      notifier.updateCard(h1.id, card.uuid, changed);
      expect(
        container.read(libraryProvider).cardsIn(h1.id)[card.uuid]!.content,
        changed,
      );
    });

    test(
      'a moved card gets the next number and both files are rewritten',
      () async {
        final (notifier, writer, container) = await open();
        final a = deck(notifier, 'A');
        final b = deck(notifier, 'B');
        final aCards = [
          for (var i = 0; i < 3; i++) notifier.addCard(a.id, _word),
        ];
        for (var i = 0; i < 2; i++) {
          notifier.addCard(b.id, _word);
        }
        await writer.flush();

        notifier.moveCard(aCards[1].uuid, from: a.id, to: b.id);
        await writer.flush();

        final library = container.read(libraryProvider);
        expect(library.cardsIn(a.id).containsKey(aCards[1].uuid), isFalse);
        final moved = library.cardsIn(b.id)[aCards[1].uuid]!;
        expect(moved.seq, 3);
        expect(moved.createdAt, aCards[1].createdAt);
        expect(seqsOnDisk(a.id), [1, 3]);
        expect(seqsOnDisk(b.id), [1, 2, 3]);
      },
    );

    test('moving the last card out removes the empty card file', () async {
      final (notifier, writer, _) = await open();
      final a = deck(notifier, 'A');
      final b = deck(notifier, 'B');
      final card = notifier.addCard(a.id, _word);
      await writer.flush();

      notifier.moveCard(card.uuid, from: a.id, to: b.id);
      await writer.flush();

      expect(cardFile(a.id).existsSync(), isFalse);
      expect(seqsOnDisk(b.id), [1]);
      final reloaded = await LibraryFiles(root).load();
      expect(reloaded.cardsIn(b.id).keys, [card.uuid]);
    });

    test('deleting the last opened card forgets it', () async {
      final (notifier, _, container) = await open();
      final h1 = deck(notifier, 'A');
      final card = notifier.addCard(h1.id, _word);
      notifier.updateSettings(
        container
            .read(libraryProvider)
            .settings
            .copyWith(lastCardId: card.uuid),
      );

      notifier.deleteCard(h1.id, card.uuid);
      expect(container.read(libraryProvider).settings.lastCardId, isNull);
    });
  });

  test('a library is immutable', () {
    final library = Library(
      decks: const {'a': Deck(id: 'a', map: 'm', submap: 's', title: 't')},
    );
    expect(() => library.decks.clear(), throwsUnsupportedError);
  });
}
