# Build log

Written only by the builder's main agent, one row per slice. State is `built` or `fixed (round N)`; results start with `self-check:`. Never write `checked` here.

| Slice | Workstream | Branch | Commit | Acceptance checks | Builder results | State | Date |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | spend-core | quick-entry-dashboard | 0393ef57d4e7cd6b233e01307697d13c1ccf4415 | Enter a USD 12.34 purchase, save once, observe it and matching totals on Dashboard, terminate/relaunch, and observe the same persisted purchase exactly once. | self-check: 17 unit + 5 UI tests passed on each of iPhone 17 Pro and iPhone SE 3rd generation, iOS 26.5; no skips or runtime warnings; Release simulator build passed; evidence below | built | 2026-11-06 |
| 1 | spend-core | quick-entry-dashboard | fb04a1dcfd827d8a6dd80e2654b03bf30d77d4e0 | Enter a USD 12.34 purchase, save once, observe it and matching totals on Dashboard, terminate/relaunch, and observe the same persisted purchase exactly once. | self-check: final completion includes the generated shared workspace used by the same passing 22-test runs on both simulators and Release build; compiled source unchanged | built | 2026-11-06 |
| 1 | spend-core | quick-entry-dashboard | 249542912e05ee44e2d5e2f5318c824362b08f0b | Enter a USD 12.34 purchase, save once, observe it and matching totals on Dashboard, terminate/relaunch, and observe the same persisted purchase exactly once. | self-check: all 5 optional follow-ups addressed; 21 unit + 5 UI tests passed on each of Pro and SE, no skips/runtime warnings; Release build passed; new evidence below; independent recheck pending | built | 2026-11-06 |
| 1 | spend-core | quick-entry-dashboard | 31ad678f6a61cc7016650a1121b99bfb8e81ea8c | Enter a USD 12.34 purchase, save once, observe it and matching totals on Dashboard, terminate/relaunch, and observe the same persisted purchase exactly once. | self-check: 25 unit + 5 UI tests passed on each of Pro and SE, no skips/runtime warnings; Release passed; dedicated journal adoption and full-row visibility verified; independent recheck pending | built | 2026-11-06 |
| 1 | spend-core | quick-entry-dashboard | bfc9b886dfc6572a96eadf673f03cf0f5bb3032e | Enter a USD 12.34 purchase, save once, observe it and matching totals on Dashboard, terminate/relaunch, and observe the same persisted purchase exactly once. | self-check: documentation-only follow-up; roadmap cleanup prerequisite and decision caveat read back; git diff --check passed; no ios changes from checked 31ad678; no new runtime test claims | built | 2026-11-06 |

## Scope and authorization

The owner approved `docs/PLAN.md` with “go” on 2026-11-06. This is one vertical
slice: native project, manual entry, explicit local persistence, and Dashboard.
USD, Other / Planned defaults, eight categories, and positive purchases follow
the approved plan. No third-party app packages were added. Slice commits are
local to `quick-entry-dashboard`; no push or merge was performed.

## Self-check results

| Check | State | Observed result |
| --- | --- | --- |
| Debug simulator compilation and tests, iPhone 17 Pro | pass | 22 passed: 17 unit and 5 UI; 0 failed, 0 skipped, 0 runtime warnings. |
| Debug simulator compilation and tests, iPhone SE 3rd generation | pass | Same 22 tests passed; 0 failed, 0 skipped, 0 runtime warnings. |
| Release, generic iOS Simulator | pass | `BUILD SUCCEEDED`, exit 0. |
| Money and calendar behavior | pass | Exact cents and overflow guards; day/week/year/leap-month/DST fixtures; current-calendar week start; monthly category/type totals. |
| Persistence and recovery | pass | Temporary disk store reopened with every field intact; duplicate draft blocked; separate identical purchases allowed; save retry and startup retry retain the journal/entry. |
| UI flow | pass | USD 12.34 appears once with matching totals after save and relaunch; repeated taps, cancel, invalid amount, category/type selection, error retry, and largest Dynamic Type in dark mode exercised. |
| Visual self-review | pass | Inspected final light-mode entry and storage-error views plus small-phone dark accessibility-size entry and Dashboard screenshots. The largest text size requires scrolling; text fields scroll long input while editing. |
| Project regeneration | pass | XcodeGen 2.46.0 regenerates the same project and shared scheme bytes. |
| Security self-review | pass | Read local store/input/commit paths. CloudKit explicitly none; no app networking or financial logging calls; no entitlements or package references; DEBUG test-hook strings absent from the final Release binary. No external security hook is configured or claimed as run. |
| Independent functional/security Check | unavailable | Not run in this Build chat; requires the fresh-chat check below. This is a pending workflow gate, not a product failure. |
| Physical iPhone / VoiceOver acceptance | unavailable | No physical-device acceptance performed. Simulator labels and screenshots do not replace it. |
| iOS 17 runtime | unavailable | Deployment target is 17 and compilation succeeded; only iOS 26.5/27 runtimes are installed. |

