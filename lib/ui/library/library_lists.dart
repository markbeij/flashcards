import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/store/library_notifier.dart';
import '../../domain/deck.dart';
import '../../l10n/app_localizations.dart';
import 'deck_sheet.dart';

/// The Library root: the maps, or the first-run empty state.
class MapsList extends ConsumerWidget {
  const MapsList({super.key, required this.onOpenMap});

  final ValueChanged<String> onOpenMap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final decks = ref.watch(libraryProvider.select((l) => l.decks)).values;
    if (decks.isEmpty) {
      return EmptyState(
        message: l10n.libraryEmpty,
        example: l10n.libraryEmptyExample,
        action: l10n.newDeck,
        onAction: () => newDeckFlow(context, ref),
      );
    }
    return ListView(
      children: [
        CupertinoListSection.insetGrouped(
          children: [
            for (final map in mapsOf(decks))
              CupertinoListTile.notched(
                leading: const Icon(CupertinoIcons.folder),
                title: Text(map),
                additionalInfo: Text(
                  l10n.deckCount(decks.where((d) => d.map == map).length),
                ),
                trailing: const CupertinoListTileChevron(),
                onTap: () => onOpenMap(map),
              ),
          ],
        ),
      ],
    );
  }
}

/// A map: its submaps as section headers with their decks underneath.
class MapContents extends ConsumerWidget {
  const MapContents({
    super.key,
    required this.map,
    required this.onOpenDeck,
    this.selectedDeckId,
  });

  final String map;
  final ValueChanged<Deck> onOpenDeck;
  final String? selectedDeckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final library = ref.watch(libraryProvider);
    final decks = library.decks.values;
    final selected = CupertinoColors.systemFill.resolveFrom(context);
    return ListView(
      children: [
        for (final submap in submapsOf(map, decks))
          CupertinoListSection.insetGrouped(
            header: Text(submap),
            children: [
              for (final deck in decksIn(map, submap, decks))
                CupertinoListTile.notched(
                  key: ValueKey(deck.id),
                  backgroundColor: deck.id == selectedDeckId ? selected : null,
                  leading: const Icon(CupertinoIcons.square_stack),
                  title: Text(deck.title),
                  additionalInfo: Text(
                    l10n.cardCount(library.cardsIn(deck.id).length),
                  ),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => onOpenDeck(deck),
                ),
            ],
          ),
      ],
    );
  }
}

/// One sentence, one example, one button.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    required this.example,
    this.action,
    this.onAction,
  });

  final String message;
  final String example;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
            ),
            const SizedBox(height: 8),
            Text(
              example,
              textAlign: TextAlign.center,
              style: TextStyle(color: secondary),
            ),
            if (action != null) ...[
              const SizedBox(height: 20),
              CupertinoButton.filled(onPressed: onAction, child: Text(action!)),
            ],
          ],
        ),
      ),
    );
  }
}
