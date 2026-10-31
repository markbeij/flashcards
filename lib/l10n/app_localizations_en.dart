// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flashcards';

  @override
  String get libraryEmpty => 'Make a folder per subject, for example Latin.';

  @override
  String get newFolder => 'New folder';

  @override
  String get printTest => 'Print test';

  @override
  String get testSheetFrontTitle =>
      'Test sheet · front · double-sided, flip on long edge, scale 100%';

  @override
  String get testSheetBackTitle => 'Test sheet · back';
}
