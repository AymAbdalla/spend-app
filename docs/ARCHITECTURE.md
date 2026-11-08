# Architecture

## Platform

Native iOS application.

## Stack

- Swift
- SwiftUI
- SwiftData
- App Intents
- XCTest or Swift Testing

## Data Model

Purchase (the stored transaction):
- id: UUID
- date: Date
- merchant: String
- amountInCents: Int64, positive USD cents
- categoryValue: stable category string with a typed interface
- spendingTypeValue: stable Planned / Impulse string with a typed interface
- notes: String?

## Storage

Local-first using SwiftData.

No remote backend required for MVP.

## App Structure

Current feature organization in `ios/SPEND/`:

- App
- Models
- Features/Dashboard
- Features/QuickEntry
- Intents
- Services

`SpendApp` owns recoverable store loading. `JournalStore` creates the local
SwiftData container with CloudKit explicitly disabled and autosave disabled.
The normal store is `Application Support/Journal/journal.store` inside the app
sandbox. Before and after opening a store, `JournalStore` requests
`FileProtectionType.complete` for the dedicated Journal directory and existing
SQLite store, WAL, and SHM files. It does not apply protection to the whole
Application Support directory. Protection errors propagate to the normal retry
screen without replacing the store. This policy
fits the current foreground-only journal. Future background work must account
for protected data being unavailable while the device is locked.
There is no backend, analytics, or purchase-content logging. Device backup policy
is controlled by iOS; local storage does not mean exclusion from device backups.

`openJournal(in:)` adopts a legacy root-level `journal.store` before the app opens
any normal journal connection. It copies the main file and available WAL/SHM
sidecars into a protected temporary directory, then promotes that completed
directory to `Journal` with a same-parent move. The legacy files remain as a
recovery copy. Once `Journal/journal.store` exists, it is authoritative; legacy
files are not reimported. Failed copies clean up only their own staging directory,
and an occupied destination is not overwritten. This relies on the current
single app process with no background journal writer. Existing protection
attributes applied to Application Support by older development builds are left
unchanged rather than downgraded.

`QuickEntrySession` holds an unsaved `PurchaseDraft`. `PurchaseWriter` validates
it before insertion, then explicitly saves the main context. A failed save rolls
back that context; draft text remains available for retry. This slice has one
writer and no other pending edits. Future editing work must revisit rollback
ownership before adding another writer.

Each draft has a stable UUID. An existing UUID is not inserted again, while a
new draft may intentionally have the same merchant and amount. Saving is
synchronous on the main actor and the entry session guards repeated submission.

Dashboard uses `@Query` on the same container. `SpendingSummary` accepts plain
value records and an explicit clock/calendar, independently of SwiftUI and
SwiftData. Periods use calendar boundaries, include the start, exclude the end,
and exclude dates later than the supplied clock. The screen refreshes its clock
on foregrounding, significant time changes, and a 30-second timer.

`Money` parses decimal text directly into cents, accepts the locale decimal
separator or a decimal point, rejects grouping and over-precision, and checks
integer overflow. Aggregation also checks overflow instead of showing a wrapped
or partial total. Formatting uses Decimal and an explicit USD currency code.

`Intents/LogPurchaseIntent` is the App Intent behind the "Log a purchase" App
Shortcut, which `Intents/SpendShortcuts` publishes to Shortcuts, Spotlight, Siri
and the Action Button setting. The intent opens the app and calls
`QuickEntryRequest.shared.request()`; it receives no input and never touches
`StoreState`, the container, a context, the commit closure or `JournalStore`.
`QuickEntryRequest` is a main-actor observable holder with one pending flag, so
repeated runs collapse into one request. It is shared because iOS can run the
intent before any SwiftUI view exists. `DashboardView` observes the flag with
`onChange(initial: true)`, so a request made during start-up or on the retry
screen is honored when the Dashboard first appears. It clears the flag, and
opens Quick Entry the same way as Add purchase unless the sheet is already open,
in which case the typed draft stays. See DECISIONS 013.

Transactions/history and reflection remain later roadmap work.

## Project and Test Isolation

Open `ios/SPEND.xcodeproj`; its shared scheme contains app, unit-test, and UI-test
targets. `ios/project.yml` is the source for generation with the already-installed
XcodeGen 2.46.0. XcodeGen is not required to open or build the checked-in project.
There are no third-party app dependencies. The deployment target is iOS 17.
Signing reads `DEVELOPMENT_TEAM` from the git-ignored
`ios/Config/Signing.local.xcconfig`, included by the committed
`ios/Config/Signing.xcconfig`; without the local file, simulator builds sign to
run locally and the team ID never enters git.

Unit persistence tests create temporary disk stores. UI tests pass a fresh UUID
to use `Application Support/UITests/<UUID>/Journal/journal.store`, preserve that store
across a relaunch, and never reset the normal journal. Failure injection and
appearance overrides are restricted to DEBUG builds with a valid test-store UUID;
Release builds ignore them. Database load/save closures are the only replaced
boundaries in the original failure tests; the model and calculations remain real.
Hosted XCTest unit runs receive no app `StoreState`, so the app displays an empty
host view and never starts normal journal loading. A valid DEBUG UI-test UUID
keeps the real app path available for UI tests.

The Simulator can't run the shortcut from the Action Button, so shortcut UI tests
use a simulated trigger. With a valid DEBUG test-store UUID,
`-run-log-purchase-at-launch` starts the real intent's `perform()` from the app's
initializer, before any view exists, and `-run-log-purchase-on-activate` runs it each
time the app becomes active, including the first launch. Release builds don't
contain either argument. These tests prove what happens once the intent runs, not
that iOS runs it when the button is pressed.

Protection tests observe requests at the filesystem attribute-setting boundary
while using real temporary SQLite stores. They cover new stores, reopening
existing stores, and failures without purchase loss. The simulator does not
expose the file-protection class on readback; these checks prove the requested
policy, not hardware encryption or lock/unlock enforcement on an iPhone.

Native text styles, system surfaces, a system accent, scrolling forms, labelled
controls, and vertical summary rows at accessibility text sizes form the initial
design system. Quick Entry places its Done control in a safe-area inset above
the keyboard, keeping it reachable without a custom keyboard. Dashboard cards use
`secondarySystemGroupedBackground` to retain a distinct surface in both
appearances. A successful save posts an accessibility announcement after sheet
dismissal; cancellation and failed saves do not announce success. Spoken output
still needs physical VoiceOver acceptance. See `PLAN.md` for
the reviewed UI references and approved scope.

## Important Decisions

- Use precise monetary arithmetic.
- Keep calculations independent of UI.
- Use calendar-aware date boundaries.
- Avoid duplicate transaction creation.
- Preserve data across app restarts.
- Support CSV export.
- Keep architecture simple.

## Testing

Test:
- Transaction persistence
- Daily and weekly totals
- Month boundaries
- Category aggregation
- Planned/impulse calculations
- Editing and deletion
- App Intent navigation
