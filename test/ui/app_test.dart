import 'package:flashcards/data/store/library.dart';
import 'package:flashcards/data/store/library_notifier.dart';
import 'package:flashcards/data/store/settings.dart';
import 'package:flashcards/domain/card_content.dart';
import 'package:flashcards/domain/deck.dart';
import 'package:flashcards/domain/flashcard.dart';
import 'package:flashcards/ui/library/card_row.dart';
import 'package:flashcards/ui/providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

const _deck = Deck(
  id: 'd1',
  map: 'VWO 4',
  submap: 'Latijn',
  title: 'Woordjes H3',
  lastCardType: CardType.vocabulary,
  lastLanguage: VocabLanguage.latin,
);

final _at = DateTime.utc(2026, 11, 1);

Flashcard _card(int seq, CardContent content) => Flashcard(
  uuid: 'c$seq',
  seq: seq,
  content: content,
  createdAt: _at,
  updatedAt: _at,
);

Library _library({List<Flashcard> cards = const [], bool open = true}) =>
    Library(
      decks: const {'d1': _deck},
      cards: {
        if (cards.isNotEmpty) 'd1': {for (final c in cards) c.uuid: c},
      },
      settings: Settings(lastDeckId: open ? 'd1' : null),
    );

const _puella = VocabularyContent(
  language: VocabLanguage.latin,
  nlSingular: 'meisje',
  targetSingular: 'puella',
);

