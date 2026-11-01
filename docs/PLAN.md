# Plan: Flashcards app v1 (Flutter, iPad + iPhone, App Store)

## Context

A tool for making printed, double-sided flash cards for VWO students. The printed card is the product; the app organises content and produces print-ready A4 PDFs. This plan is the v1 spec. v1 goes out through the Apple App Store, mainly for family use.

## Scope (agreed with owner)

| Topic | v1 decision |
|---|---|
| Audience | Mainly our family; distributed through TestFlight, then the App Store |
| Platforms | iPad and iPhone |
| Card types | All five: Vocabulary, Begrip, Paradigm, Sentence, History. The type belongs to the card; a deck can mix types |
| Organisation | Map → submap → deck. A new deck asks for a map, a submap and a title. The domain knows nothing about school years or subjects; the UI only suggests them as examples |
| Card size | One size for every card: 95×69 mm, so cards fit in an A7 card box. 8 cards per A4 sheet |
| Printing | Mirrored backs, cut ticks, footer, overflow flagging, one printer calibration (back X/Y offset) with test sheet, fronts/backs fallback export |
| Entry | Form per card (live PDF preview) + fast list entry |
| Storage | **JSON files**, not a database (see Milestone 2 for why) |
| Backup | iCloud device backup (files in Application Support) |
| Text | Plain text with FR/DE accents, plus bold/italic |
| UI languages | Dutch, English, French and German via ARB from the start |
| Licence | MIT |

## Milestone 0: Repository setup (done)

- Flutter pinned with FVM (`.fvmrc`), iOS-only project, bundle ID `nl.markbeij.flashcards`, MIT licence, `pubspec.lock` committed.
- `CLAUDE.md` with the project rules and commands; `docs/DECISIONS.md` for decisions and spike results.
- Dependencies: `path_provider`, `pdf`, `printing`, `uuid`, `flutter_riverpod`, `go_router`, `flutter_localizations`/`intl`. No code generation: JSON (de)serialisation is hand-written for the five card types.
- Font: Gentium Book Plus (SIL OFL; regular/italic/bold/bold-italic) in `assets/fonts/`, with its OFL text. Used only in the PDF.

## Milestone 1: Spikes (done; results in `docs/DECISIONS.md`)

0. **Print fidelity (physical).** Direct AirPrint via `Printing.layoutPdf` is the print path; calibration is a back X/Y offset only.
1. **Text.** FR/DE and bold/italic runs render correctly in Gentium Book Plus via `pdf` RichText.
2. **Overflow measurement.** Lay out the content at the card's inner width with unbounded height and compare `box.height` with the available height; also flag any single word wider than the content width.

## Milestone 2: Domain and data (`lib/domain`, `lib/data`)

**Why JSON files instead of a database:**
- The data is small: a family, maybe 5,000–20,000 cards, which is a few MB and fits in memory.
- v1 needs no heavy queries.

The cost is safe saving and keeping links between files consistent. Both are handled once, in the store layer below.

- **Card content:** a sealed class `CardContent` with one subclass per type, holding structured fields:
  - vocabulary: NL singular/plural, target singular/plural, language (Latin, French, German, English), article/gender, extras such as Latin genitive
  - paradigm: meaning/infinitive + label/value rows
  - begrip: term, explanation
  - sentence: NL, target, optional grammar point
  - history: date/range/era, event, optional context

  Each type gets hand-written `toJson`/`fromJson` and a validator. Blank optional fields are omitted from layout.
- **Rich text:** fields hold a minimal inline markup (`**bold**`, `*italic*`) parsed into runs. It stays editable in a plain TextField with a B/I toolbar.
- **Deck model:** `Deck(id, map, submap, title, lastCardType?, lastLanguage?)`. Map and submap are plain text on the deck, not separate objects: a map or submap exists as long as a deck uses it. All three are required. Maps, submaps and decks are natural-sorted (H2 < H10), with no manual reordering.
- **Footer:** the deck title plus `#n`, on both sides.
- **Card number `#n`:** fixed per deck in creation order (`seq` = highest + 1). Gaps remain after a delete, and a moved card gets the next number in its new deck. Cards cannot be reordered, so numbers on cards already printed don't change.
- **Files** under `Application Support/library/`. Each file has a `formatVersion: 1` field; migration code is written only when a format actually changes.
  - `decks.json`: all decks
  - `cards/<deckId>.json`: the cards in one deck, each with `uuid`, `seq`, `type`, `fields`, `createdAt`, `updatedAt`
  - `settings.json`: the single calibration (back dx/dy mm), the last opened deck/card, the last print selection, and whether the cutting guide has been shown
