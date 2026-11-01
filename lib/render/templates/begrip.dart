import '../../domain/card_content.dart';
import 'face.dart';

/// Front: the term. Back: the explanation.
CardFaces begripFaces(BegripContent c) => CardFaces(
  CardFace([TextBlock(c.term, TextRole.headline)]),
  CardFace([TextBlock(c.explanation, TextRole.body)]),
);
