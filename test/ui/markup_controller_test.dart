import 'package:flashcards/ui/entry/markup_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toggleMarkup', () {
    test('wraps the selection', () {
      final c = TextEditingController(text: 'een woord hier')
        ..selection = const TextSelection(baseOffset: 4, extentOffset: 9);
      toggleMarkup(c, bold: true);
      expect(c.text, 'een **woord** hier');
      expect(c.selection, const TextSelection(baseOffset: 6, extentOffset: 11));
    });

    test('unwraps a wrapped selection', () {
      final c = TextEditingController(text: 'een *woord* hier')
        ..selection = const TextSelection(baseOffset: 5, extentOffset: 10);
      toggleMarkup(c, bold: false);
      expect(c.text, 'een woord hier');
      expect(c.selection, const TextSelection(baseOffset: 4, extentOffset: 9));
    });

    test('inserts an empty pair at the cursor', () {
      final c = TextEditingController(text: 'ab')
        ..selection = const TextSelection.collapsed(offset: 1);
      toggleMarkup(c, bold: false);
      expect(c.text, 'a**b');
      expect(c.selection, const TextSelection.collapsed(offset: 2));
    });
  });

  testWidgets('markers are dimmed and runs styled; composing is underlined', (
    tester,
  ) async {
    final c = MarkupEditingController(text: 'a **b** c');
    late TextSpan span;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          c.value = c.value.copyWith(
            composing: const TextRange(start: 8, end: 9),
          );
          span = c.buildTextSpan(context: context, withComposing: true);
          return const SizedBox();
        },
      ),
    );
    final runs = span.children!.cast<TextSpan>();
    expect(runs.map((r) => r.text).join(), 'a **b** c');
    final bold = runs.firstWhere((r) => r.text == 'b');
    expect(bold.style!.fontWeight, FontWeight.bold);
    final marker = runs.firstWhere((r) => r.text == '**');
    expect(marker.style!.color, isNotNull);
    final composing = runs.firstWhere((r) => r.text == 'c');
    expect(composing.style!.decoration, TextDecoration.underline);
  });
}