There are no outstanding observed test failures or runtime layout warnings on the
final tested source. Xcode emits an App Intents metadata-extraction notice because
App Intents are a later roadmap integration; no App Intents behavior is claimed.
Action Button, full history/edit/delete, export, and reflection remain unbuilt.

## Reproduction and artifacts

Repository root: `/Users/aympulse/aym/projects/spend-app`.
Xcode: 27.2 (27B52). Runtime: iOS 26.5 (23F77). Simulator IDs are explicit below.
The recorded runs also used separate derived-data paths and result bundles under
`/Users/aympulse/aym/agents/work/spend-temp/2026-11-06-quick-entry-dashboard`; all test data is synthetic.

```sh
xcodebuild test -project ios/SPEND.xcodeproj -scheme SPEND -destination 'platform=iOS Simulator,id=6392B603-3453-49E8-9124-17FBBAC89C3D' -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO
```

```sh
xcodebuild test -project ios/SPEND.xcodeproj -scheme SPEND -destination 'platform=iOS Simulator,id=45D6AC76-2BBA-490E-9A09-E35E2419A1F2' -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO
```

```sh
xcodebuild build -project ios/SPEND.xcodeproj -scheme SPEND -configuration Release -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO
```

- Pro: `/Users/aympulse/aym/agents/work/spend-temp/2026-11-06-quick-entry-dashboard/acceptance-pro.log` and `acceptance-pro.xcresult`.
- SE: `/Users/aympulse/aym/agents/work/spend-temp/2026-11-06-quick-entry-dashboard/acceptance-se.log` and `acceptance-se.xcresult`.
- Release: `/Users/aympulse/aym/agents/work/spend-temp/2026-11-06-quick-entry-dashboard/acceptance-release.log`.
- Parsed result summaries: `/Users/aympulse/aym/agents/outputs/spend/quick-entry-dashboard/test-summary-pro.json` and `test-summary-se.json`.
- Tested source/project hashes: `/Users/aympulse/aym/agents/outputs/spend/quick-entry-dashboard/tested-source-sha256.txt`; matched unchanged files before the code commit.
- Screenshots: `/Users/aympulse/aym/agents/outputs/spend/quick-entry-dashboard/dashboard-light.png`, `dashboard-se-light.png`, `quick-entry-light.png`, `quick-entry-storage-error.png`, `quick-entry-se-large-dark.png`, `dashboard-se-large-dark.png`.

The dedicated simulator `SPEND Small Phone` is an iPhone SE 3rd generation using
the existing iOS 26.5 runtime. It remains available for independent reproduction.

## Test-first and correction evidence

- `red-core.log` / `.xcresult`: actual assertion failures, zero versus 10/20/1234 cents and no persisted purchase versus one. `green-core` then passed with real implementation.
- `red-summary.log` / `.xcresult`: expected literal calendar/summary and recovery assertions failed against temporary placeholders. `green-summary` passed all 17 unit tests after implementation.
- `red-ui.log` / `.xcresult`: the first UI test failed on the missing Add purchase control before the real screens existed.
- `integrated-1` exposed a test interaction error: Impulse was selected without opening its menu. The test now opens the menu; expected amounts were unchanged.
- `small-phone` exposed an automation assumption at the largest text size: the merchant field was outside the rendered viewport. The test now dismisses the amount keyboard, scrolls, and explicitly asserts the merchant is hittable before entering it; saving and totals are still required.
- `keyboard-layout` showed that removing the keyboard-toolbar spacer alone did not clear SwiftUI's invalid-frame warning. Replacing the keyboard toolbar with a keyboard-aware safe-area inset cleared it in `keyboard-inset`; both final full suites have no runtime warnings.

## Changed files

Code/project/documentation commit `0393ef5`, plus shared workspace commit `fb04a1d`:

