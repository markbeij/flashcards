import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../domain/flashcard.dart';
import 'card_size.dart';
import 'grid.dart';
import 'templates/card_frame.dart';
import 'templates/templates.dart';

const _mm = PdfPageFormat.mm;
const _a4 = PdfPageFormat(pageWidthMm * _mm, pageHeightMm * _mm);

/// A card to print with the title of its deck, for the footer.
class PrintCard {
  const PrintCard(this.card, this.deckTitle);

  final Flashcard card;
  final String deckTitle;
}

/// Which pages a document holds.
enum SheetPages {
  /// Front, back, front, back…: for a duplex printer.
  duplex,

  /// Only the fronts, for printing without duplex.
  fronts,

  /// Only the backs, printed on the other side of the fronts by hand.
  backs,
}

/// Number of A4 sheets for [cardCount] cards.
int sheetCount(int cardCount) => (cardCount + cardsPerSheet - 1) ~/ cardsPerSheet;

/// Builds the print document. Every page has the same grid; backs sit in
/// the mirrored column (flip on the long edge) and are moved by the
/// calibration offset. Cut ticks sit in the margins; cards have no borders.
/// With [swap], each card's back is printed as its front.
Future<Uint8List> buildSheets(
  List<PrintCard> cards, {
  required pw.ThemeData theme,
  required String title,
  SheetGrid grid = const SheetGrid(),
  bool swap = false,
  SheetPages pages = SheetPages.duplex,
}) {
  final doc = pw.Document(theme: theme, title: title);
  final sides = switch (pages) {
    SheetPages.duplex => Side.values,
    SheetPages.fronts => const [Side.front],
    SheetPages.backs => const [Side.back],
  };
  for (var start = 0; start < cards.length; start += cardsPerSheet) {
    final sheet = cards.sublist(
      start,
      start + cardsPerSheet > cards.length ? cards.length : start + cardsPerSheet,
    );
    for (final side in sides) {
      doc.addPage(_page(sheet, side, grid: grid, swap: swap));
    }
  }
  return doc.save();
}

pw.Page _page(
  List<PrintCard> cards,
  Side side, {
  required SheetGrid grid,
  required bool swap,
}) => pw.Page(
  pageFormat: _a4,
  margin: pw.EdgeInsets.zero,
  build: (context) => pw.Stack(
    children: [
      pw.CustomPaint(
        size: const PdfPoint(pageWidthMm * _mm, pageHeightMm * _mm),
        painter: (canvas, size) => paintCutTicks(canvas, grid, side),
      ),
      for (final (index, print) in cards.indexed)
        _placed(grid.cell(index, side), _side(print, side, swap)),
    ],
  ),
);

pw.Widget _side(PrintCard print, Side side, bool swap) {
  final faces = facesOf(print.card.content).oriented(swap: swap);
  return cardSide(
    side == Side.front ? faces.front : faces.back,
    footer: footerText(print.deckTitle, print.card.seq),
  );
}

pw.Widget _placed(MmRect rect, pw.Widget child) =>
    pw.Positioned(left: rect.left * _mm, top: rect.top * _mm, child: child);

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

/// One card at its printed size: page 1 is the front, page 2 the back. Used
/// for the preview while entering a card.
Future<Uint8List> buildCardPreview(
  PrintCard print, {
  required pw.ThemeData theme,
}) {
  const format = PdfPageFormat(cardWidthMm * _mm, cardHeightMm * _mm);
  final doc = pw.Document(theme: theme);
  final faces = facesOf(print.card.content);
  final footer = footerText(print.deckTitle, print.card.seq);
  for (final face in [faces.front, faces.back]) {
    doc.addPage(
      pw.Page(
        pageFormat: format,
        margin: pw.EdgeInsets.zero,
        build: (context) => cardSide(face, footer: footer),
      ),
    );
  }
  return doc.save();
}
