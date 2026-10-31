import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

Future<pw.ThemeData>? _cardTheme;

/// The PDF theme with the bundled card font. Loaded once.
Future<pw.ThemeData> loadCardTheme() => _cardTheme ??= _load();

Future<pw.ThemeData> _load() async {
  Future<pw.Font> font(String name) async =>
      pw.Font.ttf(await rootBundle.load('assets/fonts/gentium/$name.ttf'));

  return pw.ThemeData.withFont(
    base: await font('GentiumBookPlus-Regular'),
    italic: await font('GentiumBookPlus-Italic'),
    bold: await font('GentiumBookPlus-Bold'),
    boldItalic: await font('GentiumBookPlus-BoldItalic'),
  );
}
