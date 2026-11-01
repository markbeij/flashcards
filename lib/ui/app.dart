import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../l10n/app_localizations.dart';
import 'print_test/print_test_screen.dart';

/// Root widget. Material for routing and behaviour, iOS look via
/// [TargetPlatform.iOS] and Cupertino widgets.
class FlashcardsApp extends StatelessWidget {
  const FlashcardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: ThemeData(platform: TargetPlatform.iOS, brightness: Brightness.light),
      darkTheme: ThemeData(platform: TargetPlatform.iOS, brightness: Brightness.dark),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // Cupertino screens have no Material ancestor that sets a text style, so
      // give every route the iOS body style.
      builder: (context, child) => DefaultTextStyle(
        style: CupertinoTheme.of(context).textTheme.textStyle,
        child: child!,
      ),
      home: const _LibraryPlaceholder(),
    );
  }
}

/// Temporary home until the library screen exists.
class _LibraryPlaceholder extends StatelessWidget {
  const _LibraryPlaceholder();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(l10n.appTitle)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const PrintTestScreen()),
              ),
              child: Text(l10n.printTest),
            ),
          ],
        ),
      ),
    );
  }
}
