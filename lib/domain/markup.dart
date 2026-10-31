/// Inline markup in card fields: `**bold**` and `*italic*`.
///
/// Shared by the PDF renderer (which drops the marker runs) and the editor
/// (which shows them dimmed).
class MarkupRun {
  const MarkupRun(
    this.text, {
    this.bold = false,
    this.italic = false,
    this.marker = false,
  });

  final String text;
  final bool bold;
  final bool italic;

  /// The run is a `*` or `**` marker, not content.
  final bool marker;

  @override
  bool operator ==(Object other) =>
      other is MarkupRun &&
      other.text == text &&
      other.bold == bold &&
      other.italic == italic &&
      other.marker == marker;

  @override
  int get hashCode => Object.hash(text, bold, italic, marker);

  @override
  String toString() =>
      'MarkupRun(${['"$text"', if (bold) 'bold', if (italic) 'italic', if (marker) 'marker'].join(', ')})';
}

/// Splits [source] into runs. Joining the text of all runs gives [source]
/// back.
///
/// A marker opens only before a non-space character and closes only after
/// one. A marker that is never closed is plain text.
List<MarkupRun> parseMarkup(String source) {
  final tokens = _tokenize(source);

  // Pair openers with closers per kind; unpaired markers stay plain text.
  final paired = <int>{};
  final open = <bool, int>{};
  for (var i = 0; i < tokens.length; i++) {
    final token = tokens[i];
    if (token.bold == null) continue;
    final kind = token.bold!;
    final opener = open[kind];
    if (opener != null && token.canClose) {
      paired
        ..add(opener)
        ..add(i);
      open.remove(kind);
    } else if (opener == null && token.canOpen) {
      open[kind] = i;
    }
  }

  final runs = <MarkupRun>[];
  var bold = false;
  var italic = false;
  void add(MarkupRun run) {
    final last = runs.isEmpty ? null : runs.last;
    if (last != null &&
        !last.marker &&
        !run.marker &&
        last.bold == run.bold &&
        last.italic == run.italic) {
      runs[runs.length - 1] = MarkupRun(
        last.text + run.text,
        bold: run.bold,
        italic: run.italic,
      );
    } else {
      runs.add(run);
    }
  }

  for (var i = 0; i < tokens.length; i++) {
    final token = tokens[i];
    if (!paired.contains(i)) {
      add(MarkupRun(token.text, bold: bold, italic: italic));
      continue;
    }
    // A marker has the style of the text it encloses.
    final isBold = token.bold!;
    add(
      MarkupRun(
        token.text,
        bold: isBold || bold,
        italic: !isBold || italic,
        marker: true,
      ),
    );
    if (isBold) {
      bold = !bold;
    } else {
      italic = !italic;
    }
  }
  return runs;
}

/// [source] without its markers, e.g. for a list row.
String plainText(String source) => [
  for (final run in parseMarkup(source))
    if (!run.marker) run.text,
].join();

class _Token {
  const _Token.text(this.text) : bold = null, canOpen = false, canClose = false;
  const _Token.marker(
    this.text, {
    required bool this.bold,
    required this.canOpen,
    required this.canClose,
  });

  final String text;

  /// null for text, true for `**`, false for `*`.
  final bool? bold;
  final bool canOpen;
  final bool canClose;
}

List<_Token> _tokenize(String source) {
  final tokens = <_Token>[];
  var textStart = 0;
  var i = 0;
  while (i < source.length) {
    if (source[i] != '*') {
      i++;
      continue;
    }
    var end = i;
    while (end < source.length && source[end] == '*') {
      end++;
    }
    if (textStart < i) tokens.add(_Token.text(source.substring(textStart, i)));
    final canClose = i > 0 && !_isSpace(source[i - 1]);
    final canOpen = end < source.length && !_isSpace(source[end]);
    // A run of three or more stars is read as `**` markers and a final `*`.
    var count = end - i;
    while (count > 0) {
      final bold = count >= 2;
      tokens.add(
        _Token.marker(
          bold ? '**' : '*',
          bold: bold,
          canOpen: canOpen,
          canClose: canClose,
        ),
      );
      count -= bold ? 2 : 1;
    }
    i = end;
    textStart = end;
  }
  if (textStart < source.length) {
    tokens.add(_Token.text(source.substring(textStart)));
  }
  return tokens;
}

bool _isSpace(String char) => char.trim().isEmpty;
