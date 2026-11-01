import '../../domain/card_content.dart';

/// How a piece of text is set on the card. The styles live in
/// `card_frame.dart`.
enum TextRole {
  /// The word, term or heading the card is about.
  headline,

  /// A whole sentence.
  sentence,

  /// A line under the headline: plural, genitive, gender.
  subhead,

  /// Running text, e.g. an explanation.
  body,

  /// A small aside, e.g. a grammar point.
  note,
}

/// One piece of a card face, top to bottom.
sealed class Block {
  const Block();
}

/// Text that may hold inline markup.
class TextBlock extends Block {
  const TextBlock(this.markup, this.role);

  final String markup;
  final TextRole role;
}

/// The label/value table of a paradigm card.
class FormsBlock extends Block {
  const FormsBlock(this.rows);

  final List<ParadigmRow> rows;
}

/// What one side of a card shows.
class CardFace {
  const CardFace(this.blocks);

  final List<Block> blocks;
}

/// Both sides of a card, before the print direction is applied.
class CardFaces {
  const CardFaces(this.front, this.back);

  final CardFace front;
  final CardFace back;

  /// With [swap], the back becomes the front.
  CardFaces oriented({required bool swap}) =>
      swap ? CardFaces(back, front) : this;
}
