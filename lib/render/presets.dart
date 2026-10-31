/// Page and card geometry. All values are millimetres.
const pageWidthMm = 210.0;
const pageHeightMm = 297.0;

/// A fixed card size: a uniform grid of cards on an A4 portrait sheet.
class CardPreset {
  const CardPreset(
    this.id, {
    required this.columns,
    required this.rows,
    required this.cardWidth,
    required this.cardHeight,
  });

  final String id;
  final int columns;
  final int rows;
  final double cardWidth;
  final double cardHeight;

  int get cardsPerSheet => columns * rows;
}

const presetS = CardPreset('S', columns: 2, rows: 8, cardWidth: 95, cardHeight: 34);
const presetM = CardPreset('M', columns: 2, rows: 6, cardWidth: 95, cardHeight: 46);
const presetL = CardPreset('L', columns: 2, rows: 4, cardWidth: 95, cardHeight: 69);

const presets = [presetS, presetM, presetL];
