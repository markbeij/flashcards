import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../common/toolbar.dart';
import '../locations.dart';
import '../shell/adaptive_shell.dart';
import 'deck_sheet.dart';
import 'library_lists.dart';

/// The Library root in the single-column layout.
class LibraryRootPage extends StatelessWidget {
  const LibraryRootPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (ShellLayout.twoColumnsOf(context)) return const DetailPlaceholder();
    final l10n = AppLocalizations.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(l10n.library),
        trailing: const SettingsButton(),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: MapsList(onOpenMap: (map) => context.go(mapLocation(map))),
            ),
            const LibraryToolbar(),
          ],
        ),
      ),
    );
  }
}

/// A map in the single-column layout.
class MapPage extends ConsumerWidget {
  const MapPage({super.key, required this.map});

  final String map;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ShellLayout.twoColumnsOf(context)) return const DetailPlaceholder();
    final l10n = AppLocalizations.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(map),
        previousPageTitle: l10n.library,
        trailing: const SettingsButton(),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: MapContents(
                map: map,
                onOpenDeck: (deck) => context.go(deckLocation(deck)),
              ),
            ),
            LibraryToolbar(map: map),
          ],
        ),
      ),
    );
  }
}

/// The Library column in the two-column layout. It shows the root or a map,
/// following the router location.
class LibraryColumn extends StatelessWidget {
  const LibraryColumn({super.key, required this.location});

  final Uri location;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (:map, :deckId) = parseLibraryLocation(location);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        transitionBetweenRoutes: false,
        leading: map == null
            ? null
            : CupertinoNavigationBarBackButton(
                previousPageTitle: l10n.library,
                onPressed: () => context.go(libraryLocation),
              ),
        middle: Text(map ?? l10n.library),
        trailing: const SettingsButton(),
      ),
      child: SafeArea(
        bottom: false,
        right: false,
        child: Column(
          children: [
            Expanded(
              child: map == null
                  ? MapsList(onOpenMap: (map) => context.go(mapLocation(map)))
                  : MapContents(
                      map: map,
                      selectedDeckId: deckId,
                      onOpenDeck: (deck) => context.go(deckLocation(deck)),
                    ),
            ),
            LibraryToolbar(map: map),
          ],
        ),
      ),
    );
  }
}

/// The right column when no deck is open.
class DetailPlaceholder extends StatelessWidget {
  const DetailPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: Text(
          AppLocalizations.of(context).chooseDeck,
          style: TextStyle(
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
        ),
      ),
    );
  }
}

/// [Print] and [New deck].
class LibraryToolbar extends ConsumerWidget {
  const LibraryToolbar({super.key, this.map});

  /// The open map, suggested for a new deck.
  final String? map;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return BottomToolbar(
      children: [
        ToolbarButton(
          icon: CupertinoIcons.printer,
          label: l10n.print,
          onPressed: () => context.push(printLocation()),
        ),
        ToolbarButton(
          icon: CupertinoIcons.plus_rectangle_on_rectangle,
          label: l10n.newDeck,
          onPressed: () => newDeckFlow(context, ref, map: map),
        ),
      ],
    );
  }
}

/// The gear in the navigation bar.
class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(44, 44),
      onPressed: () => context.push(settingsLocation),
      child: Icon(
        CupertinoIcons.gear,
        semanticLabel: AppLocalizations.of(context).settings,
      ),
    );
  }
}
