import '../../domain/card_content.dart';
import 'face.dart';

/// Front: the meaning or infinitive. Back: the forms table.
CardFaces paradigmFaces(ParadigmContent c) => CardFaces(
  CardFace([TextBlock(c.heading, TextRole.headline)]),
  CardFace([FormsBlock(c.rows)]),
);
