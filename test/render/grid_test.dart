import 'package:flashcards/render/card_size.dart';
import 'package:flashcards/render/grid.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const grid = SheetGrid();

  test('8 cards of 95×69 mm per sheet', () {
    expect(cardsPerSheet, 8);
    expect(cardWidthMm, 95);
    expect(cardHeightMm, 69);
  });

  test('the grid is centred on A4 with at least 10 mm margins', () {
    expect(grid.left, 10);
    expect(grid.top, 10.5);
    expect(pageWidthMm - grid.right, 10);
    expect(pageHeightMm - grid.bottom, 10.5);
  });

  test('front cells run row by row, left to right', () {
    expect(grid.cell(0, Side.front), const MmRect(10, 10.5, 95, 69));
    expect(grid.cell(1, Side.front), const MmRect(105, 10.5, 95, 69));
    expect(grid.cell(2, Side.front), const MmRect(10, 79.5, 95, 69));
    expect(grid.cell(7, Side.front), const MmRect(105, 217.5, 95, 69));
  });

  test('back cell is the mirrored column of the same row', () {
    expect(grid.cell(0, Side.back), const MmRect(105, 10.5, 95, 69));
    expect(grid.cell(7, Side.back), const MmRect(10, 217.5, 95, 69));
    for (var i = 0; i < cardsPerSheet; i++) {
      final front = grid.cell(i, Side.front);
      final back = grid.cell(i, Side.back);
      expect(back.top, front.top);
      expect(back.centerX, closeTo(mirrorX(front.centerX), 1e-9));
    }
  });

  test('cut lines', () {
    expect(grid.columnEdges, [10, 105, 200]);
    expect(grid.rowEdges, [10.5, 79.5, 148.5, 217.5, 286.5]);
  });
}
