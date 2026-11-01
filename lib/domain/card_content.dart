import 'package:flutter/foundation.dart';

import 'markup.dart';

enum CardType { vocabulary, begrip, paradigm, sentence, history }

/// Target language of a vocabulary card. It picks the grid columns and the
/// language of printed labels.
enum VocabLanguage {
  latin('la'),
  german('de'),
  french('fr'),
  english('en');

  const VocabLanguage(this.code);

  /// Stored in JSON.
  final String code;

  static VocabLanguage fromCode(String code) => values.firstWhere(
    (l) => l.code == code,
    orElse: () => throw FormatException('Unknown language "$code"'),
  );
}

/// Grammatical gender, typed as m/f/n in the vocabulary grid.
enum Gender {
  masculine('m'),
  feminine('f'),
  neuter('n');

  const Gender(this.code);

  /// Stored in JSON.
  final String code;

  static Gender fromCode(String code) => values.firstWhere(
    (g) => g.code == code,
    orElse: () => throw FormatException('Unknown gender "$code"'),
  );
}

/// A required field that is blank. [field] is the JSON key; [row] is set for
/// paradigm rows.
class ValidationIssue {
  const ValidationIssue(this.field, {this.row});

  final String field;
  final int? row;

  @override
  bool operator ==(Object other) =>
      other is ValidationIssue && other.field == field && other.row == row;

  @override
  int get hashCode => Object.hash(field, row);

  @override
  String toString() => 'ValidationIssue($field${row == null ? '' : '[$row]'})';
}

/// The structured fields of a card. Text fields may hold inline markup
/// (see `markup.dart`); an empty string means blank.
sealed class CardContent {
  const CardContent();

  CardType get type;

  /// The fields, with blank optional fields left out.
  Map<String, Object?> toJson();

  /// Blank required fields; empty when the card is complete.
  List<ValidationIssue> validate();

  static CardContent fromJson(CardType type, Map<String, Object?> json) =>
      switch (type) {
        CardType.vocabulary => VocabularyContent.fromJson(json),
        CardType.begrip => BegripContent.fromJson(json),
        CardType.paradigm => ParadigmContent.fromJson(json),
        CardType.sentence => SentenceContent.fromJson(json),
        CardType.history => HistoryContent.fromJson(json),
      };
}

class VocabularyContent extends CardContent {
  const VocabularyContent({
    required this.language,
    this.nlSingular = '',
    this.nlPlural = '',
    this.targetSingular = '',
    this.targetPlural = '',
    this.article = '',
    this.gender,
    this.genitive = '',
  });

  factory VocabularyContent.fromJson(Map<String, Object?> json) =>
      VocabularyContent(
        language: VocabLanguage.fromCode(json['language'] as String),
        nlSingular: _string(json, 'nlSingular'),
        nlPlural: _string(json, 'nlPlural'),
        targetSingular: _string(json, 'targetSingular'),
        targetPlural: _string(json, 'targetPlural'),
        article: _string(json, 'article'),
        gender: switch (json['gender']) {
          null => null,
          final Object code => Gender.fromCode(code as String),
        },
        genitive: _string(json, 'genitive'),
      );

  final VocabLanguage language;
  final String nlSingular;
  final String nlPlural;
  final String targetSingular;
  final String targetPlural;

  /// German or French article, e.g. "der", "la".
  final String article;
  final Gender? gender;

  /// Latin genitive.
  final String genitive;

  @override
  CardType get type => CardType.vocabulary;

  @override
  Map<String, Object?> toJson() => {
    'language': language.code,
    ..._omitBlank({
      'nlSingular': nlSingular,
      'nlPlural': nlPlural,
      'targetSingular': targetSingular,
      'targetPlural': targetPlural,
      'article': article,
    }),
    if (gender != null) 'gender': gender!.code,
    ..._omitBlank({'genitive': genitive}),
  };

  @override
  List<ValidationIssue> validate() => [
    if (_isBlank(nlSingular)) const ValidationIssue('nlSingular'),
    if (_isBlank(targetSingular)) const ValidationIssue('targetSingular'),
  ];

  @override
  bool operator ==(Object other) =>
      other is VocabularyContent &&
      other.language == language &&
      other.nlSingular == nlSingular &&
      other.nlPlural == nlPlural &&
      other.targetSingular == targetSingular &&
      other.targetPlural == targetPlural &&
      other.article == article &&
      other.gender == gender &&
      other.genitive == genitive;

  @override
  int get hashCode => Object.hash(
    language,
    nlSingular,
    nlPlural,
    targetSingular,
    targetPlural,
    article,
    gender,
    genitive,
  );
}

class BegripContent extends CardContent {
  const BegripContent({this.term = '', this.explanation = ''});

  factory BegripContent.fromJson(Map<String, Object?> json) => BegripContent(
    term: _string(json, 'term'),
    explanation: _string(json, 'explanation'),
  );

  final String term;
  final String explanation;

  @override
  CardType get type => CardType.begrip;

