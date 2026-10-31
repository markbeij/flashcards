# Plan: Flashcards app v1 (Flutter, iPad + iPhone, App Store)

## Context

`flashcards-handoff.md` describes a tool for making printed, double-sided flash cards for VWO students. The printed card is the product; the app organises content and produces print-ready A4 PDFs. The repo is empty apart from the brief, a `.gitignore` and a GPL-3.0 `LICENSE`. This plan narrows the brief to a v1 that can go out through the Apple App Store, mainly for family use.

## Scope decisions (agreed with owner)

| Topic | v1 decision |
|---|---|
| Audience | Mainly our family; distributed through TestFlight, then the App Store |
| Platforms | iPad and iPhone only (no macOS, Windows or Android) |
| Card types | All five: Vocabulary, Begrip, Paradigm, Sentence, History |
| Organisation | Generic folder tree of any depth (like Files). A folder holds subfolders and cards. Optional colour per folder (inherited by subfolders) and an optional short label for the footer (e.g. "H3", "§2"). Plus free tags. No fixed vak/leerjaar levels |
| Printing | Fixed S/M/L sizes (in code), mirrored backs, cut ticks, footer, overflow flagging, one printer calibration (back X/Y offset) with test sheet, fronts/backs fallback export. **No** queue, print history, preset editor, per-card size, or multiple printers |
| Entry | Form per card (live PDF preview) + fast list entry. **No** CSV/paste import |
| Storage | **JSON files**, not a database (see Milestone 2 for why) |
| Backup | iCloud device backup only (files in Application Support). **No** export bundle or sharing |
| Text | Latin macrons, FR/DE accents, bold/italic, polytonic Greek. **No** images, sub/superscript, maths/chemistry |
| UI languages | Dutch, English, French and German via ARB from the start |
| Licence | Switch to MIT |

**Deferred (not v1):** export/import bundle and sibling sharing, print queue and print history ("only new/changed"), configurable presets (e.g. micro-perforated sheets), per-printer calibrations, CSV/paste import, images, sub/superscript, maths/chemistry, dividers, spell check, macOS/desktop, digital study/spaced repetition, sync between devices.

Kept open for later without extra v1 work: stable card UUIDs and `updatedAt` (enough to add print history later), structured fields (digital study), and JSON files (export bundle, iCloud Drive sync).

## Milestone 0: Repository setup

- Pin Flutter with FVM: `.fvmrc` → `3.47.6` (latest installed stable).
- `flutter create --platforms=ios --org nl.beijsolutions flashcards .` (confirm bundle ID with owner at this step).
- Replace `LICENSE` with MIT. Fix `.gitignore`: it ignores `*.lock`, which would drop `pubspec.lock` (apps should commit it).
- Move the brief to `docs/SPEC.md` and add a "v1 scope" section with the table above. Mark these brief sections as superseded: the vak/leerjaar tree, drift and the `VACUUM INTO` bundle. Add `CLAUDE.md` from the brief's starter, with these changes:
  - fill in the commands
  - UI languages are NL/EN/FR/DE
  - replace the rule "live SQLite DB never in iCloud Drive" with "all writes go through `lib/data/store`, atomically"
- Add `docs/DECISIONS.md` for spike results and the storage decision.
- Dependencies (owner approves this list with the plan): `path_provider`, `pdf`, `printing`, `uuid`, `flutter_riverpod`, `go_router`, `flutter_localizations`/`intl`. No code generation: write the JSON (de)serialisation by hand for the five card types. **Unicode NFC:** only if Spike 1 shows decomposed input actually occurs (e.g. text pasted from a PDF) and renders wrongly; then propose a package.
- Font: bundle **Gentium Plus** (SIL OFL; covers Latin macrons, FR/DE and polytonic Greek; has regular/italic/bold/bold-italic) in `assets/fonts/`, with its OFL text.

## Milestone 1: Spikes (results go in `docs/DECISIONS.md`)

Only assumptions whose failure would change the product get a spike. Run them in `spike/` before building on them.

