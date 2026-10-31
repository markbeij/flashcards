import 'package:flashcards/domain/markup.dart';
import 'package:flutter_test/flutter_test.dart';

const _bold = MarkupRun('**', bold: true, marker: true);

void main() {
  test('plain text is one run', () {
    expect(parseMarkup('ὁ λόγος'), [const MarkupRun('ὁ λόγος')]);
  });

  test('empty text has no runs', () {
    expect(parseMarkup(''), isEmpty);
  });

  test('bold and italic', () {
    expect(parseMarkup('a **b** *c*'), [
      const MarkupRun('a '),
      _bold,
      const MarkupRun('b', bold: true),
      _bold,
      const MarkupRun(' '),
      const MarkupRun('*', italic: true, marker: true),
      const MarkupRun('c', italic: true),
      const MarkupRun('*', italic: true, marker: true),
    ]);
  });

  test('nested and combined styles', () {
    expect(plainRuns('**bold *both***'), [
      const MarkupRun('bold ', bold: true),
      const MarkupRun('both', bold: true, italic: true),
    ]);
    expect(plainRuns('***ā ē***'), [
      const MarkupRun('ā ē', bold: true, italic: true),
    ]);
  });

  test('joining all runs gives the source back', () {
    for (final source in [
      'a **b** *c*',
      '***x***',
      '**open',
      '5 * 3 * 2',
      '*a **b* c**',
    ]) {
      expect(parseMarkup(source).map((r) => r.text).join(), source);
    }
  });

  group('unbalanced markers are plain text', () {
    test('unclosed bold', () {
      expect(parseMarkup('**open'), [const MarkupRun('**open')]);
    });

    test('unclosed italic after a closed bold', () {
      expect(plainRuns('**b** *i'), [
        const MarkupRun('b', bold: true),
        const MarkupRun(' *i'),
      ]);
    });

    test('mismatched kinds', () {
      expect(parseMarkup('**a*'), [const MarkupRun('**a*')]);
    });

    test('stars between spaces', () {
      expect(parseMarkup('5 * 3 * 2'), [const MarkupRun('5 * 3 * 2')]);
    });
  });

  test('plainText removes markers', () {
    expect(plainText('**puella**, *-ae* f'), 'puella, -ae f');
    expect(plainText('5 * 3'), '5 * 3');
  });
}

List<MarkupRun> plainRuns(String source) => [
  for (final run in parseMarkup(source))
    if (!run.marker) run,
];
