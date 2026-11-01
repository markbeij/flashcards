import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import 'entry_session.dart';
import 'markup_controller.dart';

/// The one keyboard setup for every entry field: no autocorrect,
/// suggestions, spell check, auto-capitalisation or smart punctuation, so
/// the QuickType bar never appears and the grid never jumps.
class EntryTextField extends StatelessWidget {
  const EntryTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.semanticLabel,
    this.onEditingComplete,
    this.placeholder,
    this.gender = false,
    this.multiline = false,
    this.large = false,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String semanticLabel;
  final VoidCallback? onEditingComplete;
  final String? placeholder;

  /// A one-character m/f/n field.
  final bool gender;
  final bool multiline;

  /// Bigger text, for the rapid card.
  final bool large;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      textField: true,
      child: CupertinoTextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        placeholder: placeholder,
        style: large ? const TextStyle(fontSize: 22) : null,
        padding: EdgeInsets.symmetric(
          horizontal: gender ? 4 : 8,
          vertical: large ? 12 : 10,
        ),
        textAlign: gender ? TextAlign.center : TextAlign.start,
        autocorrect: false,
        enableSuggestions: false,
        spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
        smartQuotesType: SmartQuotesType.disabled,
        smartDashesType: SmartDashesType.disabled,
        textCapitalization: TextCapitalization.none,
        textInputAction: multiline
            ? TextInputAction.newline
            : TextInputAction.next,
        keyboardType: multiline ? TextInputType.multiline : TextInputType.text,
        minLines: multiline ? 2 : null,
        maxLines: multiline ? 6 : 1,
        onEditingComplete: onEditingComplete,
        inputFormatters: gender ? const [GenderInputFormatter()] : null,
      ),
    );
  }
}

/// Keeps one character, m, f or n, in lower case.
class GenderInputFormatter extends TextInputFormatter {
  const GenderInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final typed = newValue.text.toLowerCase();
    final last = typed.isEmpty ? '' : typed.substring(typed.length - 1);
    final text = 'mfn'.contains(last) ? last : oldValue.text;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// The fixed B/I toolbar. It sits in a [TextFieldTapRegion], so tapping it
/// keeps the keyboard and focus where they are.
class MarkupToolbar extends StatelessWidget {
  const MarkupToolbar({super.key, required this.session, this.trailing});

  final EntrySession session;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextFieldTapRegion(
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: CupertinoDynamicColor.resolve(
            CupertinoTheme.of(context).barBackgroundColor,
            context,
          ),
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.separator.resolveFrom(context),
              width: 0,
            ),
          ),
        ),
        child: Row(
          children: [
            _MarkupButton(
              label: 'B',
              semanticLabel: l10n.bold,
              style: const TextStyle(fontWeight: FontWeight.bold),
              onPressed: () => applyMarkup(session, bold: true),
            ),
            _MarkupButton(
              label: 'I',
              semanticLabel: l10n.italic,
              style: const TextStyle(fontStyle: FontStyle.italic),
              onPressed: () => applyMarkup(session, bold: false),
            ),
            const Spacer(),
            if (trailing != null) Flexible(flex: 4, child: trailing!),
          ],
        ),
      ),
    );
  }
}

/// Bold or italic on the focused field of [session].
void applyMarkup(EntrySession session, {required bool bold}) {
  final controller = _focusedController(session);
  if (controller != null) toggleMarkup(controller, bold: bold);
}

TextEditingController? _focusedController(EntrySession session) {
  final focused = FocusManager.instance.primaryFocus;
  if (focused == null) return null;
  for (final row in session.rows) {
    final controller = row.controllerFor(focused);
    if (controller != null) return controller;
  }
  return null;
}

class _MarkupButton extends StatelessWidget {
  const _MarkupButton({
    required this.label,
    required this.semanticLabel,
    required this.style,
    required this.onPressed,
  });

  final String label;
  final String semanticLabel;
  final TextStyle style;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      excludeSemantics: true,
      // Don't take focus from the field.
      child: ExcludeFocus(
        child: CupertinoButton(
          minimumSize: const Size(44, 44),
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          child: Text(label, style: style.copyWith(fontSize: 20)),
        ),
      ),
    );
  }
}