0. **Print fidelity (physical).** One-page duplex test sheet (190 mm ruler, crosshairs front and back, grid outline ticks), printed via `Printing.layoutPdf` from a real iPad/iPhone over AirPrint. Measure scale error and front/back offset; note dialog behaviour (paper size, margins, duplex long edge, any "fit" scaling). Compare with printing the shared PDF from Files/another app. Decide the default print path.
1. **Text.** Render macrons (ā ē ī ō ū), FR/DE, polytonic Greek (e.g. ἀνθρώπῳ, ὁ λόγος), and bold/italic runs in Gentium Plus via `pdf` RichText. Check for missing glyphs. Check what the iOS keyboards (including polytonic Greek) produce and what text pasted from a PDF or website produces: precomposed or decomposed. If decomposed input renders wrongly, decide on NFC normalisation.
2. **Overflow measurement.** Lay out a card widget in fixed card constraints and read its box; compare it with the rendered result for short, long and multi-line text. If `layout()`/`box` is unreliable, fall back to measuring each text block's height against the available height.

Spikes 3–6 (entry grid, preview pipeline, adaptive shell, storage) were dropped on 2026-10-25: their failures don't force rework, so they are covered by the build order, rules and tests instead (see `docs/DECISIONS.md`).

## Milestone 2: Domain and data (`lib/domain`, `lib/data`)

**Why JSON files instead of a database:**
- The data is small: a family, maybe 5,000–20,000 cards, which is a few MB and fits in memory.
- v1 needs no heavy queries.
- Separate files make the deferred export, sharing and iCloud Drive sync simple. A live SQLite database can't sync through iCloud Drive.

The cost is safe saving and keeping links between files consistent. Both are handled once, in the store layer below. If digital study's review log later needs a database, it can be added as a separate store.

- **Card content:** a sealed class `CardContent` with one subclass per type, holding structured fields:
  - vocabulary: NL singular/plural, target singular/plural, language, article/gender, extras such as Latin genitive
  - paradigm: meaning/infinitive + label/value rows
  - begrip: term, explanation, subject
  - sentence: NL, target, optional grammar point
  - history: date/range/era, event, optional context

  Each type gets hand-written `toJson`/`fromJson` and a validator. Blank optional fields are omitted from layout.
- **Rich text:** fields hold a minimal inline markup (`**bold**`, `*italic*`) parsed into runs. It stays editable in a plain TextField with a B/I toolbar, and sub/superscript can be added later the same way.
- **Folder model:** `Folder(id, parentId, name, color?, shortLabel?, lastCardType?, lastLanguage?)`. Colour is inherited from the nearest ancestor that has one, and picked from 8 swatches. Folders are natural-sorted (H2 < H10, §1 < §2), with no manual reordering. The footer is the folder path (short label when set, otherwise name) plus `#n`.
- **Card number `#n`:** fixed per folder in creation order (`seq` = highest + 1). Gaps remain after a delete, and a moved card gets the next number in its new folder. Cards cannot be reordered, so numbers on cards already printed don't change.
- **Files** under `Application Support/library/`. Each file has a `formatVersion: 1` field; migration code is written only when a format actually changes.
  - `folders.json`: the whole tree
  - `cards/<folderId>.json`: the cards in one folder, each with `uuid`, `seq`, `type`, `fields`, `tags`, `createdAt`, `updatedAt`
  - `settings.json`: the single calibration (back dx/dy mm), the last opened folder/card, the last print selection, and whether the cutting guide has been shown
- **Store** (`lib/data/store/`): loads everything into memory at startup.
  - State lives in a `LibraryNotifier` holding immutable maps; derived providers read it with `select`.
  - A separate `StoreWriter` listens for changes and keeps a set of changed files. It writes them after a short delay, atomically per file (temp file → flush → rename), through one write queue.
  - It also saves immediately when the app goes to the background, via `AppLifecycleListener.onInactive`/`onHide`.
  - The library folder comes from `getApplicationSupportDirectory()` (iOS `Library/Application Support`, included in iCloud Backup).
  - Entry screens keep their drafts locally and commit to the store when a row is finished or loses focus, not on every keystroke.
  - Integrity rules live here: deleting a folder deletes its subfolders and their card files after a confirmation, and moving a card rewrites both card files in one queued operation.

## Milestone 3: Rendering (`lib/render`), the single source of truth for card appearance

