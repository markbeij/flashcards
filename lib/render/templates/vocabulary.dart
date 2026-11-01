import '../../domain/card_content.dart';
import 'face.dart';

/// Front: the Dutch word. Back: the word in the target language with its
/// article, genitive, gender and plural.
///
/// The printed labels are content in the card's language (e.g. German
/// "Pl."), not in the app's UI language.
CardFaces vocabularyFaces(VocabularyContent c) => CardFaces(
  CardFace([
    TextBlock(c.nlSingular, TextRole.headline),
    if (_has(c.nlPlural)) TextBlock('mv. ${c.nlPlural}', TextRole.subhead),
  ]),
  CardFace([
    TextBlock(_withArticle(c.article, c.targetSingular), TextRole.headline),
    if (_has(_grammarLine(c))) TextBlock(_grammarLine(c), TextRole.subhead),
    if (_has(c.targetPlural))
      TextBlock(_pluralLine(c), TextRole.subhead),
  ]),
);

bool _has(String s) => s.trim().isNotEmpty;

bool _isElided(String article) {
  final a = article.trim();
  return a.endsWith("'") || a.endsWith('’');
}

/// "la" + "maison", "l'" + "élève".
String _withArticle(String article, String word) {
  final a = article.trim();
  if (a.isEmpty) return word;
  return _isElided(a) ? '$a$word' : '$a $word';
}

/// Latin: "puellae f." German/French: the gender only when no article
/// shows it already (an elided "l'" doesn't).
String _grammarLine(VocabularyContent c) {
  final gender = c.gender == null ? '' : '${c.gender!.code}.';
  final parts = switch (c.language) {
    VocabLanguage.latin => [c.genitive.trim(), gender],
    _ => [if (!_has(c.article) || _isElided(c.article)) gender],
  };
  return parts.where(_has).join(' ');
}

String _pluralLine(VocabularyContent c) => switch (c.language) {
  // The German plural article is always "die".
  VocabLanguage.german =>
    c.targetPlural.trimLeft().startsWith('die ')
        ? c.targetPlural
        : 'die ${c.targetPlural}',
  _ => 'pl. ${c.targetPlural}',
};
