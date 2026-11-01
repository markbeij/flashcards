import 'package:pdf/pdf.dart';

import 'card_size.dart';
import 'grid.dart';

const _mm = PdfPageFormat.mm;

/// Cut ticks in the margins, 1 mm away from the grid and 5 mm long, at every
/// cut line.
void paintCutTicks(PdfGraphics canvas, SheetGrid grid, Side side) {
  final columns = grid.columnEdges(side);
  final rows = grid.rowEdges(side);
  final left = columns.first, right = columns.last;
  final top = rows.first, bottom = rows.last;

  void line(double x1, double y1, double x2, double y2) {
    canvas
      ..moveTo(x1 * _mm, (pageHeightMm - y1) * _mm)
      ..lineTo(x2 * _mm, (pageHeightMm - y2) * _mm)
      ..strokePath();
  }

  canvas
    ..setStrokeColor(PdfColors.black)
    ..setLineWidth(0.25);
  for (final x in columns) {
    line(x, top - 1, x, top - 6);
    line(x, bottom + 1, x, bottom + 6);
  }
  for (final y in rows) {
    line(left - 1, y, left - 6, y);
    line(right + 1, y, right + 6, y);
  }
}
