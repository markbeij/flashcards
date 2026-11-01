import 'package:flutter/cupertino.dart';

import '../../domain/markup.dart';

/// Shows `**bold**` and `*italic*` styled while typing, with the markers
/// dimmed. Uses the same parser as the PDF, and keeps the composing
/// underline of the keyboard.
class MarkupEditingController extends TextEditingController {
  MarkupEditingController({super.text});

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final composing = withComposing && value.isComposingRangeValid
        ? value.composing
        : TextRange.empty;
    final dimmed = CupertinoColors.tertiaryLabel.resolveFrom(context);
    final children = <TextSpan>[];
    var offset = 0;
    for (final run in parseMarkup(text)) {
      final runStyle = TextStyle(
        fontWeight: run.bold ? FontWeight.bold : null,
        fontStyle: run.italic ? FontStyle.italic : null,
        color: run.marker ? dimmed : null,
      );
      // Split the run where the composing range starts and ends.
      final start = offset;
      final end = offset + run.text.length;
      final cuts = {
        start,
        if (composing.isValid &&
            composing.start > start &&
            composing.start < end)
          composing.start,
        if (composing.isValid && composing.end > start && composing.end < end)
          composing.end,
        end,
      }.toList()..sort();
      for (var i = 0; i + 1 < cuts.length; i++) {
        final inComposing =
            composing.isValid &&
            cuts[i] >= composing.start &&
            cuts[i + 1] <= composing.end;
        children.add(
          TextSpan(
            text: text.substring(cuts[i], cuts[i + 1]),
            style: inComposing
                ? runStyle.merge(
                    const TextStyle(decoration: TextDecoration.underline),
                  )
                : runStyle,
          ),
        );
      }
      offset = end;
    }
    return TextSpan(style: style, children: children);
  }
}

/// Wraps the selection in `**` (bold) or `*` (italic), or removes the
/// markers when the selection is already wrapped. With no selection it
/// inserts an empty pair and puts the cursor between them.
void toggleMarkup(TextEditingController controller, {required bool bold}) {
  final marker = bold ? '**' : '*';
  final text = controller.text;
  var selection = controller.selection;
  if (!selection.isValid) {
    selection = TextSelection.collapsed(offset: text.length);
  }
  final start = selection.start;
  final end = selection.end;
  final m = marker.length;

  final wrapped =
      start >= m &&
      end + m <= text.length &&
      text.substring(start - m, start) == marker &&
      text.substring(end, end + m) == marker;
  if (wrapped) {
    controller.value = TextEditingValue(
      text:
          text.substring(0, start - m) +
          text.substring(start, end) +
          text.substring(end + m),
      selection: TextSelection(baseOffset: start - m, extentOffset: end - m),
    );
    return;
  }
  controller.value = TextEditingValue(
    text:
        '${text.substring(0, start)}$marker${text.substring(start, end)}'
        '$marker${text.substring(end)}',
    selection: start == end
        ? TextSelection.collapsed(offset: start + m)
        : TextSelection(baseOffset: start + m, extentOffset: end + m),
  );
}
