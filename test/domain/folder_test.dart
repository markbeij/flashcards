import 'package:flashcards/domain/card_content.dart';
import 'package:flashcards/domain/flashcard.dart';
import 'package:flashcards/domain/folder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('natural sort', () {
    List<String> sorted(List<String> names) => [...names]..sort(compareNatural);

    test('numbers sort by value', () {
      expect(sorted(['H10', 'H2', 'H1']), ['H1', 'H2', 'H10']);
      expect(sorted(['§2', '§10', '§1']), ['§1', '§2', '§10']);
      expect(sorted(['VWO 5', 'VWO 4', 'VWO 6']), ['VWO 4', 'VWO 5', 'VWO 6']);
    });

    test('case is ignored unless it is the only difference', () {
      expect(sorted(['frans', 'Duits', 'latijn']), [
        'Duits',
        'frans',
        'latijn',
      ]);
      expect(compareNatural('a', 'A'), isNot(0));
    });

    test('leading zeros and long numbers', () {
      expect(sorted(['H010', 'H9', 'H09']), ['H9', 'H09', 'H010']);
      expect(
        compareNatural('x99999999999999999999', 'x100000000000000000000'),
        lessThan(0),
      );
    });

    test('a prefix sorts first', () {
      expect(sorted(['H1a', 'H1']), ['H1', 'H1a']);
    });

    test('childrenOf sorts naturally', () {
      final folders = {
        for (final f in [
          const Folder(id: 'a', name: 'H10'),
          const Folder(id: 'b', name: 'H2'),
          const Folder(id: 'c', parentId: 'a', name: '§1'),
        ])
          f.id: f,
      };
      expect(childrenOf(null, folders).map((f) => f.name), ['H2', 'H10']);
      expect(childrenOf('a', folders).map((f) => f.name), ['§1']);
    });
  });

  group('colour inheritance', () {
    final folders = {
      for (final f in [
        const Folder(id: 'latin', name: 'Latijn', color: FolderColor.red),
        const Folder(id: 'vwo4', parentId: 'latin', name: 'VWO 4'),
        const Folder(
          id: 'h3',
          parentId: 'vwo4',
          name: 'H3',
          color: FolderColor.blue,
        ),
        const Folder(id: 'p2', parentId: 'h3', name: '§2'),
        const Folder(id: 'plain', name: 'Geschiedenis'),
      ])
        f.id: f,
    };

    test('own colour wins', () {
      expect(colorSource('h3', folders)?.id, 'h3');
    });

    test('nearest ancestor with a colour', () {
      expect(colorSource('vwo4', folders)?.id, 'latin');
      expect(colorSource('p2', folders)?.color, FolderColor.blue);
    });

    test('no colour anywhere', () {
      expect(colorSource('plain', folders), isNull);
    });

    test('a cycle does not loop forever', () {
      final cyclic = {
        'a': const Folder(id: 'a', parentId: 'b', name: 'a'),
        'b': const Folder(id: 'b', parentId: 'a', name: 'b'),
      };
      expect(colorSource('a', cyclic), isNull);
    });
  });

  test('folder JSON round-trip', () {
    const folder = Folder(
      id: 'f1',
      parentId: 'root',
      name: 'Hoofdstuk 3',
      color: FolderColor.teal,
      shortLabel: 'H3',
      lastCardType: CardType.vocabulary,
      lastLanguage: VocabLanguage.latin,
    );
    expect(Folder.fromJson(folder.toJson()), folder);
    expect(
      Folder.fromJson(const Folder(id: 'x', name: 'x').toJson()),
      const Folder(id: 'x', name: 'x'),
    );
  });

  test('copyWith can clear optional fields', () {
    const folder = Folder(
      id: 'f',
      name: 'n',
      color: FolderColor.red,
      shortLabel: 'H1',
    );
    final cleared = folder.copyWith(color: null);
    expect(cleared.color, isNull);
    expect(cleared.shortLabel, 'H1');
  });

  group('card numbering', () {
    Flashcard card(int seq) => Flashcard(
      uuid: 'c$seq',
      seq: seq,
      content: const HistoryContent(date: 'd', event: 'e'),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

    test('first card is #1', () => expect(nextSeq(const []), 1));

    test('highest + 1, gaps stay', () {
      expect(nextSeq([card(1), card(2), card(3)]), 4);
      expect(nextSeq([card(1), card(3)]), 4);
      expect(nextSeq([card(5), card(2)]), 6);
    });
  });
}
