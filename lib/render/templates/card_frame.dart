import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/card_content.dart';
import '../../domain/markup.dart';
import '../card_size.dart';
import 'face.dart';

const _mm = PdfPageFormat.mm;

/// Width of the label column of a paradigm's forms table.
const formsLabelWidthMm = 24.0;
const formsColumnGapMm = 2.0;
const formsValueWidthMm = contentWidthMm - formsLabelWidthMm - formsColumnGapMm;

const _ink = PdfColors.black;
const _muted = PdfColor.fromInt(0xff555555);

pw.TextStyle styleFor(TextRole role) => switch (role) {
  TextRole.headline => pw.TextStyle(
    fontSize: 17,
    fontWeight: pw.FontWeight.bold,
    color: _ink,
  ),
  TextRole.sentence => const pw.TextStyle(fontSize: 13, color: _ink),
  TextRole.subhead => const pw.TextStyle(fontSize: 12, color: _muted),
  TextRole.body => const pw.TextStyle(fontSize: 11, color: _ink),
  TextRole.note => pw.TextStyle(
    fontSize: 10,
    fontStyle: pw.FontStyle.italic,
    color: _muted,
  ),
};

final formsLabelStyle = pw.TextStyle(
  fontSize: 10,
  fontStyle: pw.FontStyle.italic,
  color: _muted,
);
const formsValueStyle = pw.TextStyle(fontSize: 12, color: _ink);
const footerStyle = pw.TextStyle(fontSize: 7, color: _muted);

/// Space above a block, after the first one.
double _gapBefore(Block block) => switch (block) {
  TextBlock(role: TextRole.subhead) => 1.2 * _mm,
  TextBlock(role: TextRole.note) => 2.5 * _mm,
  _ => 2 * _mm,
};

/// The markup as styled runs; the markers themselves are dropped.
pw.TextSpan markupSpan(String markup, pw.TextStyle base) => pw.TextSpan(
  style: base,
  children: [
    for (final run in parseMarkup(markup))
      if (!run.marker)
        pw.TextSpan(
          text: run.text,
          style: pw.TextStyle(
            fontWeight: run.bold ? pw.FontWeight.bold : null,
            fontStyle: run.italic ? pw.FontStyle.italic : null,
          ),
        ),
  ],
);

pw.Widget markupText(String markup, pw.TextStyle style) =>
    pw.RichText(text: markupSpan(markup, style));

/// A face's content at its natural height. The same widget is measured for
/// overflow and drawn on the card.
pw.Widget faceContent(CardFace face) => pw.Column(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  mainAxisSize: pw.MainAxisSize.min,
  children: [
    for (final (i, block) in face.blocks.indexed) ...[
      if (i > 0) pw.SizedBox(height: _gapBefore(block)),
      switch (block) {
        TextBlock(:final markup, :final role) => markupText(
          markup,
          styleFor(role),
        ),
        FormsBlock(:final rows) => _forms(rows),
      },
    ],
  ],
);

pw.Widget _forms(List<ParadigmRow> rows) => pw.Column(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  mainAxisSize: pw.MainAxisSize.min,
  children: [
    for (final (i, row) in rows.indexed) ...[
      if (i > 0) pw.SizedBox(height: 0.8 * _mm),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: formsLabelWidthMm * _mm,
            child: pw.Padding(
              // Line the smaller label up with the value's baseline.
              padding: const pw.EdgeInsets.only(top: 1.5),
              child: markupText(row.label, formsLabelStyle),
            ),
          ),
          pw.SizedBox(width: formsColumnGapMm * _mm),
          pw.SizedBox(
            width: formsValueWidthMm * _mm,
            child: markupText(row.value, formsValueStyle),
          ),
        ],
      ),
    ],
  ],
);

/// One side of a card at its printed size: the content, clipped to its area
/// if it doesn't fit, and the footer, e.g. "Woordjes H3 · #17".
pw.Widget cardSide(CardFace face, {required String footer}) => pw.Container(
  width: cardWidthMm * _mm,
  height: cardHeightMm * _mm,
  padding: const pw.EdgeInsets.fromLTRB(
    cardPaddingHorizontalMm * _mm,
    cardPaddingTopMm * _mm,
    cardPaddingHorizontalMm * _mm,
    cardPaddingBottomMm * _mm,
  ),
  child: pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(
        width: contentWidthMm * _mm,
        height: contentHeightMm * _mm,
        child: pw.ClipRect(
          child: pw.OverflowBox(
            alignment: pw.Alignment.topLeft,
            minWidth: contentWidthMm * _mm,
            maxWidth: contentWidthMm * _mm,
            maxHeight: double.infinity,
            child: faceContent(face),
          ),
        ),
      ),
      pw.SizedBox(height: footerGapMm * _mm),
      pw.SizedBox(
        width: contentWidthMm * _mm,
        height: footerHeightMm * _mm,
        child: pw.ClipRect(
          child: pw.Text(footer, style: footerStyle, maxLines: 1),
        ),
      ),
    ],
  ),
);

/// The footer text, e.g. "Woordjes H3 · #17".
String footerText(String deckTitle, int seq) => '$deckTitle · #$seq';
