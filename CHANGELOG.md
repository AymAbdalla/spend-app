# Changelog

Notable changes to SPEND., newest first. Version numbers follow
`MARKETING_VERSION` in `ios/project.yml`. A version is listed here once its
slices have an independent pass in `docs/agents/checks.md` and are merged into
`main`. The date is the day of the merge.

## 0.1.0 — 2026-11-07

The first working version: a manual purchase journal that opens from the
iPhone Action Button. It has been installed only on the owner's iPhone 18 Pro
from Xcode and tagged `v0.1.0`. There is no TestFlight or App Store build.
Details, evidence and limits: `docs/releases/0.1.0.md`.

### Added

- Quick Entry sheet. Amount and merchant or description are required. Category
  (eight options, default Other), Planned or Impulse (default Planned) and
  optional notes; date and time default to when the sheet opened. Nothing is
  saved until Save is tapped, Cancel saves nothing, and repeated Save taps
  save once.
- Dashboard. Totals for today, this week and this month; the five most recent
  purchases; this month's totals by category and by Planned / Impulse; an
  empty state; a "Purchase saved." confirmation with a VoiceOver announcement.
- Local SwiftData journal inside the app sandbox with CloudKit and autosave
  off. A failed save keeps the typed draft and offers retry. A journal that
  cannot open shows "Try again" and never deletes or replaces data.
- Exact money. Positive USD amounts are stored as integer cents and parsed
  from decimal text without floating point. Zero, negative, over-precise,
  grouped and overflowing input is rejected, and totals check for overflow.
- Calendar-aware periods using the user's calendar and time zone, including
  weeks that cross a year boundary and daylight-saving changes. Future-dated
  purchases are excluded from totals.
- "Log a purchase" App Shortcut backed by an App Intent. iOS lists it in the
  Shortcuts app, Spotlight, Siri ("Log a purchase in SPEND.") and
  Settings → Action Button. It only opens Quick Entry; it cannot read, speak
  or save purchases. A second run while Quick Entry is open keeps the draft.
- Complete file protection for the dedicated `Journal` folder and its store,
  WAL and SHM files. A journal from an earlier development build is adopted
  through a protected staged copy; the original stays as a recovery copy.
- iPhone signing without the team ID entering git. `ios/Config/Signing.xcconfig`
  includes a git-ignored `Signing.local.xcconfig`; README gains "Run on an
  iPhone".
- Project definition for XcodeGen 2.46.0 (`ios/project.yml`) with the
  generated project checked in and byte-stable on regeneration; iOS 17
  deployment target; no third-party dependencies.
- Tests: 27 unit and 10 UI tests covering money parsing, on-disk persistence,
  calendar boundaries, summaries, failed-save retry, store-load retry, legacy
  journal adoption, file-protection requests, the intent and shortcut-opened
  entry. Unit tests use temporary stores; UI tests use isolated per-run
  journals and never touch the normal journal.

### Changed while the branch was open

- Dashboard cards use a distinct surface so they stay visible in dark mode.
- The journal store moved from `Application Support/journal.store` to
  `Application Support/Journal/journal.store`; protection is requested for
  that folder only, not for all of Application Support.
- Hosted unit-test runs no longer open the normal journal.

### Verified

- Independent check in a fresh chat at commit 5732867 on 2026-11-07: slice 1,
  AB1, AB2 and security all pass. 37 of 37 tests on iPhone 17 Pro and iPhone
  SE 3rd generation (iOS 26.5); Release simulator build succeeded; the team
  ID is absent from every tracked file and every commit.
- On the owner's iPhone 18 Pro (iOS 27.2), owner-observed and not reproduced
  by the checker: the Action Button and the Shortcuts app open Quick Entry; a
  saved purchase survives force-quit, lock and unlock; a locked phone asks for
  the passcode before the app runs.

### Known limits

- No transaction history, edit, delete, CSV export or weekly reflection.
- No app icon; the Action Button setting and Shortcuts show a placeholder.
- On iPhone 18 Pro at default text size the first recent purchase sits behind
  the Add purchase bar until the Dashboard is scrolled.
- Untested: iOS 17 to 25, spoken VoiceOver output on a phone, Siri by voice,
  Spotlight, whether journal files are unreadable while locked, and a
  shortcut request that arrives while Quick Entry is closing.
- In the Simulator, tapping the shortcut in the Shortcuts app fails on
  ad-hoc-signed builds ("Couldn't find AppShortcutsProvider"). It worked on
  the team-signed phone build.
- The phone still holds a Debug build with one fake $1.00 Test purchase. It
  cannot be removed until delete exists or the app is deleted.
- With a free Apple account the installed app stops opening after 7 days.