- **Store** (`lib/data/store/`): loads everything into memory at startup.
  - State lives in a `LibraryNotifier` holding immutable maps; derived providers read it with `select`.
  - A separate `StoreWriter` listens for changes and keeps a set of changed files. It writes them after a short delay, atomically per file (temp file → flush → rename), through one write queue.
  - It also saves immediately when the app goes to the background, via `AppLifecycleListener.onInactive`/`onHide`.
  - The library folder comes from `getApplicationSupportDirectory()` (iOS `Library/Application Support`, included in iCloud Backup).
  - Entry screens keep their drafts locally and commit to the store when a row is finished or loses focus, not on every keystroke.
  - Integrity rules live here: deleting a deck deletes its card file after a confirmation, and moving a card rewrites both card files in one queued operation.

## Milestone 3: Rendering (`lib/render`), the single source of truth for card appearance

- `card_size.dart`: the one card size as constants — 95×69 mm, A4, 10 mm margins, 2 columns × 4 rows.
- `grid.dart`: pure mm geometry → card rects per page, mirrored columns for the back page, and the calibration offset applied to the back only. Unit-tested with numbers.
- `templates/`: one `pdf` widget builder per card type and side, plus a shared card frame with the footer, such as `Woordjes H3 · #17`.
- `sheet.dart`: builds the duplex document — uniform grid on every page, alternating front/back pages, cut ticks in the margins, no card borders, a "swap front/back" option at print time.
- `overflow.dart`: the measurement from Spike 2. Returns the cards that don't fit; they are flagged and never shrunk.
- `test_sheet.dart`: the calibration test page from Spike 0.
- Outputs: `Printing.layoutPdf` (AirPrint), sharing the full PDF, and separate `fronts.pdf`/`backs.pdf` via `Printing.sharePdf`.
- Preview everywhere = the rasterised PDF (`PdfPreview` / `Printing.raster`). No Flutter-widget copy of card layout.

## Milestone 4: UI (`lib/ui`, `lib/l10n`)

### Mental model

A box of cards that you print.
- **Maps and submaps** group decks.
- **A deck** has a title and holds cards.
- **A card** lives in exactly one deck. Its type belongs to the card, not the deck.
- **Three places:** Library, Print, Settings.

### Shell (`lib/ui/shell/adaptive_shell.dart`)

The layout depends on the window size, not the device type.
- **Two columns from 680 pt wide** (and at least 500 pt tall): Library on the left, detail on the right.
- **A single navigation stack below that.** iPhone is portrait-only.
- **No tab bar.**
  - The gear (Settings) is in the navigation bar.
  - The bottom toolbar holds `[Print]` and `[New deck]` in the Library, and `[Print…]` and `[+ Add cards]` inside a deck.
- **State survives layout changes.** The selection (deckId, cardId) and the editing session (controllers keyed by card id) live in Riverpod above the layout switch. One go_router route set serves both layouts.
- **Widgets:** `MaterialApp` with iOS platform behaviour, Cupertino widgets for the visible parts, and Material only where Cupertino has nothing (`MenuAnchor`).
- **Fonts:** SF for the UI; Gentium Book Plus appears only in the PDF preview.
- **Display:** dark mode in the UI, but the PDF preview stays white paper. Dynamic Type is supported (clamped to 1.6 in the grid). Touch targets are at least 44 pt.

### Library

