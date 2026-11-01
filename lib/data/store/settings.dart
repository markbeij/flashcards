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

/// The "What" of the last print job: the ticked decks.
class PrintSelection {
  PrintSelection({List<String> deckIds = const []})
    : deckIds = List.unmodifiable(deckIds);

  factory PrintSelection.fromJson(Map<String, Object?> json) => PrintSelection(
    deckIds: [for (final id in json['deckIds'] as List<Object?>) id as String],
  );

  final List<String> deckIds;

  Map<String, Object?> toJson() => {'deckIds': deckIds};

  @override
  bool operator ==(Object other) =>
      other is PrintSelection && listEquals(other.deckIds, deckIds);

  @override
  int get hashCode => Object.hashAll(deckIds);
}

class Settings {
  const Settings({
    this.calibration,
    this.lastDeckId,
    this.lastCardId,
    this.lastPrintSelection,
    this.cuttingGuideShown = false,
  });

  factory Settings.fromJson(Map<String, Object?> json) => Settings(
    calibration: switch (json['calibration']) {
      null => null,
      final Object c => Calibration.fromJson(c as Map<String, Object?>),
    },
    lastDeckId: json['lastDeckId'] as String?,
    lastCardId: json['lastCardId'] as String?,
    lastPrintSelection: switch (json['lastPrintSelection']) {
      null => null,
      final Object s => PrintSelection.fromJson(s as Map<String, Object?>),
    },
    cuttingGuideShown: json['cuttingGuideShown'] as bool? ?? false,
  );

  /// null until the user has calibrated; the print screen then shows a banner.
  final Calibration? calibration;
  final String? lastDeckId;
  final String? lastCardId;
  final PrintSelection? lastPrintSelection;
  final bool cuttingGuideShown;

  Settings copyWith({
    Object? calibration = _unchanged,
    Object? lastDeckId = _unchanged,
    Object? lastCardId = _unchanged,
    Object? lastPrintSelection = _unchanged,
    bool? cuttingGuideShown,
  }) => Settings(
    calibration: calibration == _unchanged
        ? this.calibration
        : calibration as Calibration?,
    lastDeckId: lastDeckId == _unchanged
        ? this.lastDeckId
        : lastDeckId as String?,
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
    if (lastDeckId != null) 'lastDeckId': lastDeckId,
    if (lastCardId != null) 'lastCardId': lastCardId,
    if (lastPrintSelection != null)
      'lastPrintSelection': lastPrintSelection!.toJson(),
    'cuttingGuideShown': cuttingGuideShown,
  };

  @override
  bool operator ==(Object other) =>
      other is Settings &&
      other.calibration == calibration &&
      other.lastDeckId == lastDeckId &&
      other.lastCardId == lastCardId &&
      other.lastPrintSelection == lastPrintSelection &&
      other.cuttingGuideShown == cuttingGuideShown;

  @override
  int get hashCode => Object.hash(
    calibration,
    lastDeckId,
    lastCardId,
    lastPrintSelection,
    cuttingGuideShown,
  );
}

const _unchanged = Object();
