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

Phone observation (slice AB2, 2026-11-07, iPhone 18 Pro, iOS 27.2,
owner-observed): after a saved purchase, a force-quit, about 20 seconds locked
and an unlock, the journal reopened with the purchase intact. Pressing the
Action Button on the locked phone asked for the passcode first. When the prompt
went unanswered, iOS refused to launch the app ("the device was not, or could
not be, unlocked"), so SPEND. did not run while locked. When the passcode was
entered at once, the app launched after unlock and the journal opened without
the retry screen. These show the journal reopens normally around a lock; they
don't show the files being unreadable while locked, which the app can't observe
from the foreground.

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
behave. The phone checklist in slice AB2 covers the first two. On 2026-11-07
(iPhone 18 Pro, iOS 27.2, owner-observed) the Action Button and the Shortcuts
app both opened Quick Entry with the amount field ready, and a second press
kept the typed draft. On a locked phone iOS asks for the passcode before the
app runs. iOS 17 to 25 remain unchecked.

Reference: the iOS 27.2 SDK's App Intents interface marks `openAppWhenRun`
deprecated from iOS 26 with "Please provide 'supportedModes' instead".

## 014 — Read-Only History in Day Sections

Decision: Add a History screen, reached from "See all" beside the Dashboard's
"Recent purchases", that lists every saved purchase newest first in one inset
grouped section per calendar day of the device calendar, with the day's total
in the header, and a read-only detail screen reached from any History or
Dashboard row. Grouping is a pure function (`DaySections`) with an explicit
calendar and the same overflow and non-positive-amount errors as the Dashboard
totals; an error shows a message instead of a partial list. The Dashboard's
navigation stack is value-based so the "Log a purchase" shortcut pops History
or a detail before opening Quick Entry. The Dashboard's recent rows adopt the
shared row layout with the amount at the trailing edge. A DEBUG-only launch
argument seeds four fixed-date purchases into an empty test store for UI tests.
Headers show the weekday and full date ("Thu, Jan 15, 2026"), the screen title
is "History" and the detail title is "Purchase". Edit, delete, category filter,
search, month summaries, charts, paging and CSV stay later. The owner approved
`docs/plans/transaction-history.md` on 2026-11-07 by asking to build slice H1,
which accepted the shared-row change and these defaults.

Reason: "Feel every dollar" needs a place to see every dollar, and the
Dashboard's five recent rows are not it. Grouping by the device calendar keeps
History consistent with the daily totals (010), and reusing the Dashboard's
error cases keeps money exact (007). Reading through the same container adds no
storage, copy, network or logging, so the journal's protection (011) and the
single foreground writer (009) are unchanged. Popping to the Dashboard first
keeps the shortcut's "Purchase saved." confirmation (012, 013) where the owner
expects it. The detail stays read-only because edit and delete must first
reconcile the legacy recovery copy (011, ROADMAP).

Limits: future-dated purchases appear in History under their own day while the
Dashboard totals still exclude them. Relative headers ("Today", "Yesterday")
were deferred until the owner has used History. A deleted purchase on an open
detail screen is the edit and delete slice's problem. Thousands of purchases
would need a sectioned fetch instead of grouping in the view body.

## 015 — One Accent, a Layered Icon, Dashboard Cards and a Written Design System

Decision: SPEND. gets its own face without changing what it does. One brand
accent, deep teal (#0B7A75 in light mode, #0E948E in dark mode), is the only
color that carries meaning, and it means "you can tap this"; Planned and
Impulse stay words. The app icon is concept B, an original S. monogram drawn
from two elliptical arcs plus a dot, shipped as an Icon Composer package
(`ios/SPEND/AppIcon.icon`) on an automatic gradient from the accent, with no
flat `AppIcon` set in the asset catalog; Xcode flattens it for iOS 17 to 25.
The Shortcuts tile color is teal and its symbol stays `plus.circle` (013).
Every Dashboard section is a card with one surface, radius 20 and padding 20,
in the order tagline, "Purchase saved.", Today, This week and This month,
Recent purchases with See all, This month by category, This month by
intention, the USD footnote; the five recent rows share one card with
dividers and a chevron. The History day total is in primary color. The rules
are written down in `docs/DESIGN.md`, with the tokens in
`Features/Shared/SpendCard.swift`. Apple's accessibility audit runs in the UI
tests on every screen at the xSmall, large and AX5 text sizes in light and
dark, and every excluded finding is named in the test with its reason.

The owner approved `docs/plans/look-and-feel.md` on 2026-11-08 by asking to
build it; the plan's recommended concept B and accent A were confirmed with
the go after LF1. At the LF2 stop the owner accepted that on the small phone
(iPhone SE size) the first recent purchase needs one swipe at the default
text size, because the unchanged Today and period cards leave 70 points too
little room; the alternatives were moving Recent purchases above the period
card or trimming the tagline and the Today date line. On the iPhone 17 Pro
and 18 Pro the row shows without scrolling.

Reason: the icon and the overlap were the two known limits of 0.1.0, and the
H1 check had asked for a primary-colored History total and chevrons on the
Dashboard rows. A single accent with 4.5:1 or better contrast in light mode
keeps controls recognizable without giving money a color (BRAND "Subtle
accent colors", UX "Accessible controls"). The layered icon is Apple's
current format and renders as glass on iOS 26; a flat set beside it has
reported conflicts, and no iOS 17 to 25 runtime is installed to verify a
fallback either way, so the layered file ships alone (Apple's known issue
152258860 is noted for any TestFlight build). Cards on `SpendCard` mean a
later screen changes one value, not five views. The small-phone swipe was
preferred over changing the agreed order or the Today card.

Limits: the dark accent was first #0D8D87, which put See all on a dark card at
4.19:1; the audit rated that "nearly passed", so the dark variant was raised to
#0E948E (4.57:1 on the card, 5.65:1 on black), which leaves the white label on
the dark accent button at 3.72:1, large text where 3.0 is the minimum and close
to iOS's own blue. The audit's named exclusions are: Foundation-formatted amounts flagged as "not
human-readable" (VoiceOver speaks them as dollars and cents, and the UI tests
read that text); the app's name "SPEND." as a title; system secondaryLabel
text rated "nearly passed" (Apple's palette, 3.4:1 on white, which Increase
Contrast darkens); text under a translucent bar or cut by the screen edge,
where the audit samples a background the text does not sit on and names no
element, and the Quick Entry Date label in dark mode, which the screenshots
measure at 13.9:1; the Dynamic Type heuristic on system toolbar buttons and
on labels that visibly scale in the AX5 screenshots; and the single-line
text fields it predicts may clip. iOS 17 to 25 rendering, spoken VoiceOver
on a
phone, the Action Button icon and the Shortcuts tile color remain
owner-observed or unchecked.
