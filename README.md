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
defaults. Action Button integration, history/edit/delete, CSV export, and weekly
reflection remain later work. There are no third-party app dependencies.

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

The checked-in project builds directly. To regenerate it after changing the
project definition, use the already-installed XcodeGen 2.46.0:

```sh
xcodegen generate --spec ios/project.yml
```

See docs/ROADMAP.md for milestones.
