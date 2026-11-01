import 'package:flutter/cupertino.dart';

import '../../l10n/app_localizations.dart';
import '../common/card_summary.dart';
import 'card_preview.dart';
import 'draft.dart';
import 'entry_session.dart';
import 'entry_widgets.dart';
import 'field_labels.dart';

/// Vocabulary entry on a narrow screen: the grid's row engine with one
/// visible row. Next → Next saves the card and clears the fields.
class RapidCard extends StatefulWidget {
  const RapidCard({super.key, required this.session});

  final EntrySession session;

  @override
  State<RapidCard> createState() => _RapidCardState();
}

class _RapidCardState extends State<RapidCard> {
  bool _preview = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = widget.session;
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final row = session.active;
        final saved = [
          for (final r in session.rows)
            if (!identical(r, row) && r.cardId != null) r,
        ];
        final recent = saved.length <= 3
            ? saved
            : saved.sublist(saved.length - 3);
        final fields = session.gridOrder(row);
        final extras = vocabularyExtras(row.language);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final r in recent)
              Opacity(
                opacity: 0.45,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '#${r.seq}  ${cardSummary(r.toContent()).front} — '
                    '${cardSummary(r.toContent()).back}',
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Focus(
              canRequestFocus: false,
              skipTraversal: true,
              onFocusChange: (hasFocus) {
                if (!hasFocus) session.leaveRow(row, advance: true);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final f in fields) ...[
                    Text(
                      fieldLabel(l10n, f, row.language).full,
                      style: TextStyle(color: secondary, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: f == DraftField.gender ? 72 : double.infinity,
                        child: EntryTextField(
                          key: ValueKey((row.key, f)),
                          controller: row.controller(f),
                          focusNode: row.focus(f),
                          semanticLabel: cellSemantics(l10n, row, f),
                          gender: f == DraftField.gender,
                          large: true,
                          onEditingComplete: () => session.next(row, f),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
            if (row.incomplete)
              Text(
                l10n.rowIncomplete,
                style: TextStyle(
                  color: CupertinoColors.systemOrange.resolveFrom(context),
                ),
              ),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                if (extras.isNotEmpty)
                  ExcludeFocus(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => session.toggleExpanded(row),
                      child: Text(
                        row.expanded ? l10n.fewerFields : l10n.moreFields,
                      ),
                    ),
                  ),
                ExcludeFocus(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    onPressed: () => setState(() => _preview = !_preview),
                    child: Text(_preview ? l10n.hidePreview : l10n.showPreview),
                  ),
                ),
                TextFieldTapRegion(
                  child: CupertinoButton.filled(
                    onPressed: () => session.finishRow(row),
                    child: Text(l10n.nextCard),
                  ),
                ),
              ],
            ),
            if (_preview) ...[
              const SizedBox(height: 16),
              SessionPreview(session: session),
            ],
          ],
        );
      },
    );
  }
}
