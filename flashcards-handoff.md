# Flashcards app: project brief (handoff to Claude Code)

Put this file in the repo as `docs/SPEC.md`. The "CLAUDE.md starter" at the bottom goes in `CLAUDE.md` in the repo root.

Status: design discussion finished, no code written yet. Findings below were checked against package docs and the `pdf` package source. **No Flutter code was executed** (the sandbox had no SDK and could not reach pub.dev), so anything marked UNVERIFIED must be proven by a spike before building on it.

## 1. Goal

A native app for making **printed, double-sided flash cards** for children in the Dutch VWO. The printed card is the product. The app is the tool that organises content and produces print-ready PDFs.

## 2. Decisions made

- Flutter, one codebase. Each person installs their own copy.
- No server, no hosting, no accounts, no profiles. Data is stored locally on each device.
- Local data must be backup-able via iCloud (see section 6).
- Digital study (spaced repetition) is out of scope for v1. The data model must not block it later.
- Output: A4 portrait, printed double-sided on slightly thicker paper, cut with a paper cutter.
- UI language: Dutch (English optional). Use ARB/intl from the start.

## 3. Content model

Organisation tree: **Course (vak) -> Year -> Chapter (hoofdstuk) -> Paragraph (paragraaf)**.
- Implement as a generic node table (`id`, `parent_id`, `kind`, `name`, `sort`) so levels can be adjusted; the UI enforces the four levels.
- A card belongs to a paragraph (or a chapter if there are no paragraphs). Free-form tags in addition ("toets 3", "examenstof").
- "Year" probably means leerjaar (VWO 4). Confirm (see section 9).
- Each course has a colour.

Every card: stable UUID, type, structured fields (never pre-rendered text), node reference, tags, created/updated, print history (which print batch, when).

| Type | Fields | Front | Back | Size |
|---|---|---|---|---|
| Vocabulary (NL to EN/FR/DE/LA) | NL singular + plural, target singular + plural, article/gender, language-specific extras (Latin genitive, German plural form) | Dutch (+ plural) | Target (+ plural, gender) | S |
| Sentence | NL sentence, target sentence, optional highlighted grammar point | Sentence | Translation | S/M |
| Paradigm (irregular verbs, Latin principal parts, conjugations) | Label/value rows | Meaning or infinitive | Forms table | S/M |
| History | Date / range / era, event, optional context | Date | Event | M (reverse optional) |
| Begrip | Term, explanation, subject, optional image | Term | Explanation | M/L |

Optional fields are omitted from the layout when blank. Any deck can be printed in either direction (swap sides at print time, do not duplicate data).

Rich content to plan for in the data model: bold/italic, sub- and superscript, images, maths/chemistry notation (later), Latin macrons, Greek (possibly polytonic).

## 4. Printing requirements

- Presets are grid definitions (columns, rows, card size, margins, gutter). Starting points on A4 with 10 mm margins, 2 columns: **S 95x34 mm (16/sheet), M 95x46 mm (12/sheet), L 95x69 mm (8/sheet)**. Keep presets configurable so micro-perforated card sheets can be added.
- One uniform size per deck so cards can be shuffled and stack-cut. A print job groups cards by preset; every page has a uniform grid.
- Back pages mirror the columns (flip on long edge); rows keep the same vertical position.
- Cut ticks in the margins, not printed card borders. No edge-to-edge colour; use colour only inside the card, or print on coloured paper.
- Footer on both sides: `Course · Year · H3 · §2 · #17`.
- Per-printer calibration: back-side X/Y offset **and scale**, set from a printed test sheet (with a 190 mm ruler and crosshairs on both sides).
- Print at 100%. Avoid anything that implies "fit to page".
- Print history and queue: print only new/changed cards; add paragraphs to a queue and print when sheets are full; reprint a single card.
- Overflow validation: a card whose text does not fit the preset is flagged, never silently shrunk.
- Fallback outputs: export fronts.pdf and backs.pdf (manual duplex), and export the full PDF for printing from Preview/Acrobat at "Actual size".

## 5. Architecture

- Flutter + **drift** (SQLite). Store the DB in the app support/documents directory (never Caches or tmp).
- PDF: `pdf` package (pure Dart, widget-based). Printing/preview: `printing` package.
- **Single source of truth for card appearance:** card templates exist only as `pdf` widgets. The on-screen preview is the real PDF rasterised (`PdfPreview` / `Printing.raster`), so preview and print cannot diverge. Flutter widgets are used only for the editing UI.
- Overflow detection by laying out the card widget with the card's constraints and checking the resulting box (the `pdf` widgets expose `layout(...)` and `box`). UNVERIFIED, prove in Spike 2.
- Suggested layout: `lib/data` (drift), `lib/domain` (card types, fields, validation), `lib/render` (pdf templates, presets, calibration), `lib/ui`.
- Entry UX: grid per card type with Tab/Enter navigation, paste from Excel/Sheets, CSV/tab-separated import, live preview.

## 6. Backup and portability