- `presets.dart`: the three fixed sizes as constants — S 95×34 mm (16/sheet), M 95×46 (12), L 95×69 (8); A4, 10 mm margins, 2 columns — and the default size per card type: Vocab S, Sentence S, Paradigm M, History M, Begrip M.
- `grid.dart`: pure mm geometry for a preset → card rects per page, mirrored columns for the back page, and the calibration offset applied to the back only. Unit-tested with numbers.
- `templates/`: one `pdf` widget builder per card type and side, plus a shared card frame: folder colour accent inside the card only, and the footer path such as `Latijn · VWO 4 · H3 · §2 · #17`.
- `sheet.dart`: builds the duplex document — cards grouped by preset, uniform grid per page, alternating front/back pages, cut ticks in the margins, no card borders, a "swap front/back" option at print time.
- `overflow.dart`: the measurement from Spike 2. Returns the cards that don't fit; they are flagged and never shrunk.
- `test_sheet.dart`: the calibration test page from Spike 0.
- Outputs: `Printing.layoutPdf` (AirPrint), sharing the full PDF, and separate `fronts.pdf`/`backs.pdf` via `Printing.sharePdf`.
- Preview everywhere = the rasterised PDF (`PdfPreview` / `Printing.raster`). No Flutter-widget copy of card layout.

## Milestone 4: UI (`lib/ui`, `lib/l10n`)

Merged from the UX, iOS UI and Flutter feasibility consultations. Where they disagreed, the simpler option was chosen; the richer one is listed under "UI later".

### Mental model

A binder of cards that you print.
- **Folders** work like Files.
- **A card** lives in exactly one folder. Its type belongs to the card, not the folder.
- **Tags** cut across folders and are used only for filtering and choosing what to print.
- **Three places:** Library, Print, Settings.

### Shell (`lib/ui/shell/adaptive_shell.dart`)

The layout depends on the window size, not the device type.
- **Two columns from 680 pt wide** (and at least 500 pt tall): Library on the left (subfolders first, then cards), detail on the right.
- **A single navigation stack below that.** iPhone is portrait-only.
- **No tab bar.**
  - The gear (Settings) is in the navigation bar.
  - The bottom toolbar holds `[Print]` and `[New folder]` on the Library root, and `[Print…]` and `[+ Add <type>]` inside a folder.
- **State survives layout changes.** The selection (folderId, cardId) and the editing session (controllers keyed by card id) live in Riverpod above the layout switch. One go_router route set serves both layouts.
- **Widgets:** `MaterialApp` with iOS platform behaviour, Cupertino widgets for the visible parts, and Material only where Cupertino has nothing (`MenuAnchor`).
- **Fonts:** SF for the UI; Gentium Plus appears only in the PDF preview.
- **Display:** dark mode in the UI, but the PDF preview stays white paper. Dynamic Type is supported (clamped to 1.6 in the grid). Touch targets are at least 44 pt.

### Library

- **Card row:** type icon, front text (markup removed), back text in grey, at most 2 tags + "+n", `#n`, and an overflow badge (icon + text). A "⋯" menu (also on right-click or long-press) offers Edit, New card like this, Move to…, Tags…, Delete. Deleting shows an undo toast; Cmd-Backspace also deletes. No swipe actions.
- **Card list:** shows only the folder's own cards.
- **Folders:** "Move to…" instead of drag. The folder info sheet has name, 8 swatches, short label, and "inherited from …" when the colour comes from a parent.
- **Select mode:** Move and Delete only.
- **Empty states:** one sentence, one example, one button. For example: "Make a folder per subject, e.g. Latijn" [New folder]. An empty folder shows tiles for the 5 types.

### Entry (`lib/ui/entry/`)

**"Add cards"** opens directly in the folder's last card type and language. A title menu switches the type.

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
- A "Tag new cards" field applies to every card added in this session.
- No Save button: each row is saved when you leave it. Done closes the screen.
- A fixed toolbar at the top (ā ē ī ō ū, B/I) sits inside a `TextFieldTapRegion`, so tapping it doesn't drop focus. No accessory bar above the keyboard.
- Autocorrect, suggestions, spell check, auto-capitalisation and smart quotes are off for the whole grid. One setting for all fields stops the QuickType bar from making the grid jump.
- The preview pane (≈320 pt) shows the current row's card. It updates after about 400 ms without typing and never takes focus. It hides when the keyboard leaves too little height.

