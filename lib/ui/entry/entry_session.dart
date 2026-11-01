import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/store/library_notifier.dart';
import '../../domain/card_content.dart';
import 'draft.dart';

/// What a commit did.
enum CommitResult { blank, incomplete, added, updated }

/// An editing session: the drafts of one entry or editor screen, with their
/// controllers and focus nodes. It lives in Riverpod above the layout
/// switch, so a resize between grid and rapid card loses nothing.
///
/// Drafts are committed to the store when a row is finished or loses focus,
/// not on every keystroke.
class EntrySession extends ChangeNotifier {
  EntrySession(this._ref, {required this.deckId});

  final Ref _ref;
  final String deckId;

  CardType type = CardType.vocabulary;
  VocabLanguage language = VocabLanguage.latin;

  /// The drafts, oldest first. The last one is the active draft where a new
  /// card is typed; the others are cards made in this session.
  final List<DraftCard> rows = [];

  /// The draft that has (or last had) focus; the preview shows it.
  DraftCard? current;

  /// The field that has (or last had) focus; the B/I toolbar acts on it.
  DraftField? currentField;

  /// Bumps on every edit, for the preview's debounce.
  final edits = ValueNotifier<int>(0);

  /// Cards added in this session.
  int added = 0;

  /// Called with the card number after a new card is saved, e.g. to
  /// announce it.
  void Function(int seq)? onAdded;

  bool get started => rows.isNotEmpty;
  DraftCard get active => rows.last;

  /// Starts with [first], or an empty draft of [type]/[language].
  void start({
    required CardType type,
    required VocabLanguage language,
    DraftCard? first,
  }) {
    this.type = first?.type ?? type;
    this.language = first?.language ?? language;
    _add(first ?? DraftCard(type: this.type, language: this.language));
    current = active;
  }

  /// Switches the type or language for new cards. Saved and blank drafts
  /// are put away; incomplete ones stay so nothing typed is lost.
  void switchTo(CardType type, VocabLanguage language) {
    if (type == this.type && language == this.language) return;
    commitAll();
    this.type = type;
    this.language = language;
    for (final row in [...rows]) {
      if (row.cardId != null || row.isBlank) {
        rows.remove(row);
        _disposeLater(row);
      }
    }
    _add(DraftCard(type: type, language: language));
    current = active;
    _rememberChoice();
    notifyListeners();
  }

  /// Saves [row] if it is complete. A blank row is left alone; an
  /// incomplete one is marked and kept as a draft.
  CommitResult commit(DraftCard row) {
    if (row.isBlank) {
      _setIncomplete(row, false);
      return CommitResult.blank;
    }
    final content = row.toContent();
    if (content.validate().isNotEmpty) {
      _setIncomplete(row, true);
      return CommitResult.incomplete;
    }
    _setIncomplete(row, false);
    final store = _ref.read(libraryProvider.notifier);
    final existing = row.cardId == null
        ? null
        : _ref.read(libraryProvider).cardsIn(deckId)[row.cardId];
    if (existing != null) {
      store.updateCard(deckId, existing.uuid, content);
      return CommitResult.updated;
    }
    final card = store.addCard(deckId, content);
    row
      ..cardId = card.uuid
      ..seq = card.seq;
    added++;
    _rememberChoice();
    onAdded?.call(card.seq);
    notifyListeners();
    return CommitResult.added;
  }

  void commitAll() {
    for (final row in rows) {
      commit(row);
    }
  }

  /// Drafts with typed content that can't be saved yet.
  List<DraftCard> get incompleteRows => [
    for (final row in rows)
      if (!row.isBlank && row.toContent().validate().isNotEmpty) row,
  ];

  /// Focus left [row]: save it. In the grid ([advance]), a saved active row
  /// gets a new empty row below it.
  void leaveRow(DraftCard row, {required bool advance}) {
    if (!rows.contains(row)) return;
    commit(row);
    if (advance && identical(row, active) && row.cardId != null) {
      _add(DraftCard(type: type, language: language));
      notifyListeners();
    }
  }

  /// The fields Return and Tab move through in a grid row.
  List<DraftField> gridOrder(DraftCard row) => row.type == CardType.vocabulary
      ? [
          ...vocabularyColumns(row.language),
          if (row.expanded) ...vocabularyExtras(row.language),
        ]
      : formFields(row.type, row.language);

