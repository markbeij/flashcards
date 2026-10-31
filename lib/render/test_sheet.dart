import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'grid.dart';
import 'presets.dart';

const _mm = PdfPageFormat.mm;
const _hairline = 0.25;

/// Builds the two-page duplex test sheet used to measure print fidelity and
/// to calibrate the back side.
///
/// Front: crosshairs A–D, a 190 mm horizontal and a 270 mm vertical ruler,
/// cut ticks for the M grid and six sample cards.
/// Back: at the mirrored position of each crosshair, an offset scale from
/// −5 to +5 mm in 0.5 mm steps. Hold the sheet against the light with the back
/// facing you and read where the front cross lands. Readings are in back-page
/// coordinates: x positive to the right, y positive downwards. The same
/// rulers and sample card backs are printed on the back.
Future<Uint8List> buildTestSheet(
  pw.ThemeData theme, {
  required String frontTitle,
  required String backTitle,
}) {
  const grid = SheetGrid(presetM);
  final doc = pw.Document(theme: theme, title: frontTitle);
  for (final side in Side.values) {
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) => pw.Stack(
          children: [
            pw.CustomPaint(
              size: const PdfPoint(pageWidthMm * _mm, pageHeightMm * _mm),
              painter: (canvas, size) => _paint(canvas, grid, side),
            ),
            _text(
              side == Side.front ? frontTitle : backTitle,
              left: grid.left,
              top: 3.5,
              fontSize: 7,
            ),
            for (final (index, label) in _targets.indexed)
              _text(
                label,
                left: _targetPoint(grid, index, side).$1 + 2.5,
                top: _targetPoint(grid, index, side).$2 - 9,
                fontSize: 9,
                bold: true,
              ),
            for (var mm = 0; mm <= 190; mm += 10)
              _text('$mm', left: grid.left + mm, top: _rulerY(grid) + 4.5, fontSize: 5, centered: true),
            for (var mm = 10; mm <= 270; mm += 10)
              _text('$mm', left: pageWidthMm / 2 - 9, top: _vRulerTop(grid) + mm - 1.2, fontSize: 5),
            if (side == Side.back)
              for (var target = 0; target < _targets.length; target++)
                // Labels sit in separate quadrants so they never overlap
                // (see _offsetScale).
                for (final d in const [-4, -2, 2, 4]) ...[
                  _text(_signed(d),
                      left: _targetPoint(grid, target, side).$1 + d,
                      top: _targetPoint(grid, target, side).$2 + (d < 0 ? 2.4 : -4.0),
                      fontSize: 4.5,
                      centered: true),
                  _text(_signed(d),
                      left: _targetPoint(grid, target, side).$1 + (d < 0 ? -5.0 : 2.6),
                      top: _targetPoint(grid, target, side).$2 + d - 0.9,
                      fontSize: 4.5),
                ],
            for (final (offset, (front, back)) in _sampleCards.indexed)
              _sampleCard(grid, _firstSampleIndex + offset, side, side == Side.front ? front : back),
          ],
        ),
      ),
    );
  }
  return doc.save();
}

const _targets = ['A', 'B', 'C', 'D'];

String _signed(int value) => value > 0 ? '+$value' : '−${-value}';

/// Crosshair centres: the cells of the first and last row.
(double, double) _targetPoint(SheetGrid grid, int target, Side side) {
  final last = grid.preset.cardsPerSheet - 2;
  final index = [0, 1, last, last + 1][target];
  final cell = grid.cell(index, side);
  return (cell.centerX, cell.centerY);
}

double _rulerY(SheetGrid grid) => grid.cell(2, Side.front).centerY;
double _vRulerTop(SheetGrid grid) => grid.top + (grid.bottom - grid.top - 270) / 2;

const _firstSampleIndex = 4;
const _sampleCards = [
  (('meisje', 'het meisje, de meisjes'), ('puella', 'puellae f.')),
  (('koning', 'de koning'), ('rēx', 'rēgis m.')),
  (('mens', 'de mens'), ('ὁ ἄνθρωπος', 'τοῦ ἀνθρώπου')),
  (('meisje', 'het meisje (Duits)'), ('das Mädchen', 'die Mädchen')),
  (('leerling', 'de leerling (Frans)'), ("l'élève", 'm./f.')),
  (('liefhebben', 'werkwoord'), ('amō', 'amāre, amāvī, amātum')),
];

