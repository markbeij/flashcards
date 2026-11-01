import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/store/library_notifier.dart';
import '../domain/card_content.dart';
import 'entry/card_editor_screen.dart';
import 'entry/entry_screen.dart';
import 'library/deck_page.dart';
import 'library/library_pages.dart';
import 'locations.dart';
import 'print/print_preview_screen.dart';
import 'print/print_setup_screen.dart';
import 'settings/settings_screen.dart';
import 'shell/adaptive_shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// One route set for both layouts. The Library pages live in the shell;
/// entry, print and settings cover the whole window.
GoRouter buildRouter(ProviderContainer container) {
  final library = container.read(libraryProvider);
  final lastDeck = library.decks[library.settings.lastDeckId];

  String? libraryRedirect(BuildContext context, GoRouterState state) {
    final decks = container.read(libraryProvider).decks;
    final (:map, :deckId) = parseLibraryLocation(state.uri);
    if (deckId != null) {
      final deck = decks[deckId];
      if (deck == null) return libraryLocation;
      // The deck moved to another map.
      if (deck.map != map) return deckLocation(deck);
      return null;
    }
    if (map != null && !decks.values.any((d) => d.map == map)) {
      return libraryLocation;
    }
    return null;
  }

  String? deckRedirect(BuildContext context, GoRouterState state) =>
      container
          .read(libraryProvider)
          .decks
          .containsKey(state.pathParameters['deckId'])
      ? null
      : libraryLocation;

  Page<void> fullScreen(GoRouterState state, Widget child) =>
      CupertinoPage(key: state.pageKey, fullscreenDialog: true, child: child);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: lastDeck == null
        ? libraryLocation
        : deckLocation(lastDeck),
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) =>
            AdaptiveShell(location: state.uri, child: child),
        routes: [
          GoRoute(
            path: libraryLocation,
            redirect: libraryRedirect,
            builder: (context, state) => const LibraryRootPage(),
            routes: [
              GoRoute(
                path: 'map/:map',
                builder: (context, state) =>
                    MapPage(map: state.pathParameters['map']!),
                routes: [
                  GoRoute(
                    path: 'deck/:deckId',
                    builder: (context, state) =>
                        DeckPage(deckId: state.pathParameters['deckId']!),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/add/:deckId',
        parentNavigatorKey: rootNavigatorKey,
        redirect: deckRedirect,
        pageBuilder: (context, state) => fullScreen(
          state,
          EntryScreen(
            deckId: state.pathParameters['deckId']!,
            type: switch (state.uri.queryParameters['type']) {
              null => null,
              final name => CardType.values.asNameMap()[name],
            },
            likeCardId: state.uri.queryParameters['like'],
          ),
        ),
      ),
      GoRoute(
        path: '/edit/:deckId/:cardId',
        parentNavigatorKey: rootNavigatorKey,
        redirect: deckRedirect,
        pageBuilder: (context, state) => fullScreen(
          state,
          CardEditorScreen(
            deckId: state.pathParameters['deckId']!,
            cardId: state.pathParameters['cardId']!,
          ),
        ),
      ),
      GoRoute(
        path: '/print',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => fullScreen(
          state,
          PrintSetupScreen(deckId: state.uri.queryParameters['deck']),
        ),
        routes: [
          GoRoute(
            path: 'preview',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const PrintPreviewScreen(),
          ),
        ],
      ),
      GoRoute(
        path: settingsLocation,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
