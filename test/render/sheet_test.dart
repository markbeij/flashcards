import 'dart:io';

import 'package:flashcards/render/fonts.dart';
import 'package:flashcards/render/grid.dart';
import 'package:flashcards/render/sheet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;

import 'samples.dart';

/// Counts the pages of a PDF without a parser: one `/Type /Page` object per
/// page.
int pageCount(List<int> bytes) =>
    RegExp(r'/Type\s*/Page\b').allMatches(String.fromCharCodes(bytes)).length;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late pw.ThemeData theme;

  setUpAll(() async {
    theme = await loadCardTheme();
  });

  test('sheet count', () {
    expect(sheetCount(0), 0);
    expect(sheetCount(1), 1);
    expect(sheetCount(8), 1);
    expect(sheetCount(9), 2);
    expect(sheetCount(48), 6);
  });

  test('duplex has a front and a back page per sheet', () async {
    final cards = [...samplePrintCards(), ...samplePrintCards()].take(9).toList();
    final duplex = await buildSheets(cards, theme: theme, title: 't');
    expect(pageCount(duplex), 4);

    final fronts = await buildSheets(
      cards,
      theme: theme,
      title: 't',
      pages: SheetPages.fronts,
    );
    expect(pageCount(fronts), 2);

    final backs = await buildSheets(
      cards,
      theme: theme,
      title: 't',
      pages: SheetPages.backs,
      grid: const SheetGrid(backDyMm: 1),
      swap: true,
    );
    expect(pageCount(backs), 2);

    // For a visual check: FLASHCARDS_SHEET_OUT=/path/sheet.pdf flutter test
    final out = Platform.environment['FLASHCARDS_SHEET_OUT'];
    if (out != null) {
      File(out).writeAsBytesSync(
        await buildSheets(samplePrintCards(), theme: theme, title: 't'),
      );
    }
  });

  test('card preview has the front and the back', () async {
    final bytes = await buildCardPreview(samplePrintCards().first, theme: theme);
    expect(pageCount(bytes), 2);
  });
}
