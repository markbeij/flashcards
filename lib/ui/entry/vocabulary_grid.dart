import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/card_content.dart';
import '../../l10n/app_localizations.dart';
import '../../data/store/library_notifier.dart';
import '../providers.dart';
import 'draft.dart';
import 'entry_session.dart';
import 'entry_widgets.dart';
import 'field_labels.dart';

class NextFieldIntent extends Intent {
  const NextFieldIntent();
}

class PreviousFieldIntent extends Intent {
  const PreviousFieldIntent();
}

class CommitCardIntent extends Intent {
  const CommitCardIntent();
}

/// Tab, Shift-Tab and Cmd-Return for the row engine, overriding the default
/// focus traversal inside the entry screens.
class RowEngineKeys extends StatelessWidget {
  const RowEngineKeys({super.key, required this.session, required this.child});

  final EntrySession session;
  final Widget child;

  (DraftCard, DraftField)? _focused() {
    final node = FocusManager.instance.primaryFocus;
    if (node == null) return null;
    for (final row in session.rows) {
      final field = row.fieldFor(node);
      if (field != null) return (row, field);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.tab): NextFieldIntent(),
        SingleActivator(LogicalKeyboardKey.tab, shift: true):
            PreviousFieldIntent(),
        SingleActivator(LogicalKeyboardKey.enter, meta: true):
            CommitCardIntent(),
      },
      child: Actions(
        actions: {
          NextFieldIntent: CallbackAction<NextFieldIntent>(
            onInvoke: (_) {
              final focused = _focused();
              if (focused != null) session.next(focused.$1, focused.$2);
              return null;
            },
          ),
          PreviousFieldIntent: CallbackAction<PreviousFieldIntent>(
            onInvoke: (_) {
              final focused = _focused();
              if (focused != null) session.previous(focused.$1, focused.$2);
              return null;
            },
          ),
          CommitCardIntent: CallbackAction<CommitCardIntent>(
            onInvoke: (_) {
              final row = _focused()?.$1 ?? session.current ?? session.active;
              session.finishRow(row);
              return null;
            },
          ),
        },
        child: FocusTraversalGroup(child: child),
      ),
    );
  }
}

const _genderWidth = 52.0;
const _disclosureWidth = 44.0;
const _statusWidth = 52.0;

/// Fast list entry of vocabulary: one row per card, the columns depending
/// on the language.
class VocabularyGrid extends StatelessWidget {
  const VocabularyGrid({super.key, required this.session});

  final EntrySession session;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final columns = vocabularyColumns(session.language);
        return MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.6,
          child: Column(
            children: [
              _HeaderRow(language: session.language, columns: columns),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      for (final row in session.rows)
                        _GridRow(key: row.key, session: session, row: row),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.language, required this.columns});

  final VocabLanguage language;
  final List<DraftField> columns;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final style = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: CupertinoColors.secondaryLabel.resolveFrom(context),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: _disclosureWidth),
          for (final field in columns)
            _cell(
              field,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Semantics(
                  label: fieldLabel(l10n, field, language).full,
                  excludeSemantics: true,
                  child: Text(
                    fieldLabel(l10n, field, language).short,
                    maxLines: 2,
                    style: style,
                    textAlign: field == DraftField.gender
                        ? TextAlign.center
                        : TextAlign.start,
                  ),
                ),
              ),
            ),
          const SizedBox(width: _statusWidth),
        ],
      ),
    );
  }
}

Widget _cell(DraftField field, Widget child) => field == DraftField.gender
    ? SizedBox(width: _genderWidth, child: child)
    : Expanded(child: child);

class _GridRow extends ConsumerWidget {
  const _GridRow({super.key, required this.session, required this.row});

  final EntrySession session;
  final DraftCard row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final columns = vocabularyColumns(row.language);
    final extras = vocabularyExtras(row.language);
    final card = row.cardId == null
        ? null
        : ref.watch(
            libraryProvider.select(
              (l) => l.cardsIn(session.deckId)[row.cardId],
            ),
          );
    final overflow =
        card != null &&
        (ref.watch(overflowCheckerProvider)?.overflows(card.content) ?? false);
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);
    final isCurrent = identical(session.current, row);

    Widget field(DraftField f) => Padding(
      padding: const EdgeInsets.all(3),
      child: EntryTextField(
        controller: row.controller(f),
        focusNode: row.focus(f),
        semanticLabel: cellSemantics(l10n, row, f),
        gender: f == DraftField.gender,
        onEditingComplete: () => session.next(row, f),
      ),
    );

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (hasFocus) {
        if (!hasFocus) session.leaveRow(row, advance: true);
      },
      child: Container(
        color: isCurrent
            ? CupertinoColors.systemFill
                  .resolveFrom(context)
                  .withValues(alpha: 0.12)
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: _disclosureWidth,
                  child: extras.isEmpty
                      ? null
                      : ExcludeFocus(
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(44, 44),
                            onPressed: () => session.toggleExpanded(row),
                            child: Icon(
                              row.expanded
                                  ? CupertinoIcons.chevron_down
                                  : CupertinoIcons.chevron_right,
                              size: 18,
                              semanticLabel: l10n.moreFields,
                            ),
                          ),
                        ),
                ),
                for (final f in columns) _cell(f, field(f)),
                SizedBox(
                  width: _statusWidth,
                  child: Center(
                    child: row.incomplete
                        ? Icon(
                            CupertinoIcons.circle_fill,
                            size: 10,
                            color: CupertinoColors.systemOrange.resolveFrom(
                              context,
                            ),
                            semanticLabel: l10n.rowIncomplete,
                          )
                        : overflow
                        ? Icon(
                            CupertinoIcons.exclamationmark_triangle_fill,
                            size: 18,
                            color: CupertinoColors.systemOrange.resolveFrom(
                              context,
                            ),
                            semanticLabel: l10n.overflowShort,
                          )
                        : Text(
                            row.seq == null ? '' : '#${row.seq}',
                            style: TextStyle(color: secondary),
                          ),
                  ),
                ),
              ],
            ),
            if (row.expanded)
              Padding(
                padding: const EdgeInsets.only(
                  left: _disclosureWidth,
                  right: _statusWidth,
                  bottom: 6,
                ),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final f in extras)
                      SizedBox(
                        width: f == DraftField.gender ? 120 : 220,
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                fieldLabel(l10n, f, row.language).short,
                                style: TextStyle(
                                  color: secondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            SizedBox(
                              width: f == DraftField.gender
                                  ? _genderWidth
                                  : 140,
                              child: field(f),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
