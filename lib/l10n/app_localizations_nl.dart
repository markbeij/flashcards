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
  String get library => 'Bibliotheek';

  @override
  String get settings => 'Instellingen';

  @override
  String get print => 'Printen';

  @override
  String get printEllipsis => 'Printen…';

  @override
  String get newDeck => 'Nieuwe stapel';

  @override
  String get addCards => 'Kaarten toevoegen';

  @override
  String get chooseDeck => 'Kies een stapel';

  @override
  String get libraryEmpty => 'Maak een stapel om kaarten in te zetten.';

  @override
  String get libraryEmptyExample =>
      'Bijvoorbeeld map VWO 4, submap Latijn, titel Woordjes H3';

  @override
  String get deckMap => 'Map';

  @override
  String get deckMapHint => 'bijv. leerjaar';

  @override
  String get deckSubmap => 'Submap';

  @override
  String get deckSubmapHint => 'bijv. vak';

  @override
  String get deckTitle => 'Titel';

  @override
  String get deckTitleHint => 'bijv. Woordjes H3';

  @override
  String get editDeck => 'Stapel wijzigen';

  @override
  String get deleteDeck => 'Stapel verwijderen';

  @override
  String deleteDeckTitle(String title) {
    return '„$title” verwijderen?';
  }

  @override
  String deleteDeckMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'De stapel en zijn $count kaarten worden verwijderd.',
      one: 'De stapel en zijn kaart worden verwijderd.',
      zero: 'De stapel is leeg.',
    );
    return '$_temp0';
  }

  @override
  String get deckActions => 'Stapelacties';

  @override
  String get cancel => 'Annuleren';

  @override
  String get save => 'Bewaar';

  @override
  String get delete => 'Verwijder';

  @override
  String get done => 'Klaar';

  @override
  String get edit => 'Wijzig';

  @override
  String get select => 'Selecteer';

  @override
  String get undo => 'Herstel';

  @override
  String get moveTo => 'Verplaats naar…';

  @override
  String get newCardLikeThis => 'Nieuwe kaart zoals deze';

  @override
  String get moreActions => 'Meer acties';

  @override
  String deckCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stapels',
      one: '1 stapel',
    );
    return '$_temp0';
  }

  @override
  String cardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kaarten',
      one: '1 kaart',
    );
    return '$_temp0';
  }

  @override
  String sheetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vellen',
      one: '1 vel',
    );
    return '$_temp0';
  }

  @override
  String cardsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kaarten toegevoegd',
      one: '1 kaart toegevoegd',
      zero: 'Nog geen kaarten toegevoegd',
    );
    return '$_temp0';
  }

  @override
  String cardsDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kaarten verwijderd',
      one: 'Kaart verwijderd',
    );
    return '$_temp0';
  }

  @override
  String cardSaved(int seq) {
    return 'Kaart $seq bewaard';
  }

  @override
  String cardSemantics(int seq, String front, String back) {
    return 'Kaart $seq: $front, $back';
  }

  @override
  String cardField(int seq, String field) {
    return 'Kaart $seq, $field';
  }

  @override
  String newCardField(String field) {
    return 'Nieuwe kaart, $field';
  }

  @override
  String get deckEmpty => 'Deze stapel is nog leeg.';

  @override
  String get deckEmptyExample =>
      'Kies wat voor kaarten je maakt; een stapel mag soorten mengen.';

  @override
  String get typeVocabulary => 'Woordjes';

  @override
  String get typeBegrip => 'Begrip';

  @override
  String get typeParadigm => 'Rijtje';

  @override
  String get typeSentence => 'Zin';

  @override
  String get typeHistory => 'Geschiedenis';

  @override
  String get typeVocabularyExample => 'meisje → puella';

  @override
  String get typeBegripExample => 'Fotosynthese → uitleg';

  @override
  String get typeParadigmExample => 'amare → amo, amavi, amatum';

  @override
  String get typeSentenceExample => 'Ik loop. → Ambulo.';

  @override
  String get typeHistoryExample => 'Vrede van Münster → 1648';

  @override
  String get languageLatin => 'Latijn';

  @override
  String get languageGerman => 'Duits';

  @override
  String get languageFrench => 'Frans';

  @override
  String get languageEnglish => 'Engels';

  @override
  String get languageDutch => 'Nederlands';

  @override
  String get overflowShort => 'Past niet';

  @override
  String get overflowLong => 'Past niet op de kaart — maak het korter.';

  @override
  String get spaceOnCard => 'Ruimte op de kaart';

  @override
  String spaceUsed(int percent) {
    return '$percent% vol';
  }

  @override
  String get searchDecks => 'Zoek stapels';

  @override
  String get searchNoResults => 'Geen stapels gevonden';

  @override
  String get bold => 'Vet';

  @override
  String get italic => 'Cursief';

  @override
  String get fieldNlShort => 'NL';

  @override
  String get fieldNl => 'Nederlands woord';

  @override
  String get fieldNlPluralShort => 'NL mv.';

  @override
  String get fieldNlPlural => 'Nederlands meervoud';

  @override
  String get fieldWordShort => 'Woord';

  @override
  String fieldTargetWord(String language) {
    return 'Woord ($language)';
  }

  @override
  String get fieldPluralShort => 'Mv.';

  @override
  String fieldTargetPlural(String language) {
    return 'Meervoud ($language)';
  }

  @override
  String get fieldArticleShort => 'Lidw.';

  @override
  String get fieldArticle => 'Lidwoord';

  @override
  String get fieldGenderShort => 'm/f/n';

  @override
  String get fieldGender => 'Geslacht (m/f/n)';

  @override
  String get fieldGenitiveShort => 'Gen.';

  @override
  String get fieldGenitive => 'Genitivus';

  @override
  String get fieldTerm => 'Begrip';

  @override
  String get fieldExplanation => 'Uitleg';

  @override
  String get fieldHeading => 'Betekenis of infinitief';

  @override
  String get fieldForms => 'Vormen';

  @override
  String get fieldFormLabel => 'Label';

  @override
  String get fieldFormValue => 'Vorm';

  @override
  String formLabelSemantics(int row) {
    return 'Regel $row, label';
  }

  @override
  String formValueSemantics(int row) {
    return 'Regel $row, vorm';
  }

  @override
  String get fieldSentenceNl => 'Nederlandse zin';

  @override
  String get fieldSentenceTarget => 'Vertaling';

  @override
  String get fieldGrammarPoint => 'Grammaticapunt (optioneel)';

  @override
  String get fieldDate => 'Datum, periode of tijdvak';

  @override
  String get fieldEvent => 'Gebeurtenis';

  @override
  String get fieldContext => 'Context (optioneel)';

  @override
  String get moreFields => 'Meer velden';

  @override
  String get fewerFields => 'Minder velden';

  @override
  String get rowIncomplete => 'Niet compleet, niet bewaard';

  @override
  String get cardIncomplete =>
      'Vul de verplichte velden in om de kaart te bewaren.';

  @override
  String get addRow => 'Regel toevoegen';

  @override
  String get removeRow => 'Regel verwijderen';

  @override
  String get nextCard => 'Volgende';

  @override
  String get showPreview => 'Voorbeeld tonen';

  @override
  String get hidePreview => 'Voorbeeld verbergen';

  @override
  String get fields => 'Velden';

  @override
  String get preview => 'Voorbeeld';

  @override
  String get previewEmpty => 'Nog niets om te tonen';

  @override
  String previewLabel(String content) {
    return 'Voorbeeld van de kaart: $content';
  }

  @override
  String incompleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kaarten zijn niet compleet',
      one: '1 kaart is niet compleet',
    );
    return '$_temp0';
  }

  @override
  String get incompleteMessage => 'Die worden niet bewaard.';

  @override
  String get keepEditing => 'Verder bewerken';

  @override
  String get discard => 'Weggooien';

  @override
  String get cardGone => 'Deze kaart bestaat niet meer.';

  @override
  String get printWhat => 'Wat';

  @override
  String get printNothing => 'Er zijn nog geen stapels.';

  @override
  String get fronts => 'Voorkanten';

  @override
  String get backs => 'Achterkanten';

  @override
  String get checklist => 'Controleer in het printvenster';

  @override
  String get checkDuplex => 'Dubbelzijdig, omslaan als een boek';

  @override
  String get checkA4 => 'A4';

  @override
  String get checkScale => 'Schaal niet aanpassen (100%)';

  @override
  String get sharePdf => 'PDF delen';

  @override
  String shareFile(String name) {
    return '$name delen';
  }

  @override
  String get noDuplex => 'Mijn printer kan niet dubbelzijdig printen';

  @override
  String get manualStepFronts => '1. Print de voorkanten';

  @override
  String get manualStepTurn => '2. Draai de stapel om, zo';

  @override
  String get manualStepTurnHint =>
      'Leg de vellen terug in de lade, omgeslagen langs de lange kant, met de lege kant naar de printkant.';

  @override
  String get manualStepBacks => '3. Print de achterkanten';

  @override
  String get frontsFileName => 'voorkanten';

  @override
  String get backsFileName => 'achterkanten';

  @override
  String get pdfFileName => 'flitskaarten';

  @override
  String get howToCut => 'Zo snijd je de kaarten';

  @override
  String get cutEdges => 'Snijd de randen af, langs de streepjes.';

  @override
  String get cutColumns => 'Snijd het vel in twee kolommen.';

  @override
  String get cutRows => 'Snijd elke kolom in vier kaarten.';

  @override
  String get notCalibrated =>
      'Je printer is nog niet gekalibreerd: de achterkanten kunnen iets verschoven zijn.';

  @override
  String get calibrate => 'Kalibreren';

  @override
  String get calibration => 'Kalibratie';

  @override
  String get calibrationHint =>
      'Print het testvel dubbelzijdig. Houd het tegen het licht met de achterkant naar je toe en lees bij A–D af waar het kruis van de voorkant op de schaal valt.';

  @override
  String get printTestSheet => 'Testvel printen';

  @override
  String get backOffsetX => 'Achterkant X';

  @override
  String get backOffsetXHint => 'Plus is naar rechts';

  @override
  String get backOffsetY => 'Achterkant Y';

  @override
  String get backOffsetYHint => 'Plus is omlaag';

  @override
  String get decrease => 'Verlagen';

  @override
  String get increase => 'Verhogen';

  @override
  String get keyboardShortcuts => 'Toetscombinaties';

  @override
  String get shortcutBoldItalic => 'Vet / cursief';

  @override
  String get shortcutNextCard => 'Bewaren en volgende kaart';

  @override
  String get about => 'Over';

  @override
  String get licences => 'Licenties';

  @override
  String sheetNumber(int number) {
    return 'Vel $number';
  }

  @override
  String sheetThumbnail(int number) {
    return 'Voorbeeld van vel $number';
  }

  @override
  String get testSheetFileName => 'testvel';

  @override
  String get testSheetFrontTitle =>
      'Testvel · voorkant · dubbelzijdig, omslaan langs de lange kant, schaal 100%';

  @override
  String get testSheetBackTitle => 'Testvel · achterkant';
}
