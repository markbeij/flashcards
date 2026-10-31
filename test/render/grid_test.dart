import 'package:flashcards/render/grid.dart';
import 'package:flashcards/render/presets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('presets fit A4 with at least 10 mm margins', () {
    for (final preset in presets) {
      test(preset.id, () {
        final grid = SheetGrid(preset);
        expect(grid.left, greaterThanOrEqualTo(10));
        expect(grid.top, greaterThanOrEqualTo(10));
        expect(pageWidthMm - grid.right, closeTo(grid.left, 1e-9));
        expect(pageHeightMm - grid.bottom, closeTo(grid.top, 1e-9));
      });
    }
  });

  test('cards per sheet match the brief', () {
    expect([for (final p in presets) p.cardsPerSheet], [16, 12, 8]);
  });

  group('M grid', () {
    const grid = SheetGrid(presetM);

    test('front cells run row by row, left to right', () {
      expect(grid.cell(0, Side.front), const MmRect(10, 10.5, 95, 46));
      expect(grid.cell(1, Side.front), const MmRect(105, 10.5, 95, 46));
      expect(grid.cell(2, Side.front), const MmRect(10, 56.5, 95, 46));
      expect(grid.cell(11, Side.front), const MmRect(105, 240.5, 95, 46));
    });

    test('back cell is the mirrored column of the same row', () {
      for (var i = 0; i < presetM.cardsPerSheet; i++) {
        final front = grid.cell(i, Side.front);
        final back = grid.cell(i, Side.back);
        expect(back.top, front.top);
        expect(back.centerX, closeTo(mirrorX(front.centerX), 1e-9));
      }
    });

    test('cut lines', () {
      expect(grid.columnEdges, [10, 105, 200]);
      expect(grid.rowEdges.first, 10.5);
      expect(grid.rowEdges.last, 286.5);
      expect(grid.rowEdges, hasLength(7));
    });
  });
}
