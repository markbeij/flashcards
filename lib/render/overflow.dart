import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../domain/card_content.dart';
import '../domain/markup.dart';
import 'card_size.dart';
import 'templates/card_frame.dart';
import 'templates/templates.dart';

const _mm = PdfPageFormat.mm;

/// Finds cards whose content doesn't fit (Spike 2). A card overflows when a
/// side's content is taller than the content area, or when a single word is
/// wider than the space it is set in. Overflowing cards are flagged, never
/// shrunk.
///
/// Results are cached by content, so a card is measured again only after it
/// changes.
class OverflowChecker {
  OverflowChecker(this.theme);

  final pw.ThemeData theme;
  final _document = PdfDocument();
  final _cache = <CardContent, bool>{};

  bool overflows(CardContent content) =>
      _cache[content] ??= _measure(content);

  bool _measure(CardContent content) {
    final faces = facesOf(content);
    return _faceOverflows(faces.front) || _faceOverflows(faces.back);
  }

  bool _faceOverflows(CardFace face) {
    final height = _size(
      faceContent(face),
      pw.BoxConstraints(maxWidth: contentWidthMm * _mm),
    ).y;
    // A hair of tolerance for rounding in the layout.
    if (height > contentHeightMm * _mm + 0.01) return true;
    for (final block in face.blocks) {
      final tooWide = switch (block) {
        TextBlock(:final markup, :final role) => _hasWideWord(
          markup,
          styleFor(role),
          contentWidthMm,
        ),
        FormsBlock(:final rows) => rows.any(
          (row) =>
              _hasWideWord(row.label, formsLabelStyle, formsLabelWidthMm) ||
              _hasWideWord(row.value, formsValueStyle, formsValueWidthMm),
        ),
      };
      if (tooWide) return true;
    }
    return false;
  }

  /// Whether a word of [markup], set alone, is wider than [widthMm]. Words
  /// keep their bold/italic style.
  bool _hasWideWord(String markup, pw.TextStyle style, double widthMm) {
    final words = <pw.TextSpan>[];
    for (final run in parseMarkup(markup)) {
      if (run.marker) continue;
      for (final word in run.text.split(RegExp(r'\s+'))) {
        if (word.isEmpty) continue;
        words.add(
          pw.TextSpan(
            text: word,
            style: style.copyWith(
              fontWeight: run.bold ? pw.FontWeight.bold : null,
              fontStyle: run.italic ? pw.FontStyle.italic : null,
            ),
          ),
        );
      }
    }
    return words.any(
      (word) =>
          _size(
            pw.RichText(text: word, softWrap: false),
            const pw.BoxConstraints(),
          ).x >
          widthMm * _mm + 0.01,
    );
  }

  PdfPoint _size(pw.Widget child, pw.BoxConstraints constraints) {
    final widget = pw.Theme(data: theme, child: child);
    widget.layout(pw.Context(document: _document), constraints);
    return PdfPoint(widget.box!.width, widget.box!.height);
  }
}
