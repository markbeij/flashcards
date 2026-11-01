import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show MenuAnchor, MenuItemButton;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/store/library_notifier.dart';
import '../../domain/card_content.dart';
import '../../l10n/app_localizations.dart';
import '../common/card_type_labels.dart';
import '../shell/adaptive_shell.dart';
import 'card_form.dart';
import 'card_preview.dart';
import 'draft.dart';
import 'entry_session.dart';
import 'entry_session_scope.dart';
import 'entry_widgets.dart';
import 'rapid_card.dart';
import 'vocabulary_grid.dart';

/// Width of the preview pane beside the grid or form.
const previewPaneWidth = 320.0;

/// Height the grid needs above the keyboard before the preview may show.
const _minHeightForPreview = 420.0;

/// "Add cards": opens in the deck's last card type and language. The title
/// menu switches the type. Vocabulary uses the grid in a wide window and the
/// rapid card in a narrow one; the other types use the form.
class EntryScreen extends ConsumerStatefulWidget {
  const EntryScreen({
    super.key,
    required this.deckId,
    this.type,
    this.likeCardId,
  });

  final String deckId;
  final CardType? type;

  /// "New card like this".
  final String? likeCardId;

  @override
  ConsumerState<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends ConsumerState<EntryScreen>
    with EntrySessionScope {
  @override
  String get sessionKey => addSessionKey(widget.deckId);

  @override
  void startSession(EntrySession session) {
    final library = ref.read(libraryProvider);
    final deck = library.decks[widget.deckId];
    final like = widget.likeCardId == null
        ? null
        : library.cardsIn(widget.deckId)[widget.likeCardId];
    session.start(
      type: widget.type ?? deck?.lastCardType ?? CardType.vocabulary,
      language: deck?.lastLanguage ?? VocabLanguage.latin,
      first: like == null ? null : DraftCard.like(like.content),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.sizeOf(context);
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final twoColumns = isTwoColumn(size);
    final showPreview =
        twoColumns && size.height - keyboard >= _minHeightForPreview;

    return withEntryKeys(
      CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          automaticallyImplyLeading: false,
          middle: _TypeMenu(session: session),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: done,
            child: Text(
              l10n.done,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: session,
            builder: (context, _) {
              final vocabulary = session.type == CardType.vocabulary;
              final Widget editor;
              if (vocabulary && twoColumns) {
                editor = VocabularyGrid(session: session);
              } else if (vocabulary) {
                editor = RapidCard(session: session);
              } else {
                editor = _RichEntry(
                  session: session,
                  showPreviewInline: !twoColumns,
                );
              }
              return Column(
                children: [
                  MarkupToolbar(
                    session: session,
                    trailing: Text(
                      l10n.cardsAdded(session.added),
                      style: TextStyle(
                        color: CupertinoColors.secondaryLabel.resolveFrom(
                          context,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: editor),
                        if (showPreview) ...[
                          Container(
                            width: 0.5,
                            color: CupertinoColors.separator.resolveFrom(
                              context,
                            ),
                          ),
                          SizedBox(
                            width: previewPaneWidth,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: SessionPreview(session: session),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// The form for begrip, paradigm, sentence and history in "Add cards". On a
/// narrow screen the preview is behind a Fields/Preview control.
class _RichEntry extends StatefulWidget {
  const _RichEntry({required this.session, required this.showPreviewInline});

  final EntrySession session;
  final bool showPreviewInline;

  @override
  State<_RichEntry> createState() => _RichEntryState();
}

enum _Pane { fields, preview }

class _RichEntryState extends State<_RichEntry> {
  _Pane _pane = _Pane.fields;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = widget.session;
    final form = CardForm(
      key: ValueKey(session.active.key),
      session: session,
      draft: session.active,
      adding: true,
      footer: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Align(
          alignment: Alignment.centerRight,
          child: TextFieldTapRegion(
            child: CupertinoButton.filled(
              onPressed: () => session.finishRow(session.active),
              child: Text(l10n.nextCard),
            ),
          ),
        ),
      ),
    );
    if (!widget.showPreviewInline) return form;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<_Pane>(
              groupValue: _pane,
              children: {
                _Pane.fields: Text(l10n.fields),
                _Pane.preview: Text(l10n.preview),
              },
              onValueChanged: (pane) => setState(() => _pane = pane!),
            ),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _pane.index,
            children: [
              form,
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SessionPreview(session: session),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The title: the card type (and language), with a menu to switch.
class _TypeMenu extends StatelessWidget {
  const _TypeMenu({required this.session});

  final EntrySession session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final title = session.type == CardType.vocabulary
            ? '${session.type.label(l10n)} · ${session.language.label(l10n)}'
            : session.type.label(l10n);
        return MenuAnchor(
          menuChildren: [
            for (final language in VocabLanguage.values)
              MenuItemButton(
                leadingIcon: Icon(CardType.vocabulary.icon),
                onPressed: () =>
                    session.switchTo(CardType.vocabulary, language),
                child: Text(
                  '${CardType.vocabulary.label(l10n)} · ${language.label(l10n)}',
                ),
              ),
            for (final type in CardType.values.skip(1))
              MenuItemButton(
                leadingIcon: Icon(type.icon),
                onPressed: () => session.switchTo(type, session.language),
                child: Text(type.label(l10n)),
              ),
          ],
          builder: (context, controller, _) => CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () =>
                controller.isOpen ? controller.close() : controller.open(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .navTitleTextStyle,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(CupertinoIcons.chevron_down, size: 14),
              ],
            ),
          ),
        );
      },
    );
  }
}
