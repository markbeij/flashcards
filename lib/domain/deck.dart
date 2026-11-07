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

/// The decks whose title, map or submap contains [query], in Library order
/// (map, submap, title). Case and accents are ignored. A blank query finds
/// nothing: the caller shows the whole Library instead.
List<Deck> searchDecks(String query, Iterable<Deck> decks) {
  final needle = foldForSearch(query.trim());
  if (needle.isEmpty) return const [];
  return [
    for (final deck in decks)
      if ([
        deck.title,
        deck.map,
        deck.submap,
      ].any((text) => foldForSearch(text).contains(needle)))
        deck,
  ]..sort((a, b) {
    final byMap = compareNatural(a.map, b.map);
    if (byMap != 0) return byMap;
    final bySubmap = compareNatural(a.submap, b.submap);
    return bySubmap != 0 ? bySubmap : compareNatural(a.title, b.title);
  });
}

/// Lower case without accents, so "Cafe" finds "Café" and "amo" finds
/// "amō". Covers the Latin letters of the school languages.
String foldForSearch(String text) {
  final out = StringBuffer();
  for (final rune in text.toLowerCase().runes) {
    out.write(_unaccented[rune] ?? String.fromCharCode(rune));
  }
  return out.toString();
}

final _unaccented = <int, String>{
  for (final MapEntry(:key, :value) in const {
    'a': 'àáâãäåāăą',
    'c': 'çćĉċč',
    'e': 'èéêëēĕėęě',
    'i': 'ìíîïĩīĭįı',
    'n': 'ñńņň',
    'o': 'òóôõöøōŏő',
    'u': 'ùúûüũūŭůűų',
    's': 'śŝşš',
    'y': 'ýÿ',
    'z': 'źżž',
  }.entries)
    for (final rune in value.runes) rune: key,
};

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
