import '../../domain/card_content.dart';
import '../../domain/markup.dart';
import '../../render/templates/templates.dart';

/// The main line of each side as plain text, for a card row or a screen
/// reader. Taken from the card templates, so it matches the printed card.
({String front, String back}) cardSummary(CardContent content) {
  final faces = facesOf(content);
  return (front: _firstLine(faces.front), back: _firstLine(faces.back));
}

/// Everything on both sides as plain text, e.g. for the preview's label.
String cardDescription(CardContent content) {
  final faces = facesOf(content);
  return [faces.front, faces.back].map(_allText).join(' / ');
}

String _firstLine(CardFace face) =>
    face.blocks.isEmpty ? '' : _blockText(face.blocks.first);

String _allText(CardFace face) =>
    face.blocks.map(_blockText).where((t) => t.isNotEmpty).join(', ');

String _blockText(Block block) => switch (block) {
  TextBlock(:final markup) => plainText(markup).trim(),
  FormsBlock(:final rows) => [
    for (final row in rows)
      if (plainText(row.value).trim().isNotEmpty) plainText(row.value).trim(),
  ].join(', '),
};
