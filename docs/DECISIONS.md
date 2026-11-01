# Decisions

Record decisions and spike results here, newest last. Each entry: date, decision, why, evidence.

## 2026-10-24: Storage is JSON files, not a database

- **Decision:** the library is stored as JSON files in `Application Support/library/`: `folders.json`, `cards/<folderId>.json` and `settings.json`. Everything is loaded into memory; writes are atomic per file (temp → flush → rename) through one queue.
- **Why:**
  - The data is small (≈5k–20k cards, a few MB).
  - v1 needs no heavy queries.
  - Separate files keep the deferred export bundle, deck sharing and iCloud Drive sync simple. A live SQLite DB cannot sync via iCloud Drive.
- **Cost accepted:** safe saving and integrity between files are our own code, in `lib/data/store`.
- **Revisit if:** digital study needs an append-heavy review log. Add a separate store for that rather than migrating everything.

## 2026-10-24: Card font is Gentium Book Plus 6.200 (provisional)

- **Decision:** bundle Gentium Book Plus (Regular, Italic, Bold, BoldItalic; SIL OFL) for PDF output only.
- **Why:** it covers Latin macrons, FR/DE and polytonic Greek. The Book weight is heavier than Gentium Plus, so it holds up better at small print sizes.
- **Confirmed in Spike 1** (see below); print legibility still to judge on paper in Spike 0.

## 2026-10-24: Bundle ID `nl.markbeij.flashcards`

- **Status:** the Apple Developer membership has expired and will be renewed later. Until then, real-device testing uses free provisioning (7-day signing), and TestFlight/App Store steps are blocked.

## 2026-10-25: Spikes 3–6 dropped

- **Decision:** keep spikes only for assumptions whose failure would change the product (Spikes 0–2). Spikes 3–6 move into the normal build.
- **Why:**
  - **Entry grid (3):** if it fails, we fall back to the per-card form, which is already in scope, and nothing else depends on the grid. The spike would be most of the real grid anyway. Instead it is built early and tried on the iPad right away (build order step 2).
  - **Preview pipeline (4):** a slow preview only changes when it updates, not how cards are rendered. Start on the main isolate, time it, and add a worker isolate only if typing feels slow.
  - **Adaptive shell (5):** keeping state across resizes is a design rule (editing state above the layout switch) plus a widget test.
  - **Storage (6):** `getApplicationSupportDirectory()` is the documented iOS backup location, and a rename is atomic on APFS. Covered by store unit tests.

## 2026-11-01: v1 simplified

- **Decision:**
  - **One card size, 95×69 mm** (the former L), 8 per A4. It fits in an A7 card box. S/M/L, size per card type and the print-time size choice are gone.
  - **Map → submap → deck** replaces the folder tree of any depth. A deck has a required map, submap and title. Map and submap are plain text on the deck. The UI suggests "school year" and "subject" as examples; the domain knows neither. The begrip `subject` field is gone.
  - Folder colours, short labels and tags are gone. The footer is the deck title + `#n`.
  - The card type stays per card; a deck can mix types.
  - **No special characters:** Latin macrons, polytonic Greek and scientific notation are out of v1, as is the macron toolbar. The on-device check that the Greek keyboard produces precomposed characters (Spike 1) is dropped.
  - `docs/SPEC.md` (the original brief) is removed; `docs/PLAN.md` is the only spec and holds only v1.
- **Why:** get a working first version sooner.

## 2026-11-01: No print direction

- **Decision:** the print set-up has no "Front shows: Dutch / Latin ⇄" choice. Each card type has one fixed front (vocabulary and sentence: Dutch; begrip: the term; paradigm: the meaning/infinitive; history: the date).
- **Why:**
  - A printed card has two sides, so you practise the other direction by turning the card or the stack over.
  - For begrip, paradigm and history, swapping would put the long text on the front.
  - A deck can mix types, so a language swap doesn't apply to every card in it.

## 2026-11-01: Overflow is shown while typing, not at print time

- **Decision:**
  - Entry shows a "Space on the card" bar per side. It is driven by the `overflow.dart` measurement, turns orange from 85 % and shows the "Doesn't fit" badge when full.
  - Text is never shrunk and entry is never blocked.
  - There is no overflow badge in the card list, and no "Doesn't fit" section in the print set-up.
