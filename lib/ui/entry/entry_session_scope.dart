import 'package:flutter/cupertino.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'entry_session.dart';
import 'entry_widgets.dart';
import 'vocabulary_grid.dart';

class BoldIntent extends Intent {
  const BoldIntent();
}

class ItalicIntent extends Intent {
  const ItalicIntent();
}

class DoneIntent extends Intent {
  const DoneIntent();
}

/// Shared by the entry screens: owns the session's lifetime, announces
/// saved cards, and handles Cmd-B/I, Esc and the row-engine keys.
mixin EntrySessionScope<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  late final ProviderContainer _container;
  late final EntrySession session;

  /// The session key, see [addSessionKey] and [editSessionKey].
  String get sessionKey;

  /// Called once when the session is new.
  void startSession(EntrySession session);

  @override
  void initState() {
    super.initState();
    _container = ProviderScope.containerOf(context, listen: false);
    session = _container.read(entrySessionProvider(sessionKey));
    if (!session.started) startSession(session);
    session.onAdded = _announce;
    WidgetsBinding.instance.addPostFrameCallback((_) => focusFirstField());
  }

  @override
  void dispose() {
    session.onAdded = null;
    final key = sessionKey;
    // The fields are gone by now; the session's controllers can go too.
    Future.microtask(() => _container.invalidate(entrySessionProvider(key)));
    super.dispose();
  }

  void focusFirstField() {
    final row = session.active;
    if (row.isBlank) row.focus(session.gridOrder(row).first).requestFocus();
  }

  void _announce(int seq) {
    if (!mounted) return;
    SemanticsService.sendAnnouncement(
      View.of(context),
      AppLocalizations.of(context).cardSaved(seq),
      Directionality.of(context),
    );
  }

  /// Saves what can be saved and closes the screen. Incomplete drafts are
  /// only dropped after a confirmation.
  Future<void> done() async {
    session.commitAll();
    final incomplete = session.incompleteRows.length;
    if (incomplete > 0) {
      final l10n = AppLocalizations.of(context);
      final discard = await showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(l10n.incompleteTitle(incomplete)),
          content: Text(l10n.incompleteMessage),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.keepEditing),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.discard),
            ),
          ],
        ),
      );
      if (discard != true) return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  /// Wraps the screen's body with the keyboard shortcuts.
  Widget withEntryKeys(Widget child) => Shortcuts(
    shortcuts: const {
      SingleActivator(LogicalKeyboardKey.keyB, meta: true): BoldIntent(),
      SingleActivator(LogicalKeyboardKey.keyI, meta: true): ItalicIntent(),
      SingleActivator(LogicalKeyboardKey.escape): DoneIntent(),
    },
    child: Actions(
      actions: {
        BoldIntent: CallbackAction<BoldIntent>(
          onInvoke: (_) => applyMarkup(session, bold: true),
        ),
        ItalicIntent: CallbackAction<ItalicIntent>(
          onInvoke: (_) => applyMarkup(session, bold: false),
        ),
        DoneIntent: CallbackAction<DoneIntent>(onInvoke: (_) => done()),
      },
      child: RowEngineKeys(session: session, child: child),
    ),
  );
}
