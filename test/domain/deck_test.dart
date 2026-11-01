import 'package:flashcards/domain/card_content.dart';
import 'package:flashcards/domain/deck.dart';
import 'package:flashcards/domain/flashcard.dart';
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
  });

  group('maps, submaps and decks', () {
    const decks = [
      Deck(id: 'a', map: 'VWO 4', submap: 'Latijn', title: 'Woordjes H10'),
      Deck(id: 'b', map: 'VWO 4', submap: 'Latijn', title: 'Woordjes H2'),
      Deck(id: 'c', map: 'VWO 4', submap: 'Frans', title: 'H1'),
      Deck(id: 'd', map: 'VWO 10', submap: 'Latijn', title: 'H1'),
      Deck(id: 'e', map: 'VWO 5', submap: 'Grieks', title: 'H1'),
    ];

    test('maps are distinct and sort naturally', () {
      expect(mapsOf(decks), ['VWO 4', 'VWO 5', 'VWO 10']);
      expect(mapsOf(const []), isEmpty);
    });

    test('submaps of one map are distinct and sort naturally', () {
      expect(submapsOf('VWO 4', decks), ['Frans', 'Latijn']);
      expect(submapsOf('VWO 10', decks), ['Latijn']);
      expect(submapsOf('VWO 6', decks), isEmpty);
    });

    test('decks of one submap sort naturally by title', () {
      expect(decksIn('VWO 4', 'Latijn', decks).map((d) => d.id), ['b', 'a']);
      expect(decksIn('VWO 10', 'Latijn', decks).map((d) => d.id), ['d']);
    });
  });

  test('deck JSON round-trip', () {
    const deck = Deck(
      id: 'd1',
      map: 'VWO 4',
      submap: 'Latijn',
      title: 'Woordjes H3',
      lastCardType: CardType.vocabulary,
      lastLanguage: VocabLanguage.latin,
    );
    expect(Deck.fromJson(deck.toJson()), deck);
    const plain = Deck(id: 'x', map: 'm', submap: 's', title: 't');
    expect(plain.toJson().keys, ['id', 'map', 'submap', 'title']);
    expect(Deck.fromJson(plain.toJson()), plain);
  });

  test('copyWith can clear the last entry choices', () {
    const deck = Deck(
      id: 'd',
      map: 'm',
      submap: 's',
      title: 't',
      lastCardType: CardType.begrip,
      lastLanguage: VocabLanguage.french,
    );
    final changed = deck.copyWith(submap: 'Frans', lastLanguage: null);
    expect(changed.submap, 'Frans');
    expect(changed.lastLanguage, isNull);
    expect(changed.lastCardType, CardType.begrip);
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