  /// Return or Tab in [field] of [row]: the next field, or at the last
  /// field, save the row and start a new one. Focus moves synchronously, to
  /// a field that is already on screen, so the keyboard stays up.
  void next(DraftCard row, DraftField field) {
    final order = gridOrder(row);
    final i = order.indexOf(field);
    if (i >= 0 && i < order.length - 1) {
      row.focus(order[i + 1]).requestFocus();
      return;
    }
    finishRow(row);
  }

  /// Shift-Tab: the previous field, or the last field of the previous row.
  void previous(DraftCard row, DraftField field) {
    final order = gridOrder(row);
    final i = order.indexOf(field);
    if (i > 0) {
      row.focus(order[i - 1]).requestFocus();
      return;
    }
    final r = rows.indexOf(row);
    if (r > 0) {
      final before = rows[r - 1];
      before.focus(gridOrder(before).last).requestFocus();
    }
  }

  /// Saves [row] and moves on. The active row hands its card to a new row
  /// above it and is emptied, so focus stays in the same text field.
  void finishRow(DraftCard row) {
    final result = commit(row);
    if (result == CommitResult.incomplete) {
      final missing = row.firstMissing();
      if (missing != null) row.focus(missing).requestFocus();
      return;
    }
    if (!identical(row, active)) {
      final next = rows[rows.indexOf(row) + 1];
      next.focus(gridOrder(next).first).requestFocus();
      return;
    }
    if (result == CommitResult.blank) return;
    final saved = DraftCard.of(
      row.toContent(),
      cardId: row.cardId,
      seq: row.seq,
    );
    _wire(saved);
    rows.insert(rows.length - 1, saved);
    row.clear();
    current = row;
    row.focus(gridOrder(row).first).requestFocus();
    notifyListeners();
  }

  /// Adds a label/value line to a paradigm draft.
  FormRowDraft addFormRow(DraftCard row) {
    final line = row.addFormRow();
    notifyListeners();
    return line;
  }

  void removeFormRow(DraftCard row, FormRowDraft line) {
    row.forms.remove(line);
    _edited();
    notifyListeners();
    _disposeSoon(line.dispose);
  }

  /// Changes the language of an existing vocabulary card in the editor.
  void setLanguage(DraftCard row, VocabLanguage language) {
    if (row.language == language) return;
    row.language = language;
    commit(row);
    _edited();
    notifyListeners();
  }

  void toggleExpanded(DraftCard row) {
    row.expanded = !row.expanded;
    notifyListeners();
  }

  void _add(DraftCard row) {
    _wire(row);
    // A paradigm starts with one empty line.
    if (row.type == CardType.paradigm && row.forms.isEmpty) row.addFormRow();
    rows.add(row);
  }

  void _wire(DraftCard row) {
    row.onFocus = (draft, field) {
      if (identical(current, draft) && currentField == field) return;
      current = draft;
      currentField = field;
      notifyListeners();
    };
    row.onEdit = _edited;
  }

  void _edited() => edits.value++;

  void _setIncomplete(DraftCard row, bool value) {
    if (row.incomplete == value) return;
    row.incomplete = value;
    notifyListeners();
  }

  /// "Add cards" opens with this type and language next time.
  void _rememberChoice() {
    final deck = _ref.read(libraryProvider).decks[deckId];
    if (deck == null) return;
    final lastLanguage = type == CardType.vocabulary
        ? language
        : deck.lastLanguage;
    if (deck.lastCardType == type && deck.lastLanguage == lastLanguage) return;
    _ref
        .read(libraryProvider.notifier)
        .updateDeck(
          deck.copyWith(lastCardType: type, lastLanguage: lastLanguage),
        );
  }

  void _disposeLater(DraftCard row) => _disposeSoon(row.dispose);

  @override
  void dispose() {
    for (final row in rows) {
      row.dispose();
    }
    edits.dispose();
    super.dispose();
  }
}

/// Disposes a little later, when no widget uses the object anymore (e.g.
/// after a row's exit animation).
void _disposeSoon(VoidCallback dispose) =>
    Future<void>.delayed(const Duration(milliseconds: 500), dispose);

/// The session of a screen: `add:<deckId>` for "Add cards" or
/// `edit:<cardId>` for the card editor. Disposed when the screen closes.
final entrySessionProvider = Provider.family<EntrySession, String>((ref, key) {
  final deckId = key.split(':')[1];
  final session = EntrySession(ref, deckId: deckId);
  ref.onDispose(session.dispose);
  return session;
});

String addSessionKey(String deckId) => 'add:$deckId';
String editSessionKey(String deckId, String cardId) => 'edit:$deckId:$cardId';
