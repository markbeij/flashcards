import 'presets.dart';

enum Side { front, back }

/// A rectangle in millimetres, origin at the top-left of the page.
class MmRect {
  const MmRect(this.left, this.top, this.width, this.height);

  final double left;
  final double top;
  final double width;
  final double height;

  double get right => left + width;
  double get bottom => top + height;
  double get centerX => left + width / 2;
  double get centerY => top + height / 2;

  @override
  bool operator ==(Object other) =>
      other is MmRect &&
      other.left == left &&
      other.top == top &&
      other.width == width &&
      other.height == height;

  @override
  int get hashCode => Object.hash(left, top, width, height);

  @override
  String toString() => 'MmRect($left, $top, $width × $height)';
}

/// Card positions on a sheet for one preset. The grid is centred on the page.
///
/// The back is printed flipping on the long edge, so a card's back sits in the
/// mirrored column of the same row.
class SheetGrid {
  const SheetGrid(this.preset);

  final CardPreset preset;

  double get left => (pageWidthMm - preset.columns * preset.cardWidth) / 2;
  double get top => (pageHeightMm - preset.rows * preset.cardHeight) / 2;
  double get right => left + preset.columns * preset.cardWidth;
  double get bottom => top + preset.rows * preset.cardHeight;

  /// The rectangle of card [index] (row by row, left to right as seen on the
  /// front) on the given [side].
  MmRect cell(int index, Side side) {
    assert(index >= 0 && index < preset.cardsPerSheet);
    var column = index % preset.columns;
    final row = index ~/ preset.columns;
    if (side == Side.back) column = preset.columns - 1 - column;
    return MmRect(
      left + column * preset.cardWidth,
      top + row * preset.cardHeight,
      preset.cardWidth,
      preset.cardHeight,
    );
  }

  /// X positions of all vertical cut lines (identical on front and back).
  List<double> get columnEdges => [
        for (var c = 0; c <= preset.columns; c++) left + c * preset.cardWidth,
      ];

  /// Y positions of all horizontal cut lines.
  List<double> get rowEdges => [
        for (var r = 0; r <= preset.rows; r++) top + r * preset.cardHeight,
      ];
}

/// Mirrors an x position for the back page (flip on the long edge).
double mirrorX(double x) => pageWidthMm - x;
