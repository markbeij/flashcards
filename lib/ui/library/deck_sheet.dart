import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/store/library_notifier.dart';
import '../../domain/deck.dart';
import '../../l10n/app_localizations.dart';
import '../locations.dart';

/// Asks for a map, submap and title, creates the deck and opens it.
Future<void> newDeckFlow(
  BuildContext context,
  WidgetRef ref, {
  String? map,
}) async {
  final fields = await _showDeckSheet(
    context,
    initial: (map: map ?? '', submap: '', title: ''),
  );
  if (fields == null || !context.mounted) return;
  final deck = ref
      .read(libraryProvider.notifier)
      .createDeck(map: fields.map, submap: fields.submap, title: fields.title);
  context.go(deckLocation(deck));
}

/// Edits a deck's map, submap and title. A new map or submap moves the deck.
Future<void> editDeckFlow(
  BuildContext context,
  WidgetRef ref,
  Deck deck,
) async {
  final fields = await _showDeckSheet(
    context,
    initial: (map: deck.map, submap: deck.submap, title: deck.title),
    editing: true,
  );
  if (fields == null || !context.mounted) return;
  final updated = deck.copyWith(
    map: fields.map,
    submap: fields.submap,
    title: fields.title,
  );
  ref.read(libraryProvider.notifier).updateDeck(updated);
  if (updated.map != deck.map) context.go(deckLocation(updated));
}

/// Deletes a deck and its cards after a confirmation.
Future<void> deleteDeckFlow(
  BuildContext context,
  WidgetRef ref,
  Deck deck,
) async {
  final l10n = AppLocalizations.of(context);
  final count = ref.read(libraryProvider).cardsIn(deck.id).length;
  final confirmed = await showCupertinoDialog<bool>(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(l10n.deleteDeckTitle(deck.title)),
      content: Text(l10n.deleteDeckMessage(count)),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  final others = ref
      .read(libraryProvider)
      .decks
      .values
      .where((d) => d.id != deck.id && d.map == deck.map);
  ref.read(libraryProvider.notifier).deleteDeck(deck.id);
  context.go(others.isEmpty ? libraryLocation : mapLocation(deck.map));
}

typedef _DeckFields = ({String map, String submap, String title});

Future<_DeckFields?> _showDeckSheet(
  BuildContext context, {
  required _DeckFields initial,
  bool editing = false,
}) => showCupertinoSheet<_DeckFields>(
  context: context,
  scrollableBuilder: (context, controller) => _DeckForm(
    initial: initial,
    editing: editing,
    scrollController: controller,
  ),
);

class _DeckForm extends ConsumerStatefulWidget {
  const _DeckForm({
    required this.initial,
    required this.editing,
    required this.scrollController,
  });

  final _DeckFields initial;
  final bool editing;
  final ScrollController scrollController;

  @override
  ConsumerState<_DeckForm> createState() => _DeckFormState();
}

class _DeckFormState extends ConsumerState<_DeckForm> {
  late final _map = TextEditingController(text: widget.initial.map);
  late final _submap = TextEditingController(text: widget.initial.submap);
  late final _title = TextEditingController(text: widget.initial.title);
  final _submapFocus = FocusNode();
  final _titleFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    for (final c in [_map, _submap, _title]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_map, _submap, _title]) {
      c.dispose();
    }
    _submapFocus.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  bool get _valid =>
      [_map, _submap, _title].every((c) => c.text.trim().isNotEmpty);

  void _save() {
    if (!_valid) return;
    Navigator.pop<_DeckFields>(context, (
      map: _map.text.trim(),
      submap: _submap.text.trim(),
      title: _title.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final decks = ref.watch(libraryProvider.select((l) => l.decks)).values;
    final maps = mapsOf(decks);
    final submaps = submapsOf(_map.text.trim(), decks);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        middle: Text(widget.editing ? l10n.editDeck : l10n.newDeck),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _valid ? _save : null,
          child: Text(
            l10n.save,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          controller: widget.scrollController,
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            _Field(
              label: l10n.deckMap,
              placeholder: l10n.deckMapHint,
              controller: _map,
              autofocus: !widget.editing && _map.text.isEmpty,
              suggestions: maps,
              onSubmitted: (_) => _submapFocus.requestFocus(),
            ),
            _Field(
              label: l10n.deckSubmap,
              placeholder: l10n.deckSubmapHint,
              controller: _submap,
              focusNode: _submapFocus,
              autofocus: !widget.editing && _map.text.isNotEmpty,
              suggestions: submaps,
              onSubmitted: (_) => _titleFocus.requestFocus(),
            ),
            _Field(
              label: l10n.deckTitle,
              placeholder: l10n.deckTitleHint,
              controller: _title,
              focusNode: _titleFocus,
              suggestions: const [],
              onSubmitted: (_) => _save(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.placeholder,
    required this.controller,
    required this.suggestions,
    required this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
  });

  final String label;
  final String placeholder;
  final TextEditingController controller;
  final List<String> suggestions;
  final ValueChanged<String> onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final shown = suggestions
        .where((s) => s != controller.text.trim())
        .where(
          (s) => s.toLowerCase().contains(controller.text.trim().toLowerCase()),
        )
        .toList();
    return CupertinoListSection.insetGrouped(
      header: Text(label),
      footer: shown.isEmpty
          ? null
          : Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final s in shown)
                  CupertinoButton.tinted(
                    sizeStyle: CupertinoButtonSize.small,
                    onPressed: () {
                      controller.text = s;
                      onSubmitted(s);
                    },
                    child: Text(s),
                  ),
              ],
            ),
      children: [
        CupertinoTextField.borderless(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          placeholder: placeholder,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textInputAction: TextInputAction.next,
          onSubmitted: onSubmitted,
        ),
      ],
    );
  }
}
