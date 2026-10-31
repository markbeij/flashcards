// Spike 1: glyph coverage and mark positioning in the pdf package.
// Run: fvm dart run spike/text_spike.dart  → spike/out/text_spike.pdf
import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

pw.Font _font(String name) {
  final bytes = File('assets/fonts/gentium/$name.ttf').readAsBytesSync();
  return pw.Font.ttf(ByteData.sublistView(bytes));
}

const _samples = <String, String>{
  'Latin macrons': 'puella, puellae f. · rēx, rēgis m. · amō, amāre, amāvī, amātum · Ā Ē Ī Ō Ū',
  'French': "l'élève, les élèves · être · garçon · Noël · cœur · déjà · Œuvre",
  'German': 'das Mädchen, die Mädchen · der Fluss, die Flüsse · groß · Straße · Äpfel',
  'Greek precomposed': 'ὁ ἄνθρωπος, τοῦ ἀνθρώπου · ἀνθρώπῳ · ὁ λόγος · ᾅδης · Ἑλλάς · ῥήτωρ · ᾠδή',
  // Same words typed as base letter + combining marks (NFD), as pasting from
  // some PDFs produces.
  'Latin decomposed': 'rēx, rēgis · amō, amāre',
  'Greek decomposed': 'ἄνθρωπος · ᾦ · ὁ λόγος',
};

Future<void> main() async {
  final regular = _font('GentiumBookPlus-Regular');
  final italic = _font('GentiumBookPlus-Italic');
  final bold = _font('GentiumBookPlus-Bold');
  final boldItalic = _font('GentiumBookPlus-BoldItalic');

  final doc = pw.Document(
    theme: pw.ThemeData.withFont(base: regular, italic: italic, bold: bold, boldItalic: boldItalic),
  );

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(15 * PdfPageFormat.mm),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          for (final entry in _samples.entries) ...[
            pw.Text(entry.key, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
            pw.Text(entry.value, style: const pw.TextStyle(fontSize: 20)),
            pw.SizedBox(height: 10),
          ],
          pw.Text('Bold / italic runs', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          pw.RichText(
            text: pw.TextSpan(
              style: const pw.TextStyle(fontSize: 20),
              children: [
                const pw.TextSpan(text: 'De '),
                pw.TextSpan(text: 'ablativus absolutus', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                const pw.TextSpan(text: ' staat in '),
                pw.TextSpan(text: 'Caesare duce', style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
                const pw.TextSpan(text: ' · '),
                pw.TextSpan(
                  text: 'ἀνθρώπῳ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontStyle: pw.FontStyle.italic),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Small print size (8 pt, footer size)', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          pw.Text('Latijn · VWO 4 · H3 · §2 · #17 — rēx, rēgis · ἀνθρώπῳ', style: const pw.TextStyle(fontSize: 8)),
        ],
      ),
    ),
  );

  final out = File('spike/out/text_spike.pdf')..createSync(recursive: true);
  out.writeAsBytesSync(await doc.save());
  stdout.writeln('Wrote ${out.path}');
}
