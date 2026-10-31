import 'dart:convert';

import 'package:flashcards/domain/card_content.dart';
import 'package:flashcards/domain/flashcard.dart';
import 'package:flutter_test/flutter_test.dart';

/// Through a JSON string, as on disk.
CardContent roundTrip(CardContent content) => CardContent.fromJson(
  content.type,
  jsonDecode(jsonEncode(content.toJson())) as Map<String, Object?>,
);

void main() {
  group('JSON round-trip', () {
    final samples = <CardContent>[
      const VocabularyContent(
        language: VocabLanguage.latin,
        nlSingular: 'meisje',
        nlPlural: 'meisjes',
        targetSingular: 'puella',
        targetPlural: 'puellae',
        gender: Gender.feminine,
        genitive: 'puellae',
      ),
      const VocabularyContent(
        language: VocabLanguage.german,
        nlSingular: 'huis',
        targetSingular: 'Haus',
        targetPlural: 'Häuser',
        article: 'das',
      ),
      const BegripContent(
        term: 'fotosynthese',
        explanation: 'Omzetting van **licht** in *chemische* energie',
        subject: 'biologie',
      ),
      ParadigmContent(
        heading: 'amare – liefhebben',
        rows: const [
          ParadigmRow(label: 'praes.', value: 'amō'),
          ParadigmRow(label: 'perf.', value: 'amāvī'),
          ParadigmRow(value: 'amātum'),
        ],
      ),
      const SentenceContent(
        nl: 'De mens is een redelijk wezen.',
        target: 'ὁ ἄνθρωπος ζῷον λογικόν ἐστιν.',
        grammarPoint: 'ἐστιν',
      ),
      const HistoryContent(
        date: '1568–1648',
        event: 'Tachtigjarige Oorlog',
        context: 'Opstand tegen Spanje',
      ),
    ];

    for (final content in samples) {
      test(content.type.name, () => expect(roundTrip(content), content));
    }

    test('blank optional fields are left out', () {
      const content = VocabularyContent(
        language: VocabLanguage.english,
        nlSingular: 'hond',
        targetSingular: 'dog',
      );
      expect(content.toJson(), {
        'language': 'en',
        'nlSingular': 'hond',
        'targetSingular': 'dog',
      });
      expect(roundTrip(content), content);
    });

    test('a card with its metadata', () {
      final card = Flashcard(
        uuid: '7b0c8a0e-0000-4000-8000-000000000001',
        seq: 17,
        content: const HistoryContent(date: '1815', event: 'Waterloo'),
        tags: const ['toets 3'],
        createdAt: DateTime.utc(2026, 10, 30, 12),
        updatedAt: DateTime.utc(2026, 10, 31, 9, 30),
      );
      final json =
          jsonDecode(jsonEncode(card.toJson())) as Map<String, Object?>;
      expect(json['type'], 'history');
      expect(Flashcard.fromJson(json), card);
    });

    test('unknown codes are rejected', () {
      expect(
        () => VocabularyContent.fromJson({'language': 'xx'}),
        throwsFormatException,
      );
      expect(
        () => VocabularyContent.fromJson({'language': 'la', 'gender': 'x'}),
        throwsFormatException,
      );
    });
  });

  group('validators', () {
    test('complete cards have no issues', () {
      expect(
        const VocabularyContent(
          language: VocabLanguage.french,
          nlSingular: 'boek',
          targetSingular: 'livre',
        ).validate(),
        isEmpty,
      );
      expect(
        const BegripContent(term: 't', explanation: 'e').validate(),
        isEmpty,
      );
      expect(
        ParadigmContent(
          heading: 'h',
          rows: const [ParadigmRow(value: 'v')],
        ).validate(),
        isEmpty,
      );
      expect(const SentenceContent(nl: 'a', target: 'b').validate(), isEmpty);
      expect(
        const HistoryContent(date: '1815', event: 'e').validate(),
        isEmpty,
      );
    });

    test('vocabulary needs both singulars', () {
      expect(
        const VocabularyContent(language: VocabLanguage.latin).validate(),
        const [
          ValidationIssue('nlSingular'),
          ValidationIssue('targetSingular'),
        ],
      );
    });

    test('begrip needs term and explanation, not subject', () {
      expect(const BegripContent(subject: 'bio').validate(), const [
        ValidationIssue('term'),
        ValidationIssue('explanation'),
      ]);
    });

    test('paradigm needs a heading and a value in every row', () {
      expect(ParadigmContent().validate(), const [
        ValidationIssue('heading'),
        ValidationIssue('rows'),
      ]);
      expect(
        ParadigmContent(
          heading: 'h',
          rows: const [
            ParadigmRow(label: 'a', value: 'x'),
            ParadigmRow(label: 'b'),
          ],
        ).validate(),
        const [ValidationIssue('value', row: 1)],
      );
    });

    test('sentence needs both sentences', () {
      expect(const SentenceContent(grammarPoint: 'g').validate(), const [
        ValidationIssue('nl'),
        ValidationIssue('target'),
      ]);
    });

    test('history needs date and event', () {
      expect(const HistoryContent(context: 'c').validate(), const [
        ValidationIssue('date'),
        ValidationIssue('event'),
      ]);
    });

    test('whitespace counts as blank', () {
      expect(const SentenceContent(nl: '  ', target: '\n').validate(), const [
        ValidationIssue('nl'),
        ValidationIssue('target'),
      ]);
    });
  });
}
