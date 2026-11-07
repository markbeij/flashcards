import 'package:flashcards/domain/card_content.dart';
import 'package:flashcards/render/fonts.dart';
import 'package:flashcards/render/overflow.dart';
import 'package:flutter_test/flutter_test.dart';

import 'samples.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late OverflowChecker checker;

  setUpAll(() async {
    checker = OverflowChecker(await loadCardTheme());
  });

  test('typical cards fit', () {
    for (final content in sampleContents) {
      expect(checker.overflows(content), isFalse, reason: '$content');
    }
  });

  test('a side fills as text is added, and is full when it is too tall', () {
    CardFill fill(String explanation) =>
        checker.measure(BegripContent(term: 'Term', explanation: explanation));
    final short = fill('Kort.');
    final medium = fill(List.filled(12, 'een lange uitleg').join(' '));
    final long = fill(List.filled(60, 'een lange uitleg').join(' '));

    // The front holds only the term, so it stays the same.
    expect(medium.front.fill, short.front.fill);
    expect(short.back.fill, inExclusiveRange(0, medium.back.fill));
    expect(medium.back.fill, lessThan(1));
    expect(medium.full, isFalse);
    expect(long.back.fill, greaterThan(1));
    expect(long.back.full, isTrue);
    expect(long.front.full, isFalse);
  });

  test('a word that is too wide fills the side even when it is short', () {
    final fill = checker.measure(
      const BegripContent(
        term: 'Donaudampfschifffahrtsgesellschaftskapitänsmützenabzeichen',
        explanation: 'Kort.',
      ),
    );
    expect(fill.front.wordTooWide, isTrue);
    expect(fill.front.fill, lessThan(1));
    expect(fill.front.full, isTrue);
    expect(fill.back.full, isFalse);
  });

  test('a long explanation overflows', () {
    final long = List.filled(
      40,
      'Achttiende-eeuwse stroming die de rede '
      'boven traditie en geloof stelde.',
    ).join(' ');
    expect(
      checker.overflows(BegripContent(term: 'Verlichting', explanation: long)),
      isTrue,
    );
  });

  test('a single word wider than the card overflows', () {
    const content = BegripContent(
      term: 'Donaudampfschifffahrtsgesellschaftskapitänsmützenabzeichen',
      explanation: 'One word wider than the card.',
    );
    expect(checker.overflows(content), isTrue);
  });

  test('a word too wide for the paradigm value column overflows', () {
    final narrow = ParadigmContent(
      heading: 'x',
      rows: const [
        ParadigmRow(label: 'a', value: 'Rindfleischetikettierungsüberwachung'),
      ],
    );
    expect(checker.overflows(narrow), isTrue);
  });

  test('too many paradigm rows overflow', () {
    final rows = [
      for (var i = 0; i < 20; i++) ParadigmRow(label: '$i', value: 'amabam'),
    ];
    expect(
      checker.overflows(ParadigmContent(heading: 'amare', rows: rows)),
      isTrue,
    );
  });

  test('bold makes a borderline word wider', () {
    // Find a word length that fits in regular but not in bold.
    for (var n = 10; n < 60; n++) {
      final word = 'm' * n;
      final plain = checker.overflows(
        BegripContent(term: 't', explanation: word),
      );
      final bold = checker.overflows(
        BegripContent(term: 't', explanation: '**$word**'),
      );
      if (plain != bold) {
        expect(plain, isFalse);
        expect(bold, isTrue);
        return;
      }
    }
    fail('No borderline word found');
  });
}
