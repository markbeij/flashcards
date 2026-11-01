import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import 'library/deck_sheet.dart';
import 'locations.dart';
import 'router.dart';

/// Root widget. Material for routing and behaviour (iOS platform), Cupertino
/// widgets for what is visible. Dark mode follows the system.
class FlashcardsApp extends ConsumerStatefulWidget {
  const FlashcardsApp({super.key});

  @override
  ConsumerState<FlashcardsApp> createState() => _FlashcardsAppState();
}

class _FlashcardsAppState extends ConsumerState<FlashcardsApp> {
  late final GoRouter _router = buildRouter(
    ProviderScope.containerOf(context, listen: false),
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  static ThemeData _theme(Brightness brightness) => ThemeData(
    platform: TargetPlatform.iOS,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: CupertinoColors.systemBlue,
      brightness: brightness,
    ),
    cupertinoOverrideTheme: const CupertinoThemeData(
      primaryColor: CupertinoColors.systemBlue,
      scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
      // Cupertino screens have no Material ancestor that sets a text style,
      // so give every route the iOS body style.
      builder: (context, child) => DefaultTextStyle(
        style: CupertinoTheme.of(context).textTheme.textStyle,
        child: _AppShortcuts(router: _router, child: child!),
      ),
    );
  }
}

/// Cmd-N (add cards to the open deck), Shift-Cmd-N (new deck) and Cmd-P
/// (print), from the Library.
class _AppShortcuts extends ConsumerWidget {
  const _AppShortcuts({required this.router, required this.child});

  final GoRouter router;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Uri location() => router.routerDelegate.currentConfiguration.uri;
    bool inLibrary() {
      final first = location().pathSegments.firstOrNull;
      return first == null || first == 'map';
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, meta: true): () {
          final deckId = parseLibraryLocation(location()).deckId;
          if (inLibrary() && deckId != null) {
            router.push(addCardsLocation(deckId));
          }
        },
        const SingleActivator(
          LogicalKeyboardKey.keyN,
          meta: true,
          shift: true,
        ): () {
          final context = rootNavigatorKey.currentContext;
          if (inLibrary() && context != null) {
            newDeckFlow(
              context,
              ref,
              map: parseLibraryLocation(location()).map,
            );
          }
        },
        const SingleActivator(LogicalKeyboardKey.keyP, meta: true): () {
          if (inLibrary()) {
            router.push(
              printLocation(deckId: parseLibraryLocation(location()).deckId),
            );
          }
        },
      },
      child: child,
    );
  }
}
