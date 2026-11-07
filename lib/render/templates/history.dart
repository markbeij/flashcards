import '../../domain/card_content.dart';
import 'face.dart';

/// Front: the date, range or era. Back: the event and the context.
CardFaces historyFaces(HistoryContent c) => CardFaces(
  CardFace([TextBlock(c.date, TextRole.headline)]),
  CardFace([
    TextBlock(c.event, TextRole.headline),
    if (c.context.trim().isNotEmpty) TextBlock(c.context, TextRole.body),
  ]),
);