- iOS/iPadOS: iCloud Backup includes `Documents/` and `Library/Application Support/` automatically; `Library/Caches/` and `tmp/` are excluded. SQLite `-wal`/`-shm` sidecar files belong to the store. Source: [Apple Developer Forums](https://developer.apple.com/forums/thread/113648).
- macOS/Windows: iCloud Backup does not apply to Mac app containers (Time Machine does); not verified here. So the app needs its own export.
- **Export/import bundle** (zip: consistent DB snapshot made with `VACUUM INTO` + media + format version). Saved/restored through the system share sheet or file picker, so the user can put it in iCloud Drive (on Windows: the iCloud Drive folder). The same format is used to share a deck between siblings.
- Do **not** keep the live SQLite DB inside iCloud Drive (sync conflicts on a multi-file DB). Do not use `icloud_storage` (last release January 2023, needs container setup, not required for this design).
- Backup is not sync. Syncing between a person's own devices (CloudKit) is future work.

## 7. Findings from the investigation

Verified (docs/source):
- `printing` 5.15.1 and `pdf` 3.13.1 were published in September 2026; `printing` supports Android, iOS, Linux, macOS, Windows, web. [printing](https://pub.dev/packages/printing), [pdf](https://pub.dev/packages/pdf), [source](https://github.com/DavBfr/dart_pdf).
- `pdf` has RichText/TextSpan, WidgetSpan, Table, Transform, TrueType fonts, SVG, hyphenation support, `maxLines`/overflow, and **`baseline` on spans** (sub/superscript is possible).
- `pdf` has Arabic/bidi code but I found **no kerning handling** in its font code, and there is no general text shaping. Use precomposed characters (normalise input to NFC); combining marks will not position correctly.
- `pdf` has no LaTeX support. `flutter_math_fork` 0.7.4 (last release May 2025) renders maths as Flutter widgets only, and its page does not mention mhchem chemistry. Maths in the PDF would need rasterising.
- `printing`'s docs say nothing about scaling, margins or duplex behaviour per platform. `usePrinterSettings` is Windows-only and `forceCustomPrintPaper` is iOS-only.
- drift 2.35.3 (Oct 2026): all platforms, migrations, actively published. [drift](https://pub.dev/packages/drift)
- Spell check: Flutter's default service supports only Android and iOS ([API docs](https://api.flutter.dev/flutter/widgets/EditableText/spellCheckConfiguration.html)); `native_spell_checker` covers Android/Linux/Windows, not iOS/macOS ([pub.dev](https://pub.dev/packages/native_spell_checker)). No per-field language setting is documented. Spell check is out of scope for v1.
- Signing with a free Apple ID lasts 7 days; the paid Apple Developer Program lasts about a year ([article](https://flaviocopes.com/install-iphone-apps.md)). TestFlight is part of the paid program (standard Apple knowledge, not confirmed in the sources above).

## 8. Spikes (do these before features)

0. **Print fidelity (highest risk, physical).** Generate a one-page duplex test sheet from Flutter, print it on the real printer via `printing` on the real device, and measure: scale error, front/back offset, behaviour of the print dialog (page size, margins, duplex long edge). Compare with printing the exported PDF from Preview/Acrobat at Actual size. Decide the print path from the result.
1. **Text.** Render sample text with Latin macrons, French and German characters, sub/superscript via span baseline, and (if relevant) polytonic Greek, in one chosen open-licence font. Check missing glyphs and mark positioning.
2. **Overflow measurement.** Lay out a card widget with fixed constraints and read its box; verify it matches the rendered result for short, long and multi-line text.
3. **Backup round trip.** Export bundle on one device, wipe, import on another; check DB integrity.
4. **Maths (later).** Rasterise a `flutter_math_fork` widget off-screen and embed in a card; or decide on Unicode-only notation for v1.

## 9. Open questions for the owner

1. Which devices do the children use (iPad, iPhone, Mac, Windows)? This decides platform priorities and the backup story.
2. "Year": leerjaar or schooljaar?
3. Is there an Apple Developer Program membership available for installing on the children's iOS devices?
4. Do the children take Latin and Greek (polytonic)? Which method/textbooks?
5. Which printer, paper weight, and paper cutter (single sheet or stack)?

## 10. Phases

1. Spikes 0-3, then core: course tree, vocabulary + paradigm + begrip types, PDF with calibration, backup bundle.
2. Print queue and history, CSV import, deck sharing via bundle.
3. Sentences, history, images, dividers; maths/chemistry decision.
4. Later: digital study (review log table, CloudKit sync).

## CLAUDE.md starter

```markdown
# Flashcards app

Flutter app for printed double-sided VWO flash cards. Read docs/SPEC.md first.

## Rules
- Local only: no server, no accounts, no network calls.
- Card appearance exists only in lib/render as `pdf` widgets. The preview is the rasterised PDF. Never duplicate card layout in Flutter widgets.
- Normalise all user text to Unicode NFC before rendering.
- The live SQLite DB never goes in iCloud Drive. Backup = export/import bundle.
- UI strings are Dutch via ARB/intl; code, comments and commit messages are English.
- Run the spikes in docs/SPEC.md section 8 before building features; record results in docs/DECISIONS.md.
- Ask before adding a dependency; prefer maintained packages with a recent release.

## Commands
(fill in: flutter pub get, flutter run -d macos, flutter test, dart run build_runner build)
```
