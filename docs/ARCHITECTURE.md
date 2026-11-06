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
- Services

`SpendApp` owns recoverable store loading. `JournalStore` creates the local
SwiftData container with CloudKit explicitly disabled and autosave disabled.
The normal store is `Application Support/journal.store` inside the app sandbox.
There is no backend, analytics, or purchase-content logging. Device backup policy
is controlled by iOS; local storage does not mean exclusion from device backups.

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

Transactions/history, reflection, and App Intents remain later roadmap work.

## Project and Test Isolation

Open `ios/SPEND.xcodeproj`; its shared scheme contains app, unit-test, and UI-test
targets. `ios/project.yml` is the source for generation with the already-installed
XcodeGen 2.46.0. XcodeGen is not required to open or build the checked-in project.
There are no third-party app dependencies. The deployment target is iOS 17.

Unit persistence tests create temporary disk stores. UI tests pass a fresh UUID
to use `Application Support/UITests/<UUID>/journal.store`, preserve that store
across a relaunch, and never reset the normal journal. Failure injection and
appearance overrides are restricted to DEBUG builds with a valid test-store UUID;
Release builds ignore them. Database load/save closures are the only replaced
boundaries in failure tests; the model and calculations remain real.

Native text styles, system surfaces, a system accent, scrolling forms, labelled
controls, and vertical summary rows at accessibility text sizes form the initial
design system. Quick Entry places its Done control in a safe-area inset above
the keyboard, keeping it reachable without a custom keyboard. See `PLAN.md` for
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
