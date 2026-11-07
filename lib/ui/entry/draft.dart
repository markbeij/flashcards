import 'package:flutter/widgets.dart';

import '../../domain/card_content.dart';
import '../../render/grid.dart' show Side;
import 'markup_controller.dart';

/// A field of a card in the entry screens. The names match the JSON keys,
/// so validation issues map onto them.
enum DraftField {
  nlSingular,
  nlPlural,
  targetSingular,
  targetPlural,
  article,
  gender,
  genitive,
  term,
  explanation,
  heading,
  nl,
  target,
  grammarPoint,
  date,
  event,
  context;

  /// Fields where bold/italic matters show the markup styled.
  bool get styled => switch (this) {
    explanation || nl || target || context => true,
    _ => false,
  };

  static DraftField? byName(String name) => values.asNameMap()[name];

  /// The side of the card the field is printed on.
  Side get side => switch (this) {
    nlSingular || nlPlural || term || heading || nl || date => Side.front,
    _ => Side.back,
  };
}

/// The vocabulary grid's columns for a language.
List<DraftField> vocabularyColumns(VocabLanguage language) =>
    switch (language) {
      VocabLanguage.latin => const [
        DraftField.nlSingular,
        DraftField.targetSingular,
        DraftField.genitive,
        DraftField.gender,
      ],
      VocabLanguage.german => const [
        DraftField.nlSingular,
        DraftField.article,
        DraftField.targetSingular,
        DraftField.targetPlural,
      ],
      VocabLanguage.french => const [
        DraftField.nlSingular,
        DraftField.article,
        DraftField.targetSingular,
      ],
      VocabLanguage.english => const [
        DraftField.nlSingular,
        DraftField.targetSingular,
      ],
    };

/// Every vocabulary field that applies to a language, in form order.
List<DraftField> vocabularyFields(VocabLanguage language) => switch (language) {
  VocabLanguage.latin => const [
    DraftField.nlSingular,
    DraftField.nlPlural,
    DraftField.targetSingular,
    DraftField.targetPlural,
    DraftField.genitive,
    DraftField.gender,
  ],
  VocabLanguage.german || VocabLanguage.french => const [
    DraftField.nlSingular,
    DraftField.nlPlural,
    DraftField.article,
    DraftField.targetSingular,
    DraftField.targetPlural,
    DraftField.gender,
  ],
  VocabLanguage.english => const [
    DraftField.nlSingular,
    DraftField.nlPlural,
    DraftField.targetSingular,
    DraftField.targetPlural,
  ],
};

/// The fields behind a grid row's disclosure arrow.
List<DraftField> vocabularyExtras(VocabLanguage language) => [
  for (final f in vocabularyFields(language))
    if (!vocabularyColumns(language).contains(f)) f,
];

/// The form's fields for a card type (without paradigm rows).
List<DraftField> formFields(CardType type, VocabLanguage language) =>
    switch (type) {
      CardType.vocabulary => vocabularyFields(language),
      CardType.begrip => const [DraftField.term, DraftField.explanation],
      CardType.paradigm => const [DraftField.heading],
      CardType.sentence => const [
        DraftField.nl,
        DraftField.target,
        DraftField.grammarPoint,
      ],
      CardType.history => const [
        DraftField.date,
        DraftField.event,
        DraftField.context,
      ],
    };

/// A label/value line of a paradigm being edited.
class FormRowDraft {
  FormRowDraft({String label = '', String value = ''})
    : label = TextEditingController(text: label),
      value = TextEditingController(text: value);

  final Key key = UniqueKey();
  final TextEditingController label;
  final TextEditingController value;
  final labelFocus = FocusNode(debugLabel: 'paradigm label');
  final valueFocus = FocusNode(debugLabel: 'paradigm value');

  void dispose() {
    label.dispose();
    value.dispose();
    labelFocus.dispose();
    valueFocus.dispose();
  }
}

/// A card being entered or edited: one controller and one focus node per
/// field. It becomes a card once it is valid and committed.
class DraftCard {
  DraftCard({required this.type, required this.language});

  /// A draft holding [content], e.g. an existing card.
  factory DraftCard.of(CardContent content, {String? cardId, int? seq}) {
    final language = content is VocabularyContent
        ? content.language
        : VocabLanguage.latin;
    return DraftCard(type: content.type, language: language)
      ..cardId = cardId
      ..seq = seq
      ..load(content);
  }

  /// A new draft like [content]: the same type and language; a paradigm
  /// keeps its labels with empty values.
  factory DraftCard.like(CardContent content) => DraftCard.of(content)..clear();

  final Key key = UniqueKey();
  final CardType type;
  VocabLanguage language;

  /// Set once the draft is saved as a card.
  String? cardId;
  int? seq;

  /// The grid row shows its extra fields.
  bool expanded = false;

  /// The last commit failed because a required field is blank.
  bool incomplete = false;

  final _controllers = <DraftField, TextEditingController>{};
  final _focusNodes = <DraftField, FocusNode>{};
  final List<FormRowDraft> forms = [];

  /// Called when any field gains focus or changes; set by the session.
  void Function(DraftCard draft, DraftField? field)? onFocus;
  VoidCallback? onEdit;