**iPhone "rapid card":** the same row engine with one visible row. Large fields; Next → Next saves and clears. A counter, the last 3 cards faded above, and the preview on demand.

**Rich editor** (begrip, paradigm, sentence, history):
- A stacked form. The front/back preview is beside it on iPad and behind a Fields/Preview segmented control on iPhone.
- Paradigm: Return adds a row. "New card like this" copies the labels and clears the values.
- Bold/italic markup shows styled in the editor, with the markers dimmed, via a `TextEditingController.buildTextSpan` override that keeps the composing underline. The parser is the same one the PDF uses. This applies only to fields where bold/italic matters (explanation, sentence, context); vocabulary fields are plain.
- Cmd-B/I via `Shortcuts`/`Actions`.

**Overflow:** a badge plus plain words: "Doesn't fit an M card — shorten it, or print this group as L." Never a modal dialog during entry. Overflow results are cached by (content hash, size).

**Preview rendering:** build the PDF on the main isolate first and time it on the oldest family iPad. Move PDF building (and the overflow check) to a long-lived worker isolate only if typing feels slow.

### Print (`lib/ui/print/`)

A full-screen route with two screens. It opens either from a folder ("Print…", with that folder and its subfolders preselected) or from the Library root (with the last selection).

1. **Set-up page** (scrolling), with three sections and a sticky bar "48 cards · 4 sheets [Preview]":
   - **What:** a folder tree with checkboxes, plus tag chips. Tags narrow the folders (AND); with no folder ticked, tags apply to the whole library.
   - **Groups:** one row per type with a size menu ("M ▾"). Overflowing cards appear inline with Fix / Try L / Skip; the default is Skip, and the print job is never blocked. This section is hidden when there is only one type and nothing overflows.
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
- **Calibration:** "Print test sheet" plus one illustrated form with two ± fields: back X and Y offset in 0.5 mm steps, read off the printed scale. The value can also be typed in. No scale correction (Spike 0: the printer scales both sides equally).
- **About/licences:** `LicenseRegistry` + OFL.
- **Keyboard shortcuts** as a static list.

### Shortcuts and system integration

- **Shortcuts:**

| Shortcut | Action |
|---|---|
| Cmd-N | Add cards |
| Shift-Cmd-N | New folder |
| Cmd-P | Print… |
| Cmd-B / Cmd-I | Bold / italic |
| Cmd-Return | Commit and start the next card |
| Cmd-Backspace | Delete |
| Esc | Done |

- **No state restoration:** the last folder/card comes from `settings.json`.
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

### UI later (not v1)

- Three-column layout with a tree sidebar.
- Accessory bar above the software keyboard.
- Swipe actions.
- Native `UIKeyCommand` shim (Cmd-hold overlay, iPadOS menu bar).
- Calibration wizard with one step per page.
- Half-height sheets.

### Build order

Riskiest first, tried on the real iPad as soon as each works:
1. store, writer and lifecycle flush (domain + store unit tests)
2. vocabulary grid with a minimal folder picker, tested on the iPad with software keyboard, hardware keyboard and trackpad: Return/Tab and new-row focus without keyboard flicker, the one-character gender field, no jumping from the QuickType bar, grid visible above the keyboard, toolbar taps keep focus, the Greek keyboard types precomposed characters
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
  - the store: atomic write (no partial file after an interrupted save), cascading folder delete, moving cards between folders, reload after restart
- Golden tests: rasterise sample sheets for each card type (including Greek and macrons) with `Printing.raster` and compare against committed PNGs.
- Run on the iPad and iPhone simulators. Enter cards in each type with both editors; check that the preview matches the printed output.
- On a real iPad:
  - enter 50 Latin words using only the keyboard, with a hardware keyboard and with the software keyboard
  - resize live in Split View / Stage Manager while typing (nothing may be lost)
  - test VoiceOver on the grid
  - check the UI in German, the longest language
- Widget tests: grid focus order (Return/Tab, new row), a layout switch at 680 pt keeps selection and draft, the overflow badge appears.
- Physical: print the test sheet and a full sheet of each preset on the real printer, cut with the paper cutter, and check that front/back alignment after calibration is within ~1 mm.
- Install the TestFlight build on a family device; enter, print, then reinstall from backup to confirm the data survives.
