import '../../domain/flashcard.dart';
import '../../domain/folder.dart';
import 'settings.dart';

/// The whole library in memory. Immutable: every change makes a new
/// [Library] that shares the unchanged maps, so a changed file can be found
/// by identity.
class Library {
  Library({
    Map<String, Folder> folders = const {},
    Map<String, Map<String, Flashcard>> cards = const {},
    Settings settings = const Settings(),
  }) : this._(_freezeFolders(folders), _freezeCards(cards), settings);

  const Library._(this.folders, this.cards, this.settings);

  /// By folder id.
  final Map<String, Folder> folders;

  /// Folder id → card uuid → card. A folder without cards has no entry.
  /// The inner maps must be unmodifiable.
  final Map<String, Map<String, Flashcard>> cards;

  final Settings settings;

  Map<String, Flashcard> cardsIn(String folderId) =>
      cards[folderId] ?? const {};

  /// Maps that are not passed keep their identity.
  Library copyWith({
    Map<String, Folder>? folders,
    Map<String, Map<String, Flashcard>>? cards,
    Settings? settings,
  }) => Library._(
    folders == null ? this.folders : _freezeFolders(folders),
    cards == null ? this.cards : _freezeCards(cards),
    settings ?? this.settings,
  );
}

Map<String, Folder> _freezeFolders(Map<String, Folder> folders) =>
    Map.unmodifiable(folders);

Map<String, Map<String, Flashcard>> _freezeCards(
  Map<String, Map<String, Flashcard>> cards,
) => Map.unmodifiable({
  for (final MapEntry(:key, :value) in cards.entries)
    if (value.isNotEmpty) key: value,
});
