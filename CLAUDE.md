# Flashcards app

Flutter app (iPad + iPhone) for printed double-sided flash cards. Read docs/PLAN.md (v1 scope, wins on conflict) and docs/SPEC.md (original brief) first.

## Rules
- Local only: no server, no accounts, no network calls.
- Card appearance exists only in lib/render as `pdf` widgets. The preview is the rasterised PDF. Never duplicate card layout in Flutter widgets.
- All library writes go through `lib/data/store`, atomically (temp file → flush → rename). Nothing else touches the library files.
- UI strings live in ARB files (lib/l10n; `app_nl.arb` is the template, plus en/fr/de). No hard-coded UI strings. Code, comments and commit messages are English.
- Don't add speculative features: every feature, field or safeguard must trace to a requirement in docs/PLAN.md.
- Run the spikes in docs/PLAN.md Milestone 1 before building on them; record results in docs/DECISIONS.md.
- Ask before adding a dependency; prefer maintained packages with a recent release.

## Commands
- Flutter is pinned with FVM (`.fvmrc`): prefix commands with `fvm`.
- `fvm flutter pub get` (also regenerates lib/l10n)
- `fvm flutter analyze`
- `fvm flutter test`
- `fvm flutter run -d <ipad-simulator-or-device>`
