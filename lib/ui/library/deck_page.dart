import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show MenuAnchor, MenuItemButton;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/store/library_notifier.dart';
import '../../domain/card_content.dart';
import '../../domain/deck.dart';
import '../../l10n/app_localizations.dart';
import '../common/card_type_labels.dart';
import '../common/toolbar.dart';
import '../locations.dart';
import '../providers.dart';
import '../shell/adaptive_shell.dart';
import 'card_actions.dart';
import 'card_row.dart';
import 'deck_sheet.dart';
import 'library_lists.dart';

/// A deck's cards, in the order they were made.
class DeckPage extends ConsumerStatefulWidget {
  const DeckPage({super.key, required this.deckId});

  final String deckId;

  @override
  ConsumerState<DeckPage> createState() => _DeckPageState();
}

class _DeckPageState extends ConsumerState<DeckPage> {
  /// The selected row, to scroll it into view when the deck opens.
  final _selectedKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _remember();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _selectedKey.currentContext;
      if (context != null) Scrollable.ensureVisible(context, alignment: 0.3);
    });
  }

  @override
  void didUpdateWidget(DeckPage old) {
    super.didUpdateWidget(old);
    if (old.deckId != widget.deckId) {
      _remember();
      Future.microtask(() => ref.read(selectModeProvider.notifier).stop());
    }
  }

  /// The deck opens again at the next start.
  void _remember() {
    Future.microtask(() {
      final notifier = ref.read(libraryProvider.notifier);
      final settings = ref.read(libraryProvider).settings;
      if (settings.lastDeckId != widget.deckId &&
          ref.read(libraryProvider).decks.containsKey(widget.deckId)) {
        notifier.updateSettings(settings.copyWith(lastDeckId: widget.deckId));
      }
    });
  }

  void _openCard(String cardId) {
    ref.read(cardSelectionProvider.notifier).select(cardId);
    context.push(cardLocation(widget.deckId, cardId));
  }

  void _onAction(CardAction action, String cardId) {
    ref.read(cardSelectionProvider.notifier).select(cardId);
    switch (action) {
      case CardAction.edit:
        _openCard(cardId);
      case CardAction.newLikeThis:
        context.push(addCardsLocation(widget.deckId, likeCardId: cardId));
      case CardAction.move:
        moveCardsFlow(context, ref, widget.deckId, [cardId]);
      case CardAction.delete:
        deleteCardsWithUndo(context, ref, widget.deckId, [cardId]);
    }
  }

  /// Cmd-Backspace: the ticked cards in select mode, else the selected card.
  void _deleteSelected() {
    final ticked = ref.read(selectModeProvider);
    final selected = ref.read(cardSelectionProvider);
    final ids = ticked ?? {?selected};
    deleteCardsWithUndo(context, ref, widget.deckId, ids);
    ref.read(selectModeProvider.notifier).stop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final deck = ref.watch(deckProvider(widget.deckId));
    if (deck == null) {
      // Deleted elsewhere, e.g. from the other column.
      return const CupertinoPageScaffold(child: SizedBox.expand());
    }
    final cards =
        ref
            .watch(libraryProvider.select((l) => l.cardsIn(widget.deckId)))
            .values
            .toList()
          ..sort((a, b) => a.seq.compareTo(b.seq));
    final selected = ref.watch(cardSelectionProvider);
    final ticked = ref.watch(selectModeProvider);
    final twoColumns = ShellLayout.twoColumnsOf(context);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.backspace, meta: true):
            _deleteSelected,
      },
      child: Focus(
        autofocus: true,
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            automaticallyImplyLeading: !twoColumns,
            previousPageTitle: twoColumns ? null : deck.submap,
            middle: Text(deck.title),
            trailing: ticked != null
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () =>
                        ref.read(selectModeProvider.notifier).stop(),
                    child: Text(
                      l10n.done,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (cards.isNotEmpty)
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          onPressed: () =>
                              ref.read(selectModeProvider.notifier).start(),
                          child: Text(l10n.select),
                        ),
                      _DeckMenu(deck: deck),
                    ],
                  ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: cards.isEmpty
                      ? _EmptyDeck(deckId: deck.id)
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: cards.length,
                          separatorBuilder: (_, _) => Container(
                            height: 0.5,
                            margin: const EdgeInsets.only(left: 52),
                            color: CupertinoColors.separator.resolveFrom(
                              context,
                            ),
                          ),
                          itemBuilder: (context, i) {
                            final card = cards[i];
                            return CardRow(
                              key: card.uuid == selected
                                  ? _selectedKey
                                  : ValueKey(card.uuid),
                              card: card,
                              selected: card.uuid == selected,
                              ticked: ticked?.contains(card.uuid),
                              onTap: ticked != null
                                  ? () => ref
                                        .read(selectModeProvider.notifier)
                                        .toggle(card.uuid)
                                  : () => _openCard(card.uuid),
                              onAction: (action) =>
                                  _onAction(action, card.uuid),
                            );
                          },
                        ),
                ),
                if (ticked != null)
                  BottomToolbar(
                    children: [
                      ToolbarButton(
                        icon: CupertinoIcons.folder,
                        label: l10n.moveTo,
                        onPressed: ticked.isEmpty
                            ? null
                            : () async {
                                await moveCardsFlow(
                                  context,
                                  ref,
                                  deck.id,
                                  ticked,
                                );
                                ref.read(selectModeProvider.notifier).stop();
                              },
                      ),
                      ToolbarButton(
                        icon: CupertinoIcons.delete,
                        label: l10n.delete,
                        destructive: true,
                        onPressed: ticked.isEmpty ? null : _deleteSelected,
                      ),
                    ],
                  )
                else
                  BottomToolbar(
                    children: [
                      ToolbarButton(
                        icon: CupertinoIcons.printer,
                        label: l10n.printEllipsis,
                        onPressed: () =>
                            context.push(printLocation(deckId: deck.id)),
                      ),
                      ToolbarButton(
                        icon: CupertinoIcons.add,
                        label: l10n.addCards,
                        onPressed: () =>
                            context.push(addCardsLocation(deck.id)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "⋯": edit or delete the deck.
class _DeckMenu extends ConsumerWidget {
  const _DeckMenu({required this.deck});

  final Deck deck;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          onPressed: () => editDeckFlow(context, ref, deck),
          child: Text(l10n.editDeck),
        ),
        MenuItemButton(
          onPressed: () => deleteDeckFlow(context, ref, deck),
          child: Text(
            l10n.deleteDeck,
            style: TextStyle(
              color: CupertinoColors.destructiveRed.resolveFrom(context),
            ),
          ),
        ),
      ],
      builder: (context, controller, _) => CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size(44, 44),
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        child: Icon(
          CupertinoIcons.ellipsis_circle,
          semanticLabel: l10n.deckActions,
        ),
      ),
    );
  }
}

/// An empty deck: one tile per card type.
class _EmptyDeck extends StatelessWidget {
  const _EmptyDeck({required this.deckId});

  final String deckId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        EmptyState(message: l10n.deckEmpty, example: l10n.deckEmptyExample),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final type in CardType.values)
              SizedBox(
                width: 200,
                child: CupertinoButton(
                  padding: const EdgeInsets.all(16),
                  color: CupertinoColors.secondarySystemGroupedBackground
                      .resolveFrom(context),
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () =>
                      context.push(addCardsLocation(deckId, type: type)),
                  child: Column(
                    children: [
                      Icon(type.icon, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        type.label(l10n),
                        style: TextStyle(
                          color: CupertinoColors.label.resolveFrom(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        type.example(l10n),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: secondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
