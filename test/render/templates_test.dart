import 'package:flashcards/domain/card_content.dart';
import 'package:flashcards/render/templates/templates.dart';
import 'package:flutter_test/flutter_test.dart';

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

  test('swap exchanges the sides', () {
    final faces = facesOf(const BegripContent(term: 't', explanation: 'e'));
    final swapped = faces.oriented(swap: true);
    expect(texts(swapped.front), ['e']);
    expect(texts(swapped.back), ['t']);
  });
}
