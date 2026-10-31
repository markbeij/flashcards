import 'package:flutter/foundation.dart';

/// Back-side print offset, read off the calibration test sheet.
class Calibration {
  const Calibration({this.backDxMm = 0, this.backDyMm = 0});

  factory Calibration.fromJson(Map<String, Object?> json) => Calibration(
    backDxMm: (json['backDxMm'] as num).toDouble(),
    backDyMm: (json['backDyMm'] as num).toDouble(),
  );

  final double backDxMm;
  final double backDyMm;

  Map<String, Object?> toJson() => {'backDxMm': backDxMm, 'backDyMm': backDyMm};

  @override
  bool operator ==(Object other) =>
      other is Calibration &&
      other.backDxMm == backDxMm &&
      other.backDyMm == backDyMm;

  @override
  int get hashCode => Object.hash(backDxMm, backDyMm);
}

/// The "What" of the last print job: ticked folders and tag chips.
class PrintSelection {
  PrintSelection({
    List<String> folderIds = const [],
    List<String> tags = const [],
  }) : folderIds = List.unmodifiable(folderIds),
       tags = List.unmodifiable(tags);

  factory PrintSelection.fromJson(Map<String, Object?> json) => PrintSelection(
    folderIds: [
      for (final id in json['folderIds'] as List<Object?>) id as String,
    ],
    tags: [for (final tag in json['tags'] as List<Object?>) tag as String],
  );

  final List<String> folderIds;
  final List<String> tags;

  Map<String, Object?> toJson() => {'folderIds': folderIds, 'tags': tags};

  @override
  bool operator ==(Object other) =>
      other is PrintSelection &&
      listEquals(other.folderIds, folderIds) &&
      listEquals(other.tags, tags);

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(folderIds), Object.hashAll(tags));
}

class Settings {
  const Settings({
    this.calibration,
    this.lastFolderId,
    this.lastCardId,
    this.lastPrintSelection,
    this.cuttingGuideShown = false,
  });

  factory Settings.fromJson(Map<String, Object?> json) => Settings(
    calibration: switch (json['calibration']) {
      null => null,
      final Object c => Calibration.fromJson(c as Map<String, Object?>),
    },
    lastFolderId: json['lastFolderId'] as String?,
    lastCardId: json['lastCardId'] as String?,
    lastPrintSelection: switch (json['lastPrintSelection']) {
      null => null,
      final Object s => PrintSelection.fromJson(s as Map<String, Object?>),
    },
    cuttingGuideShown: json['cuttingGuideShown'] as bool? ?? false,
  );

  /// null until the user has calibrated; the print screen then shows a banner.
  final Calibration? calibration;
  final String? lastFolderId;
  final String? lastCardId;
  final PrintSelection? lastPrintSelection;
  final bool cuttingGuideShown;

  Settings copyWith({
    Object? calibration = _unchanged,
    Object? lastFolderId = _unchanged,
    Object? lastCardId = _unchanged,
    Object? lastPrintSelection = _unchanged,
    bool? cuttingGuideShown,
  }) => Settings(
    calibration: calibration == _unchanged
        ? this.calibration
        : calibration as Calibration?,
    lastFolderId: lastFolderId == _unchanged
        ? this.lastFolderId
        : lastFolderId as String?,
    lastCardId: lastCardId == _unchanged
        ? this.lastCardId
        : lastCardId as String?,
    lastPrintSelection: lastPrintSelection == _unchanged
        ? this.lastPrintSelection
        : lastPrintSelection as PrintSelection?,
    cuttingGuideShown: cuttingGuideShown ?? this.cuttingGuideShown,
  );

  Map<String, Object?> toJson() => {
    if (calibration != null) 'calibration': calibration!.toJson(),
    if (lastFolderId != null) 'lastFolderId': lastFolderId,
    if (lastCardId != null) 'lastCardId': lastCardId,
    if (lastPrintSelection != null)
      'lastPrintSelection': lastPrintSelection!.toJson(),
    'cuttingGuideShown': cuttingGuideShown,
  };

  @override
  bool operator ==(Object other) =>
      other is Settings &&
      other.calibration == calibration &&
      other.lastFolderId == lastFolderId &&
      other.lastCardId == lastCardId &&
      other.lastPrintSelection == lastPrintSelection &&
      other.cuttingGuideShown == cuttingGuideShown;

  @override
  int get hashCode => Object.hash(
    calibration,
    lastFolderId,
    lastCardId,
    lastPrintSelection,
    cuttingGuideShown,
  );
}

const _unchanged = Object();
