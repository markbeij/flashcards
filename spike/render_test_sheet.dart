// Renders the calibration test sheet on the desktop for a visual check.
// Run: fvm dart run spike/render_test_sheet.dart → spike/out/test_sheet.pdf
import 'dart:io';
import 'dart:typed_data';

import 'package:flashcards/render/test_sheet.dart';
import 'package:pdf/widgets.dart' as pw;

pw.Font _font(String name) =>
    pw.Font.ttf(ByteData.sublistView(File('assets/fonts/gentium/$name.ttf').readAsBytesSync()));

Future<void> main() async {
  final theme = pw.ThemeData.withFont(
    base: _font('GentiumBookPlus-Regular'),
    bold: _font('GentiumBookPlus-Bold'),
    italic: _font('GentiumBookPlus-Italic'),
    boldItalic: _font('GentiumBookPlus-BoldItalic'),
  );
  final bytes = await buildTestSheet(theme, frontTitle: 'Testvel · voorkant', backTitle: 'Testvel · achterkant');
  final out = File('spike/out/test_sheet.pdf')..createSync(recursive: true);
  out.writeAsBytesSync(bytes);
  stdout.writeln('Wrote ${out.path}');
}
