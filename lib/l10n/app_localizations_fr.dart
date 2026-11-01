// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Cartes mémoire';

  @override
  String get printTest => 'Test d\'impression';

  @override
  String get testSheetFrontTitle =>
      'Feuille de test · recto · recto verso, reliure bord long, échelle 100 %';

  @override
  String get testSheetBackTitle => 'Feuille de test · verso';
}
