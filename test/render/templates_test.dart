import 'package:flashcards/domain/card_content.dart';
import 'package:flashcards/render/templates/templates.dart';
import 'package:flutter_test/flutter_test.dart';

import 'samples.dart';

List<String> texts(CardFace face) => [
  for (final block in face.blocks)
    if (block is TextBlock) block.markup,
];

void main() {
  test('Latin: genitive and gender under the word', () {
    final faces = facesOf(
      const VocabularyContent(
        language: VocabLanguage.latin,
        nlSingular: 'meisje',
        targetSingular: 'puella',
        genitive: 'puellae',
        gender: Gender.feminine,
      ),
    );
    expect(texts(faces.front), ['meisje']);
    expect(texts(faces.back), ['puella', 'puellae f.']);
  });

  test('German: article before the word, plural with "die"', () {
    final faces = facesOf(
      const VocabularyContent(
        language: VocabLanguage.german,
        nlSingular: 'meisje',
        article: 'das',
        targetSingular: 'Mädchen',
        targetPlural: 'Mädchen',
        gender: Gender.neuter,
      ),
    );
    expect(texts(faces.back), ['das Mädchen', 'die Mädchen']);
  });

  test("French: an elided article joins the word and shows the gender", () {
    final faces = facesOf(
      const VocabularyContent(
        language: VocabLanguage.french,
        nlSingular: 'leerling',
        article: "l'",
        targetSingular: 'élève',
        gender: Gender.masculine,
      ),
    );
    expect(texts(faces.back), ["l'élève", 'm.']);
  });

  test('blank optional fields are left out', () {
    final faces = facesOf(
      const SentenceContent(nl: 'Ik loop.', target: 'Ambulo.'),
    );
    expect(texts(faces.back), ['Ambulo.']);
  });

  test('each card type has one fixed front', () {
    CardFaces facesFor(int sample) => facesOf(sampleContents[sample]);
    // Vocabulary and sentence: Dutch.
    expect(texts(facesFor(0).front), ['meisje', 'mv. meisjes']);
    expect(texts(facesFor(6).front), ['Het meisje houdt van de zeeman.']);
    // Begrip: the term. Paradigm: the meaning/infinitive.
    expect(texts(facesFor(4).front), ['Fotosynthese']);
    expect(texts(facesFor(5).front), ['amare – liefhebben']);
    // History: the date; the event is on the back.
    expect(texts(facesFor(7).front), ['1568–1648']);
    expect(texts(facesFor(7).back).first, 'Tachtigjarige Oorlog');
  });
}
