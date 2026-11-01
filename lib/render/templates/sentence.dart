import '../../domain/card_content.dart';
import 'face.dart';

/// Front: the Dutch sentence. Back: the translation and the grammar point.
CardFaces sentenceFaces(SentenceContent c) => CardFaces(
  CardFace([TextBlock(c.nl, TextRole.sentence)]),
  CardFace([
    TextBlock(c.target, TextRole.sentence),
    if (c.grammarPoint.trim().isNotEmpty)
      TextBlock(c.grammarPoint, TextRole.note),
  ]),
);