void main() {
  testWidgets('an empty library starts in Dutch with one example', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Bibliotheek'), findsOneWidget);
    expect(find.textContaining('VWO 4, submap Latijn'), findsOneWidget);
    expect(find.text('Nieuwe stapel'), findsWidgets);
  });

  testWidgets('a new deck asks for map, submap and title and opens', (
    tester,
  ) async {
    final container = await pumpApp(tester);
    await tester.tap(
      find.widgetWithText(CupertinoButton, 'Nieuwe stapel').first,
    );
    await tester.pumpAndSettle();

    final fields = find.byType(CupertinoTextField);
    await tester.enterText(fields.at(0), 'VWO 4');
    await tester.enterText(fields.at(1), 'Latijn');
    await tester.enterText(fields.at(2), 'Woordjes H3');
    await tester.pump();
    await tester.tap(find.text('Bewaar'));
    await tester.pumpAndSettle();

    final decks = container.read(libraryProvider).decks.values;
    expect(decks.single.title, 'Woordjes H3');
    // The deck is open, with tiles for the five card types.
    expect(find.text('Woordjes H3'), findsWidgets);
    expect(find.text('Rijtje'), findsOneWidget);
  });

  testWidgets('the last deck opens at startup', (tester) async {
    await pumpApp(tester, library: _library(cards: [_card(1, _puella)]));
    expect(find.text('Woordjes H3'), findsWidgets);
    expect(find.text('meisje'), findsOneWidget);
    expect(find.text('puella'), findsOneWidget);
    expect(find.text('#1'), findsOneWidget);
  });

  testWidgets('a card that does not fit shows the overflow badge', (
    tester,
  ) async {
    final long = List.filled(60, 'een lange uitleg').join(' ');
    await pumpApp(
      tester,
      library: _library(
        cards: [
          _card(1, _puella),
          _card(2, BegripContent(term: 'Verlichting', explanation: long)),
        ],
      ),
    );
    expect(find.text('Past niet'), findsOneWidget);
  });

  testWidgets('deleting a card can be undone', (tester) async {
    final container = await pumpApp(
      tester,
      library: _library(cards: [_card(1, _puella)]),
    );
    await tester.tap(
      find.descendant(
        of: find.byType(CardRow),
        matching: find.byIcon(CupertinoIcons.ellipsis_circle),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Verwijder'));
    await tester.pumpAndSettle();
    expect(container.read(libraryProvider).cardsIn('d1'), isEmpty);

    await tester.tap(find.text('Herstel'));
    await tester.pumpAndSettle();
    expect(container.read(libraryProvider).cardsIn('d1').keys, ['c1']);
  });

  group('vocabulary grid', () {
    testWidgets('Return and Tab move through the row; the last field saves '
        'it and starts a new one', (tester) async {
      final container = await pumpApp(tester, library: _library());
      await tester.tap(find.text('Kaarten toevoegen'));
      await tester.pumpAndSettle();

      final nl = field('Nieuwe kaart, Nederlands woord');
      final latin = field('Nieuwe kaart, Woord (Latijn)');
      final genitive = field('Nieuwe kaart, Genitivus');
      final gender = field('Nieuwe kaart, Geslacht (m/f/n)');
      expect(hasFocus(tester, nl), isTrue);

      await tester.enterText(nl, 'meisje');
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(hasFocus(tester, latin), isTrue);

      await tester.enterText(latin, 'puella');
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();
      expect(hasFocus(tester, genitive), isTrue);

      await tester.enterText(genitive, 'puellae');
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();
      expect(hasFocus(tester, gender), isTrue);

      // The gender field keeps one of m/f/n.
      await tester.enterText(gender, 'X');
      expect(tester.widget<EditableText>(gender).controller.text, '');
      await tester.enterText(gender, 'F');
      expect(tester.widget<EditableText>(gender).controller.text, 'f');

      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();

      final card = container.read(libraryProvider).cardsIn('d1').values.single;
      expect(
        card.content,
        const VocabularyContent(
          language: VocabLanguage.latin,
          nlSingular: 'meisje',
          targetSingular: 'puella',
          genitive: 'puellae',
          gender: Gender.feminine,
        ),
      );
      // The saved row stays above; focus is in the new, empty row.
      expect(field('Kaart 1, Nederlands woord'), findsOneWidget);
      expect(hasFocus(tester, nl), isTrue);
      expect(tester.widget<EditableText>(nl).controller.text, isEmpty);

      // Shift-Tab goes back to the last field of the saved row.
      await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(hasFocus(tester, field('Kaart 1, Geslacht (m/f/n)')), isTrue);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('an incomplete row is not saved and keeps focus', (
      tester,
    ) async {
      final container = await pumpApp(tester, library: _library());
      await tester.tap(find.text('Kaarten toevoegen'));
      await tester.pumpAndSettle();
      final nl = field('Nieuwe kaart, Nederlands woord');
      await tester.enterText(nl, 'meisje');
      for (var i = 0; i < 4; i++) {
        await tester.testTextInput.receiveAction(TextInputAction.next);
        await tester.pump();
      }
      expect(container.read(libraryProvider).cardsIn('d1'), isEmpty);
      expect(hasFocus(tester, field('Nieuwe kaart, Woord (Latijn)')), isTrue);
      await tester.pump(const Duration(seconds: 1));
    });
  });

  group('layout switch at 680 pt', () {
    testWidgets('keeps the selection', (tester) async {
      final container = await pumpApp(
        tester,
        library: _library(cards: [_card(1, _puella)]),
      );
      // Two columns: the Library column is beside the deck.
      expect(find.text('Latijn'), findsOneWidget);
      container.read(cardSelectionProvider.notifier).select('c1');

      setSize(tester, narrow);
      await tester.pumpAndSettle();
      expect(container.read(cardSelectionProvider), 'c1');
      expect(find.text('meisje'), findsOneWidget);

      setSize(tester, wide);
      await tester.pumpAndSettle();
      expect(container.read(cardSelectionProvider), 'c1');
      expect(find.text('meisje'), findsOneWidget);
    });

    testWidgets('keeps the draft between grid and rapid card', (tester) async {
      await pumpApp(tester, library: _library());
      await tester.tap(find.text('Kaarten toevoegen'));
      await tester.pumpAndSettle();
      await tester.enterText(field('Nieuwe kaart, Nederlands woord'), 'meisje');
      await tester.pump();

      setSize(tester, narrow);
      await tester.pumpAndSettle();
      // The rapid card shows the same draft.
      expect(find.text('Volgende'), findsOneWidget);
      final nl = field('Nieuwe kaart, Nederlands woord');
      expect(tester.widget<EditableText>(nl).controller.text, 'meisje');

      setSize(tester, wide);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<EditableText>(field('Nieuwe kaart, Nederlands woord'))
            .controller
            .text,
        'meisje',
      );
    });
  });
}