- **Why:**
  - Shrinking text makes it hard to read and gives a stack mixed text sizes; a minimum size would still need a warning.
  - A character limit is a poor proxy for the real width, and a hard stop is frustrating.
  - Warning at print time is too late. Without the badge in the list and the print section, v1 needs less UI.
- **Cost accepted:** a card that is saved too full prints as it is.

## Spike results

- **Spike 0 (print fidelity), 2026-10-31, done.** Canon MG5700, plain copy paper (Action A4, weight not stated; likely 80 g/m²). Printed from the iPad through AirPrint (`Printing.layoutPdf`), double-sided, uncalibrated.
  - **Back offset:** about 1 mm too high, the same at all four targets A–D. No horizontal shift.
  - **Scale:** the 190 mm ruler is exact; the 270 mm ruler prints about 0.5 mm short (−0.2 %). Because the offset is the same at the top (A/B) and bottom (C/D) targets, both sides are scaled equally, so front/back alignment is unaffected. Each card ends up about 0.1 mm shorter, which is negligible.
  - **Decisions:**
    - The direct AirPrint path is the default print path. The Files/Mac comparison was skipped because the direct path already meets the target.
    - Calibration is only a back X/Y offset (dy ≈ +1 mm for this printer). The scale fields are dropped from the plan.
  - **Still open:** card-weight paper. Heavier paper may not go through the printer's automatic duplex; if so, the manual fronts/backs fallback covers it.
  - How to run it:
  1. On the iPad, open the app → **Printtest** → print. In the print dialog, note the paper size, whether double-sided is on and set to the long edge, and any scaling option. Use A4, double-sided, no scaling.
  2. **Scale:** measure the 190 mm and 270 mm rulers on the front and on the back with a good ruler.
  3. **Back offset:** hold the sheet against a window with the back facing you. At each target A–D, read where the front cross lands on the back's scale. Readings are in mm: x positive to the right, y positive downwards.
  4. **Cutting:** cut along the ticks and check that each sample card's back (e.g. #5 meisje → puella) sits squarely behind its front, footer included.
  5. Repeat steps 2–3 for the same PDF shared to Files and printed from there (or from a Mac in Preview at "Actual size").
  6. Record here: printer model, paper weight, ruler lengths (front/back), offsets A–D, and whether the two print paths differ.
- **Spike 1 (text), 2026-10-24, partly done** (`spike/text_spike.dart`). Rendered with `pdf` 3.13.1 + Gentium Book Plus, checked zoomed.
  - Precomposed text renders correctly at 20 pt and at the 8 pt footer size: Latin macrons, FR/DE, polytonic Greek (ἀνθρώπῳ, ᾅδης, Ἑλλάς, ῥήτωρ, ᾠδή), and bold/italic/bold-italic runs (including Greek). No missing glyphs.
  - Decomposed text with **one** combining mark (Latin `e` + U+0304) also renders correctly.
  - Decomposed text with **stacked** marks (Greek breathing + accent, or + circumflex + iota subscript) **collides**: the marks overlap, because `pdf` has no mark positioning.
  - **Decision:** no NFC normalisation in v1. Typed input only comes from iOS keyboards, and CSV/paste import is deferred. Add NFC if pasting polytonic Greek from PDFs turns out to matter.
  - **Still to check on device (build order step 2, vocabulary grid):** that the iOS Greek polytonic keyboard produces precomposed characters.
- **Spike 2 (overflow measurement), 2026-10-24, done** (`spike/overflow_spike.dart`).
  - With a bounded height, `RichText.layout` silently stops adding lines, so a bounded `box` can't show overflow.
  - **Works:** lay out the content with the card's inner width and unbounded height (`pw.Theme` + `pw.Context(document:)`) and compare `box.height` with the available height. The measured height matched the rendered last line exactly, for short, long and multi-line text.
  - **Finding:** a single word wider than the card is broken mid-word with no hyphen, and the reported width is clamped to the constraint, so the width check misses it.
  - **Decision:** `overflow.dart` flags a card when its content height is greater than the available height, **or** when any single word measured alone is wider than the content width.
