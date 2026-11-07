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
  String get library => 'Bibliothèque';

  @override
  String get settings => 'Réglages';

  @override
  String get print => 'Imprimer';

  @override
  String get printEllipsis => 'Imprimer…';

  @override
  String get newDeck => 'Nouveau paquet';

  @override
  String get addCards => 'Ajouter des cartes';

  @override
  String get chooseDeck => 'Choisissez un paquet';

  @override
  String get libraryEmpty => 'Créez un paquet pour vos cartes.';

  @override
  String get libraryEmptyExample =>
      'Par exemple : dossier VWO 4, sous-dossier Latin, titre Vocabulaire ch. 3';

  @override
  String get deckMap => 'Dossier';

  @override
  String get deckMapHint => 'ex. année scolaire';

  @override
  String get deckSubmap => 'Sous-dossier';

  @override
  String get deckSubmapHint => 'ex. matière';

  @override
  String get deckTitle => 'Titre';

  @override
  String get deckTitleHint => 'ex. Vocabulaire ch. 3';

  @override
  String get editDeck => 'Modifier le paquet';

  @override
  String get deleteDeck => 'Supprimer le paquet';

  @override
  String deleteDeckTitle(String title) {
    return 'Supprimer « $title » ?';
  }

  @override
  String deleteDeckMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Le paquet et ses $count cartes seront supprimés.',
      one: 'Le paquet et sa carte seront supprimés.',
      zero: 'Le paquet est vide.',
    );
    return '$_temp0';
  }

  @override
  String get deckActions => 'Actions du paquet';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get done => 'OK';

  @override
  String get edit => 'Modifier';

  @override
  String get select => 'Sélectionner';

  @override
  String get undo => 'Annuler';

  @override
  String get moveTo => 'Déplacer vers…';

  @override
  String get newCardLikeThis => 'Nouvelle carte similaire';

  @override
  String get moreActions => 'Plus d\'actions';

  @override
  String deckCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count paquets',
      one: '1 paquet',
    );
    return '$_temp0';
  }

  @override
  String cardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartes',
      one: '1 carte',
    );
    return '$_temp0';
  }

  @override
  String sheetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count feuilles',
      one: '1 feuille',
    );
    return '$_temp0';
  }

  @override
  String cardsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartes ajoutées',
      one: '1 carte ajoutée',
      zero: 'Aucune carte ajoutée',
    );
    return '$_temp0';
  }

  @override
  String cardsDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartes supprimées',
      one: 'Carte supprimée',
    );
    return '$_temp0';
  }

  @override
  String cardSaved(int seq) {
    return 'Carte $seq enregistrée';
  }

  @override
  String cardSemantics(int seq, String front, String back) {
    return 'Carte $seq : $front, $back';
  }

  @override
  String cardField(int seq, String field) {
    return 'Carte $seq, $field';
  }

  @override
  String newCardField(String field) {
    return 'Nouvelle carte, $field';
  }

  @override
  String get deckEmpty => 'Ce paquet est vide.';

  @override
  String get deckEmptyExample =>
      'Choisissez un type de carte ; un paquet peut en mélanger.';

  @override
  String get typeVocabulary => 'Vocabulaire';

  @override
  String get typeBegrip => 'Notion';

  @override
  String get typeParadigm => 'Paradigme';

  @override
  String get typeSentence => 'Phrase';

  @override
  String get typeHistory => 'Histoire';

  @override
  String get typeVocabularyExample => 'meisje → puella';

  @override
  String get typeBegripExample => 'Photosynthèse → explication';

  @override
  String get typeParadigmExample => 'amare → amo, amavi, amatum';

  @override
  String get typeSentenceExample => 'Je marche. → Ambulo.';

  @override
  String get typeHistoryExample => 'Paix de Münster → 1648';

  @override
  String get languageLatin => 'Latin';

  @override
  String get languageGerman => 'Allemand';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageDutch => 'Néerlandais';

  @override
  String get overflowShort => 'Ne tient pas';

  @override
  String get overflowLong => 'Ne tient pas sur la carte — raccourcissez.';

  @override
  String get spaceOnCard => 'Place sur la carte';

  @override
  String spaceUsed(int percent) {
    return '$percent % plein';
  }

  @override
  String get searchDecks => 'Rechercher un paquet';

  @override
  String get searchNoResults => 'Aucun paquet trouvé';

  @override
  String get bold => 'Gras';

  @override
  String get italic => 'Italique';

  @override
  String get fieldNlShort => 'NL';

  @override
  String get fieldNl => 'Mot néerlandais';

  @override
  String get fieldNlPluralShort => 'NL pl.';

  @override
  String get fieldNlPlural => 'Pluriel néerlandais';

  @override
  String get fieldWordShort => 'Mot';

  @override
  String fieldTargetWord(String language) {
    return 'Mot ($language)';
  }

  @override
  String get fieldPluralShort => 'Pluriel';

  @override
  String fieldTargetPlural(String language) {
    return 'Pluriel ($language)';
  }

  @override
  String get fieldArticleShort => 'Art.';

  @override
  String get fieldArticle => 'Article';

  @override
  String get fieldGenderShort => 'm/f/n';

  @override
  String get fieldGender => 'Genre (m/f/n)';

  @override
  String get fieldGenitiveShort => 'Gén.';

  @override
  String get fieldGenitive => 'Génitif';

  @override
  String get fieldTerm => 'Notion';

  @override
  String get fieldExplanation => 'Explication';

  @override
  String get fieldHeading => 'Sens ou infinitif';

  @override
  String get fieldForms => 'Formes';

  @override
  String get fieldFormLabel => 'Étiquette';

  @override
  String get fieldFormValue => 'Forme';

  @override
  String formLabelSemantics(int row) {
    return 'Ligne $row, étiquette';
  }

  @override
  String formValueSemantics(int row) {
    return 'Ligne $row, forme';
  }

  @override
  String get fieldSentenceNl => 'Phrase néerlandaise';

  @override
  String get fieldSentenceTarget => 'Traduction';

  @override
  String get fieldGrammarPoint => 'Point de grammaire (facultatif)';

  @override
  String get fieldDate => 'Date, période ou époque';

  @override
  String get fieldEvent => 'Événement';

  @override
  String get fieldContext => 'Contexte (facultatif)';

  @override
  String get moreFields => 'Plus de champs';

  @override
  String get fewerFields => 'Moins de champs';

  @override
  String get rowIncomplete => 'Incomplète, non enregistrée';

  @override
  String get cardIncomplete =>
      'Remplissez les champs obligatoires pour enregistrer la carte.';

  @override
  String get addRow => 'Ajouter une ligne';

  @override
  String get removeRow => 'Supprimer la ligne';

  @override
  String get nextCard => 'Suivante';

  @override
  String get showPreview => 'Afficher l\'aperçu';

  @override
  String get hidePreview => 'Masquer l\'aperçu';

  @override
  String get fields => 'Champs';

  @override
  String get preview => 'Aperçu';

  @override
  String get previewEmpty => 'Rien à afficher';

  @override
  String previewLabel(String content) {
    return 'Aperçu de la carte : $content';
  }

  @override
  String incompleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartes sont incomplètes',
      one: '1 carte est incomplète',
    );
    return '$_temp0';
  }

  @override
  String get incompleteMessage => 'Elles ne seront pas enregistrées.';

  @override
  String get keepEditing => 'Continuer';

  @override
  String get discard => 'Abandonner';

  @override
  String get cardGone => 'Cette carte n\'existe plus.';

  @override
  String get printWhat => 'Quoi';

  @override
  String get printNothing => 'Il n\'y a pas encore de paquets.';

  @override
  String get fronts => 'Rectos';

  @override
  String get backs => 'Versos';

  @override
  String get checklist => 'Vérifiez dans la fenêtre d\'impression';

  @override
  String get checkDuplex => 'Recto verso, se tourne comme un livre';

  @override
  String get checkA4 => 'A4';

  @override
  String get checkScale => 'Ne pas modifier l\'échelle (100 %)';

  @override
  String get sharePdf => 'Partager le PDF';

  @override
  String shareFile(String name) {
    return 'Partager $name';
  }

  @override
  String get noDuplex => 'Mon imprimante n\'imprime pas en recto verso';

  @override
  String get manualStepFronts => '1. Imprimez les rectos';

  @override
  String get manualStepTurn => '2. Retournez la pile comme ceci';

  @override
  String get manualStepTurnHint =>
      'Remettez les feuilles dans le bac, retournées sur le bord long, côté vierge vers la face d\'impression.';

  @override
  String get manualStepBacks => '3. Imprimez les versos';

  @override
  String get frontsFileName => 'rectos';

  @override
  String get backsFileName => 'versos';

  @override
  String get pdfFileName => 'cartes-memoire';

  @override
  String get howToCut => 'Comment découper';

  @override
  String get cutEdges => 'Coupez les bords, le long des repères.';

  @override
  String get cutColumns => 'Coupez la feuille en deux colonnes.';

  @override
  String get cutRows => 'Coupez chaque colonne en quatre cartes.';

  @override
  String get notCalibrated =>
      'Votre imprimante n\'est pas encore calibrée : les versos peuvent être un peu décalés.';

  @override
  String get calibrate => 'Calibrer';

  @override
  String get calibration => 'Calibrage';

  @override
  String get calibrationHint =>
      'Imprimez la feuille de test en recto verso. Tenez-la face à la lumière, verso vers vous, et lisez où la croix du recto tombe sur l\'échelle en A–D.';

  @override
  String get printTestSheet => 'Imprimer la feuille de test';

  @override
  String get backOffsetX => 'Verso X';

  @override
  String get backOffsetXHint => 'Plus vers la droite';

  @override
  String get backOffsetY => 'Verso Y';

  @override
  String get backOffsetYHint => 'Plus vers le bas';

  @override
  String get decrease => 'Diminuer';

  @override
  String get increase => 'Augmenter';

  @override
  String get keyboardShortcuts => 'Raccourcis clavier';

  @override
  String get shortcutBoldItalic => 'Gras / italique';

  @override
  String get shortcutNextCard => 'Enregistrer et carte suivante';

  @override
  String get about => 'À propos';

  @override
  String get licences => 'Licences';

  @override
  String sheetNumber(int number) {
    return 'Feuille $number';
  }

  @override
  String sheetThumbnail(int number) {
    return 'Aperçu de la feuille $number';
  }

  @override
  String get testSheetFileName => 'feuille-de-test';

  @override
  String get testSheetFrontTitle =>
      'Feuille de test · recto · recto verso, reliure bord long, échelle 100 %';

  @override
  String get testSheetBackTitle => 'Feuille de test · verso';
}
