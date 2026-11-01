import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../l10n/app_localizations.dart';

OverlayEntry? _current;
Timer? _timer;

/// Shows [message] with an Undo button near the bottom of the screen for a
/// few seconds. A new toast replaces the previous one.
void showUndoToast(
  BuildContext context, {
  required String message,
  required VoidCallback onUndo,
}) {
  _dismiss();
  final overlay = Overlay.of(context, rootOverlay: true);
  final l10n = AppLocalizations.of(context);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => Positioned(
      left: 16,
      right: 16,
      bottom: MediaQuery.paddingOf(context).bottom + 64,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Semantics(
            liveRegion: true,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: CupertinoColors.label.resolveFrom(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                          color: CupertinoColors.systemBackground.resolveFrom(
                            context,
                          ),
                        ),
                      ),
                    ),
                    CupertinoButton(
                      minimumSize: const Size(44, 44),
                      onPressed: () {
                        _dismiss();
                        onUndo();
                      },
                      child: Text(
                        l10n.undo,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.systemYellow.resolveFrom(
                            context,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  _current = entry;
  overlay.insert(entry);
  _timer = Timer(const Duration(seconds: 5), _dismiss);
}

void _dismiss() {
  _timer?.cancel();
  _timer = null;
  _current?.remove();
  _current = null;
}