pw.Widget _sampleCard(SheetGrid grid, int index, Side side, (String, String) text) {
  final cell = grid.cell(index, side);
  return pw.Positioned(
    left: cell.left * _mm,
    top: cell.top * _mm,
    child: pw.Container(
      width: cell.width * _mm,
      height: cell.height * _mm,
      padding: const pw.EdgeInsets.fromLTRB(4 * _mm, 4 * _mm, 7 * _mm, 2.5 * _mm),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(text.$1, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 1 * _mm),
          pw.Text(text.$2, style: const pw.TextStyle(fontSize: 10)),
          pw.Spacer(),
          pw.Text(
            'Test · M · #${index + 1}',
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
          ),
        ],
      ),
    ),
  );
}

/// Text at a page position in mm. With [centered], [left] is the horizontal
/// centre of the text.
pw.Widget _text(
  String text, {
  required double left,
  required double top,
  required double fontSize,
  bool bold = false,
  bool centered = false,
}) {
  const centerBox = 12.0;
  final label = pw.Text(
    text,
    textAlign: centered ? pw.TextAlign.center : null,
    style: pw.TextStyle(fontSize: fontSize, fontWeight: bold ? pw.FontWeight.bold : null),
  );
  return pw.Positioned(
    left: (centered ? left - centerBox / 2 : left) * _mm,
    top: top * _mm,
    child: centered ? pw.SizedBox(width: centerBox * _mm, child: label) : label,
  );
}

/// Draws all lines. Coordinates are page millimetres from the top-left.
void _paint(PdfGraphics canvas, SheetGrid grid, Side side) {
  void line(double x1, double y1, double x2, double y2, [double width = _hairline]) {
    canvas
      ..setLineWidth(width)
      ..moveTo(x1 * _mm, (pageHeightMm - y1) * _mm)
      ..lineTo(x2 * _mm, (pageHeightMm - y2) * _mm)
      ..strokePath();
  }

  canvas.setStrokeColor(PdfColors.black);

  // Cut ticks in the margins, 1 mm away from the grid, 5 mm long.
  for (final x in grid.columnEdges) {
    line(x, grid.top - 1, x, grid.top - 6);
    line(x, grid.bottom + 1, x, grid.bottom + 6);
  }
  for (final y in grid.rowEdges) {
    line(grid.left - 1, y, grid.left - 6, y);
    line(grid.right + 1, y, grid.right + 6, y);
  }

  // Horizontal ruler, 190 mm, ticks downwards.
  final ry = _rulerY(grid);
  line(grid.left, ry, grid.left + 190, ry);
  for (var mm = 0; mm <= 190; mm++) {
    line(grid.left + mm, ry, grid.left + mm, ry + _tickLength(mm));
  }

  // Vertical ruler, 270 mm, on the page centre line, ticks to the left.
  const cx = pageWidthMm / 2;
  final vy = _vRulerTop(grid);
  line(cx, vy, cx, vy + 270);
  for (var mm = 0; mm <= 270; mm++) {
    line(cx, vy + mm, cx - _tickLength(mm), vy + mm);
  }

  for (var target = 0; target < _targets.length; target++) {
    final (x, y) = _targetPoint(grid, target, side);
    if (side == Side.front) {
      _crosshair(line, canvas, x, y);
    } else {
      _offsetScale(line, x, y);
    }
  }
}

double _tickLength(int mm) => mm % 10 == 0 ? 4 : (mm % 5 == 0 ? 2.5 : 1.5);

typedef _Line = void Function(double x1, double y1, double x2, double y2, [double width]);

void _crosshair(_Line line, PdfGraphics canvas, double x, double y) {
  line(x - 7, y, x + 7, y, 0.35);
  line(x, y - 7, x, y + 7, 0.35);
  canvas
    ..setLineWidth(0.35)
    ..drawEllipse(x * _mm, (pageHeightMm - y) * _mm, 2 * _mm, 2 * _mm)
    ..strokePath();
}

/// Scale from −5 to +5 mm in both directions, 0.5 mm per tick.
void _offsetScale(_Line line, double x, double y) {
  line(x - 5, y, x + 5, y);
  line(x, y - 5, x, y + 5);
  // Each quadrant holds one set of ticks, so its labels fit past the tips:
  // x ticks point down for negatives and up for positives, y ticks point left
  // for negatives (up) and right for positives (down).
  for (var half = -10; half <= 10; half++) {
    if (half == 0) continue;
    final d = half / 2;
    final length = half % 2 != 0 ? 0.8 : (half % 4 == 0 ? 2.0 : 1.4);
    final sign = half < 0 ? 1.0 : -1.0;
    line(x + d, y, x + d, y + sign * length);
    line(x, y + d, x - sign * length, y + d);
  }
}
