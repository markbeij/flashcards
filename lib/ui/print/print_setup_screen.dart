import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/store/library_notifier.dart';
import '../../domain/deck.dart';
import '../../l10n/app_localizations.dart';
import '../../render/sheet.dart';
import '../locations.dart';
import 'print_job.dart';

/// Print, step 1: what to print. Opens from a deck (that deck ticked) or
/// from the Library (the last selection).
class PrintSetupScreen extends ConsumerStatefulWidget {
  const PrintSetupScreen({super.key, this.deckId});

  final String? deckId;

  @override
  ConsumerState<PrintSetupScreen> createState() => _PrintSetupScreenState();
}

class _PrintSetupScreenState extends ConsumerState<PrintSetupScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(printJobProvider.notifier).open(deckId: widget.deckId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final printed = ref.watch(printCardsProvider);
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.pop(),
          child: Text(l10n.cancel),
        ),
        middle: Text(l10n.print),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [const _WhatSection(), const SizedBox(height: 24)],
              ),
            ),
            // The sticky bar.
            DecoratedBox(
              decoration: BoxDecoration(
                color: CupertinoDynamicColor.resolve(
                  CupertinoTheme.of(context).barBackgroundColor,
                  context,
                ),
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(context),
                    width: 0,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${l10n.cardCount(printed.length)} · '
                          '${l10n.sheetCount(sheetCount(printed.length))}',
                          style: TextStyle(color: secondary),
                        ),
                      ),
                      CupertinoButton.filled(
                        onPressed: printed.isEmpty
                            ? null
                            : () {
                                ref.read(printJobProvider.notifier).remember();
                                context.push(printPreviewLocation);
                              },
                        child: Text(l10n.preview),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Maps, submaps and decks with checkboxes. Ticking a map or submap ticks
/// its decks.
class _WhatSection extends ConsumerWidget {
  const _WhatSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final library = ref.watch(libraryProvider);
    final job = ref.watch(printJobProvider);
    final notifier = ref.read(printJobProvider.notifier);
    final decks = library.decks.values;

    if (decks.isEmpty) {
      return CupertinoListSection.insetGrouped(
        header: Text(l10n.printWhat),
        children: [CupertinoListTile(title: Text(l10n.printNothing))],
      );
    }

    bool? state(Iterable<Deck> group) {
      final ticked = group.where((d) => job.deckIds.contains(d.id)).length;
      if (ticked == 0) return false;
      return ticked == group.length ? true : null;
    }

    Widget tile({
      required String title,
      required Iterable<Deck> group,
      required double indent,
      String? info,
      bool bold = false,
    }) {
      final value = state(group);
      void toggle() =>
          notifier.setDecks(group.map((d) => d.id), ticked: value != true);
      return CupertinoListTile(
        padding: EdgeInsetsDirectional.only(start: 12 + indent, end: 14),
        leading: CupertinoCheckbox(
          value: value,
          tristate: true,
          onChanged: (_) => toggle(),
          semanticLabel: title,
        ),
        title: Text(
          title,
          style: bold ? const TextStyle(fontWeight: FontWeight.w600) : null,
        ),
        additionalInfo: info == null ? null : Text(info),
        onTap: toggle,
      );
    }

    return CupertinoListSection.insetGrouped(
      header: Text(l10n.printWhat),
      children: [
        for (final map in mapsOf(decks)) ...[
          tile(
            title: map,
            group: decks.where((d) => d.map == map),
            indent: 0,
            bold: true,
          ),
          for (final submap in submapsOf(map, decks)) ...[
            tile(title: submap, group: decksIn(map, submap, decks), indent: 24),
            for (final deck in decksIn(map, submap, decks))
              tile(
                title: deck.title,
                group: [deck],
                indent: 48,
                info: l10n.cardCount(library.cardsIn(deck.id).length),
              ),
          ],
        ],
      ],
    );
  }
}
