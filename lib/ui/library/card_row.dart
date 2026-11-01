import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show MenuAnchor, MenuController, MenuItemButton;
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/flashcard.dart';
import '../../l10n/app_localizations.dart';
import '../common/card_summary.dart';
import '../common/card_type_labels.dart';
import '../common/overflow_badge.dart';
import '../providers.dart';

/// What the row's menu can do.
enum CardAction { edit, newLikeThis, move, delete }

/// A card in a deck: type icon, front text, back text in grey, `#n` and an
/// overflow badge. The "⋯" menu also opens on right-click or long-press.
class CardRow extends ConsumerStatefulWidget {
  const CardRow({
    super.key,
    required this.card,
    required this.selected,
    required this.onTap,
    required this.onAction,
    this.ticked,
  });

  final Flashcard card;
  final bool selected;
  final VoidCallback onTap;
  final ValueChanged<CardAction> onAction;

  /// In select mode: whether the card is ticked. null outside select mode.
  final bool? ticked;

  @override
  ConsumerState<CardRow> createState() => _CardRowState();
}

class _CardRowState extends ConsumerState<CardRow> {
  final _menu = MenuController();

  void _openMenu([Offset? position]) {
    if (widget.ticked != null) return;
    _menu.open(position: position);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final card = widget.card;
    final summary = cardSummary(card.content);
    final overflow =
        ref.watch(overflowCheckerProvider)?.overflows(card.content) ?? false;
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);
    final background = widget.selected
        ? CupertinoColors.systemFill.resolveFrom(context)
        : CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context);

    return MenuAnchor(
      controller: _menu,
      menuChildren: [
        for (final (action, label) in [
          (CardAction.edit, l10n.edit),
          (CardAction.newLikeThis, l10n.newCardLikeThis),
          (CardAction.move, l10n.moveTo),
          (CardAction.delete, l10n.delete),
        ])
          MenuItemButton(
            onPressed: () => widget.onAction(action),
            child: Text(
              label,
              style: action == CardAction.delete
                  ? TextStyle(
                      color: CupertinoColors.destructiveRed.resolveFrom(
                        context,
                      ),
                    )
                  : null,
            ),
          ),
      ],
      child: Semantics(
        label: l10n.cardSemantics(card.seq, summary.front, summary.back),
        selected: widget.selected || (widget.ticked ?? false),
        button: true,
        excludeSemantics: true,
        customSemanticsActions: {
          CustomSemanticsAction(label: l10n.moreActions): _openMenu,
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onLongPress: _openMenu,
          onSecondaryTapUp: (details) => _openMenu(details.localPosition),
          child: Container(
            color: background,
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (widget.ticked != null) ...[
                  Icon(
                    widget.ticked!
                        ? CupertinoIcons.check_mark_circled_solid
                        : CupertinoIcons.circle,
                    color: widget.ticked!
                        ? CupertinoTheme.of(context).primaryColor
                        : secondary,
                  ),
                  const SizedBox(width: 12),
                ],
                Icon(card.type.icon, color: secondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(summary.front),
                      if (summary.back.isNotEmpty)
                        Text(
                          summary.back,
                          style: TextStyle(color: secondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (overflow) ...[
                        const SizedBox(height: 4),
                        const OverflowBadge(),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '#${card.seq}',
                  style: TextStyle(
                    color: secondary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (widget.ticked == null)
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(44, 44),
                    onPressed: _openMenu,
                    child: Icon(
                      CupertinoIcons.ellipsis_circle,
                      semanticLabel: l10n.moreActions,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
