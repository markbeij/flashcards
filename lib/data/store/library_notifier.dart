import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/card_content.dart';
import '../../domain/flashcard.dart';
import '../../domain/folder.dart';
import 'library.dart';
import 'library_files.dart';
import 'settings.dart';
import 'store_writer.dart';

/// The library as loaded at startup; overridden by [openLibrary].
final loadedLibraryProvider = Provider<Library>(
  (ref) => throw UnimplementedError('Use openLibrary() to load the library'),
);

final libraryProvider = NotifierProvider<LibraryNotifier, Library>(
  LibraryNotifier.new,
);

/// Loads the library from [root] (default: [libraryDirectory]) and returns a
/// container whose library changes are saved by a [StoreWriter].
Future<(ProviderContainer, StoreWriter)> openLibrary({Directory? root}) async {
  final files = LibraryFiles(root ?? await libraryDirectory());
  final library = await files.load();
  final writer = StoreWriter(files, library);
  final container = ProviderContainer(
    overrides: [loadedLibraryProvider.overrideWithValue(library)],
  );
  container.listen(libraryProvider, (_, next) => writer.changed(next));
  return (container, writer);
}

/// All changes to the library, including the rules that keep the files
/// consistent with each other.
class LibraryNotifier extends Notifier<Library> {
  static const _uuid = Uuid();

  @override
  Library build() => ref.watch(loadedLibraryProvider);

  // Folders

  Folder createFolder(String name, {String? parentId}) {
    if (parentId != null) _folder(parentId);
    final folder = Folder(id: _uuid.v4(), parentId: parentId, name: name);
    state = state.copyWith(folders: {...state.folders, folder.id: folder});
    return folder;
  }

  /// Replaces a folder's name, colour, short label or last entry choices.
  void updateFolder(Folder folder) {
    if (_folder(folder.id).parentId != folder.parentId) {
      throw ArgumentError('Use moveFolder to change the parent');
    }
    state = state.copyWith(folders: {...state.folders, folder.id: folder});
  }

  /// Moves a folder under [parentId], or to the root when it is null.
  void moveFolder(String folderId, String? parentId) {
    final folder = _folder(folderId);
    if (parentId != null) {
      _folder(parentId);
      if (ancestry(parentId, state.folders).any((f) => f.id == folderId)) {
        throw ArgumentError('A folder cannot move into itself');
      }
    }
    state = state.copyWith(
      folders: {...state.folders, folderId: folder.movedTo(parentId)},
    );
  }

  /// Deletes a folder, its subfolders and all their cards, and forgets them
  /// in the settings.
  void deleteFolder(String folderId) {
    _folder(folderId);
    final doomed = {
      for (final folder in state.folders.values)
        if (ancestry(folder.id, state.folders).any((f) => f.id == folderId))
          folder.id,
    };
    final doomedCards = {for (final id in doomed) ...state.cardsIn(id).keys};
    final settings = state.settings;
    final selection = settings.lastPrintSelection;
    final cleaned = settings.copyWith(
      lastFolderId: doomed.contains(settings.lastFolderId)
          ? null
          : settings.lastFolderId,
      lastCardId: doomedCards.contains(settings.lastCardId)
          ? null
          : settings.lastCardId,
      lastPrintSelection: selection == null
          ? null
          : PrintSelection(
              folderIds: [
                for (final id in selection.folderIds)
                  if (!doomed.contains(id)) id,
              ],
              tags: selection.tags,
            ),
    );
    state = state.copyWith(
      folders: {...state.folders}..removeWhere((id, _) => doomed.contains(id)),
      cards: {...state.cards}..removeWhere((id, _) => doomed.contains(id)),
      settings: cleaned == settings ? null : cleaned,
    );
  }

  // Cards

  Flashcard addCard(
    String folderId,
    CardContent content, {
    List<String> tags = const [],
  }) {
    _folder(folderId);
    final now = DateTime.now().toUtc();
    final card = Flashcard(
      uuid: _uuid.v4(),
      seq: nextSeq(state.cardsIn(folderId).values),
      content: content,
      tags: tags,
      createdAt: now,
      updatedAt: now,
    );
    _putCards({
      folderId: {...state.cardsIn(folderId), card.uuid: card},
    });
    return card;
  }

  void updateCard(
    String folderId,
    String uuid, {
    CardContent? content,
    List<String>? tags,
  }) {
    final card = _card(folderId, uuid);
    // Keep updatedAt for a commit that changes nothing, e.g. on focus loss.
    if ((content ?? card.content) == card.content &&
        listEquals(tags ?? card.tags, card.tags)) {
      return;
    }
    final updated = card.copyWith(
      content: content,
      tags: tags,
      updatedAt: DateTime.now().toUtc(),
    );
    _putCards({
      folderId: {...state.cardsIn(folderId), uuid: updated},
    });
  }

  void deleteCard(String folderId, String uuid) {
    _card(folderId, uuid);
    _putCards(
      {
        folderId: {...state.cardsIn(folderId)}..remove(uuid),
      },
      settings: state.settings.lastCardId == uuid
          ? state.settings.copyWith(lastCardId: null)
          : null,
    );
  }

  /// Moves a card to another folder, where it gets the next number (so it
  /// counts as changed). Both card files change in one state update, so the
  /// writer saves them in one queued job.
  void moveCard(String uuid, {required String from, required String to}) {
    final card = _card(from, uuid);
    _folder(to);
    if (from == to) return;
    final moved = card.copyWith(
      seq: nextSeq(state.cardsIn(to).values),
      updatedAt: DateTime.now().toUtc(),
    );
    _putCards({
      from: {...state.cardsIn(from)}..remove(uuid),
      to: {...state.cardsIn(to), uuid: moved},
    });
  }

  // Settings

  void updateSettings(Settings settings) {
    state = state.copyWith(settings: settings);
  }

  Folder _folder(String id) =>
      state.folders[id] ??
      (throw ArgumentError.value(id, 'folderId', 'No such folder'));

  Flashcard _card(String folderId, String uuid) =>
      state.cardsIn(folderId)[uuid] ??
      (throw ArgumentError.value(uuid, 'uuid', 'No such card in $folderId'));

  void _putCards(
    Map<String, Map<String, Flashcard>> changed, {
    Settings? settings,
  }) {
    state = state.copyWith(
      cards: {
        ...state.cards,
        for (final MapEntry(:key, :value) in changed.entries)
          key: Map.unmodifiable(value),
      },
      settings: settings,
    );
  }
}
