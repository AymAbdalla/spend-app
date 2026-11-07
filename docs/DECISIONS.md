# Decision Log

## 001 — Native iOS

Decision: SwiftUI.

Reason: Native iPhone experience and
integration with Apple Shortcuts.

## 002 — Manual Entry

Decision: No automatic transaction imports.

Reason: Intentional logging is central
to the product philosophy.

## 003 — Local-First

Decision: SwiftData storage.

Reason: Privacy, simplicity and offline use.

## 004 — Minimal MVP

Decision: Build core logging before
advanced budgeting or AI features.

Reason: Validate the primary behavior first.

## 005 — Source of Truth

Decision: Git repository with Markdown docs.

Reason: Maintain clear, portable context
for development and coding agents.

## 006 — First Vertical Slice

Decision: Build Quick Entry → local SwiftData → Dashboard before Action Button,
full history, editing/deleting, export, and reflection. The owner approved
`docs/PLAN.md` with “go” on 2026-11-06.

Reason: Prove deliberate logging, persistence, and visible totals first.

## 007 — Exact USD Cents

Decision: This slice records positive USD purchases as Int64 cents, parsed
without floating-point arithmetic or silent rounding. Decimal formatting always
uses USD. Check both conversion and aggregation for overflow.

Reason: Keep amounts exact and avoid combining currencies without conversion.
Currency settings and refunds remain outside this approved slice.

## 008 — Visible Entry Defaults

Decision: Category defaults to Other, spending type to Planned, and date/time to
opening Quick Entry. Category and type remain editable before saving; notes are
optional. A blank merchant/description cannot be saved.

Reason: Keep manual entry intentional while avoiding unnecessary steps. These
defaults were included in the approved plan and need user validation later.

## 009 — Explicit Local Saves

Decision: Disable CloudKit and autosave. Save only after the user presses Save;
keep unsaved input on failure, prevent the same draft from saving twice, and
offer retry without deleting or replacing the journal.

Reason: Cancel must create no record; storage failures must remain visible and
must not cause silent data loss. Separate identical purchases remain valid.

Reference: Apple's [ModelConfiguration documentation](https://developer.apple.com/documentation/swiftdata/modelconfiguration)
and [CloudKitDatabase.none](https://developer.apple.com/documentation/swiftdata/modelconfiguration/cloudkitdatabase-swift.struct/none).

## 010 — Calendar Periods

Decision: Daily, weekly, and monthly summaries use the user's current calendar
and time zone. Category and intention totals explicitly cover this month.

Reason: A week can cross a month/year and a day can span a daylight-saving
change. Fixed 24-hour or seven-day subtraction is insufficient.

Reference: Apple's [Calendar.dateInterval documentation](https://developer.apple.com/documentation/foundation/calendar/dateinterval(of:for:)).

## 011 — Protect the Local Journal While Locked

Decision: Store the journal at `Application Support/Journal/journal.store`.
Apply `FileProtectionType.complete` to that dedicated directory and its SQLite
store, WAL, and SHM files before and after container creation, without applying
the policy to all of Application Support. Adopt an existing root-level journal
via a protected staged copy before opening it, keep the original as a recovery
copy, and prefer the dedicated store on later launches. Copy/protection errors
use the existing retry flow; occupied destinations are never overwritten.
Existing parent-directory attributes from older development builds are not
automatically weakened. The owner requested the independent check's optional
hardening and folder-isolation follow-ups on 2026-11-06.

Legacy recovery files retain their original protection class. The edit/delete
slice must remove or reconcile those files and their sidecars before enabling
mutations, with regression checks against stale values or deleted purchases
being loaded or reimported. See `ROADMAP.md` for the acceptance requirement.

Reason: The current manual journal operates in the foreground and does not need
locked-device background access. Apple's complete-protection policy makes files
unavailable while locked; later background features must revisit their access
requirements. Simulator tests verify policy requests and preservation of real
temporary stores, with physical-device enforcement still unverified.

Reference: Apple's [FileProtectionType documentation](https://developer.apple.com/documentation/foundation/fileprotectiontype).

## 012 — Announce a Successful Save After Dismissal

Decision: Post `AccessibilityNotification.Announcement("Purchase saved")` when
Quick Entry finishes dismissing after a successful save. Remove the unrelated
frequently-updating trait from the confirmation label.

Reason: Post the explicit announcement after the sheet's focus transition.
Cancel and failed saves must not announce success. This implements the owner's
optional accessibility follow-up; audible VoiceOver acceptance remains open.

Reference: Apple's [announcement documentation](https://developer.apple.com/documentation/accessibility/accessibilitynotification/announcement).

## 013 — The Shortcut Only Opens Quick Entry

Decision: Offer one App Shortcut, "Log a purchase" (Siri and Spotlight phrase
"Log a purchase in SPEND.", icon `plus.circle`). Its App Intent opens the app
and leaves a single "open Quick Entry" request in a holder that outlives the
Dashboard. The Dashboard honors the request the same way as Add purchase: it
clears an old "Purchase saved." confirmation, then presents Quick Entry. If
Quick Entry is already open, it stays open and keeps the typed draft. The
intent declares `openAppWhenRun` for iOS 17 to 25 and
`supportedModes = .foreground(.immediate)` for iOS 26 and later. The owner
approved `docs/plans/action-button.md` on 2026-11-07 and chose to stack this
work on `quick-entry-dashboard` instead of merging it into `main` first.

Reason: Manual entry stays deliberate (002, 009). Nothing is saved until the
owner taps Save, and the journal keeps one foreground writer. The intent
cannot read, return, speak or save purchases, so Siri, Spotlight, Shortcuts
automations and the lock screen never expose journal content. Because the
request outlives the Dashboard, a shortcut run during start-up or on the
"Try again" screen still opens Quick Entry once the journal is open. Clearing
the old confirmation stops a later Cancel from announcing success (012).

Limits: simulator tests run the real intent through DEBUG-only launch
arguments (a simulated trigger). They don't prove that iOS runs it when the
Action Button is pressed, what happens on a locked phone, or how iOS 17 to 25
behave. The phone checklist in slice AB2 covers the first two.

Reference: the iOS 27.2 SDK's App Intents interface marks `openAppWhenRun`
deprecated from iOS 26 with "Please provide 'supportedModes' instead".
