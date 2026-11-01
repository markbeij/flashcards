import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('nl'),
  ];

  /// App name.
  ///
  /// In nl, this message translates to:
  /// **'Flitskaarten'**
  String get appTitle;

  /// Title of the Library (maps and decks).
  ///
  /// In nl, this message translates to:
  /// **'Bibliotheek'**
  String get library;

  /// Settings page title and gear button label.
  ///
  /// In nl, this message translates to:
  /// **'Instellingen'**
  String get settings;

  /// Print button and print screen title.
  ///
  /// In nl, this message translates to:
  /// **'Printen'**
  String get print;

  /// Print button inside a deck (opens the print set-up).
  ///
  /// In nl, this message translates to:
  /// **'Printen…'**
  String get printEllipsis;

  /// Button and sheet title: make a new deck.
  ///
  /// In nl, this message translates to:
  /// **'Nieuwe stapel'**
  String get newDeck;

  /// Button: add cards to the open deck.
  ///
  /// In nl, this message translates to:
  /// **'Kaarten toevoegen'**
  String get addCards;

  /// Shown on the right while no deck is open.
  ///
  /// In nl, this message translates to:
  /// **'Kies een stapel'**
  String get chooseDeck;

  /// Empty Library: one sentence.
  ///
  /// In nl, this message translates to:
  /// **'Maak een stapel om kaarten in te zetten.'**
  String get libraryEmpty;

  /// Empty Library: one example.
  ///
  /// In nl, this message translates to:
  /// **'Bijvoorbeeld map VWO 4, submap Latijn, titel Woordjes H3'**
  String get libraryEmptyExample;

  /// Deck field: the map (top-level group).
  ///
  /// In nl, this message translates to:
  /// **'Map'**
  String get deckMap;

  /// Placeholder of the map field.
  ///
  /// In nl, this message translates to:
  /// **'bijv. leerjaar'**
  String get deckMapHint;

  /// Deck field: the submap (group inside a map).
  ///
  /// In nl, this message translates to:
  /// **'Submap'**
  String get deckSubmap;

  /// Placeholder of the submap field.
  ///
  /// In nl, this message translates to:
  /// **'bijv. vak'**
  String get deckSubmapHint;

  /// Deck field: the title, printed on every card.
  ///
  /// In nl, this message translates to:
  /// **'Titel'**
  String get deckTitle;

  /// Placeholder of the title field.
  ///
  /// In nl, this message translates to:
  /// **'bijv. Woordjes H3'**
  String get deckTitleHint;

  /// Menu item and sheet title.
  ///
  /// In nl, this message translates to:
  /// **'Stapel wijzigen'**
  String get editDeck;

  /// Menu item.
  ///
  /// In nl, this message translates to:
  /// **'Stapel verwijderen'**
  String get deleteDeck;

  /// Confirmation title.
  ///
  /// In nl, this message translates to:
  /// **'„{title}” verwijderen?'**
  String deleteDeckTitle(String title);

  /// Confirmation message.
  ///
  /// In nl, this message translates to:
  /// **'{count, plural, =0{De stapel is leeg.} =1{De stapel en zijn kaart worden verwijderd.} other{De stapel en zijn {count} kaarten worden verwijderd.}}'**
  String deleteDeckMessage(int count);

  /// Accessibility label of the deck "⋯" menu.
  ///
  /// In nl, this message translates to:
  /// **'Stapelacties'**
  String get deckActions;

  /// Button.
  ///
  /// In nl, this message translates to:
  /// **'Annuleren'**
  String get cancel;

  /// Button.
  ///
  /// In nl, this message translates to:
  /// **'Bewaar'**
  String get save;

  /// Button and menu item.
  ///
  /// In nl, this message translates to:
  /// **'Verwijder'**
  String get delete;

  /// Button: close the screen.
  ///
  /// In nl, this message translates to:
  /// **'Klaar'**
  String get done;

  /// Menu item.
  ///
  /// In nl, this message translates to:
  /// **'Wijzig'**
  String get edit;

  /// Button: start select mode.
  ///
  /// In nl, this message translates to:
  /// **'Selecteer'**
  String get select;

  /// Button in the toast after deleting.
  ///
  /// In nl, this message translates to:
  /// **'Herstel'**
  String get undo;

  /// Menu item, toolbar button and sheet title.
  ///
  /// In nl, this message translates to:
  /// **'Verplaats naar…'**
  String get moveTo;

  /// Card menu item: a new card copying this one's type (and paradigm labels).
  ///
  /// In nl, this message translates to:
  /// **'Nieuwe kaart zoals deze'**
  String get newCardLikeThis;

  /// Accessibility label of a "⋯" button.
  ///
  /// In nl, this message translates to:
  /// **'Meer acties'**
  String get moreActions;

  /// Number of decks.
  ///
  /// In nl, this message translates to:
  /// **'{count, plural, =1{1 stapel} other{{count} stapels}}'**
  String deckCount(int count);

  /// Number of cards.
  ///
  /// In nl, this message translates to:
  /// **'{count, plural, =1{1 kaart} other{{count} kaarten}}'**
  String cardCount(int count);

  /// Number of A4 sheets.
  ///
  /// In nl, this message translates to:
  /// **'{count, plural, =1{1 vel} other{{count} vellen}}'**
  String sheetCount(int count);

  /// Counter in the entry screens.
  ///
  /// In nl, this message translates to:
  /// **'{count, plural, =0{Nog geen kaarten toegevoegd} =1{1 kaart toegevoegd} other{{count} kaarten toegevoegd}}'**
  String cardsAdded(int count);

  /// Toast after deleting cards.
  ///
  /// In nl, this message translates to:
  /// **'{count, plural, =1{Kaart verwijderd} other{{count} kaarten verwijderd}}'**
  String cardsDeleted(int count);

  /// VoiceOver announcement when a card is saved.
  ///
  /// In nl, this message translates to:
  /// **'Kaart {seq} bewaard'**
  String cardSaved(int seq);

  /// VoiceOver label of a card row.
  ///
  /// In nl, this message translates to:
  /// **'Kaart {seq}: {front}, {back}'**
  String cardSemantics(int seq, String front, String back);

  /// VoiceOver label of an entry field of a saved card, e.g. "Card 12, Latin word".
  ///
  /// In nl, this message translates to:
  /// **'Kaart {seq}, {field}'**
  String cardField(int seq, String field);

  /// VoiceOver label of an entry field of a new card.
  ///
  /// In nl, this message translates to:
  /// **'Nieuwe kaart, {field}'**
  String newCardField(String field);

  /// Empty deck: one sentence.
  ///
  /// In nl, this message translates to:
  /// **'Deze stapel is nog leeg.'**
  String get deckEmpty;

  /// Empty deck: hint above the card type tiles.
  ///
  /// In nl, this message translates to:
  /// **'Kies wat voor kaarten je maakt; een stapel mag soorten mengen.'**
  String get deckEmptyExample;

  /// Card type.
  ///
  /// In nl, this message translates to:
  /// **'Woordjes'**
  String get typeVocabulary;

  /// Card type: a term and its explanation.
  ///
  /// In nl, this message translates to:
  /// **'Begrip'**
  String get typeBegrip;

  /// Card type: a verb or noun with its forms.
  ///
  /// In nl, this message translates to:
  /// **'Rijtje'**
  String get typeParadigm;

  /// Card type.
  ///
  /// In nl, this message translates to:
  /// **'Zin'**
  String get typeSentence;

  /// Card type: a date and an event.
  ///
  /// In nl, this message translates to:
  /// **'Geschiedenis'**
  String get typeHistory;

  /// Example on the empty deck tile.
  ///
  /// In nl, this message translates to:
  /// **'meisje → puella'**
  String get typeVocabularyExample;

  /// Example on the empty deck tile.
  ///
  /// In nl, this message translates to:
  /// **'Fotosynthese → uitleg'**
  String get typeBegripExample;

  /// Example on the empty deck tile.
  ///
  /// In nl, this message translates to:
  /// **'amare → amo, amavi, amatum'**
  String get typeParadigmExample;

  /// Example on the empty deck tile.
  ///
  /// In nl, this message translates to:
  /// **'Ik loop. → Ambulo.'**
  String get typeSentenceExample;

  /// Example on the empty deck tile.
  ///
  /// In nl, this message translates to:
  /// **'Vrede van Münster → 1648'**
  String get typeHistoryExample;

  /// Language.
  ///
  /// In nl, this message translates to:
  /// **'Latijn'**
  String get languageLatin;

  /// Language.
  ///
  /// In nl, this message translates to:
  /// **'Duits'**
  String get languageGerman;

  /// Language.
  ///
  /// In nl, this message translates to:
  /// **'Frans'**
  String get languageFrench;

  /// Language.
  ///
  /// In nl, this message translates to:
  /// **'Engels'**
  String get languageEnglish;

  /// Language.
  ///
  /// In nl, this message translates to:
  /// **'Nederlands'**
  String get languageDutch;

  /// Overflow badge on a card row.
  ///
  /// In nl, this message translates to:
  /// **'Past niet'**
  String get overflowShort;

  /// Overflow badge in the entry screens.
  ///
  /// In nl, this message translates to:
  /// **'Past niet op de kaart — maak het korter.'**
  String get overflowLong;

  /// Toolbar button.
  ///
  /// In nl, this message translates to:
  /// **'Vet'**
  String get bold;

  /// Toolbar button.
  ///
  /// In nl, this message translates to:
  /// **'Cursief'**
  String get italic;

  /// Grid header: Dutch word (short, may wrap).
  ///
  /// In nl, this message translates to:
  /// **'NL'**
  String get fieldNlShort;

  /// Field: the Dutch word.
  ///
  /// In nl, this message translates to:
  /// **'Nederlands woord'**
  String get fieldNl;

  /// Short label: Dutch plural.
  ///
  /// In nl, this message translates to:
  /// **'NL mv.'**
  String get fieldNlPluralShort;

  /// Field: the Dutch plural.
  ///
  /// In nl, this message translates to:
  /// **'Nederlands meervoud'**
  String get fieldNlPlural;

  /// Grid header: the word in the target language.
  ///
  /// In nl, this message translates to:
  /// **'Woord'**
  String get fieldWordShort;

  /// Field: the word in a language.
  ///
  /// In nl, this message translates to:
  /// **'Woord ({language})'**
  String fieldTargetWord(String language);

  /// Grid header: plural.
  ///
  /// In nl, this message translates to:
  /// **'Mv.'**
  String get fieldPluralShort;

  /// Field: the plural in a language.
  ///
  /// In nl, this message translates to:
  /// **'Meervoud ({language})'**
  String fieldTargetPlural(String language);

  /// Grid header: article.
  ///
  /// In nl, this message translates to:
  /// **'Lidw.'**
  String get fieldArticleShort;

  /// Field: article, e.g. der, la.
  ///
  /// In nl, this message translates to:
  /// **'Lidwoord'**
  String get fieldArticle;

  /// Grid header: gender.
  ///
  /// In nl, this message translates to:
  /// **'m/f/n'**
  String get fieldGenderShort;

  /// Field: grammatical gender, typed as m, f or n.
  ///
  /// In nl, this message translates to:
  /// **'Geslacht (m/f/n)'**
  String get fieldGender;

  /// Grid header: Latin genitive.
  ///
  /// In nl, this message translates to:
  /// **'Gen.'**
  String get fieldGenitiveShort;

  /// Field: Latin genitive.
  ///
  /// In nl, this message translates to:
  /// **'Genitivus'**
  String get fieldGenitive;

  /// Field.
  ///
  /// In nl, this message translates to:
  /// **'Begrip'**
  String get fieldTerm;

  /// Field.
  ///
  /// In nl, this message translates to:
  /// **'Uitleg'**
  String get fieldExplanation;

  /// Paradigm field: the front.
  ///
  /// In nl, this message translates to:
  /// **'Betekenis of infinitief'**
  String get fieldHeading;

  /// Paradigm: the label/value rows.
  ///
  /// In nl, this message translates to:
  /// **'Vormen'**
  String get fieldForms;

  /// Placeholder: paradigm row label, e.g. perf.
  ///
  /// In nl, this message translates to:
  /// **'Label'**
  String get fieldFormLabel;

  /// Placeholder: paradigm row value.
  ///
  /// In nl, this message translates to:
  /// **'Vorm'**
  String get fieldFormValue;

  /// VoiceOver: a paradigm row label.
  ///
  /// In nl, this message translates to:
  /// **'Regel {row}, label'**
  String formLabelSemantics(int row);

  /// VoiceOver: a paradigm row value.
  ///
  /// In nl, this message translates to:
  /// **'Regel {row}, vorm'**
  String formValueSemantics(int row);

  /// Field.
  ///
  /// In nl, this message translates to:
  /// **'Nederlandse zin'**
  String get fieldSentenceNl;

  /// Field.
  ///
  /// In nl, this message translates to:
  /// **'Vertaling'**
  String get fieldSentenceTarget;

  /// Field.
  ///
  /// In nl, this message translates to:
  /// **'Grammaticapunt (optioneel)'**
  String get fieldGrammarPoint;

  /// Field.
  ///
  /// In nl, this message translates to:
  /// **'Datum, periode of tijdvak'**
  String get fieldDate;

  /// Field.
  ///
  /// In nl, this message translates to:
  /// **'Gebeurtenis'**
  String get fieldEvent;

  /// Field.
  ///
  /// In nl, this message translates to:
  /// **'Context (optioneel)'**
  String get fieldContext;

  /// Disclosure: show the other fields.
  ///
  /// In nl, this message translates to:
  /// **'Meer velden'**
  String get moreFields;

  /// Disclosure: hide the other fields.
  ///
  /// In nl, this message translates to:
  /// **'Minder velden'**
  String get fewerFields;

  /// A draft with a blank required field.
  ///
  /// In nl, this message translates to:
  /// **'Niet compleet, niet bewaard'**
  String get rowIncomplete;

  /// Form: a required field is blank.
  ///
  /// In nl, this message translates to:
  /// **'Vul de verplichte velden in om de kaart te bewaren.'**
  String get cardIncomplete;

  /// Paradigm: add a row.
  ///
  /// In nl, this message translates to:
  /// **'Regel toevoegen'**
  String get addRow;

  /// Paradigm: remove a row.
  ///
  /// In nl, this message translates to:
  /// **'Regel verwijderen'**
  String get removeRow;

  /// Button: save and start the next card.
  ///
  /// In nl, this message translates to:
  /// **'Volgende'**
  String get nextCard;

  /// Button.
  ///
  /// In nl, this message translates to:
  /// **'Voorbeeld tonen'**
  String get showPreview;

  /// Button.
  ///
  /// In nl, this message translates to:
  /// **'Voorbeeld verbergen'**
  String get hidePreview;

  /// Segment: the form fields.
  ///
  /// In nl, this message translates to:
  /// **'Velden'**
  String get fields;

  /// Segment and button: the preview.
  ///
  /// In nl, this message translates to:
  /// **'Voorbeeld'**
  String get preview;

  /// VoiceOver label of an empty preview.
  ///
  /// In nl, this message translates to:
  /// **'Nog niets om te tonen'**
  String get previewEmpty;

  /// VoiceOver label of the card preview.
  ///
  /// In nl, this message translates to:
  /// **'Voorbeeld van de kaart: {content}'**
  String previewLabel(String content);

  /// Done with incomplete drafts.
  ///
  /// In nl, this message translates to:
  /// **'{count, plural, =1{1 kaart is niet compleet} other{{count} kaarten zijn niet compleet}}'**
  String incompleteTitle(int count);

  /// Done with incomplete drafts.
  ///
  /// In nl, this message translates to:
  /// **'Die worden niet bewaard.'**
  String get incompleteMessage;

  /// Button.
  ///
  /// In nl, this message translates to:
  /// **'Verder bewerken'**
  String get keepEditing;

  /// Button.
  ///
  /// In nl, this message translates to:
  /// **'Weggooien'**
  String get discard;

  /// Editor: the card was deleted.
  ///
  /// In nl, this message translates to:
  /// **'Deze kaart bestaat niet meer.'**
  String get cardGone;

  /// Print set-up section: which decks.
  ///
  /// In nl, this message translates to:
  /// **'Wat'**
  String get printWhat;

  /// Print set-up without decks.
  ///
  /// In nl, this message translates to:
  /// **'Er zijn nog geen stapels.'**
  String get printNothing;

  /// Print set-up section: overflowing cards.
  ///
  /// In nl, this message translates to:
  /// **'Past niet'**
  String get printDoesntFit;

  /// Under the overflowing cards.
  ///
  /// In nl, this message translates to:
  /// **'Deze kaarten worden overgeslagen, tenzij je Overslaan uitzet.'**
  String get printDoesntFitHint;

  /// Button: open the card to shorten it.
  ///
  /// In nl, this message translates to:
  /// **'Aanpassen'**
  String get fix;

  /// Switch label: leave the card out.
  ///
  /// In nl, this message translates to:
  /// **'Overslaan'**
  String get skip;

  /// Print set-up section.
  ///
  /// In nl, this message translates to:
  /// **'Richting'**
  String get printDirection;

  /// Direction line.
  ///
  /// In nl, this message translates to:
  /// **'Voorkant: {side}'**
  String frontShows(String side);

  /// Direction line.
  ///
  /// In nl, this message translates to:
  /// **'Achterkant: {side}'**
  String backShows(String side);

  /// Direction for cards without a language: the question side.
  ///
  /// In nl, this message translates to:
  /// **'vraag'**
  String get directionQuestion;

  /// Direction for cards without a language: the answer side.
  ///
  /// In nl, this message translates to:
  /// **'antwoord'**
  String get directionAnswer;

  /// Button ⇄.
  ///
  /// In nl, this message translates to:
  /// **'Voor- en achterkant wisselen'**
  String get swapSides;

  /// Preview toggle.
  ///
  /// In nl, this message translates to:
  /// **'Voorkanten'**
  String get fronts;

  /// Preview toggle.
  ///
  /// In nl, this message translates to:
  /// **'Achterkanten'**
  String get backs;

  /// Header of the print checklist.
  ///
  /// In nl, this message translates to:
  /// **'Controleer in het printvenster'**
  String get checklist;

  /// Checklist item.
  ///
  /// In nl, this message translates to:
  /// **'Dubbelzijdig, omslaan als een boek'**
  String get checkDuplex;

  /// Checklist item.
  ///
  /// In nl, this message translates to:
  /// **'A4'**
  String get checkA4;

  /// Checklist item.
  ///
  /// In nl, this message translates to:
  /// **'Schaal niet aanpassen (100%)'**
  String get checkScale;

  /// Button.
  ///
  /// In nl, this message translates to:
  /// **'PDF delen'**
  String get sharePdf;

  /// Button: share a named file.
  ///
  /// In nl, this message translates to:
  /// **'{name} delen'**
  String shareFile(String name);

  /// Menu item and sheet title.
  ///
  /// In nl, this message translates to:
  /// **'Mijn printer kan niet dubbelzijdig printen'**
  String get noDuplex;

  /// Manual double-sided, step 1.
  ///
  /// In nl, this message translates to:
  /// **'1. Print de voorkanten'**
  String get manualStepFronts;

  /// Manual double-sided, step 2.
  ///
  /// In nl, this message translates to:
  /// **'2. Draai de stapel om, zo'**
  String get manualStepTurn;

  /// Under the illustration.
  ///
  /// In nl, this message translates to:
  /// **'Leg de vellen terug in de lade, omgeslagen langs de lange kant, met de lege kant naar de printkant.'**
  String get manualStepTurnHint;

  /// Manual double-sided, step 3.
  ///
  /// In nl, this message translates to:
  /// **'3. Print de achterkanten'**
  String get manualStepBacks;

  /// File name without .pdf.
  ///
  /// In nl, this message translates to:
  /// **'voorkanten'**
  String get frontsFileName;

  /// File name without .pdf.
  ///
  /// In nl, this message translates to:
  /// **'achterkanten'**
  String get backsFileName;

  /// File name of the print PDF without .pdf.
  ///
  /// In nl, this message translates to:
  /// **'flitskaarten'**
  String get pdfFileName;

  /// Cutting guide title and link.
  ///
  /// In nl, this message translates to:
  /// **'Zo snijd je de kaarten'**
  String get howToCut;

  /// Cutting guide step.
  ///
  /// In nl, this message translates to:
  /// **'Snijd de randen af, langs de streepjes.'**
  String get cutEdges;

  /// Cutting guide step.
  ///
  /// In nl, this message translates to:
  /// **'Snijd het vel in twee kolommen.'**
  String get cutColumns;

  /// Cutting guide step.
  ///
  /// In nl, this message translates to:
  /// **'Snijd elke kolom in vier kaarten.'**
  String get cutRows;

  /// Banner on the print preview.
  ///
  /// In nl, this message translates to:
  /// **'Je printer is nog niet gekalibreerd: de achterkanten kunnen iets verschoven zijn.'**
  String get notCalibrated;

  /// Banner action.
  ///
  /// In nl, this message translates to:
  /// **'Kalibreren'**
  String get calibrate;

  /// Settings section.
  ///
  /// In nl, this message translates to:
  /// **'Kalibratie'**
  String get calibration;

  /// Under the calibration form.
  ///
  /// In nl, this message translates to:
  /// **'Print het testvel dubbelzijdig. Houd het tegen het licht met de achterkant naar je toe en lees bij A–D af waar het kruis van de voorkant op de schaal valt.'**
  String get calibrationHint;

  /// Settings button.
  ///
  /// In nl, this message translates to:
  /// **'Testvel printen'**
  String get printTestSheet;

  /// Calibration field.
  ///
  /// In nl, this message translates to:
  /// **'Achterkant X'**
  String get backOffsetX;

  /// Calibration field hint.
  ///
  /// In nl, this message translates to:
  /// **'Plus is naar rechts'**
  String get backOffsetXHint;

  /// Calibration field.
  ///
  /// In nl, this message translates to:
  /// **'Achterkant Y'**
  String get backOffsetY;

  /// Calibration field hint.
  ///
  /// In nl, this message translates to:
  /// **'Plus is omlaag'**
  String get backOffsetYHint;

  /// VoiceOver: − button.
  ///
  /// In nl, this message translates to:
  /// **'Verlagen'**
  String get decrease;

  /// VoiceOver: + button.
  ///
  /// In nl, this message translates to:
  /// **'Verhogen'**
  String get increase;

  /// Settings section.
  ///
  /// In nl, this message translates to:
  /// **'Toetscombinaties'**
  String get keyboardShortcuts;

  /// Shortcut list.
  ///
  /// In nl, this message translates to:
  /// **'Vet / cursief'**
  String get shortcutBoldItalic;

  /// Shortcut list.
  ///
  /// In nl, this message translates to:
  /// **'Bewaren en volgende kaart'**
  String get shortcutNextCard;

  /// Settings section.
  ///
  /// In nl, this message translates to:
  /// **'Over'**
  String get about;

  /// Settings item.
  ///
  /// In nl, this message translates to:
  /// **'Licenties'**
  String get licences;

  /// Under a sheet thumbnail.
  ///
  /// In nl, this message translates to:
  /// **'Vel {number}'**
  String sheetNumber(int number);

  /// VoiceOver: a sheet thumbnail.
  ///
  /// In nl, this message translates to:
  /// **'Voorbeeld van vel {number}'**
  String sheetThumbnail(int number);

  /// File name of the test sheet.
  ///
  /// In nl, this message translates to:
  /// **'testvel'**
  String get testSheetFileName;

  /// Printed at the top of the test sheet's front page.
  ///
  /// In nl, this message translates to:
  /// **'Testvel · voorkant · dubbelzijdig, omslaan langs de lange kant, schaal 100%'**
  String get testSheetFrontTitle;

  /// Printed at the top of the test sheet's back page.
  ///
  /// In nl, this message translates to:
  /// **'Testvel · achterkant'**
  String get testSheetBackTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'fr', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
