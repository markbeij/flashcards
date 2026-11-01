import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/store/library_notifier.dart';
import '../../domain/card_content.dart';
import '../../domain/deck.dart';
import '../../l10n/app_localizations.dart';
import '../../render/sheet.dart';
import '../common/card_summary.dart';
import '../common/card_type_labels.dart';
import '../locations.dart';
import 'print_job.dart';

/// Print, step 1: what to print, the cards that don't fit, and the
/// direction. Opens from a deck (that deck ticked) or from the Library (the
/// last selection).
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
    final job = ref.watch(printJobProvider);
    final plan = ref.watch(printPlanProvider);
    final printed = plan.printed(job);
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
                children: [
                  const _WhatSection(),
                  if (plan.overflowing.isNotEmpty) _OverflowSection(plan: plan),
                  CupertinoListSection.insetGrouped(
                    header: Text(l10n.printDirection),
                    children: [_DirectionTile(plan: plan, swap: job.swap)],
                  ),
                  const SizedBox(height: 24),
                ],
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

/// Cards that don't fit: Fix opens the card, Skip (the default) leaves it
/// out. Printing is never blocked.
class _OverflowSection extends ConsumerWidget {
  const _OverflowSection({required this.plan});

  final PrintPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final job = ref.watch(printJobProvider);
    final library = ref.watch(libraryProvider);
    return CupertinoListSection.insetGrouped(
      header: Text(l10n.printDoesntFit),
      footer: Text(l10n.printDoesntFitHint),
      children: [
        for (final c in plan.cards)
          if (plan.overflowing.contains(c.card.uuid))
            CupertinoListTile(
              leading: Icon(c.card.type.icon),
              title: Text(cardSummary(c.card.content).front),
              subtitle: Text('${c.deckTitle} · #${c.card.seq}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    onPressed: () {
                      final deckId = library.cards.entries
                          .firstWhere((e) => e.value.containsKey(c.card.uuid))
                          .key;
                      context.push(cardLocation(deckId, c.card.uuid));
                    },
                    child: Text(l10n.fix),
                  ),
                  Text(l10n.skip),
                  const SizedBox(width: 6),
                  CupertinoSwitch(
                    value: !job.printAnyway.contains(c.card.uuid),
                    onChanged: (skip) => ref
                        .read(printJobProvider.notifier)
                        .setSkip(c.card.uuid, skip: skip),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

/// "Front shows: Dutch / Back shows: Latin" with ⇄.
class _DirectionTile extends ConsumerWidget {
  const _DirectionTile({required this.plan, required this.swap});

  final PrintPlan plan;
  final bool swap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final languages = plan.languages;
    final (question, answer) = languages.isEmpty
        ? (l10n.directionQuestion, l10n.directionAnswer)
        : (
            l10n.languageDutch,
            [
              for (final language in VocabLanguage.values)
                if (languages.contains(language)) language.label(l10n),
            ].join(', '),
          );
    final (front, back) = swap ? (answer, question) : (question, answer);
    return CupertinoListTile(
      title: Text(l10n.frontShows(front)),
      subtitle: Text(l10n.backShows(back)),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size(44, 44),
        onPressed: () => ref.read(printJobProvider.notifier).toggleSwap(),
        child: Icon(
          CupertinoIcons.arrow_right_arrow_left,
          semanticLabel: l10n.swapSides,
        ),
      ),
      onTap: () => ref.read(printJobProvider.notifier).toggleSwap(),
    );
  }
}