  @override
  Map<String, Object?> toJson() =>
      _omitBlank({'term': term, 'explanation': explanation});

  @override
  List<ValidationIssue> validate() => [
    if (_isBlank(term)) const ValidationIssue('term'),
    if (_isBlank(explanation)) const ValidationIssue('explanation'),
  ];

  @override
  bool operator ==(Object other) =>
      other is BegripContent &&
      other.term == term &&
      other.explanation == explanation;

  @override
  int get hashCode => Object.hash(term, explanation);
}

/// One line of a paradigm's forms table, e.g. "perf." → "amavi".
class ParadigmRow {
  const ParadigmRow({this.label = '', this.value = ''});

  factory ParadigmRow.fromJson(Map<String, Object?> json) =>
      ParadigmRow(label: _string(json, 'label'), value: _string(json, 'value'));

  /// Optional.
  final String label;
  final String value;

  Map<String, Object?> toJson() => _omitBlank({'label': label, 'value': value});

  @override
  bool operator ==(Object other) =>
      other is ParadigmRow && other.label == label && other.value == value;

  @override
  int get hashCode => Object.hash(label, value);
}

class ParadigmContent extends CardContent {
  ParadigmContent({this.heading = '', List<ParadigmRow> rows = const []})
    : rows = List.unmodifiable(rows);

  factory ParadigmContent.fromJson(Map<String, Object?> json) =>
      ParadigmContent(
        heading: _string(json, 'heading'),
        rows: [
          for (final row in (json['rows'] as List<Object?>?) ?? const [])
            ParadigmRow.fromJson(row as Map<String, Object?>),
        ],
      );

  /// The front: meaning or infinitive.
  final String heading;
  final List<ParadigmRow> rows;

  @override
  CardType get type => CardType.paradigm;

  @override
  Map<String, Object?> toJson() => {
    ..._omitBlank({'heading': heading}),
    'rows': [for (final row in rows) row.toJson()],
  };

  @override
  List<ValidationIssue> validate() => [
    if (_isBlank(heading)) const ValidationIssue('heading'),
    if (rows.isEmpty) const ValidationIssue('rows'),
    for (var i = 0; i < rows.length; i++)
      if (_isBlank(rows[i].value)) ValidationIssue('value', row: i),
  ];

  @override
  bool operator ==(Object other) =>
      other is ParadigmContent &&
      other.heading == heading &&
      listEquals(other.rows, rows);

  @override
  int get hashCode => Object.hash(heading, Object.hashAll(rows));
}

class SentenceContent extends CardContent {
  const SentenceContent({
    this.nl = '',
    this.target = '',
    this.grammarPoint = '',
  });

  factory SentenceContent.fromJson(Map<String, Object?> json) =>
      SentenceContent(
        nl: _string(json, 'nl'),
        target: _string(json, 'target'),
        grammarPoint: _string(json, 'grammarPoint'),
      );

  final String nl;
  final String target;

  /// Optional.
  final String grammarPoint;

  @override
  CardType get type => CardType.sentence;

  @override
  Map<String, Object?> toJson() =>
      _omitBlank({'nl': nl, 'target': target, 'grammarPoint': grammarPoint});

  @override
  List<ValidationIssue> validate() => [
    if (_isBlank(nl)) const ValidationIssue('nl'),
    if (_isBlank(target)) const ValidationIssue('target'),
  ];

  @override
  bool operator ==(Object other) =>
      other is SentenceContent &&
      other.nl == nl &&
      other.target == target &&
      other.grammarPoint == grammarPoint;

  @override
  int get hashCode => Object.hash(nl, target, grammarPoint);
}

class HistoryContent extends CardContent {
  const HistoryContent({this.date = '', this.event = '', this.context = ''});

  factory HistoryContent.fromJson(Map<String, Object?> json) => HistoryContent(
    date: _string(json, 'date'),
    event: _string(json, 'event'),
    context: _string(json, 'context'),
  );

  /// A date, range or era as typed, e.g. "1568–1648".
  final String date;
  final String event;

  /// Optional.
  final String context;

  @override
  CardType get type => CardType.history;

  @override
  Map<String, Object?> toJson() =>
      _omitBlank({'date': date, 'event': event, 'context': context});

  @override
  List<ValidationIssue> validate() => [
    if (_isBlank(date)) const ValidationIssue('date'),
    if (_isBlank(event)) const ValidationIssue('event'),
  ];

  @override
  bool operator ==(Object other) =>
      other is HistoryContent &&
      other.date == date &&
      other.event == event &&
      other.context == context;

  @override
  int get hashCode => Object.hash(date, event, context);
}

String _string(Map<String, Object?> json, String key) =>
    json[key] as String? ?? '';

Map<String, Object?> _omitBlank(Map<String, String> fields) => {
  for (final MapEntry(:key, :value) in fields.entries)
    if (value.isNotEmpty) key: value,
};

/// Blank once markup and whitespace are removed.
bool _isBlank(String field) => plainText(field).trim().isEmpty;
