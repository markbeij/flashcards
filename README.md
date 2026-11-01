# Flashcards

Flutter app for iPad and iPhone that makes printed, double-sided flash cards (A4, duplex, cut with a paper cutter).

- v1 spec and plan: [docs/PLAN.md](docs/PLAN.md)
- Decisions and spike results: [docs/DECISIONS.md](docs/DECISIONS.md)

```bash
fvm flutter pub get
fvm flutter test
fvm flutter run -d <ipad-simulator-or-device>
```

Code layout:

- `lib/domain`: decks, cards, the five card types, inline markup
- `lib/data/store`: the JSON library files and every write to them
- `lib/render`: card appearance as `pdf` widgets, the duplex sheet, overflow measurement, the calibration test sheet
- `lib/ui`: adaptive shell, Library, entry (grid, rapid card, form), print flow, settings
- `lib/l10n`: UI strings (`app_nl.arb` is the template)

Licence: MIT. The bundled Gentium Book Plus font is under the SIL Open Font License (assets/fonts/gentium/OFL.txt).
