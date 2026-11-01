import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/store/library_notifier.dart';
import '../../l10n/app_localizations.dart';
import '../common/card_type_labels.dart';
import '../shell/adaptive_shell.dart';
import 'card_form.dart';
import 'card_preview.dart';
import 'draft.dart';
import 'entry_session.dart';
import 'entry_session_scope.dart';
import 'entry_widgets.dart';

/// Edits one card in the form, with its preview beside it on a wide screen
/// and behind a Fields/Preview control on a narrow one. Changes are saved
/// when a field loses focus and on Done.
class CardEditorScreen extends ConsumerStatefulWidget {
  const CardEditorScreen({
    super.key,
    required this.deckId,
    required this.cardId,
  });

  final String deckId;
  final String cardId;

  @override
  ConsumerState<CardEditorScreen> createState() => _CardEditorScreenState();
}

enum _Pane { fields, preview }

class _CardEditorScreenState extends ConsumerState<CardEditorScreen>
    with EntrySessionScope {
  _Pane _pane = _Pane.fields;

  @override
  String get sessionKey => editSessionKey(widget.deckId, widget.cardId);

  @override
  void startSession(EntrySession session) {
    final card = ref
        .read(libraryProvider)
        .cardsIn(widget.deckId)[widget.cardId];
    if (card == null) return;
    session.start(
      type: card.type,
      language: session.language,
      first: DraftCard.of(card.content, cardId: card.uuid, seq: card.seq),
      editing: true,
    );
    // The card opens again at the next start.
    Future.microtask(() {
      final notifier = ref.read(libraryProvider.notifier);
      final settings = ref.read(libraryProvider).settings;
      notifier.updateSettings(
        settings.copyWith(lastDeckId: widget.deckId, lastCardId: card.uuid),
      );
    });
  }

  @override
  void focusFirstField() {
    // Editing an existing card: the keyboard comes up when a field is tapped.
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!session.started) {
      // The card was deleted.
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(),
        child: Center(child: Text(l10n.cardGone)),
      );
    }
    final draft = session.active;
    final twoColumns = isTwoColumn(MediaQuery.sizeOf(context));
    final form = CardForm(session: session, draft: draft);
    final preview = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SessionPreview(session: session),
    );

    return withEntryKeys(
      CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          automaticallyImplyLeading: false,
          middle: Text(
            draft.seq == null
                ? draft.type.label(l10n)
                : '${draft.type.label(l10n)} #${draft.seq}',
          ),
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
          child: Column(
            children: [
              MarkupToolbar(session: session),
              if (!twoColumns)
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
                child: twoColumns
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: form),
                          SizedBox(width: 320, child: preview),
                        ],
                      )
                    : IndexedStack(
                        index: _pane.index,
                        children: [form, preview],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
