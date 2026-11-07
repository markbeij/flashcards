import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../domain/card_content.dart';
import '../domain/markup.dart';
import 'card_size.dart';
import 'templates/card_frame.dart';
import 'templates/templates.dart';

const _mm = PdfPageFormat.mm;

/// A hair of tolerance for rounding in the layout, in points.
const _tolerance = 0.01;

/// How full one side of a card is.
class SideFill {
  const SideFill({required this.fill, required this.wordTooWide});

  /// Content height ÷ available height. Above 1 the content is too tall.
  final double fill;

  /// A single word is wider than the space it is set in.
  final bool wordTooWide;

  /// The side doesn't fit: too tall, or a word is too wide.
  bool get full =>
      wordTooWide || fill > 1 + _tolerance / (contentHeightMm * _mm);
}

/// How full both sides of a card are.
class CardFill {
  const CardFill({required this.front, required this.back});

  final SideFill front;
  final SideFill back;

  /// Either side doesn't fit.
  bool get full => front.full || back.full;
}

/// Measures how full each side of a card is (Spike 2). A side is full when
/// its content is as tall as the content area, or when a single word is
/// wider than the space it is set in. Text is never shrunk.
///
/// Results are cached by content, so a card is measured again only after it
/// changes.
class OverflowChecker {
  OverflowChecker(this.theme);

  final pw.ThemeData theme;
  final _document = PdfDocument();
  final _cache = <CardContent, CardFill>{};

  CardFill measure(CardContent content) =>
      _cache[content] ??= _measure(content);

  /// Whether either side of the card doesn't fit.
  bool overflows(CardContent content) => measure(content).full;

  CardFill _measure(CardContent content) {
    final faces = facesOf(content);
    return CardFill(front: _side(faces.front), back: _side(faces.back));
  }

  SideFill _side(CardFace face) {
    final height = _size(
      faceContent(face),
      pw.BoxConstraints(maxWidth: contentWidthMm * _mm),
    ).y;
    return SideFill(
      fill: height / (contentHeightMm * _mm),
      wordTooWide: _hasTooWideWord(face),
    );
  }

  bool _hasTooWideWord(CardFace face) {
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