- **Levels:** the Library root lists the maps. A map shows its submaps as section headers with their decks underneath. A deck shows its cards.
- **New deck:** one sheet with three required fields:
  - map, with the hint "e.g. school year" and the existing maps as suggestions
  - submap, with the hint "e.g. subject" and the existing submaps of that map as suggestions
  - title
- **Deck:** a "⋯" menu offers Edit (the same three fields; changing map or submap moves the deck) and Delete (with confirmation).
- **Card row:** type icon, front text (markup removed), back text in grey, `#n`, and an overflow badge (icon + text). A "⋯" menu (also on right-click or long-press) offers Edit, New card like this, Move to…, Delete. Deleting shows an undo toast; Cmd-Backspace also deletes.
- **Select mode:** Move and Delete only.
- **Empty states:** one sentence, one example, one button. For example: "Make a deck, e.g. map VWO 4, submap Latijn, title Woordjes H3" [New deck]. An empty deck shows tiles for the 5 types.

### Entry (`lib/ui/entry/`)

**"Add cards"** opens directly in the deck's last card type and language. A title menu switches the type.

**Vocabulary grid** (iPad, two-column layout):
- The columns depend on the language:
  - Latin: NL, Latin, genitive, gender
  - German: NL, article, word, plural
  - French: NL, article, word
  - English: NL, English
- Other fields sit behind a disclosure arrow on the row.
- Return/Tab goes to the next field; Return on the last field saves the row and starts a new one.
- One explicit `FocusNode` per row × field. Focus moves synchronously in `onEditingComplete`. Tab handling is overridden inside a `FocusTraversalGroup`.
- The gender field is a one-character `TextField` (m/f/n).
- No Save button: each row is saved when you leave it. Done closes the screen.
- A fixed B/I toolbar at the top sits inside a `TextFieldTapRegion`, so tapping it doesn't drop focus.
- Autocorrect, suggestions, spell check, auto-capitalisation and smart quotes are off for the whole grid. One setting for all fields stops the QuickType bar from making the grid jump.
- The preview pane (≈320 pt) shows the current row's card. It updates after about 400 ms without typing and never takes focus. It hides when the keyboard leaves too little height.

**iPhone "rapid card":** the same row engine with one visible row. Large fields; Next → Next saves and clears. A counter, the last 3 cards faded above, and the preview on demand.

**Rich editor** (begrip, paradigm, sentence, history):
- A stacked form. The front/back preview is beside it on iPad and behind a Fields/Preview segmented control on iPhone.
- Paradigm: Return adds a row. "New card like this" copies the labels and clears the values.
- Bold/italic markup shows styled in the editor, with the markers dimmed, via a `TextEditingController.buildTextSpan` override that keeps the composing underline. The parser is the same one the PDF uses. This applies only to fields where bold/italic matters (explanation, sentence, context); vocabulary fields are plain.
- Cmd-B/I via `Shortcuts`/`Actions`.

**Overflow:** a badge plus plain words: "Doesn't fit on the card — shorten it." Never a modal dialog during entry. Overflow results are cached by content hash.

**Preview rendering:** build the PDF on the main isolate first and time it on the oldest family iPad. Move PDF building (and the overflow check) to a long-lived worker isolate only if typing feels slow.

### Print (`lib/ui/print/`)

A full-screen route with two screens. It opens either from a deck ("Print…", with that deck preselected) or from the Library (with the last selection).

1. **Set-up page** (scrolling), with a sticky bar "48 cards · 6 sheets [Preview]":
   - **What:** the maps, submaps and decks with checkboxes; ticking a map or submap ticks its decks.
   - **Doesn't fit:** overflowing cards appear inline with Fix / Skip; the default is Skip, and the print job is never blocked. This section is hidden when nothing overflows.
   - **Direction**, in words: "Front shows: Dutch / Latin" ⇄.
2. **Preview:** sheet thumbnails with a Fronts/Backs toggle.
   - A short checklist: "Double-sided, flips like a book · A4 · don't change the scale". Each item is a word plus a small illustration.
   - Then the actions:
     - **[Print]** calls `Printing.layoutPdf`, which always returns A4.
     - **Share PDF.**
     - **"My printer can't print double-sided"** (in the ⋯ menu): fronts → a "turn the stack over like this" illustration → backs.
   - The **cutting guide** (3 illustrations: edges, columns, rows) appears automatically after the first successful print; after that it is a "How to cut" link.
   - `sharePdf` gets `bounds` for the iPad popover.
   - If no calibration exists yet, a non-blocking banner links to it.

