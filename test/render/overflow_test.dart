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
