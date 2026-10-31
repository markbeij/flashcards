import 'card_content.dart';

/// The 8 folder colour swatches. The actual colours live in the UI and
/// renderer.
enum FolderColor { red, orange, yellow, green, teal, blue, purple, pink }

class Folder {
  const Folder({
    required this.id,
    this.parentId,
    required this.name,
    this.color,
    this.shortLabel,
    this.lastCardType,
    this.lastLanguage,
  });

  factory Folder.fromJson(Map<String, Object?> json) => Folder(
    id: json['id'] as String,
    parentId: json['parentId'] as String?,
    name: json['name'] as String,
    color: switch (json['color']) {
      null => null,
      final Object name => FolderColor.values.byName(name as String),
    },
    shortLabel: json['shortLabel'] as String?,
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

  /// null for a folder at the library root.
  final String? parentId;
  final String name;

  /// Own colour; see [colorSource] for the inherited one.
  final FolderColor? color;

  /// Used instead of [name] in the card footer, e.g. "H3".
  final String? shortLabel;

  /// What "Add cards" opens with.
  final CardType? lastCardType;
  final VocabLanguage? lastLanguage;

  /// Changes everything but the parent; use [movedTo] for that.
  Folder copyWith({
    String? name,
    Object? color = _unchanged,
    Object? shortLabel = _unchanged,
    Object? lastCardType = _unchanged,
    Object? lastLanguage = _unchanged,
  }) => Folder(
    id: id,
    parentId: parentId,
    name: name ?? this.name,
    color: color == _unchanged ? this.color : color as FolderColor?,
    shortLabel: shortLabel == _unchanged
        ? this.shortLabel
        : shortLabel as String?,
    lastCardType: lastCardType == _unchanged
        ? this.lastCardType
        : lastCardType as CardType?,
    lastLanguage: lastLanguage == _unchanged
        ? this.lastLanguage
        : lastLanguage as VocabLanguage?,
  );

  /// A copy at the library root, or under [parentId].
  Folder movedTo(String? parentId) => Folder(
    id: id,
    parentId: parentId,
    name: name,
    color: color,
    shortLabel: shortLabel,
    lastCardType: lastCardType,
    lastLanguage: lastLanguage,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    if (parentId != null) 'parentId': parentId,
    'name': name,
    if (color != null) 'color': color!.name,
    if (shortLabel != null) 'shortLabel': shortLabel,
    if (lastCardType != null) 'lastCardType': lastCardType!.name,
    if (lastLanguage != null) 'lastLanguage': lastLanguage!.code,
  };

  @override
  bool operator ==(Object other) =>
      other is Folder &&
      other.id == id &&
      other.parentId == parentId &&
      other.name == name &&
      other.color == color &&
      other.shortLabel == shortLabel &&
      other.lastCardType == lastCardType &&
      other.lastLanguage == lastLanguage;

  @override
  int get hashCode => Object.hash(
    id,
    parentId,
    name,
    color,
    shortLabel,
    lastCardType,
    lastLanguage,
  );
}

const _unchanged = Object();

/// The nearest folder, starting with [folderId] itself, that has its own
/// colour; null if none has. The UI shows it as "inherited from …".
Folder? colorSource(String folderId, Map<String, Folder> folders) {
  for (final folder in ancestry(folderId, folders)) {
    if (folder.color != null) return folder;
  }
  return null;
}

/// [folderId] and then its parents up to the root.
Iterable<Folder> ancestry(String folderId, Map<String, Folder> folders) sync* {
  final seen = <String>{};
  String? id = folderId;
  while (id != null && seen.add(id)) {
    final folder = folders[id];
    if (folder == null) return;
    yield folder;
    id = folder.parentId;
  }
}

/// The subfolders of [parentId] (null for the root), in natural order.
List<Folder> childrenOf(String? parentId, Map<String, Folder> folders) => [
  for (final folder in folders.values)
    if (folder.parentId == parentId) folder,
]..sort((a, b) => compareNatural(a.name, b.name));

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
