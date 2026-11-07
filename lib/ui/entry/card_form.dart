import 'package:flutter/cupertino.dart';

import '../../domain/card_content.dart';
import '../../l10n/app_localizations.dart';
import '../../render/grid.dart' show Side;
import '../common/card_type_labels.dart';
import 'draft.dart';
import 'entry_session.dart';
import 'entry_widgets.dart';
import 'field_labels.dart';
import 'space_bar.dart';

/// The stacked form for one card of any type. Used by "Add cards" for
/// begrip, paradigm, sentence and history, and by the card editor.
class CardForm extends StatelessWidget {
  const CardForm({
    super.key,
    required this.session,
    required this.draft,
    this.adding = false,
    this.footer,
  });

  final EntrySession session;
  final DraftCard draft;

  /// In "Add cards" (as opposed to editing a card).
  final bool adding;
  final Widget? footer;

  static bool _multiline(DraftField f) => switch (f) {
    DraftField.explanation || DraftField.context => true,
    _ => false,
  };

  List<DraftField> get _fields => formFields(draft.type, draft.language);

  /// The field at [index] is the last one on the front.
  bool _endsFront(int index) {
    final fields = _fields;
    return fields[index].side == Side.front &&
        (index == fields.length - 1 || fields[index + 1].side == Side.back);
  }

  void _next(DraftField field) {
    final fields = _fields;
    final i = fields.indexOf(field);
    if (i < fields.length - 1) {
      draft.focus(fields[i + 1]).requestFocus();
    } else if (draft.type == CardType.paradigm) {
      _focusLine(0);
    } else {
      session.finishRow(draft);
    }
  }

  /// Focuses the label of paradigm line [index], adding the line if needed.
  void _focusLine(int index) {
    if (index < draft.forms.length &&
        draft.forms[index].labelFocus.context != null) {
      draft.forms[index].labelFocus.requestFocus();
      return;
    }
    final line = index < draft.forms.length
        ? draft.forms[index]
        : session.addFormRow(draft);
    // A new line is on screen after the next frame. Focus stays in the
    // current field until then, so the keyboard stays up.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => line.labelFocus.requestFocus(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) => Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onFocusChange: (hasFocus) {
          if (!hasFocus) session.leaveRow(draft, advance: false);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (draft.type == CardType.vocabulary && !adding) ...[
              CupertinoSlidingSegmentedControl<VocabLanguage>(
                groupValue: draft.language,
                children: {
                  for (final language in VocabLanguage.values)
                    language: Text(language.label(l10n)),
                },
                onValueChanged: (language) {
                  if (language != null) session.setLanguage(draft, language);
                },
              ),
              const SizedBox(height: 16),
            ],
            for (final (i, f) in _fields.indexed) ...[
              Text(
                fieldLabel(l10n, f, draft.language).full,
                style: TextStyle(color: secondary, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: f == DraftField.gender ? 72 : double.infinity,
                  child: EntryTextField(
                    key: ValueKey((draft.key, f)),
                    controller: draft.controller(f),
                    focusNode: draft.focus(f),
                    semanticLabel: cellSemantics(l10n, draft, f),
                    gender: f == DraftField.gender,
                    multiline: _multiline(f),
                    onEditingComplete: _multiline(f) ? null : () => _next(f),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (_endsFront(i))
                SpaceBar(session: session, draft: draft, side: Side.front),
            ],
            if (draft.type == CardType.paradigm) ...[
              Text(
                l10n.fieldForms,
                style: TextStyle(color: secondary, fontSize: 13),
              ),
              const SizedBox(height: 4),
              for (final (i, line) in draft.forms.indexed)
                Padding(
                  key: line.key,
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 110,
                        child: EntryTextField(
                          controller: line.label,
                          focusNode: line.labelFocus,
                          placeholder: l10n.fieldFormLabel,
                          semanticLabel: l10n.formLabelSemantics(i + 1),
                          onEditingComplete: () =>
                              line.valueFocus.requestFocus(),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: EntryTextField(
                          controller: line.value,
                          focusNode: line.valueFocus,
                          placeholder: l10n.fieldFormValue,
                          semanticLabel: l10n.formValueSemantics(i + 1),
                          // Return adds a row.
                          onEditingComplete: () => _focusLine(i + 1),
                        ),
                      ),
                      ExcludeFocus(
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(44, 44),
                          onPressed: () => session.removeFormRow(draft, line),
                          child: Icon(
                            CupertinoIcons.minus_circle,
                            semanticLabel: l10n.removeRow,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: ExcludeFocus(
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _focusLine(draft.forms.length),
                    child: Text(l10n.addRow),
                  ),
                ),
              ),
            ],
            SpaceBar(session: session, draft: draft, side: Side.back),
            if (draft.incomplete)
              Text(
                l10n.cardIncomplete,
                style: TextStyle(
                  color: CupertinoColors.systemOrange.resolveFrom(context),
                ),
              ),
            ?footer,
          ],
        ),
      ),
    );
  }
}
