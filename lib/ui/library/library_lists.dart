import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/store/library.dart';
import '../../data/store/library_notifier.dart';
import '../../domain/deck.dart';
import '../../l10n/app_localizations.dart';
import '../providers.dart';
import 'deck_sheet.dart';

/// The Library root: a search field and the maps, or the first-run empty
/// state. Typing replaces the maps with the decks that match.
class MapsList extends ConsumerStatefulWidget {
  const MapsList({
    super.key,
    required this.onOpenMap,
    required this.onOpenDeck,
  });

  final ValueChanged<String> onOpenMap;
  final ValueChanged<Deck> onOpenDeck;

  @override
  ConsumerState<MapsList> createState() => _MapsListState();
}

class _MapsListState extends ConsumerState<MapsList> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(librarySearchProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final library = ref.watch(libraryProvider);
    final decks = library.decks.values;
    if (decks.isEmpty) {
      return EmptyState(
        message: l10n.libraryEmpty,
        example: l10n.libraryEmptyExample,
        action: l10n.newDeck,
        onAction: () => newDeckFlow(context, ref),
      );
    }
    final query = ref.watch(librarySearchProvider);
    final found = searchDecks(query, decks);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: CupertinoSearchTextField(
            controller: _controller,
            placeholder: l10n.searchDecks,
            autocorrect: false,
            onChanged: ref.read(librarySearchProvider.notifier).set,
          ),
        ),
        Expanded(
          child: query.trim().isEmpty
              ? _maps(l10n, decks)
              : found.isEmpty
              ? Center(
                  child: Text(
                    l10n.searchNoResults,
                    style: TextStyle(
                      color: CupertinoColors.secondaryLabel.resolveFrom(
                        context,
                      ),
                    ),
                  ),
                )
              : _results(l10n, library, found),
        ),
      ],
    );
  }

  Widget _maps(AppLocalizations l10n, Iterable<Deck> decks) => ListView(
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
              onTap: () => widget.onOpenMap(map),
            ),
        ],
      ),
    ],
  );

  /// The deck, `map › submap` and the card count.
  Widget _results(AppLocalizations l10n, Library library, List<Deck> found) =>
      ListView(
        children: [
          CupertinoListSection.insetGrouped(
            children: [
              for (final deck in found)
                CupertinoListTile.notched(
                  key: ValueKey(deck.id),
                  leading: const Icon(CupertinoIcons.square_stack),
                  title: Text(deck.title),
                  subtitle: Text('${deck.map} › ${deck.submap}'),
                  additionalInfo: Text(
                    l10n.cardCount(library.cardsIn(deck.id).length),
                  ),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => widget.onOpenDeck(deck),
                ),
            ],
          ),
        ],
      );
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