- `CLAUDE.md`
- `README.md`
- `docs/ARCHITECTURE.md`
- `docs/DECISIONS.md`
- `docs/PLAN.md`
- `docs/ROADMAP.md`
- `ios/project.yml`
- `ios/SPEND.xcodeproj/project.pbxproj`
- `ios/SPEND.xcodeproj/project.xcworkspace/contents.xcworkspacedata`
- `ios/SPEND.xcodeproj/xcshareddata/xcschemes/SPEND.xcscheme`
- `ios/SPEND/App/AppConfiguration.swift`
- `ios/SPEND/App/SpendApp.swift`
- `ios/SPEND/App/StoreState.swift`
- `ios/SPEND/Models/Purchase.swift`
- `ios/SPEND/Features/Dashboard/DashboardView.swift`
- `ios/SPEND/Features/QuickEntry/QuickEntrySession.swift`
- `ios/SPEND/Features/QuickEntry/QuickEntryView.swift`
- `ios/SPEND/Services/JournalStore.swift`
- `ios/SPEND/Services/Money.swift`
- `ios/SPEND/Services/SpendingSummary.swift`
- `ios/SPENDTests/JournalTests.swift`
- `ios/SPENDTests/RecoveryTests.swift`
- `ios/SPENDTests/SummaryTests.swift`
- `ios/SPENDUITests/JournalUITests.swift`

The shared workspace file was generated by Xcode and present during the final
runs. It is now committed; no compiled source changed after those runs.

Record commits add `docs/agents/build.md`, `docs/agents/status.md`, and the empty
`docs/agents/checks.md` template. No checker rows are written by this builder.

## Independent Check handoff

Check slice 1 in /Users/aympulse/aym/projects/spend-app (branch quick-entry-dashboard)
against docs/PLAN.md with check-this, slice check; treat docs/agents/build.md as
claims to verify, not evidence. Report only, except your own checks.md rows.
Reproduce functional and security checks on latest non-record commit fb04a1d; use fresh result
bundles and isolated stores. Keep physical-device and older-runtime gaps explicit.

The merge gate was run after Build and refused for exactly the two expected
pending requirements: independent slice 1 pass and independent security pass.
No checker rows were added.

## 2026-11-06 optional check follow-ups

Current code commit: `2495429`. This section supersedes the earlier recheck
pointer. The independent checker passed `fb04a1d` with no required fixes. The
owner requested the five optional follow-ups in the Build chat; all five are
implemented. Previous checker rows remain unchanged and apply to the older code.

| Finding | Change | Evidence / limit |
| --- | --- | --- |
| 1: Dark cards blend into background | Today, period-total and recent-purchase cards use secondarySystemGroupedBackground. | Inspected final dark Pro dashboard and SE recent-purchase screenshots; surfaces are visibly distinct. |
| 2: Save confirmation needs an announcement | Remove updatesFrequently; post AccessibilityNotification.Announcement after a successful entry-sheet dismissal. | Compiled and exercised the save/dismiss path. Code reading confirms cancel and failure do not announce success. Actual spoken VoiceOver output is not checked. |
| 3: Relaunch assertions incomplete | Require week/month totals, Test cafe and $12.34 in the one row, and a hittable row after scrolling. Relaunch in dark mode and capture cards. | Enhanced UI test passes on both simulators. |
| 4: Hosted unit tests open normal store | Return no StoreState for hosted XCTest runs; display an empty host view without loading the journal. Explicit DEBUG UI-store UUIDs retain the real UI path. | New unit assertion passes. Normal journal, WAL and SHM content fingerprints and modification times are unchanged across both complete test runs. |
| 5: Explicit file protection | Request complete protection for the parent folder and existing store/WAL/SHM before and after opening. Keep the same paths and propagate setting failures. | Filesystem-boundary contract tests, real disk persistence/reopening, and error recovery pass. Device encryption and lock/unlock enforcement remain unverified. |

### Self-checks and artifacts

- **pass:** `acceptance-pro.xcresult` and `acceptance-se.xcresult`: 26 tests each
  (21 unit, 5 UI), zero failures, zero skips, zero runtime warnings; exit 0.
- **pass:** Release simulator build, exit 0. The only build warning is the
  expected App Intents metadata-extraction notice; this slice has no App Intents.
- **pass:** New store and existing-store protection policy requests; existing
  purchase survives reopening and a simulated attribute-setting failure.
- **pass:** Security self-review: no app networking, financial logging, new
  packages, or secrets; CloudKit remains none; DEBUG hook strings absent from
  the final Release binary. Native XCTest host detection is intentionally
  available in Release test hosts as well.
