// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Flitskaarten';

  @override
  String get libraryEmpty => 'Maak een map per vak, bijvoorbeeld Latijn.';

  @override
  String get newFolder => 'Nieuwe map';

  @override
  String get printTest => 'Printtest';

  @override
  String get testSheetFrontTitle =>
      'Testvel · voorkant · dubbelzijdig, omslaan langs de lange kant, schaal 100%';

  @override
  String get testSheetBackTitle => 'Testvel · achterkant';
}
