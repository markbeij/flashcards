// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Karteikarten';

  @override
  String get printTest => 'Drucktest';

  @override
  String get testSheetFrontTitle =>
      'Testblatt · Vorderseite · beidseitig, an langer Kante wenden, Skalierung 100 %';

  @override
  String get testSheetBackTitle => 'Testblatt · Rückseite';
}
