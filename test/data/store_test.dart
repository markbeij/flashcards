import 'dart:convert';
import 'dart:io';

import 'package:flashcards/data/store/library.dart';
import 'package:flashcards/data/store/library_files.dart';
import 'package:flashcards/data/store/library_notifier.dart';
import 'package:flashcards/data/store/settings.dart';
import 'package:flashcards/data/store/store_writer.dart';
import 'package:flashcards/domain/card_content.dart';
import 'package:flashcards/domain/folder.dart';
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

  File cardFile(String folderId) => File('${root.path}/cards/$folderId.json');

  Map<String, Object?> readJson(File file) =>
      jsonDecode(file.readAsStringSync()) as Map<String, Object?>;

  List<int> seqsOnDisk(String folderId) => [
    for (final card in readJson(cardFile(folderId))['cards'] as List<Object?>)
      (card as Map<String, Object?>)['seq'] as int,
  ];

  group('atomic write', () {
    test('an interrupted save leaves the old file intact', () async {
      final file = File('${root.path}/folders.json');
      await writeAtomically(
        file,
        utf8.encode('{"formatVersion":1,"folders":[]}'),
      );

      await expectLater(
        writeAtomically(
          file,
          utf8.encode(
            '{"formatVersion":1,"folders":[{"id":"x","name":"new"}]}',
          ),
          beforeRename: () => throw const FileSystemException('killed'),
        ),
        throwsA(isA<FileSystemException>()),
      );

      expect(file.readAsStringSync(), '{"formatVersion":1,"folders":[]}');
      final library = await LibraryFiles(root).load();
      expect(library.folders, isEmpty);
    });

    test('a leftover temp file is ignored and later replaced', () async {
      final (notifier, writer, _) = await open();
      final folder = notifier.createFolder('Latijn');
      notifier.addCard(folder.id, _word);
      await writer.flush();
      File('${cardFile(folder.id).path}.tmp').writeAsStringSync('{"formatVer');

      final library = await LibraryFiles(root).load();
      expect(library.cardsIn(folder.id), hasLength(1));

      notifier.addCard(folder.id, _word);
      await writer.flush();
      expect(seqsOnDisk(folder.id), [1, 2]);
      expect(File('${cardFile(folder.id).path}.tmp').existsSync(), isFalse);
    });
  });

  group('writer', () {
    test('saves a short while after a change', () async {
      final (notifier, _, _) = await open();
      notifier.createFolder('Latijn');
      expect(File('${root.path}/folders.json').existsSync(), isFalse);

      await Future<void>.delayed(const Duration(milliseconds: 800));
      expect(File('${root.path}/folders.json').existsSync(), isTrue);
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

      container.read(libraryProvider.notifier).createFolder('Latijn');
      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await writer.idle;

      expect(File('${root.path}/folders.json').existsSync(), isTrue);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    });

    test('writes only changed files', () async {
      final (notifier, writer, _) = await open();
      final a = notifier.createFolder('A');
      final b = notifier.createFolder('B');
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
    final latin = notifier.createFolder('Latijn');
    notifier.updateFolder(
      latin.copyWith(
        color: FolderColor.red,
        lastCardType: CardType.vocabulary,
        lastLanguage: VocabLanguage.latin,
      ),
    );
    final h3 = notifier.createFolder('H3', parentId: latin.id);
    final card = notifier.addCard(h3.id, _word, tags: ['toets 3']);
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
        lastFolderId: h3.id,
        lastCardId: card.uuid,
        lastPrintSelection: PrintSelection(
          folderIds: [latin.id],
          tags: ['toets 3'],
        ),
      ),
    );
    await writer.flush();
    final before = container.read(libraryProvider);

    final (_, _, reopened) = await open();
    final after = reopened.read(libraryProvider);

    expect(after.folders, before.folders);
    expect(after.cards, before.cards);
    expect(after.settings, before.settings);
    for (final name in [
      'folders.json',
      'settings.json',
      'cards/${h3.id}.json',
    ]) {
      expect(readJson(File('${root.path}/$name'))['formatVersion'], 1);
    }
  });

  test('an unknown formatVersion is refused', () async {
    File('${root.path}/folders.json')
      ..createSync(recursive: true)
      ..writeAsStringSync('{"formatVersion":2,"folders":[]}');
    expect(LibraryFiles(root).load(), throwsFormatException);
  });

  group('folders', () {
    test(
      'deleting a folder removes its subfolders and their card files',
      () async {
        final (notifier, writer, container) = await open();
        final latin = notifier.createFolder('Latijn');
        final vwo4 = notifier.createFolder('VWO 4', parentId: latin.id);
        final h3 = notifier.createFolder('H3', parentId: vwo4.id);
        final greek = notifier.createFolder('Grieks');
        for (final folder in [latin, vwo4, h3, greek]) {
          notifier.addCard(folder.id, _word);
        }
        final h3Card = container
            .read(libraryProvider)
            .cardsIn(h3.id)
            .keys
            .single;
        notifier.updateSettings(
          container
              .read(libraryProvider)
              .settings
              .copyWith(
                lastFolderId: vwo4.id,
                lastCardId: h3Card,
                lastPrintSelection: PrintSelection(
                  folderIds: [h3.id, greek.id],
                ),
              ),
        );
        await writer.flush();

        notifier.deleteFolder(latin.id);
        await writer.flush();

        final library = container.read(libraryProvider);
        expect(library.folders.keys, [greek.id]);
        expect(library.cards.keys, [greek.id]);
        for (final folder in [latin, vwo4, h3]) {
          expect(
            cardFile(folder.id).existsSync(),
            isFalse,
            reason: folder.name,
          );
        }
        expect(cardFile(greek.id).existsSync(), isTrue);
        expect(library.settings.lastFolderId, isNull);
        expect(library.settings.lastCardId, isNull);
        expect(library.settings.lastPrintSelection!.folderIds, [greek.id]);

        final reloaded = await LibraryFiles(root).load();
        expect(reloaded.folders.keys, [greek.id]);
      },
    );

    test('a folder cannot move into itself or its subfolders', () async {
      final (notifier, _, container) = await open();
      final a = notifier.createFolder('A');
      final b = notifier.createFolder('B', parentId: a.id);
      expect(() => notifier.moveFolder(a.id, a.id), throwsArgumentError);
      expect(() => notifier.moveFolder(a.id, b.id), throwsArgumentError);

      notifier.moveFolder(b.id, null);
      expect(container.read(libraryProvider).folders[b.id]!.parentId, isNull);
    });
  });

  group('cards', () {
    test('numbers keep their gaps after a delete', () async {
      final (notifier, _, container) = await open();
      final folder = notifier.createFolder('H1');
      final cards = [
        for (var i = 0; i < 3; i++) notifier.addCard(folder.id, _word),
      ];
      expect(cards.map((c) => c.seq), [1, 2, 3]);

      notifier.deleteCard(folder.id, cards[1].uuid);
      final next = notifier.addCard(folder.id, _word);
      expect(next.seq, 4);
      expect(
        container
            .read(libraryProvider)
            .cardsIn(folder.id)
            .values
            .map((c) => c.seq),
        unorderedEquals([1, 3, 4]),
      );
    });

    test('an update that changes nothing keeps the same state', () async {
      final (notifier, _, container) = await open();
      final folder = notifier.createFolder('H1');
      final card = notifier.addCard(folder.id, _word);
      final before = container.read(libraryProvider);

      notifier.updateCard(folder.id, card.uuid, content: _word, tags: const []);
      expect(identical(container.read(libraryProvider), before), isTrue);

      notifier.updateCard(folder.id, card.uuid, tags: ['toets']);
      expect(
        container.read(libraryProvider).cardsIn(folder.id)[card.uuid]!.tags,
        ['toets'],
      );
    });

    test(
      'a moved card gets the next number and both files are rewritten',
      () async {
        final (notifier, writer, container) = await open();
        final a = notifier.createFolder('A');
        final b = notifier.createFolder('B');
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
      final a = notifier.createFolder('A');
      final b = notifier.createFolder('B');
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
      final folder = notifier.createFolder('A');
      final card = notifier.addCard(folder.id, _word);
      notifier.updateSettings(
        container
            .read(libraryProvider)
            .settings
            .copyWith(lastCardId: card.uuid),
      );

      notifier.deleteCard(folder.id, card.uuid);
      expect(container.read(libraryProvider).settings.lastCardId, isNull);
    });
  });

  test('a library is immutable', () {
    final library = Library(
      folders: const {'a': Folder(id: 'a', name: 'a')},
    );
    expect(() => library.folders.clear(), throwsUnsupportedError);
  });
}
