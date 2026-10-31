// Spike 2: can we measure whether card content fits before rendering?
// Approach: lay out the content with the card's inner width and UNBOUNDED
// height, read box.height, compare with the available height. (With a bounded
// height RichText silently stops adding lines, so the box can't reveal overflow.)
// Run: fvm dart run spike/overflow_spike.dart → spike/out/overflow_spike.pdf
// Each card is drawn at M size (95×46 mm). Blue frame = content area, red line =
// measured content height. The red line must sit exactly under the last line.
import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const mm = PdfPageFormat.mm;
const cardW = 95 * mm, cardH = 46 * mm, pad = 3 * mm, footerH = 4 * mm;
const contentW = cardW - 2 * pad, contentH = cardH - 2 * pad - footerH;

pw.Font _font(String name) =>
    pw.Font.ttf(ByteData.sublistView(File('assets/fonts/gentium/$name.ttf').readAsBytesSync()));

pw.Widget content(String term, String explanation) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(term, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 1.5 * mm),
        pw.Text(explanation, style: const pw.TextStyle(fontSize: 10)),
      ],
    );

/// Returns the content's natural size at [width] with unbounded height.
PdfPoint measure(pw.ThemeData theme, PdfDocument doc, pw.Widget child, double width) {
  final widget = pw.Theme(data: theme, child: child);
  final context = pw.Context(document: doc);
  widget.layout(context, pw.BoxConstraints(maxWidth: width));
  return PdfPoint(widget.box!.width, widget.box!.height);
}

const samples = [
  ('Fotosynthese', 'Omzetting van licht, water en CO₂ in glucose en zuurstof.'),
  ('Ablativus absolutus',
      'Een bijzin-achtige constructie met een naamwoord en een deelwoord in de ablativus, los van de rest van de zin. Vertaal met een bijzin: toen, nadat, omdat, hoewel.'),
  ('Verlichting',
      'Achttiende-eeuwse stroming die de rede boven traditie en geloof stelde. Denkers als Voltaire, Rousseau en Montesquieu bepleitten scheiding der machten, verdraagzaamheid en vrijheid van meningsuiting; de ideeën beïnvloedden de Amerikaanse en Franse revoluties en de Nederlandse Bataafse Republiek.'),
  ('Donaudampfschifffahrtsgesellschaftskapitänsmützenabzeichen', 'One word wider than the card.'),
];

Future<void> main() async {
  final theme = pw.ThemeData.withFont(
    base: _font('GentiumBookPlus-Regular'),
    bold: _font('GentiumBookPlus-Bold'),
    italic: _font('GentiumBookPlus-Italic'),
    boldItalic: _font('GentiumBookPlus-BoldItalic'),
  );
  final doc = pw.Document(theme: theme);

  final results = [
    for (final (term, text) in samples)
      (term, text, measure(theme, doc.document, content(term, text), contentW)),
  ];

  doc.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(10 * mm),
    build: (context) => pw.Wrap(
      spacing: 5 * mm,
      runSpacing: 5 * mm,
      children: [
        for (final (term, text, size) in results)
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Container(
              width: cardW,
              height: cardH,
              padding: const pw.EdgeInsets.all(pad),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: 0.3)),
              child: pw.Stack(overflow: pw.Overflow.visible, children: [
                pw.Container(width: contentW, height: contentH,
                    decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blue, width: 0.3))),
                pw.Positioned(left: 0, top: 0, child: pw.SizedBox(width: contentW, child: content(term, text))),
                pw.Positioned(left: 0, top: size.y,
                    child: pw.Container(width: contentW, height: 0.4, color: PdfColors.red)),
              ]),
            ),
            pw.Text(
              'measured ${(size.x / mm).toStringAsFixed(1)} × ${(size.y / mm).toStringAsFixed(1)} mm, '
              'available ${(contentW / mm).toStringAsFixed(0)} × ${(contentH / mm).toStringAsFixed(0)} mm → '
              '${size.y <= contentH && size.x <= contentW + 0.01 ? 'FITS' : 'OVERFLOW'}',
              style: const pw.TextStyle(fontSize: 7),
            ),
          ]),
      ],
    ),
  ));

  for (final (term, _, size) in results) {
    stdout.writeln('$term: ${(size.x / mm).toStringAsFixed(2)} × ${(size.y / mm).toStringAsFixed(2)} mm '
        '(fits: ${size.y <= contentH && size.x <= contentW + 0.01})');
  }
  final out = File('spike/out/overflow_spike.pdf')..createSync(recursive: true);
  out.writeAsBytesSync(await doc.save());
  stdout.writeln('Wrote ${out.path}');
}
