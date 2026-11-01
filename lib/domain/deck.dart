import 'card_content.dart';

/// A deck of cards, filed under a map and a submap. Maps and submaps are
/// plain text on their decks: a map or submap exists as long as a deck uses
/// it.
class Deck {
  const Deck({
    required this.id,
    required this.map,
    required this.submap,
    required this.title,
    this.lastCardType,
    this.lastLanguage,
  });

  factory Deck.fromJson(Map<String, Object?> json) => Deck(
    id: json['id'] as String,
    map: json['map'] as String,
    submap: json['submap'] as String,
    title: json['title'] as String,
    lastCardType: switch (json['lastCardType']) {
      null => null,
      final Object name => CardType.values.byName(name as String),
    },
    lastLanguage: switch (json['lastLanguage']) {
      null => null,
      final Object code => VocabLanguage.fromCode(code as String),
    },
  );

  final String id;

  /// E.g. "VWO 4"; the domain doesn't know it is a school year.
  final String map;

  /// E.g. "Latijn"; the domain doesn't know it is a subject.
  final String submap;

  /// Printed in the card footer, e.g. "Woordjes H3".
  final String title;

  /// What "Add cards" opens with.
  final CardType? lastCardType;
  final VocabLanguage? lastLanguage;

  Deck copyWith({
    String? map,
    String? submap,
    String? title,
    Object? lastCardType = _unchanged,
    Object? lastLanguage = _unchanged,
  }) => Deck(
    id: id,
    map: map ?? this.map,
    submap: submap ?? this.submap,
    title: title ?? this.title,
    lastCardType: lastCardType == _unchanged
        ? this.lastCardType
        : lastCardType as CardType?,
    lastLanguage: lastLanguage == _unchanged
        ? this.lastLanguage
        : lastLanguage as VocabLanguage?,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'map': map,
    'submap': submap,
    'title': title,
    if (lastCardType != null) 'lastCardType': lastCardType!.name,
    if (lastLanguage != null) 'lastLanguage': lastLanguage!.code,
  };

  @override
  bool operator ==(Object other) =>
      other is Deck &&
      other.id == id &&
      other.map == map &&
      other.submap == submap &&
      other.title == title &&
      other.lastCardType == lastCardType &&
      other.lastLanguage == lastLanguage;

  @override
  int get hashCode =>
      Object.hash(id, map, submap, title, lastCardType, lastLanguage);
}

const _unchanged = Object();

/// The maps in use, in natural order.
List<String> mapsOf(Iterable<Deck> decks) =>
    {for (final deck in decks) deck.map}.toList()..sort(compareNatural);

/// The submaps in use in [map], in natural order.
List<String> submapsOf(String map, Iterable<Deck> decks) => {
  for (final deck in decks)
    if (deck.map == map) deck.submap,
}.toList()..sort(compareNatural);

/// The decks in [map] → [submap], in natural order of title.
List<Deck> decksIn(String map, String submap, Iterable<Deck> decks) => [
  for (final deck in decks)
    if (deck.map == map && deck.submap == submap) deck,
]..sort((a, b) => compareNatural(a.title, b.title));

/// Compares names so that numbers sort by value: "H2" < "H10", "§1" < "§2".
/// Case is ignored unless it is the only difference.
int compareNatural(String a, String b) {
  final byValue = _compareNatural(a.toLowerCase(), b.toLowerCase());
  return byValue != 0 ? byValue : a.compareTo(b);
}

final _chunk = RegExp(r'\d+|\D+');

int _compareNatural(String a, String b) {
  final chunksA = _chunk.allMatches(a).map((m) => m[0]!).toList();
  final chunksB = _chunk.allMatches(b).map((m) => m[0]!).toList();
  for (var i = 0; i < chunksA.length && i < chunksB.length; i++) {
    final x = chunksA[i];
    final y = chunksB[i];
    final result = _isDigits(x) && _isDigits(y)
        ? _compareDigits(x, y)
        : x.compareTo(y);
    if (result != 0) return result;
  }
  return chunksA.length.compareTo(chunksB.length);
}

bool _isDigits(String chunk) {
  final first = chunk.codeUnitAt(0);
  return first >= 0x30 && first <= 0x39;
}

/// Compares digit strings by value without parsing, so long numbers can't
/// overflow. Leading zeros: "02" sorts after "2".
int _compareDigits(String x, String y) {
  final a = x.replaceFirst(RegExp('^0+(?=.)'), '');
  final b = y.replaceFirst(RegExp('^0+(?=.)'), '');
  if (a.length != b.length) return a.length.compareTo(b.length);
  final byValue = a.compareTo(b);
  return byValue != 0 ? byValue : x.length.compareTo(y.length);
}
