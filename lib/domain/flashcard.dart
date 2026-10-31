import 'package:flutter/foundation.dart';

import 'card_content.dart';

/// A card in a folder. The folder is implied by the card file it is stored in.
class Flashcard {
  Flashcard({
    required this.uuid,
    required this.seq,
    required this.content,
    List<String> tags = const [],
    required this.createdAt,
    required this.updatedAt,
  }) : tags = List.unmodifiable(tags);

  factory Flashcard.fromJson(Map<String, Object?> json) {
    final type = CardType.values.byName(json['type'] as String);
    return Flashcard(
      uuid: json['uuid'] as String,
      seq: json['seq'] as int,
      content: CardContent.fromJson(
        type,
        json['fields'] as Map<String, Object?>,
      ),
      tags: [for (final tag in json['tags'] as List<Object?>) tag as String],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  final String uuid;

  /// The `#n` printed on the card, fixed within its folder.
  final int seq;
  final CardContent content;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  CardType get type => content.type;

  Flashcard copyWith({
    int? seq,
    CardContent? content,
    List<String>? tags,
    DateTime? updatedAt,
  }) => Flashcard(
    uuid: uuid,
    seq: seq ?? this.seq,
    content: content ?? this.content,
    tags: tags ?? this.tags,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, Object?> toJson() => {
    'uuid': uuid,
    'seq': seq,
    'type': type.name,
    'fields': content.toJson(),
    'tags': tags,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      other is Flashcard &&
      other.uuid == uuid &&
      other.seq == seq &&
      other.content == content &&
      listEquals(other.tags, tags) &&
      other.createdAt.isAtSameMomentAs(createdAt) &&
      other.updatedAt.isAtSameMomentAs(updatedAt);

  @override
  int get hashCode => Object.hash(
    uuid,
    seq,
    content,
    Object.hashAll(tags),
    createdAt.microsecondsSinceEpoch,
    updatedAt.microsecondsSinceEpoch,
  );
}

/// The number for a new card in a folder: one more than the highest so far.
/// Gaps left by deleted cards stay.
int nextSeq(Iterable<Flashcard> cardsInFolder) =>
    cardsInFolder.fold(
      0,
      (highest, card) => card.seq > highest ? card.seq : highest,
    ) +
    1;