- **pass:** Normal journal file fingerprints and modification times unchanged.
  The evidence collector initially retained data-container paths from before
  reinstallation, which caused an assertion error. Resolving each current
  simulator container before comparison corrected the collector; all three
  files match on both simulators.
- **unavailable:** Physical VoiceOver output, file-protection enforcement while
  locked, and older iOS runtime acceptance. The new simulator tests verify
  requests to the filesystem boundary, not hardware encryption.
- **pending:** Independent functional/security recheck on `2495429`.

Scratch evidence directory:
`/Users/aympulse/aym/agents/work/spend-temp/2026-11-06-check-followups/`.
It contains `baseline.log` / `.xcresult`, `red-protection-isolation.log` /
`.xcresult`, `green-protection-isolation.log` / `.xcresult`,
`green-policy-contract.log` / `.xcresult`, `red-policy-contract.log` /
`.xcresult`, `acceptance-pro.log` / `.xcresult`, `acceptance-se.log` /
`.xcresult`, and `release-build.log`.

The initial direct-attribute tests assumed the simulator exposed file-protection
class readback. It returned nil even after the real setter succeeded, so those
assertions could not judge encryption policy here. The tests were corrected to
observe the filesystem request boundary while retaining real temporary stores.
A disposable `weaker-policy-ios/` source copy deliberately requested the weaker
completeUntilFirstUserAuthentication policy; the policy test then failed on all
four expected paths. This confirms regression sensitivity without weakening the
required complete policy. The repository's policy stayed unchanged during that
mutation run. Hosted-store suppression also failed on the original non-nil
StoreState before its fix. No manufactured test was added for the color edit or
for audible output that cannot be heard in these automated tests.

Deliverables:
`/Users/aympulse/aym/agents/outputs/spend/check-followups/`.
Files: `test-summary-pro.json`, `test-summary-se.json`,
`normal-journal-isolation.txt`, `tested-source-sha256.txt`,
`dark-dashboard-pro.png`, `dark-dashboard-se.png`, `dark-recent-pro.png`,
`dark-recent-se.png`, `light-dashboard-pro.png`, `light-dashboard-se.png`.

Changed files in `2495429`: `docs/ARCHITECTURE.md`, `docs/DECISIONS.md`,
`ios/SPEND/App/AppConfiguration.swift`, `ios/SPEND/App/SpendApp.swift`,
`ios/SPEND/Features/Dashboard/DashboardView.swift`,
`ios/SPEND/Services/JournalStore.swift`, `ios/SPENDTests/RecoveryTests.swift`,
and `ios/SPENDUITests/JournalUITests.swift`. This record commit changes only
`docs/agents/build.md` and the builder's `docs/agents/status.md` row.

### Recheck

Say **recheck** in the existing independent Check chat. Recheck slice 1 and
security on code commit `2495429` in `quick-entry-dashboard`, against
`docs/PLAN.md` and the five owner-requested optional findings. Treat this Build
record as claims to verify. Report only, except checker-owned `checks.md` rows.

## 2026-11-06 folder and screenshot follow-ups

Current code commit: `31ad678`. This supersedes the earlier recheck pointer.
The independent recheck passed `2495429` with no required fixes; the owner asked
Build to address the two additional optional findings. Checker records remain
unchanged and apply to the previous code.

1. The relaunch scroll loop now tests the row's full bottom edge against the Add
   purchase button's top edge, with an 8-point gap, rather than stopping solely
   on isHittable. A final frame assertion enforces the same condition. Both Pro
   and SE screenshots now show the whole recent-purchase card above the button.
2. The normal active store is `Application Support/Journal/journal.store`.
   AppConfiguration uses openJournal(in:), which confines new protection requests
   to the journal and its private migration staging folder. It never sets the
   protection class on Application Support. Legacy store/WAL/SHM files are copied
   before the app opens a normal store connection; a completed protected staging
   directory is promoted to Journal. Original files remain a recovery copy,
   existing parent attributes are not downgraded, and the dedicated store takes
   precedence on later opens. Copy failures and occupied destinations preserve
   existing data. DECISIONS 011 and ARCHITECTURE describe these choices.

### Self-check evidence

- **pass:** Full suites on iPhone 17 Pro and iPhone SE 3rd generation, iOS 26.5:
  30 tests each (25 unit and 5 UI), zero failed, zero skipped, zero runtime
  warnings; both commands exited 0.
- **pass:** Release simulator build, exit 0. Only the previously documented App
  Intents metadata-extraction notice remains.
