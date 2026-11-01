import 'package:flutter/cupertino.dart';

import '../../domain/card_content.dart';
import '../../l10n/app_localizations.dart';

extension CardTypeLabels on CardType {
  String label(AppLocalizations l10n) => switch (this) {
    CardType.vocabulary => l10n.typeVocabulary,
    CardType.begrip => l10n.typeBegrip,
    CardType.paradigm => l10n.typeParadigm,
    CardType.sentence => l10n.typeSentence,
    CardType.history => l10n.typeHistory,
  };

  /// A one-line example for the empty deck's tiles.
  String example(AppLocalizations l10n) => switch (this) {
    CardType.vocabulary => l10n.typeVocabularyExample,
    CardType.begrip => l10n.typeBegripExample,
    CardType.paradigm => l10n.typeParadigmExample,
    CardType.sentence => l10n.typeSentenceExample,
    CardType.history => l10n.typeHistoryExample,
  };

  IconData get icon => switch (this) {
    CardType.vocabulary => CupertinoIcons.textformat_abc,
    CardType.begrip => CupertinoIcons.book,
    CardType.paradigm => CupertinoIcons.table,
    CardType.sentence => CupertinoIcons.text_quote,
    CardType.history => CupertinoIcons.time,
  };
}

extension VocabLanguageLabels on VocabLanguage {
  String label(AppLocalizations l10n) => switch (this) {
    VocabLanguage.latin => l10n.languageLatin,
    VocabLanguage.german => l10n.languageGerman,
    VocabLanguage.french => l10n.languageFrench,
    VocabLanguage.english => l10n.languageEnglish,
  };
}