  TextEditingController controller(DraftField field) =>
      _controllers.putIfAbsent(field, () {
        final c = field.styled
            ? MarkupEditingController()
            : TextEditingController();
        return c..addListener(() => onEdit?.call());
      });

  FocusNode focus(DraftField field) => _focusNodes.putIfAbsent(field, () {
    final node = FocusNode(debugLabel: field.name);
    node.addListener(() {
      if (node.hasFocus) onFocus?.call(this, field);
    });
    return node;
  });

  /// The controller of the field that [node] belongs to, if any.
  TextEditingController? controllerFor(FocusNode node) {
    for (final MapEntry(:key, :value) in _focusNodes.entries) {
      if (identical(value, node)) return _controllers[key];
    }
    for (final line in forms) {
      if (identical(line.labelFocus, node)) return line.label;
      if (identical(line.valueFocus, node)) return line.value;
    }
    return null;
  }

  /// The field that [node] belongs to, if any.
  DraftField? fieldFor(FocusNode node) {
    for (final MapEntry(:key, :value) in _focusNodes.entries) {
      if (identical(value, node)) return key;
    }
    return null;
  }

  FormRowDraft addFormRow({String label = ''}) {
    final row = FormRowDraft(label: label);
    row.label.addListener(() => onEdit?.call());
    row.value.addListener(() => onEdit?.call());
    for (final node in [row.labelFocus, row.valueFocus]) {
      node.addListener(() {
        if (node.hasFocus) onFocus?.call(this, null);
      });
    }
    forms.add(row);
    return row;
  }

  String _text(DraftField field) => _controllers[field]?.text.trim() ?? '';

  CardContent toContent() => switch (type) {
    CardType.vocabulary => VocabularyContent(
      language: language,
      nlSingular: _text(DraftField.nlSingular),
      nlPlural: _text(DraftField.nlPlural),
      targetSingular: _text(DraftField.targetSingular),
      targetPlural: _text(DraftField.targetPlural),
      article: _text(DraftField.article),
      gender: Gender.values
          .where((g) => g.code == _text(DraftField.gender).toLowerCase())
          .firstOrNull,
      genitive: _text(DraftField.genitive),
    ),
    CardType.begrip => BegripContent(
      term: _text(DraftField.term),
      explanation: _text(DraftField.explanation),
    ),
    CardType.paradigm => ParadigmContent(
      heading: _text(DraftField.heading),
      rows: [
        for (final row in forms)
          if (row.label.text.trim().isNotEmpty ||
              row.value.text.trim().isNotEmpty)
            ParadigmRow(
              label: row.label.text.trim(),
              value: row.value.text.trim(),
            ),
      ],
    ),
    CardType.sentence => SentenceContent(
      nl: _text(DraftField.nl),
      target: _text(DraftField.target),
      grammarPoint: _text(DraftField.grammarPoint),
    ),
    CardType.history => HistoryContent(
      date: _text(DraftField.date),
      event: _text(DraftField.event),
      context: _text(DraftField.context),
    ),
  };

  /// Nothing typed yet (paradigm labels alone don't count).
  bool get isBlank =>
      _controllers.values.every((c) => c.text.trim().isEmpty) &&
      forms.every((r) => r.value.text.trim().isEmpty);

  void load(CardContent content) {
    void set(DraftField field, String value) => controller(field).text = value;
    switch (content) {
      case VocabularyContent():
        language = content.language;
        set(DraftField.nlSingular, content.nlSingular);
        set(DraftField.nlPlural, content.nlPlural);
        set(DraftField.targetSingular, content.targetSingular);
        set(DraftField.targetPlural, content.targetPlural);
        set(DraftField.article, content.article);
        set(DraftField.gender, content.gender?.code ?? '');
        set(DraftField.genitive, content.genitive);
      case BegripContent():
        set(DraftField.term, content.term);
        set(DraftField.explanation, content.explanation);
      case ParadigmContent():
        set(DraftField.heading, content.heading);
        for (final row in forms) {
          row.dispose();
        }
        forms.clear();
        for (final row in content.rows) {
          addFormRow(label: row.label).value.text = row.value;
        }
      case SentenceContent():
        set(DraftField.nl, content.nl);
        set(DraftField.target, content.target);
        set(DraftField.grammarPoint, content.grammarPoint);
      case HistoryContent():
        set(DraftField.date, content.date);
        set(DraftField.event, content.event);
        set(DraftField.context, content.context);
    }
  }

  /// Empties the fields for the next card; paradigm labels stay.
  void clear() {
    for (final c in _controllers.values) {
      c.clear();
    }
    for (final row in forms) {
      row.value.clear();
    }
    cardId = null;
    seq = null;
    expanded = false;
    incomplete = false;
  }

  /// The field to focus for the first blank required field.
  DraftField? firstMissing() {
    for (final issue in toContent().validate()) {
      final field = DraftField.byName(issue.field);
      if (field != null) return field;
    }
    return null;
  }

  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final n in _focusNodes.values) {
      n.dispose();
    }
    for (final row in forms) {
      row.dispose();
    }
  }
}
