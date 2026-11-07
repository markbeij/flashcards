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
  String get library => 'Library';

  @override
  String get settings => 'Settings';

  @override
  String get print => 'Print';

  @override
  String get printEllipsis => 'Print…';

  @override
  String get newDeck => 'New deck';

  @override
  String get addCards => 'Add cards';

  @override
  String get chooseDeck => 'Choose a deck';

  @override
  String get libraryEmpty => 'Make a deck to hold your cards.';

  @override
  String get libraryEmptyExample =>
      'For example: folder VWO 4, subfolder Latin, title Words ch. 3';

  @override
  String get deckMap => 'Folder';

  @override
  String get deckMapHint => 'e.g. school year';

  @override
  String get deckSubmap => 'Subfolder';

  @override
  String get deckSubmapHint => 'e.g. subject';

  @override
  String get deckTitle => 'Title';

  @override
  String get deckTitleHint => 'e.g. Words ch. 3';

  @override
  String get editDeck => 'Edit deck';

  @override
  String get deleteDeck => 'Delete deck';

  @override
  String deleteDeckTitle(String title) {
    return 'Delete “$title”?';
  }

  @override
  String deleteDeckMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'The deck and its $count cards will be deleted.',
      one: 'The deck and its card will be deleted.',
      zero: 'The deck is empty.',
    );
    return '$_temp0';
  }

  @override
  String get deckActions => 'Deck actions';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get done => 'Done';

  @override
  String get edit => 'Edit';

  @override
  String get select => 'Select';

  @override
  String get undo => 'Undo';

  @override
  String get moveTo => 'Move to…';

  @override
  String get newCardLikeThis => 'New card like this';

  @override
  String get moreActions => 'More actions';

  @override
  String deckCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count decks',
      one: '1 deck',
    );
    return '$_temp0';
  }

  @override
  String cardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String sheetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sheets',
      one: '1 sheet',
    );
    return '$_temp0';
  }

  @override
  String cardsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards added',
      one: '1 card added',
      zero: 'No cards added yet',
    );
    return '$_temp0';
  }

  @override
  String cardsDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards deleted',
      one: 'Card deleted',
    );
    return '$_temp0';
  }

  @override
  String cardSaved(int seq) {
    return 'Card $seq saved';
  }

  @override
  String cardSemantics(int seq, String front, String back) {
    return 'Card $seq: $front, $back';
  }

  @override
  String cardField(int seq, String field) {
    return 'Card $seq, $field';
  }

  @override
  String newCardField(String field) {
    return 'New card, $field';
  }

  @override
  String get deckEmpty => 'This deck is empty.';

  @override
  String get deckEmptyExample => 'Choose a kind of card; a deck can mix kinds.';

  @override
  String get typeVocabulary => 'Vocabulary';

  @override
  String get typeBegrip => 'Term';

  @override
  String get typeParadigm => 'Paradigm';

  @override
  String get typeSentence => 'Sentence';

  @override
  String get typeHistory => 'History';

  @override
  String get typeVocabularyExample => 'meisje → puella';

  @override
  String get typeBegripExample => 'Photosynthesis → explanation';

  @override
  String get typeParadigmExample => 'amare → amo, amavi, amatum';

  @override
  String get typeSentenceExample => 'I walk. → Ambulo.';

  @override
  String get typeHistoryExample => 'Peace of Münster → 1648';

  @override
  String get languageLatin => 'Latin';

  @override
  String get languageGerman => 'German';

  @override
  String get languageFrench => 'French';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageDutch => 'Dutch';

  @override
  String get overflowShort => 'Doesn\'t fit';

  @override
  String get overflowLong => 'Doesn\'t fit on the card — shorten it.';

  @override
  String get spaceOnCard => 'Space on the card';

  @override
  String spaceUsed(int percent) {
    return '$percent% full';
  }

  @override
  String get searchDecks => 'Search decks';

  @override
  String get searchNoResults => 'No decks found';

  @override
  String get bold => 'Bold';

  @override
  String get italic => 'Italic';

  @override
  String get fieldNlShort => 'NL';

  @override
  String get fieldNl => 'Dutch word';

  @override
  String get fieldNlPluralShort => 'NL pl.';

  @override
  String get fieldNlPlural => 'Dutch plural';

  @override
  String get fieldWordShort => 'Word';

  @override
  String fieldTargetWord(String language) {
    return '$language word';
  }

  @override
  String get fieldPluralShort => 'Plural';

  @override
  String fieldTargetPlural(String language) {
    return '$language plural';
  }

  @override
  String get fieldArticleShort => 'Art.';

  @override
  String get fieldArticle => 'Article';

  @override
  String get fieldGenderShort => 'm/f/n';

  @override
  String get fieldGender => 'Gender (m/f/n)';

  @override
  String get fieldGenitiveShort => 'Gen.';

  @override
  String get fieldGenitive => 'Genitive';

  @override
  String get fieldTerm => 'Term';

  @override
  String get fieldExplanation => 'Explanation';

  @override
  String get fieldHeading => 'Meaning or infinitive';

  @override
  String get fieldForms => 'Forms';

  @override
  String get fieldFormLabel => 'Label';

  @override
  String get fieldFormValue => 'Form';

  @override
  String formLabelSemantics(int row) {
    return 'Row $row, label';
  }

  @override
  String formValueSemantics(int row) {
    return 'Row $row, form';
  }

  @override
  String get fieldSentenceNl => 'Dutch sentence';

  @override
  String get fieldSentenceTarget => 'Translation';

  @override
  String get fieldGrammarPoint => 'Grammar point (optional)';

  @override
  String get fieldDate => 'Date, range or era';

  @override
  String get fieldEvent => 'Event';

  @override
  String get fieldContext => 'Context (optional)';

  @override
  String get moreFields => 'More fields';

  @override
  String get fewerFields => 'Fewer fields';

  @override
  String get rowIncomplete => 'Incomplete, not saved';

  @override
  String get cardIncomplete => 'Fill in the required fields to save the card.';

  @override
  String get addRow => 'Add row';

  @override
  String get removeRow => 'Remove row';

  @override
  String get nextCard => 'Next';

  @override
  String get showPreview => 'Show preview';

  @override
  String get hidePreview => 'Hide preview';

  @override
  String get fields => 'Fields';

  @override
  String get preview => 'Preview';

  @override
  String get previewEmpty => 'Nothing to show yet';

  @override
  String previewLabel(String content) {
    return 'Card preview: $content';
  }

  @override
  String incompleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards are incomplete',
      one: '1 card is incomplete',
    );
    return '$_temp0';
  }

  @override
  String get incompleteMessage => 'They won\'t be saved.';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get discard => 'Discard';

  @override
  String get cardGone => 'This card no longer exists.';

  @override
  String get printWhat => 'What';

  @override
  String get printNothing => 'There are no decks yet.';

  @override
  String get fronts => 'Fronts';

  @override
  String get backs => 'Backs';

  @override
  String get checklist => 'Check in the print dialog';

  @override
  String get checkDuplex => 'Double-sided, flips like a book';

  @override
  String get checkA4 => 'A4';

  @override
  String get checkScale => 'Don\'t change the scale (100%)';

  @override
  String get sharePdf => 'Share PDF';

  @override
  String shareFile(String name) {
    return 'Share $name';
  }

  @override
  String get noDuplex => 'My printer can\'t print double-sided';

  @override
  String get manualStepFronts => '1. Print the fronts';

  @override
  String get manualStepTurn => '2. Turn the stack over like this';

  @override
  String get manualStepTurnHint =>
      'Put the sheets back in the tray, turned over along the long edge, with the blank side facing the print side.';

  @override
  String get manualStepBacks => '3. Print the backs';

  @override
  String get frontsFileName => 'fronts';

  @override
  String get backsFileName => 'backs';

  @override
  String get pdfFileName => 'flashcards';

  @override
  String get howToCut => 'How to cut';

  @override
  String get cutEdges => 'Cut off the edges, along the ticks.';

  @override
  String get cutColumns => 'Cut the sheet into two columns.';

  @override
  String get cutRows => 'Cut each column into four cards.';

  @override
  String get notCalibrated =>
      'Your printer isn\'t calibrated yet: the backs may be slightly off.';

  @override
  String get calibrate => 'Calibrate';

  @override
  String get calibration => 'Calibration';

  @override
  String get calibrationHint =>
      'Print the test sheet double-sided. Hold it against the light with the back facing you, and read where the front\'s cross lands on the scale at A–D.';

  @override
  String get printTestSheet => 'Print test sheet';

  @override
  String get backOffsetX => 'Back X';

  @override
  String get backOffsetXHint => 'Plus is to the right';

  @override
  String get backOffsetY => 'Back Y';

  @override
  String get backOffsetYHint => 'Plus is down';

  @override
  String get decrease => 'Decrease';

  @override
  String get increase => 'Increase';

  @override
  String get keyboardShortcuts => 'Keyboard shortcuts';

  @override
  String get shortcutBoldItalic => 'Bold / italic';

  @override
  String get shortcutNextCard => 'Save and start the next card';

  @override
  String get about => 'About';

  @override
  String get licences => 'Licences';

  @override
  String sheetNumber(int number) {
    return 'Sheet $number';
  }

  @override
  String sheetThumbnail(int number) {
    return 'Preview of sheet $number';
  }

  @override
  String get testSheetFileName => 'test-sheet';

  @override
  String get testSheetFrontTitle =>
      'Test sheet · front · double-sided, flip on long edge, scale 100%';

  @override
  String get testSheetBackTitle => 'Test sheet · back';
}
