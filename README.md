# SPEND.

**Feel every dollar.**

SPEND. is a privacy-first, manual spending journal
designed to help people become more conscious of
where their money goes.

## Philosophy

Digital payments make spending feel effortless.
SPEND. brings intentionality back to purchases
through deliberate manual logging.

Awareness over automation.
Intentional spending without shame.

## Technology

- SwiftUI
- SwiftData
- App Intents / Shortcuts
- Native iOS
- Local-first storage

## MVP

- Quick purchase entry
- Action Button shortcut
- Daily, weekly, monthly dashboard
- Transaction history
- Categories
- Planned vs. impulse spending
- Weekly reflection
- CSV export

## Structure

- ios/ — Native iOS application
- docs/ — Product and engineering documentation
- CHANGELOG.md — What each version contains; release notes in docs/releases/
- design/ — Design assets and references
- scripts/ — Development utilities

## Status

Version 0.1.0 is on `main` (merged 2026-11-07): Quick Entry → local SwiftData →
Dashboard, plus the "Log a purchase" App Shortcut that opens SPEND. straight into
Quick Entry from the Shortcuts app, Spotlight, Siri ("Log a purchase in SPEND.")
or Settings → Action Button → Shortcut. The shortcut only opens the app: nothing
is saved until you tap Save. Slices 1, AB1 and AB2 and the security review passed
the independent Check at commit 5732867 (`docs/agents/checks.md`). The Action
Button steps were observed by the owner on an iPhone 18 Pro (iOS 27.2), not
reproduced by the checker.

History (slice H1) passed the independent Check at 4c8cdb0 and was merged into
`main` at 4fef33f on 2026-11-07: "See all" beside the Dashboard's recent
purchases opens every saved purchase, newest first, in one section per day
with the day's total, and tapping any row on the Dashboard or in History opens
a read-only detail of every saved field. See `docs/plans/transaction-history.md`.

Branch `look-and-feel` (slices LF1 to LF3, built 2026-11-08, awaiting the
independent Check) gives SPEND. its face: an S. monogram app icon as an Icon
Composer package (glass on iOS 26, flattened by Xcode for iOS 17 to 25), one
deep-teal accent on every tinted control, a Dashboard of uniform cards with the
recent purchases third so the purchase you just saved shows without scrolling
on the iPhone 17 Pro and 18 Pro (one swipe on an iPhone SE), the History day
total in primary color, and the design system written down in
`docs/DESIGN.md`. Apple's accessibility audit runs in the UI tests on every
screen at three text sizes in light and dark. See `docs/plans/look-and-feel.md`.

This version uses USD, positive purchase amounts, and visible Other / Planned
defaults. There are no third-party app dependencies. Edit/delete, category
filter and search, CSV export, and weekly reflection remain later work. See
`CHANGELOG.md` and `docs/releases/0.1.0.md` for what shipped and its known
limits.

## Open and Run

Open `ios/SPEND.xcodeproj`, select the shared `SPEND` scheme and an iPhone
simulator, then Run. The project requires Xcode with an iOS 17-or-newer SDK.
Simulator builds require no developer account. Signing and physical-device
acceptance are separate from simulator verification.

From the repository root, run unit and UI tests on the installed simulator:

```sh
xcodebuild test -project ios/SPEND.xcodeproj -scheme SPEND -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO
```

Tests use synthetic purchases and isolated stores. UI tests verify relaunch
persistence without clearing the test journal between those launches.

## Run on an iPhone

Use only fake purchases while testing: edit and delete don't exist yet, and
deleting the app erases its whole journal.

1. Find your team ID. It is the `OU=` value printed by this command (or see
   Membership details at developer.apple.com):

   ```sh
   security find-certificate -c "Apple Development" -p | openssl x509 -noout -subject
   ```

2. Create `ios/Config/Signing.local.xcconfig` with one line,
   `DEVELOPMENT_TEAM = <your team ID>`. Git ignores this file. Don't pick the
   team in Xcode's Signing tab, because that writes it into the shared project.
3. Unlock the iPhone, connect it by cable and tap Trust. Turn on Developer Mode
   if iOS asks (Settings → Privacy & Security → Developer Mode).
4. Open `ios/SPEND.xcodeproj`, choose the iPhone as the run destination, and
   press Run. Approve any prompt to register the app.
5. With SPEND. opened once, go to Settings → Action Button → Shortcut and choose
   SPEND. "Log a purchase".

With a free Apple account, the installed app stops opening after 7 days;
press Run again to reinstall it.

## Regenerate the Project

The checked-in project builds directly. To regenerate it after changing the
project definition, use the already-installed XcodeGen 2.46.0:

```sh
xcodegen generate --spec ios/project.yml
```

See docs/ROADMAP.md for milestones.
