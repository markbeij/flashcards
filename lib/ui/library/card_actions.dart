import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/store/library_notifier.dart';
import '../../domain/deck.dart';
import '../../l10n/app_localizations.dart';
import '../common/toast.dart';

/// Deletes cards right away and offers to undo it.
void deleteCardsWithUndo(
  BuildContext context,
  WidgetRef ref,
  String deckId,
  Iterable<String> cardIds,
) {
  final notifier = ref.read(libraryProvider.notifier);
  final cards = ref.read(libraryProvider).cardsIn(deckId);
  final deleted = [
    for (final id in cardIds)
      if (cards[id] != null) cards[id]!,
  ];
  if (deleted.isEmpty) return;
  for (final card in deleted) {
    notifier.deleteCard(deckId, card.uuid);
  }
  showUndoToast(
    context,
    message: AppLocalizations.of(context).cardsDeleted(deleted.length),
    onUndo: () => notifier.restoreCards(deckId, deleted),
  );
}

/// Asks for another deck and moves the cards there.
Future<void> moveCardsFlow(
  BuildContext context,
  WidgetRef ref,
  String fromDeckId,
  Iterable<String> cardIds,
) async {
  final ids = cardIds.toList();
  final target = await showCupertinoSheet<Deck>(
    context: context,
    scrollableBuilder: (context, controller) =>
        _MoveSheet(fromDeckId: fromDeckId, scrollController: controller),
  );
  if (target == null) return;
  final notifier = ref.read(libraryProvider.notifier);
  for (final id in ids) {
    notifier.moveCard(id, from: fromDeckId, to: target.id);
  }
}

class _MoveSheet extends ConsumerWidget {
  const _MoveSheet({required this.fromDeckId, required this.scrollController});

  final String fromDeckId;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final decks = ref.watch(libraryProvider.select((l) => l.decks)).values;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        middle: Text(l10n.moveTo),
      ),
      child: SafeArea(
        child: ListView(
          controller: scrollController,
          children: [
            for (final map in mapsOf(decks))
              for (final submap in submapsOf(map, decks))
                CupertinoListSection.insetGrouped(
                  header: Text('$map · $submap'),
                  children: [
                    for (final deck in decksIn(map, submap, decks))
                      CupertinoListTile(
                        title: Text(deck.title),
                        trailing: deck.id == fromDeckId
                            ? const Icon(CupertinoIcons.checkmark_alt)
                            : null,
                        onTap: deck.id == fromDeckId
                            ? null
                            : () => Navigator.pop(context, deck),
                      ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