### Settings

A pushed page with:
- **Calibration:** "Print test sheet" plus one illustrated form with two ± fields: back X and Y offset in 0.5 mm steps, read off the printed scale. The value can also be typed in.
- **About/licences:** `LicenseRegistry` + OFL.
- **Keyboard shortcuts** as a static list.

### Shortcuts and system integration

- **Shortcuts:**

| Shortcut | Action |
|---|---|
| Cmd-N | Add cards |
| Shift-Cmd-N | New deck |
| Cmd-P | Print… |
| Cmd-B / Cmd-I | Bold / italic |
| Cmd-Return | Commit and start the next card |
| Cmd-Backspace | Delete |
| Esc | Done |

- **No state restoration:** the last deck/card comes from `settings.json`.
- **`CFBundleLocalizations`** lists nl, en, fr, de, so the system print dialog matches the app's language.

### Accessibility and l10n

- Short grid headers that may wrap to 2 lines; the full name goes in the semantics label.
- ICU plurals; text wraps and never truncates.
- VoiceOver:
  - cells are labelled "Card 12, Latin word"
  - "Card 12 saved" is announced when a row is saved
  - the preview raster has a text label with the card's content
- ARB files: `app_nl.arb` (template), `app_en.arb`, `app_fr.arb`, `app_de.arb`; no hard-coded strings.
- Printed labels on cards (m/v/o, gen.) are content, not UI language: they follow the card's language.

### Build order

Riskiest first, tried on the real iPad as soon as each works:
1. store, writer and lifecycle flush (domain + store unit tests)
2. vocabulary grid with a minimal deck picker, tested on the iPad with software keyboard, hardware keyboard and trackpad: Return/Tab and new-row focus without keyboard flicker, the one-character gender field, no jumping from the QuickType bar, grid visible above the keyboard, toolbar taps keep focus
3. card preview (time it; see "Preview rendering")
4. adaptive shell + Library; editing state lives above the layout switch (rule + widget test)
5. markup controller and rich editor; iPhone rapid card
6. print flow
7. calibration and settings
8. shortcuts and l10n polish

## Milestone 5: App Store release

- App icon, display name, `ITSAppUsesNonExemptEncryption = false`, orientations, minimum iOS version.
- Privacy policy URL (required even with no data collection): a short static page (e.g. GitHub Pages) saying no data is collected. Privacy label: "Data Not Collected".
- App Store Connect record, age rating, screenshots (iPhone 6.9", iPad 13"), at least NL metadata.
- TestFlight build for the family first, then submit for review.

## Verification

- `fvm flutter test` covers:
  - domain validators and the JSON round-trip for each card type
  - the markup parser
  - grid geometry, with exact mm assertions including mirroring and calibration
  - overflow detection
  - the store: atomic write (no partial file after an interrupted save), deleting a deck, moving cards between decks, reload after restart
- Golden tests: rasterise a sample sheet for each card type with `Printing.raster` and compare against committed PNGs.
- Run on the iPad and iPhone simulators. Enter cards in each type with both editors; check that the preview matches the printed output.
- On a real iPad:
  - enter 50 Latin words using only the keyboard, with a hardware keyboard and with the software keyboard
  - resize live in Split View / Stage Manager while typing (nothing may be lost)
  - test VoiceOver on the grid
  - check the UI in German, the longest language
- Widget tests: grid focus order (Return/Tab, new row), a layout switch at 680 pt keeps selection and draft, the overflow badge appears.
- Physical: print the test sheet and a full sheet of cards on the real printer, cut with the paper cutter, check that front/back alignment after calibration is within ~1 mm, and that the cards fit the A7 box.
- Install the TestFlight build on a family device; enter, print, then reinstall from backup to confirm the data survives.
