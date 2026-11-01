import '../../domain/card_content.dart';
import 'begrip.dart';
import 'face.dart';
import 'history.dart';
import 'paradigm.dart';
import 'sentence.dart';
import 'vocabulary.dart';

export 'face.dart';

/// What each side of a card shows.
CardFaces facesOf(CardContent content) => switch (content) {
  VocabularyContent() => vocabularyFaces(content),
  BegripContent() => begripFaces(content),
  ParadigmContent() => paradigmFaces(content),
  SentenceContent() => sentenceFaces(content),
  HistoryContent() => historyFaces(content),
};
