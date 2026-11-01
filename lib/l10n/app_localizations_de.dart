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
  String get library => 'Bibliothek';

  @override
  String get settings => 'Einstellungen';

  @override
  String get print => 'Drucken';

  @override
  String get printEllipsis => 'Drucken…';

  @override
  String get newDeck => 'Neuer Stapel';

  @override
  String get addCards => 'Karten hinzufügen';

  @override
  String get chooseDeck => 'Wähle einen Stapel';

  @override
  String get libraryEmpty => 'Lege einen Stapel für deine Karten an.';

  @override
  String get libraryEmptyExample =>
      'Zum Beispiel: Ordner VWO 4, Unterordner Latein, Titel Vokabeln Kap. 3';

  @override
  String get deckMap => 'Ordner';

  @override
  String get deckMapHint => 'z. B. Schuljahr';

  @override
  String get deckSubmap => 'Unterordner';

  @override
  String get deckSubmapHint => 'z. B. Fach';

  @override
  String get deckTitle => 'Titel';

  @override
  String get deckTitleHint => 'z. B. Vokabeln Kap. 3';

  @override
  String get editDeck => 'Stapel bearbeiten';

  @override
  String get deleteDeck => 'Stapel löschen';

  @override
  String deleteDeckTitle(String title) {
    return '„$title“ löschen?';
  }

  @override
  String deleteDeckMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Der Stapel und seine $count Karten werden gelöscht.',
      one: 'Der Stapel und seine Karte werden gelöscht.',
      zero: 'Der Stapel ist leer.',
    );
    return '$_temp0';
  }

  @override
  String get deckActions => 'Stapelaktionen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Sichern';

  @override
  String get delete => 'Löschen';

  @override
  String get done => 'Fertig';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get select => 'Auswählen';

  @override
  String get undo => 'Widerrufen';

  @override
  String get moveTo => 'Bewegen nach…';

  @override
  String get newCardLikeThis => 'Neue Karte wie diese';

  @override
  String get moreActions => 'Weitere Aktionen';

  @override
  String deckCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Stapel',
      one: '1 Stapel',
    );
    return '$_temp0';
  }

  @override
  String cardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Karten',
      one: '1 Karte',
    );
    return '$_temp0';
  }

  @override
  String sheetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Blätter',
      one: '1 Blatt',
    );
    return '$_temp0';
  }

  @override
  String cardsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Karten hinzugefügt',
      one: '1 Karte hinzugefügt',
      zero: 'Noch keine Karten hinzugefügt',
    );
    return '$_temp0';
  }

  @override
  String cardsDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Karten gelöscht',
      one: 'Karte gelöscht',
    );
    return '$_temp0';
  }

  @override
  String cardSaved(int seq) {
    return 'Karte $seq gesichert';
  }

  @override
  String cardSemantics(int seq, String front, String back) {
    return 'Karte $seq: $front, $back';
  }

  @override
  String cardField(int seq, String field) {
    return 'Karte $seq, $field';
  }

  @override
  String newCardField(String field) {
    return 'Neue Karte, $field';
  }

  @override
  String get deckEmpty => 'Dieser Stapel ist leer.';

  @override
  String get deckEmptyExample =>
      'Wähle eine Kartenart; ein Stapel darf Arten mischen.';

  @override
  String get typeVocabulary => 'Vokabeln';

  @override
  String get typeBegrip => 'Begriff';

  @override
  String get typeParadigm => 'Paradigma';

  @override
  String get typeSentence => 'Satz';

  @override
  String get typeHistory => 'Geschichte';

  @override
  String get typeVocabularyExample => 'meisje → puella';

  @override
  String get typeBegripExample => 'Photosynthese → Erklärung';

  @override
  String get typeParadigmExample => 'amare → amo, amavi, amatum';

  @override
  String get typeSentenceExample => 'Ich gehe. → Ambulo.';

  @override
  String get typeHistoryExample => 'Friede von Münster → 1648';

  @override
  String get languageLatin => 'Latein';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageFrench => 'Französisch';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageDutch => 'Niederländisch';

  @override
  String get overflowShort => 'Passt nicht';

  @override
  String get overflowLong => 'Passt nicht auf die Karte – bitte kürzen.';

  @override
  String get bold => 'Fett';

  @override
  String get italic => 'Kursiv';

  @override
  String get fieldNlShort => 'NL';

  @override
  String get fieldNl => 'Niederländisches Wort';

  @override
  String get fieldNlPluralShort => 'NL Pl.';

  @override
  String get fieldNlPlural => 'Niederländischer Plural';

  @override
  String get fieldWordShort => 'Wort';

  @override
  String fieldTargetWord(String language) {
    return 'Wort ($language)';
  }

  @override
  String get fieldPluralShort => 'Plural';

  @override
  String fieldTargetPlural(String language) {
    return 'Plural ($language)';
  }

  @override
  String get fieldArticleShort => 'Art.';

  @override
  String get fieldArticle => 'Artikel';

  @override
  String get fieldGenderShort => 'm/f/n';

  @override
  String get fieldGender => 'Genus (m/f/n)';

  @override
  String get fieldGenitiveShort => 'Gen.';

  @override
  String get fieldGenitive => 'Genitiv';

  @override
  String get fieldTerm => 'Begriff';

  @override
  String get fieldExplanation => 'Erklärung';

  @override
  String get fieldHeading => 'Bedeutung oder Infinitiv';

  @override
  String get fieldForms => 'Formen';

  @override
  String get fieldFormLabel => 'Bezeichnung';

  @override
  String get fieldFormValue => 'Form';

  @override
  String formLabelSemantics(int row) {
    return 'Zeile $row, Bezeichnung';
  }

  @override
  String formValueSemantics(int row) {
    return 'Zeile $row, Form';
  }

  @override
  String get fieldSentenceNl => 'Niederländischer Satz';

  @override
  String get fieldSentenceTarget => 'Übersetzung';

  @override
  String get fieldGrammarPoint => 'Grammatikpunkt (optional)';

  @override
  String get fieldDate => 'Datum, Zeitraum oder Epoche';

  @override
  String get fieldEvent => 'Ereignis';

  @override
  String get fieldContext => 'Kontext (optional)';

  @override
  String get moreFields => 'Weitere Felder';

  @override
  String get fewerFields => 'Weniger Felder';

  @override
  String get rowIncomplete => 'Unvollständig, nicht gesichert';

  @override
  String get cardIncomplete =>
      'Fülle die Pflichtfelder aus, um die Karte zu sichern.';

  @override
  String get addRow => 'Zeile hinzufügen';

  @override
  String get removeRow => 'Zeile entfernen';

  @override
  String get nextCard => 'Weiter';

  @override
  String get showPreview => 'Vorschau zeigen';

  @override
  String get hidePreview => 'Vorschau ausblenden';

  @override
  String get fields => 'Felder';

  @override
  String get preview => 'Vorschau';

  @override
  String get previewEmpty => 'Noch nichts zu zeigen';

  @override
  String previewLabel(String content) {
    return 'Kartenvorschau: $content';
  }

  @override
  String incompleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Karten sind unvollständig',
      one: '1 Karte ist unvollständig',
    );
    return '$_temp0';
  }

  @override
  String get incompleteMessage => 'Sie werden nicht gesichert.';

  @override
  String get keepEditing => 'Weiter bearbeiten';

  @override
  String get discard => 'Verwerfen';

  @override
  String get cardGone => 'Diese Karte gibt es nicht mehr.';

  @override
  String get printWhat => 'Was';

  @override
  String get printNothing => 'Es gibt noch keine Stapel.';

  @override
  String get printDoesntFit => 'Passt nicht';

  @override
  String get printDoesntFitHint =>
      'Diese Karten werden übersprungen, außer du schaltest Überspringen aus.';

  @override
  String get fix => 'Korrigieren';

  @override
  String get skip => 'Überspringen';

  @override
  String get printDirection => 'Richtung';

  @override
  String frontShows(String side) {
    return 'Vorderseite: $side';
  }

  @override
  String backShows(String side) {
    return 'Rückseite: $side';
  }

  @override
  String get directionQuestion => 'Frage';

  @override
  String get directionAnswer => 'Antwort';

  @override
  String get swapSides => 'Vorder- und Rückseite tauschen';

  @override
  String get fronts => 'Vorderseiten';

  @override
  String get backs => 'Rückseiten';

  @override
  String get checklist => 'Im Druckdialog prüfen';

  @override
  String get checkDuplex => 'Beidseitig, wie ein Buch umblättern';

  @override
  String get checkA4 => 'A4';

  @override
  String get checkScale => 'Skalierung nicht ändern (100 %)';

  @override
  String get sharePdf => 'PDF teilen';

  @override
  String shareFile(String name) {
    return '$name teilen';
  }

  @override
  String get noDuplex => 'Mein Drucker kann nicht beidseitig drucken';

  @override
  String get manualStepFronts => '1. Drucke die Vorderseiten';

  @override
  String get manualStepTurn => '2. Drehe den Stapel so um';

  @override
  String get manualStepTurnHint =>
      'Lege die Blätter zurück ins Fach, an der langen Kante gewendet, die leere Seite zur Druckseite.';

  @override
  String get manualStepBacks => '3. Drucke die Rückseiten';

  @override
  String get frontsFileName => 'vorderseiten';

  @override
  String get backsFileName => 'rueckseiten';

  @override
  String get pdfFileName => 'karteikarten';

  @override
  String get howToCut => 'So schneidest du';

  @override
  String get cutEdges => 'Schneide die Ränder an den Markierungen ab.';

  @override
  String get cutColumns => 'Schneide das Blatt in zwei Spalten.';

  @override
  String get cutRows => 'Schneide jede Spalte in vier Karten.';

  @override
  String get notCalibrated =>
      'Dein Drucker ist noch nicht kalibriert: Die Rückseiten können leicht verschoben sein.';

  @override
  String get calibrate => 'Kalibrieren';

  @override
  String get calibration => 'Kalibrierung';

  @override
  String get calibrationHint =>
      'Drucke das Testblatt beidseitig. Halte es mit der Rückseite zu dir gegen das Licht und lies bei A–D ab, wo das Kreuz der Vorderseite auf der Skala liegt.';

  @override
  String get printTestSheet => 'Testblatt drucken';

  @override
  String get backOffsetX => 'Rückseite X';

  @override
  String get backOffsetXHint => 'Plus ist nach rechts';

  @override
  String get backOffsetY => 'Rückseite Y';

  @override
  String get backOffsetYHint => 'Plus ist nach unten';

  @override
  String get decrease => 'Verringern';

  @override
  String get increase => 'Erhöhen';

  @override
  String get keyboardShortcuts => 'Tastaturkurzbefehle';

  @override
  String get shortcutBoldItalic => 'Fett / kursiv';

  @override
  String get shortcutNextCard => 'Sichern und nächste Karte';

  @override
  String get about => 'Über';

  @override
  String get licences => 'Lizenzen';

  @override
  String sheetNumber(int number) {
    return 'Blatt $number';
  }

  @override
  String sheetThumbnail(int number) {
    return 'Vorschau von Blatt $number';
  }

  @override
  String get testSheetFileName => 'testblatt';

  @override
  String get testSheetFrontTitle =>
      'Testblatt · Vorderseite · beidseitig, an langer Kante wenden, Skalierung 100 %';

  @override
  String get testSheetBackTitle => 'Testblatt · Rückseite';
}
