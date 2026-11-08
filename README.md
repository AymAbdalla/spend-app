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
- design/ — Design assets and references
- scripts/ — Development utilities

## Status

First vertical slice built on `quick-entry-dashboard`:
Quick Entry → local SwiftData → Dashboard. Build verification and independent
Check are separate; see `docs/agents/` for the recorded state when available.

This slice uses USD, positive purchase amounts, and visible Other / Planned
defaults. There are no third-party app dependencies.

The "Log a purchase" App Shortcut (slice AB1, on `action-button-shortcut`) opens
SPEND. straight into Quick Entry. It only opens the app: nothing is saved until
you tap Save. iOS lists it in the Shortcuts app, Spotlight, Siri ("Log a purchase
in SPEND.") and Settings → Action Button → Shortcut. Simulator tests cover what
happens once it runs. Slice AB2 ran it from the Action Button on an iPhone 18 Pro
(iOS 27.2): Quick Entry opened, a test purchase saved and survived a force-quit
and lock. Those phone results are owner-observed; the independent Check is still
to come. History/edit/delete, CSV export, and weekly reflection remain later work.

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
