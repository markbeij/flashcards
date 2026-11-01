import '../../domain/card_content.dart';
import '../../l10n/app_localizations.dart';
import 'draft.dart';

/// A short header (may wrap to two lines) and the full name for screen
/// readers and form labels.
({String short, String full}) fieldLabel(
  AppLocalizations l10n,
  DraftField field,
  VocabLanguage language,
) {
  final lang = switch (language) {
    VocabLanguage.latin => l10n.languageLatin,
    VocabLanguage.german => l10n.languageGerman,
    VocabLanguage.french => l10n.languageFrench,
    VocabLanguage.english => l10n.languageEnglish,
  };
  return switch (field) {
    DraftField.nlSingular => (short: l10n.fieldNlShort, full: l10n.fieldNl),
    DraftField.nlPlural => (
      short: l10n.fieldNlPluralShort,
      full: l10n.fieldNlPlural,
    ),
    DraftField.targetSingular => (
      short: switch (language) {
        VocabLanguage.latin || VocabLanguage.english => lang,
        _ => l10n.fieldWordShort,
      },
      full: l10n.fieldTargetWord(lang),
    ),
    DraftField.targetPlural => (
      short: l10n.fieldPluralShort,
      full: l10n.fieldTargetPlural(lang),
    ),
    DraftField.article => (
      short: l10n.fieldArticleShort,
      full: l10n.fieldArticle,
    ),
    DraftField.gender => (short: l10n.fieldGenderShort, full: l10n.fieldGender),
    DraftField.genitive => (
      short: l10n.fieldGenitiveShort,
      full: l10n.fieldGenitive,
    ),
    DraftField.term => (short: l10n.fieldTerm, full: l10n.fieldTerm),
    DraftField.explanation => (
      short: l10n.fieldExplanation,
      full: l10n.fieldExplanation,
    ),
    DraftField.heading => (short: l10n.fieldHeading, full: l10n.fieldHeading),
    DraftField.nl => (short: l10n.fieldSentenceNl, full: l10n.fieldSentenceNl),
    DraftField.target => (
      short: l10n.fieldSentenceTarget,
      full: l10n.fieldSentenceTarget,
    ),
    DraftField.grammarPoint => (
      short: l10n.fieldGrammarPoint,
      full: l10n.fieldGrammarPoint,
    ),
    DraftField.date => (short: l10n.fieldDate, full: l10n.fieldDate),
    DraftField.event => (short: l10n.fieldEvent, full: l10n.fieldEvent),
    DraftField.context => (short: l10n.fieldContext, full: l10n.fieldContext),
  };
}

/// "Card 12, Latin word" or "New card, Latin word".
String cellSemantics(AppLocalizations l10n, DraftCard draft, DraftField field) {
  final name = fieldLabel(l10n, field, draft.language).full;
  return draft.seq == null
      ? l10n.newCardField(name)
      : l10n.cardField(draft.seq!, name);
}
