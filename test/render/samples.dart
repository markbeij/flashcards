import 'package:flashcards/domain/card_content.dart';
import 'package:flashcards/domain/flashcard.dart';
import 'package:flashcards/render/sheet.dart';

final _at = DateTime.utc(2026, 11, 1);

Flashcard card(int seq, CardContent content) => Flashcard(
  uuid: 'card-$seq',
  seq: seq,
  content: content,
  createdAt: _at,
  updatedAt: _at,
);

/// One card of each type and language, as they are typically filled in.
final sampleContents = <CardContent>[
  const VocabularyContent(
    language: VocabLanguage.latin,
    nlSingular: 'meisje',
    nlPlural: 'meisjes',
    targetSingular: 'puella',
    genitive: 'puellae',
    gender: Gender.feminine,
  ),
  const VocabularyContent(
    language: VocabLanguage.german,
    nlSingular: 'meisje',
    article: 'das',
    targetSingular: 'Mädchen',
    targetPlural: 'Mädchen',
  ),
  const VocabularyContent(
    language: VocabLanguage.french,
    nlSingular: 'leerling',
    article: "l'",
    targetSingular: 'élève',
    gender: Gender.masculine,
  ),
  const VocabularyContent(
    language: VocabLanguage.english,
    nlSingular: 'kind',
    targetSingular: 'child',
    targetPlural: 'children',
  ),
  const BegripContent(
    term: 'Fotosynthese',
    explanation:
        'Omzetting van **licht**, water en CO₂ in *glucose* en zuurstof.',
  ),
  ParadigmContent(
    heading: 'amare – liefhebben',
    rows: const [
      ParadigmRow(label: 'praes.', value: 'amo'),
      ParadigmRow(label: 'inf.', value: 'amare'),
      ParadigmRow(label: 'perf.', value: 'amavi'),
      ParadigmRow(label: 'ppp', value: 'amatum'),
    ],
  ),
  const SentenceContent(
    nl: 'Het meisje houdt van de zeeman.',
    target: 'Puella nautam *amat*.',
    grammarPoint: 'accusativus als lijdend voorwerp',
  ),
  const HistoryContent(
    date: '1568–1648',
    event: 'Tachtigjarige Oorlog',
    context: 'Opstand van de Nederlanden tegen Spanje; eindigt met de **Vrede van Münster**.',
  ),
];

List<PrintCard> samplePrintCards() => [
  for (final (i, content) in sampleContents.indexed)
    PrintCard(card(i + 1, content), 'Woordjes H3'),
];