- **pass:** New unit tests confirm the dedicated path and protection-request
  scope; all legacy purchase fields survive adoption; reopening does not
  reimport the backup; partial copy failure leaves original bytes intact and
  retries successfully; an occupied destination is not overwritten.
- **pass:** Normal legacy and dedicated journal/WAL/SHM file content fingerprints
  and modification times remained unchanged during both full automated runs.
  Unit and UI tests continue to use their own stores.
- **pass:** Visual self-review of both final recent-card screenshots, including
  Pro; the Pro before-scroll and after-scroll files are different and the full
  row is visibly above the bar. The frame assertion also passes on both devices.
- **pass:** Security self-review: only fixed journal filenames inside the app
  sandbox are adopted; original files are never deleted; normal error cleanup
  removes only the staging directory created by that invocation. No networking,
  financial logging, packages, or secrets were added; CloudKit remains none;
  DEBUG hook strings remain absent from Release.
- **unavailable:** Physical lock/unlock file-protection enforcement, audible
  VoiceOver acceptance and older-runtime acceptance remain unchanged gaps.
- **pending:** Independent slice 1/security recheck at `31ad678`.

`red-path-visibility.log` / `.xcresult` reproduced the issues before the fix:
new-path assertions failed against the temporary root-path stub, and the Pro row
bottom was 886.6667 points versus an allowed 758.0 points. The existing disk
persistence baseline passed first. `green-path-visibility` then passed all 25
unit tests plus the focused relaunch UI test before the full suites ran.

Scratch logs and result bundles:
`/Users/aympulse/aym/agents/work/spend-temp/2026-11-06-journal-folder/`:
`baseline`, `red-path-visibility`, `green-path-visibility`, `acceptance-pro`,
`acceptance-se` (each `.log` and `.xcresult`), plus `release-build.log`.

Deliverables:
`/Users/aympulse/aym/agents/outputs/spend/journal-folder/`:
`test-summary-pro.json`, `test-summary-se.json`, `tested-source-sha256.txt`,
`normal-journal-isolation.txt`, `dark-before-scroll-pro.png`,
`dark-before-scroll-se.png`, `dark-recent-pro.png`, `dark-recent-se.png`.

Changed files in `31ad678`: `docs/ARCHITECTURE.md`, `docs/DECISIONS.md`,
`ios/SPEND/App/AppConfiguration.swift`, `ios/SPEND/Services/JournalStore.swift`,
`ios/SPENDTests/RecoveryTests.swift`, `ios/SPENDUITests/JournalUITests.swift`.
This record commit changes only `docs/agents/build.md` and the builder's
`docs/agents/status.md` row.

### Recheck

Say **recheck** in the existing independent Check chat. Recheck slice 1 and
security at `31ad678` on `quick-entry-dashboard` against `docs/PLAN.md` and the
two owner-requested optional findings from `2495429`. Treat this Build record
as claims to verify. Report only, except checker-owned `checks.md` rows.

## 2026-11-06 recovery-copy roadmap follow-up

Current documentation commit: `bfc9b88`. This supersedes earlier recheck
pointers. The independent check passed code `31ad678` with no required fixes.
The owner offered either protecting legacy copies or recording cleanup in the
edit/delete roadmap. This follow-up uses the explicitly offered roadmap option.

`docs/ROADMAP.md` now requires removing or reconciling the legacy recovery
SQLite database, WAL/SHM sidecars, and other app-controlled migration recovery
copies before enabling edit/delete. Its acceptance checks cover legacy adoption,
mutation and relaunch, preventing deleted purchases or obsolete edited values
from being loaded or reimported from those copies. `docs/DECISIONS.md` records
this prerequisite and explicitly states that legacy copies retain their
original protection class. Immediate legacy-file hardening is not claimed.

Self-check: read back both additions and ran `git diff --check` (pass).
`git diff 31ad678 -- ios` is empty: app source, project and tests are unchanged.
No tests/builds were rerun for this prose-only change, and no new runtime pass is
claimed. The independent runtime/security evidence on `31ad678` remains in the
checker-owned log; the gate needs refreshed rows for the new documentation head.

This record commit changes only `docs/agents/build.md` and the builder's
`docs/agents/status.md` row. Checker records were not edited.

Next: say **recheck** in the existing independent Check chat for `bfc9b88` on
`quick-entry-dashboard`, focusing on the requested roadmap/decision addition
against the optional finding from `31ad678`. Report only, except checker-owned
`checks.md` rows.
