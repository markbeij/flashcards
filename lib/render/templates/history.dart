import '../../domain/card_content.dart';
import 'face.dart';

/// Front: the event. Back: the date, range or era, and the context.
CardFaces historyFaces(HistoryContent c) => CardFaces(
  CardFace([TextBlock(c.event, TextRole.headline)]),
  CardFace([
    TextBlock(c.date, TextRole.headline),
    if (c.context.trim().isNotEmpty) TextBlock(c.context, TextRole.body),
  ]),
);
