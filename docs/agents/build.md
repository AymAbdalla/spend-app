# Build log

Written only by the builder's main agent, one row per slice. State is `built` or `fixed (round N)`; results start with `self-check:`. Never write `checked` here.

| Slice | Workstream | Branch | Commit | Acceptance checks | Builder results | State | Date |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | spend-core | quick-entry-dashboard | 0393ef57d4e7cd6b233e01307697d13c1ccf4415 | Enter a USD 12.34 purchase, save once, observe it and matching totals on Dashboard, terminate/relaunch, and observe the same persisted purchase exactly once. | self-check: 17 unit + 5 UI tests passed on each of iPhone 17 Pro and iPhone SE 3rd generation, iOS 26.5; no skips or runtime warnings; Release simulator build passed; evidence below | built | 2026-11-06 |
| 1 | spend-core | quick-entry-dashboard | fb04a1dcfd827d8a6dd80e2654b03bf30d77d4e0 | Enter a USD 12.34 purchase, save once, observe it and matching totals on Dashboard, terminate/relaunch, and observe the same persisted purchase exactly once. | self-check: final completion includes the generated shared workspace used by the same passing 22-test runs on both simulators and Release build; compiled source unchanged | built | 2026-11-06 |
| 1 | spend-core | quick-entry-dashboard | 249542912e05ee44e2d5e2f5318c824362b08f0b | Enter a USD 12.34 purchase, save once, observe it and matching totals on Dashboard, terminate/relaunch, and observe the same persisted purchase exactly once. | self-check: all 5 optional follow-ups addressed; 21 unit + 5 UI tests passed on each of Pro and SE, no skips/runtime warnings; Release build passed; new evidence below; independent recheck pending | built | 2026-11-06 |
| 1 | spend-core | quick-entry-dashboard | 31ad678f6a61cc7016650a1121b99bfb8e81ea8c | Enter a USD 12.34 purchase, save once, observe it and matching totals on Dashboard, terminate/relaunch, and observe the same persisted purchase exactly once. | self-check: 25 unit + 5 UI tests passed on each of Pro and SE, no skips/runtime warnings; Release passed; dedicated journal adoption and full-row visibility verified; independent recheck pending | built | 2026-11-06 |
| 1 | spend-core | quick-entry-dashboard | bfc9b886dfc6572a96eadf673f03cf0f5bb3032e | Enter a USD 12.34 purchase, save once, observe it and matching totals on Dashboard, terminate/relaunch, and observe the same persisted purchase exactly once. | self-check: documentation-only follow-up; roadmap cleanup prerequisite and decision caveat read back; git diff --check passed; no ios changes from checked 31ad678; no new runtime test claims | built | 2026-11-06 |
| AB1 | spend-core | action-button-shortcut | a6b2f551c72104372fbb44f6fb7d62c2b7df83cc | A UI test runs the real intent at launch (simulated trigger): Quick Entry appears with the amount field focused; typing 12.34 and Test cafe and tapping Save shows $12.34 today and one Test cafe row. Edge cases in the Verification table pass. The built app's App Intents metadata lists "Log a purchase" as an app-opening shortcut. All 30 existing tests still pass on iPhone 17 Pro and iPhone SE. | self-check: 37 of 37 tests passed on each of iPhone 17 Pro and iPhone SE 3rd gen, iOS 26.5 (27 unit, 10 UI: the 30 existing plus 7 new), 0 skipped, 0 build warnings; Release simulator build passed; Release metadata lists LogPurchaseIntent "Log a purchase" with openAppWhenRun true and supportedModes 2; test-hook strings absent from Release; simulated trigger only; optional Shortcuts-app tap failed ("Couldn't find AppShortcutsProvider"), not a gate, and an owner-approved Release retry failed the same way, with the log showing iOS rejected the app for having no Team ID; evidence below | built | 2026-11-07 |
| AB2 | spend-core | action-button-shortcut | 573286721f91475dd7bb0a79a36875be9b499ff1 | On the owner's iPhone 18 Pro: Settings → Action Button → Shortcut lists "Log a purchase"; tapping it in the Shortcuts app opens Quick Entry; pressing the button from the Home Screen opens Quick Entry; saving a clearly fake purchase (TEST, 1.00) shows it on the Dashboard; it is still there after force-quit, lock and unlock. `git grep` finds no team ID. Simulator suites still pass. | self-check: 37 of 37 tests on each of iPhone 17 Pro and iPhone SE 3rd gen, iOS 26.5, 0 skipped, 0 compiler warnings; Release build passed; the local file's team reaches the app and both test targets in Debug and Release and is absent without it; git ignores the file and the team ID has 0 matches in files or history; fresh clone builds for the simulator; phone steps 3 to 8 and 10 passed and step 9 was observed (owner-observed, iPhone 18 Pro, iOS 27.2, screenshots only because Mac screen recording is unsupported); merchant saved as "Test", as typed; evidence below | built | 2026-11-07 |
| H1 | spend-core | transaction-history | 4c8cdb0436fae523d23b90ed875f83867edeeecf | On a seeded test store: Dashboard → See all shows History with three day sections in the order Jun 1, 2030; Jan 15, 2026; Jan 14, 2026, totals $60.00, $36.60 and $2.75, and four rows; tapping Weekly grocer shows $32.10, Weekly grocer, Groceries, Planned, Jan 15, 2026 at 6:40 PM and "Weekly shop"; Back returns to History; the Dashboard's today total stays $0.00. A relaunch without the seed argument shows the same sections. A fresh store shows the empty state. All 37 existing tests still pass on iPhone 17 Pro and SPEND Small Phone (iOS 26.5); the Release simulator build passes; the seed argument is absent from the Release binary. | self-check: 49 of 49 tests (34 unit, 15 UI; 7 unit and 5 UI new) passed on each of iPhone 17 Pro and SPEND Small Phone, iOS 26.5, 0 skipped, 0 warnings; Release simulator build passed; the seed argument and the 6 earlier hook arguments are absent from the Release binary and present once each in the Debug code library; normal journals unchanged; XcodeGen byte-stable; one visual defect (merchant truncated at accessibility text sizes) fixed before the final runs; evidence below | built | 2026-11-07 |
| P1 | spend-core | portfolio-ready | 85655e6a59c431e58f340f4dd20ea4af19d0f46a | Every relative link and image path in README.md resolves to a tracked file (a script in the scratch folder lists each one with exists or missing: 0 missing). Each PNG's IHDR plus concatenated IDAT bytes hash the same as the owner's original, and its chunk list has no eXIf or iTXt. git grep on the branch finds no /Users/, no DEVELOPMENT_TEAM = followed by a value, and no email in README.md. Every number in the README matches its named source row. After git push -u origin portfolio-ready, the branch README on GitHub shows the four images (owner-visible while private; the checker confirms with gh api that the four image paths exist on the branch). | self-check: links_check.py on README.md at 85655e6 lists 19 links, 18 resolve and 1 missing (LICENSE, which P2 adds; 0 missing is expected at the branch tip after P2); png_strip.py copied the four screenshots from ~/aym/agents/outputs/spend/portfolio-ready/screenshots/ into docs/images/ dropping only eXIf and iTXt, and the SHA-256 of IHDR plus IDAT bytes is equal before and after for all four (dashboard 99ff6ae3, quick-entry 2797ec3b, dashboard-breakdown 56f70de2, dashboard-recent-purchases 2e62e790; chunk lists after: IHDR, sRGB or iCCP plus cICP, pHYs, IDAT, IEND); grep on README.md: /Users/ 0, DEVELOPMENT_TEAM with a value 0, email 0, Co-Authored 0, Generated 0; git diff main --stat -- ios/ is empty; README numbers read beside their sources: 49 tests (34 unit, 15 UI) and the Release build and hook strings from the checks.md H1 row at 4c8cdb0, 0.1.0 merged and tagged 2026-11-07 (git log v0.1.0), History merged 2026-11-07 at 4fef33f, look-and-feel one of three slices passed (LF2) plus security and LF1 and LF3 failed one finding each (that branch's checks.md, 2026-11-08), known limits from CHANGELOG 0.1.0; the GitHub branch view is not yet checked because the push happens at the end of Build (result goes in status.md). Scripts and the originals with their hashes: ~/aym/agents/outputs/spend/portfolio-ready/ and the session scratch folder. | built | 2026-11-18 |
| P2 | spend-core | portfolio-ready | 47006a2d0b8d7fa5d2dcc30d5900bdd41cb2fa47 | git grep -c '/Users/' on the branch reports no tracked file. git diff main -- docs/agents/build.md changes only lines that contained the path, plus the new rows after the H1 row. python3 <check-this>/scripts/agents_gate.py check --base main lists exactly the slices this round added, refuses only for "no independent pass" and "no security pass" (expected before the Check), and reports no column, State or self-check problem. LICENSE equals the SPDX MIT text apart from the copyright line, which reads Copyright (c) 2026 Ayman Abdalla. | self-check: sed replaced the home folder prefix with ~/ in build.md at 47006a2: 21 lines removed, every one of them held the prefix, 21 lines added, the first table untouched (first changed hunk at line 49); status.md's single mention went when its line was rewritten in the P1 record commit 4918ceb; git grep for the username path on the tip after the plan wording commit that follows this row: 0 tracked files (the plan's own P2 row had quoted the username path, reworded to /Users/<username>/ with no decision changed); the bare string /Users/ still appears as the quoted search pattern in docs/plans/portfolio-ready.md and in the P1 row, which is the acceptance wording itself and not a path, so the literal acceptance is not met to the letter; gate after the P1 record: refused for slice P1 no independent pass and security stale at 85655e6, no column, State or self-check problem (rerun at the branch tip recorded in status.md); LICENSE diffed against the choosealicense.com MIT template fetched 2026-11-18 with 2026 and Ayman Abdalla filled in: identical apart from a leading blank line in the extracted template; git diff main --stat -- ios/ empty. | built | 2026-11-18 |

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

Repository root: `~/aym/projects/spend-app`.
Xcode: 27.2 (27B52). Runtime: iOS 26.5 (23F77). Simulator IDs are explicit below.
The recorded runs also used separate derived-data paths and result bundles under
`~/aym/agents/work/spend-temp/2026-11-06-quick-entry-dashboard`; all test data is synthetic.

```sh
xcodebuild test -project ios/SPEND.xcodeproj -scheme SPEND -destination 'platform=iOS Simulator,id=6392B603-3453-49E8-9124-17FBBAC89C3D' -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO
```

```sh
xcodebuild test -project ios/SPEND.xcodeproj -scheme SPEND -destination 'platform=iOS Simulator,id=45D6AC76-2BBA-490E-9A09-E35E2419A1F2' -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO
```

```sh
xcodebuild build -project ios/SPEND.xcodeproj -scheme SPEND -configuration Release -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO
```

- Pro: `~/aym/agents/work/spend-temp/2026-11-06-quick-entry-dashboard/acceptance-pro.log` and `acceptance-pro.xcresult`.
- SE: `~/aym/agents/work/spend-temp/2026-11-06-quick-entry-dashboard/acceptance-se.log` and `acceptance-se.xcresult`.
- Release: `~/aym/agents/work/spend-temp/2026-11-06-quick-entry-dashboard/acceptance-release.log`.
- Parsed result summaries: `~/aym/agents/outputs/spend/quick-entry-dashboard/test-summary-pro.json` and `test-summary-se.json`.
- Tested source/project hashes: `~/aym/agents/outputs/spend/quick-entry-dashboard/tested-source-sha256.txt`; matched unchanged files before the code commit.
- Screenshots: `~/aym/agents/outputs/spend/quick-entry-dashboard/dashboard-light.png`, `dashboard-se-light.png`, `quick-entry-light.png`, `quick-entry-storage-error.png`, `quick-entry-se-large-dark.png`, `dashboard-se-large-dark.png`.

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

Check slice 1 in ~/aym/projects/spend-app (branch quick-entry-dashboard)
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
`~/aym/agents/work/spend-temp/2026-11-06-check-followups/`.
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
`~/aym/agents/outputs/spend/check-followups/`.
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
`~/aym/agents/work/spend-temp/2026-11-06-journal-folder/`:
`baseline`, `red-path-visibility`, `green-path-visibility`, `acceptance-pro`,
`acceptance-se` (each `.log` and `.xcresult`), plus `release-build.log`.

Deliverables:
`~/aym/agents/outputs/spend/journal-folder/`:
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

## 2026-11-07 slice AB1: "Log a purchase" shortcut

Branch `action-button-shortcut`, stacked on `quick-entry-dashboard` at `d289d2a`
(the owner chose stacking on 2026-11-07 instead of merging into `main` first).
Plan: `docs/plans/action-button.md`, approved by the owner on 2026-11-07 and
committed in `342959a`. Code commit: `a6b2f55`. All runtime results below use a
simulated trigger: DEBUG launch arguments make the app run the real intent
itself. No iPhone was used and no Action Button was pressed.

### Self-check results

| Check | State | Observed result |
| --- | --- | --- |
| Full suite, iPhone 17 Pro, iOS 26.5 | pass | 37 of 37 passed (27 unit, 10 UI), 0 failed, 0 skipped, 0 build warnings, exit 0. |
| Full suite, iPhone SE 3rd gen (SPEND Small Phone), iOS 26.5 | pass | Same 37 of 37, 0 skipped, 0 build warnings, exit 0. |
| Existing behavior | pass | All 30 existing tests (25 unit, 5 UI) pass in both runs above. |
| Cold launch, Quick Entry, save, Dashboard | pass | `testShortcutAtLaunchOpensQuickEntryAndSaves`: Quick Entry appears without any tap; the Done control (shown only while a field has focus) is present; typing 12.34 works without tapping the field; Save shows today $12.34 and one row containing Test cafe. |
| Journal failed to open | pass | `testShortcutWaitsForJournalRetryThenOpensQuickEntry`: retry screen and no Quick Entry first; after Try again, Quick Entry opens focused; Cancel leaves $0.00. |
| Request made before the Dashboard exists | pass | The launch hook starts `perform()` from the app initializer, before any view exists, and the retry test above makes the order certain. That the request also lands before the journal's load task is likely (both queue on the main actor in order) but not observed. |
| Cancel after a shortcut open | pass | `testCancelAfterShortcutSavesNothing`: $0.00, 0 rows, no "Purchase saved." label. |
| Typed draft kept | pass | `testShortcutAgainKeepsTypedDraft`: 8.75 typed, app sent Home and reactivated (second request), field still 8.75, one amount field. |
| No false "Purchase saved" | pass | `testShortcutAfterSaveClearsOldConfirmation`: after a save, a second request opens Quick Entry with the old label gone while the sheet is open and after Cancel; today stays $12.34 with 1 row. Spoken output not checked. |
| Intent only records a request | pass | Unit test: `perform()` sets the shared request flag. Checked by reading plus grep: the intent files and request holder mention journal, store, context, save or commit only in comments and the title. |
| Intent opens the app | pass | Unit test: `openAppWhenRun` is true; on iOS 26.5 `supportedModes` equals `.foreground(.immediate)`. |
| Shortcut published to iOS | pass | Release `SPEND.app/Metadata.appintents/extract.actionsdata`: action `LogPurchaseIntent`, title "Log a purchase", `openAppWhenRun` true, `supportedModes` 2, 0 parameters; autoShortcuts phrase "Log a purchase in ${applicationName}", short title "Log a purchase", image `plus.circle`. The "Metadata extraction skipped" notice now appears only for the SPENDUITests target in Debug, and 0 times in the Release build log. |
| Release simulator build | pass | `BUILD SUCCEEDED`, exit 0. |
| DEBUG hooks absent from Release | pass | `strings` on the Release `SPEND` binary: 0 matches for each of the 6 hook arguments (2 new, 4 existing). The Debug binary has 1 of each, so the search can find them. |
| Project regeneration | pass | XcodeGen 2.46.0 run twice: identical project and scheme hashes; the project diff only adds the 5 new files. |
| Security self-review | pass | No networking, logging, packages, entitlements or secrets added. The intent takes no input and returns nothing; it can't read, speak or save purchases. Hooks need DEBUG plus a valid test-store UUID. |
| Optional: tap "Log a purchase" in the Simulator's Shortcuts app | fail (optional, not a gate) | iPhone 17 Pro Max simulator, iOS 26.5, Debug build with ad-hoc "Sign to Run Locally" signing (no team), installed and opened once. The Shortcuts app lists SPEND.'s "Log a purchase" tile; tapping it shows "Unable to run App Shortcut". Simulator log: `LNActionForAutoShortcutPhraseFetchError Code=1 "Couldn't find AppShortcutsProvider."` The plan said to record a refusal as unavailable; the check did run, so it is recorded as fail. A second, owner-approved attempt with a Release build signed the same way failed identically; see "Shortcuts-app failure" below. |
| Action Button press, locked phone, iOS 17 to 25, spoken VoiceOver | unavailable | Need the owner's iPhone (AB2) or an older runtime. |
| Independent Check | pending | Per the plan, one fresh chat checks 1, AB1, AB2 and security together after AB2. |

### Shortcuts-app failure

First hypothesis: Debug builds put the app's code in `SPEND.debug.dylib`
(`SpendShortcuts` symbols: 7 there, 0 in the `SPEND` executable), so iOS might
not find the provider. The owner approved one more attempt to test it.

Second attempt, same simulator, same driver test: a Release build signed the
same way (ad-hoc, `TeamIdentifier=not set`), one binary with 13 `SpendShortcuts`
symbols in `SPEND`, and the same `autoShortcutProviderMangledName`
(`5SPEND14SpendShortcutsV`) in its metadata as the Debug build. Installed over
the Debug build and opened once. Result: fail, the same "Unable to run App
Shortcut" alert and the same error. The Debug-file hypothesis is rejected.

Both attempts' logs show the order of events: iOS launches SPEND for the
shortcut; SPEND connects back to the system App Intents service (`linkd`); `linkd`
logs "Failed to generate bundleIdentity: Not a platform binary, checking
teamId... Unable to get teamId from com.aymanabdalla.spend", then "Rejecting
invalid client due to requiresValidBundle", then reports "Couldn't find
AppShortcutsProvider." The likely cause is the missing Team ID in the
simulator's ad-hoc signature, not the intent code. Not proven: a simulator build
signed with a real team was not tried, because that needs the owner's account.
AB2 already signs with the owner's team through the git-ignored settings file,
so phone step 5 is the test. If step 5 fails on a team-signed build, the plan
says Build stops and moves to Debug.

### Test-first and sensitivity evidence

- `baseline`: one existing unit test passed before any new test was written.
- `red`: stubs (`request()` did nothing, `openAppWhenRun` false, `supportedModes`
  `.background`, `perform()` did nothing). All 7 new tests compiled and failed on
  assertions: request flag false; `openAppWhenRun` false; `IntentModes(rawValue: 1)`
  versus 2; all 5 UI tests at "Quick Entry should open".
- `green`: the 7 new tests passed on the first implementation.
- `mutation/mutation-a`: the shortcut path skipped `saved = false` and closed an
  already open sheet. The confirmation test failed at the label check while the
  sheet was open; the draft test failed when the sheet did not come back. Restored
  from a saved copy; `cmp` identical.
- `mutation/mutation-b`: Quick Entry's initial focus removed. The cold-launch
  test failed with "The amount field should be focused". Restored; `cmp`
  identical and `git diff` empty for Quick Entry.
- After the full runs, one code comment in `AppConfiguration.swift` was reworded
  (same line count) so it no longer claims the hook runs "before the journal
  opens". The Release rebuild recompiled the file and the `SPEND` binary's
  SHA-256 stayed `4321923a37286112784b3cc27e1f50dbd115f386a7c507933c02756dc3f1bde2`.
  Tested and committed source hashes differ only for that file.

Expected values come from the plan: 12.34, Test cafe, $12.34 and one row from
the AB1 acceptance check; `openAppWhenRun` true and `.foreground(.immediate)`
from the AB1 build notes; $0.00 and no rows after Cancel, and the typed amount
kept, from the Agreed behavior table.

### Reproduction and artifacts

Repository root: `~/aym/projects/spend-app`. Xcode 27.2 (27B52),
iOS 26.5 (23F77) runtime, XcodeGen 2.46.0. Test data is synthetic.

```sh
xcodebuild test -project ios/SPEND.xcodeproj -scheme SPEND -destination 'platform=iOS Simulator,id=6392B603-3453-49E8-9124-17FBBAC89C3D' -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO
```

```sh
xcodebuild test -project ios/SPEND.xcodeproj -scheme SPEND -destination 'platform=iOS Simulator,id=45D6AC76-2BBA-490E-9A09-E35E2419A1F2' -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO
```

```sh
xcodebuild build -project ios/SPEND.xcodeproj -scheme SPEND -configuration Release -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO
```

Scratch logs and result bundles:
`~/aym/agents/work/spend-temp/2026-11-07-action-button-ab1/`:
`baseline`, `red`, `green`, `acceptance-pro`, `acceptance-se` (each `.log` and
`.xcresult`), `release-build.log`, `release-build-after-comment.log`,
`release-binary-*.sha`, `regen*.sha`, `tested-source-sha256.txt`,
`final-source-sha256.txt`, `mutation/`, `shortcuts-attempt/` (driver project,
logs, result bundle and simulator log) and `shortcuts-attempt-2/` (Release
attempt: `release-signed-build.log`, `attempt.log`, `attempt.xcresult`, full
`syslog-attempt.txt`, screenshots). The Release attempt's app was built with:

```sh
xcodebuild build -project ios/SPEND.xcodeproj -scheme SPEND -configuration Release -destination 'platform=iOS Simulator,id=87D58183-18C9-453A-B535-ACEB34DB80D5'
```

Deliverables: `~/aym/agents/outputs/spend/action-button/ab1/`:
`test-summary-pro.json`, `test-summary-se.json`, `shortcut-*-pro.png` and
`shortcut-*-se.png` (Quick Entry at launch, Dashboard after save, journal retry
screen, draft kept after second run), `shortcuts-app-attempt-1-library.png`,
`shortcuts-app-attempt-2-after-tap.png`, `shortcuts-attempt-syslog.txt` (these
three are the first attempt), `release-attempt-1-library.png`,
`release-attempt-2-after-tap.png`, `release-attempt-syslog-excerpt.txt`,
`release-attempt-bundles.txt` (the Release attempt), and all exported test
attachments under `pro/` and `se/`.

The iPhone 17 Pro Max simulator used for the optional attempts now has the
Release build of SPEND. installed, with its own normal journal from the opens,
and is shut down. The two test simulators' normal journals were not opened by
this work.

### Changed files

`a6b2f55`: `README.md`, `docs/ARCHITECTURE.md`, `docs/DECISIONS.md` (013),
`docs/ROADMAP.md`, `ios/SPEND.xcodeproj/project.pbxproj`,
`ios/SPEND/App/AppConfiguration.swift`, `ios/SPEND/App/QuickEntryRequest.swift`,
`ios/SPEND/App/SpendApp.swift`, `ios/SPEND/Features/Dashboard/DashboardView.swift`,
`ios/SPEND/Intents/LogPurchaseIntent.swift`, `ios/SPEND/Intents/SpendShortcuts.swift`,
`ios/SPENDTests/LogPurchaseIntentTests.swift`,
`ios/SPENDUITests/LogPurchaseShortcutUITests.swift`. `342959a`:
`docs/plans/action-button.md` (status line set to approved and stacked). This
record commit changes only `docs/agents/build.md` and the builder's
`docs/agents/status.md` row, and so does the later commit that records the
Release attempt.

### Deviations and open items

- The optional Shortcuts-app check is recorded as fail rather than the plan's
  "unavailable", because it ran and iOS refused.
- The plan allowed one Shortcuts-app attempt; the owner approved a second
  (Release build) to test the Debug-file hypothesis. No code or project setting
  changed for it.
- Add purchase and the shortcut now share one `openEntry()` helper, so they
  stay identical. Add purchase behaves as before; its existing UI tests pass.
- The Dashboard's request handling has no unit test of its own (it is SwiftUI
  view state). The UI tests and both mutation runs cover it.
- Not tested: a request that arrives while the sheet is mid-dismissal (plan
  risk). The current hooks can't time it reliably.
- Leaving and returning in the UI tests uses the Home button and
  `XCUIApplication.activate()`.
- The merge gate counts slice 1 on this branch too (stacked), so the final
  Check must record fresh rows for 1, AB1, AB2 and security.

## 2026-11-07 slice AB2: Action Button on the owner's iPhone

### Scope and authorization

The owner said "go" for AB2 after AB1 and the Release Shortcuts attempt, then
"yes" to the builder writing the team ID (read from the Apple Development
certificate) into the git-ignored local file, building and installing over
Wi-Fi from Terminal, and taking phone screenshots from the Mac. The owner
performed every phone step. Nothing was pushed or merged.

### Signing change

`ios/Config/Signing.xcconfig` (committed) optionally includes
`ios/Config/Signing.local.xcconfig` (git-ignored), which holds
`DEVELOPMENT_TEAM`. `ios/project.yml` attaches the committed file to the
project's Debug and Release configurations through `configFiles` and no longer
sets an empty `DEVELOPMENT_TEAM`. Regenerated with XcodeGen 2.46.0; two runs gave
identical project and scheme hashes. The project diff adds the file and group,
sets it as the base configuration, and removes the empty team values.

| Check | State | Observed result |
| --- | --- | --- |
| Before the change, a local team file is ignored | pass (red) | Clone at `bbc1983` with a local file holding `FAKETEAM01`: `xcodebuild -showBuildSettings` has no `DEVELOPMENT_TEAM` and no `FAKETEAM01`. |
| After the change, the local team reaches every target | pass | Clone with the change and the fake file: `DEVELOPMENT_TEAM = FAKETEAM01` for SPEND in Debug and Release, and for SPENDTests and SPENDUITests. Without the file: no team. |
| The empty team value had to go | pass (mutation) | Putting `DEVELOPMENT_TEAM: ""` back in `project.yml` and regenerating: 0 matches for `FAKETEAM01`. Restored; `cmp` identical. |
| Git ignores the local file | pass | `git check-ignore -v` names `.gitignore:14`; `git status --ignored` lists it as ignored. |
| Team ID stays out of git | pass | `git grep --untracked` for the real team ID: none. `git log -p --all`: 0 matches. |
| Fresh clone builds for the simulator | pass | Clone of `5732867` (no local file): Debug simulator build succeeded, "Sign to Run Locally", 0 compiler warnings. |
| Full suite, iPhone 17 Pro, iOS 26.5 | pass | 37 of 37 (27 unit, 10 UI), 0 failed, 0 skipped, exit 0. The only `warning:` line is the known App Intents metadata notice for SPENDUITests; 0 compiler warnings. |
| Full suite, iPhone SE 3rd gen, iOS 26.5 | pass | Same 37 of 37, 0 skipped, exit 0, same single notice. |
| Release simulator build | pass | `BUILD SUCCEEDED`, 0 warnings. |
| Tested source equals committed source | pass | SHA-256 of `.gitignore`, `project.yml`, `project.pbxproj` and `Signing.xcconfig` before commit match the hashes taken when the suites ran. Docs changed after the runs. |

### Phone checklist (iPhone 18 Pro, iOS 27.2)

Phone results are owner-observed: the owner pressed the button and typed; the
builder captured each screen from the Mac only after the owner said it was
showing. Screenshots show screens, not the physical button presses.

| Step | State | Evidence and notes |
| --- | --- | --- |
| 0. No real purchases on the phone | pass | Developer app list on the phone had no `com.aymanabdalla.spend` before install. |
| 1. Connected, trusted, Developer Mode | pass | Device details: paired, connected over the local network, Developer Mode enabled. No cable needed. |
| 2. Team in the local file, install, open once | pass | Team read from the certificate's OU field, written without printing it. Build signed with "Apple Development" and "iOS Team Provisioning Profile: *"; app signature has a 10-character TeamIdentifier. Installed and launched with `devicectl`. |
| 3. Dashboard with 0 purchases | pass | `step-3-dashboard-empty.png`: today, week and month $0.00. |
| 4. Action Button → Shortcut lists "Log a purchase" | pass | `step-4-action-button-setting.png`: Shortcut, "Log a purchase" selected. Its icon is a blank placeholder (the app has no icon). |
| 5. Shortcuts app tap opens Quick Entry | pass | `step-5-shortcuts-app-opens-quick-entry.png`: Quick Entry, cursor in the amount field, decimal keypad up. The same tap failed on the ad-hoc simulator builds, which supports the missing-Team-ID explanation in AB1. |
| 6. Button press from the Home Screen, app closed | pass | `step-6-action-button-opens-quick-entry.png`: Quick Entry, amount field focused. Screen recording was unavailable (see deviations). |
| 7. Enter 1.00 and TEST, Save | pass | `step-7-saved-test-purchase.png`: "Purchase saved.", today, week and month $1.00, one row "Test" $1.00. The merchant field capitalizes sentences and the app only trims spaces (`JournalStore.swift:77`), so "Test" is what the keyboard produced. |
| 8. Type 2, press the button again | pass | `step-8-second-press-keeps-draft.png`: Quick Entry still open with 2 and the cursor in the amount field. After Cancel the total stayed $1.00 (`step-9-after-unlock-dashboard.png`). |
| 9. Locked phone, press the button | observed | First try: iOS asked for the passcode; the owner answered the builder before entering it, and iOS refused the launch. Notification text as the owner typed it, with typing errors corrected: "The request was denied by service delegate (SBMainWorkspace) for reason: Locked ("Unable to launch com.aymanabdalla.spend because the device was not, or could not be, unlocked"). The request to open "com.aymanabdalla.spend" failed." Unlocking showed the Dashboard the owner had left open, with no Quick Entry, so the intent did not reach the app. Retry with SPEND. closed and the passcode entered at once: Quick Entry opened with the amount field ready and no journal error (`step-9-retry-passcode-then-quick-entry.png`). |
| 10. Force-quit, lock about 20 s, unlock, reopen | pass | `step-10-after-force-quit-lock-totals.png` and `step-10-after-force-quit-lock-row.png`: $1.00 totals and one row "Test", $1.00, Other · Planned, Nov 7, 2026 at 6:34 PM. |

DECISIONS 011 and 013 record the phone observations. The ROADMAP ticks
"Action Button setup" and "Test on physical iPhone" because their checklist
steps passed.

### Reproduction and artifacts

```sh
xcodebuild build -project ios/SPEND.xcodeproj -scheme SPEND -configuration Debug -destination 'id=<iPhone UDID>' -allowProvisioningUpdates
```

```sh
xcrun devicectl device install app --device <iPhone UDID> <DerivedData>/Build/Products/Debug-iphoneos/SPEND.app
```

```sh
xcrun devicectl device capture screenshot --device <iPhone UDID> --destination <file>.png
```

The simulator suite commands are the same as AB1's. Scratch:
`~/aym/agents/work/spend-temp/2026-11-07-action-button-ab2/`
(`red-clone/`, `green-clone/`, `fresh-clone/`, `acceptance-pro` and
`acceptance-se` logs and result bundles, `release-build.log`,
`clone-sim-build.log`, `fresh-clone-build.log`, `phone-build.log`,
`phone-install.log`, settings dumps, `tested-change-sha256.txt`,
`precommit-sha.txt`). Deliverables:
`~/aym/agents/outputs/spend/action-button/ab2/` (the 10
screenshots named above).

### Changed files

`5732867`: `.gitignore`, `README.md` (Run on an iPhone steps, status),
`docs/ARCHITECTURE.md` (one signing sentence), `docs/DECISIONS.md` (011 phone
observation, 013 limits), `docs/ROADMAP.md`, `ios/Config/Signing.xcconfig`,
`ios/project.yml`, `ios/SPEND.xcodeproj/project.pbxproj`. This record commit
changes only `docs/agents/build.md` and the builder's `docs/agents/status.md`
row.

### Deviations, follow-ups and untested

- The owner approved installing from Terminal (`xcodebuild` and `devicectl`)
  instead of pressing Run in Xcode, and the builder writing the team into the
  local file. Both still keep the team out of git.
- The plan asked for a screen recording of steps 6 and 7. `devicectl` reported
  "The capability Screen Recording is not supported by this device" over the
  Wi-Fi connection, so screenshots were used.
- Two screenshots caught unrelated personal content (another app, then the lock
  screen). Both were deleted on the spot and are not in the evidence.
- Step 9 was run twice because the first passcode prompt went unanswered.
- The plan listed DECISIONS 011 for AB2; 013's limits paragraph and one
  ARCHITECTURE sentence were also updated so they don't contradict the result.
- Follow-up: SPEND. has no app icon, so the Action Button setting, Shortcuts and
  notifications show a blank placeholder.
- Follow-up: on the iPhone 18 Pro at default text size, the Dashboard's first
  recent purchase (and the empty-state line) sits behind the Add purchase bar
  until the owner scrolls.
- The phone keeps the Debug build with one "Test" $1.00 purchase, and the Action
  Button stays set to "Log a purchase". Removing the purchase needs edit/delete
  or deleting the app. The local signing file stays in the working tree.
- Not tested: iOS 17 to 25, spoken VoiceOver output and the save announcement on
  the phone, Siri by voice, Spotlight, and whether the journal files are
  unreadable while locked.

## 2026-11-07 slice H1: History list and purchase detail

### Scope and authorization

The owner asked on 2026-11-07 to build slice H1 from
`docs/plans/transaction-history.md` with implement-this, in the worktree
`.claude/worktrees/transaction-history` on branch `transaction-history`. That
request approved the plan, including the open decision that the Dashboard's
recent rows adopt the shared row layout and the stated defaults (titles
"History" and "Purchase", weekday-and-date headers). Work stayed on the
branch: the slice commit and this records commit. Nothing was pushed or merged.

### Self-check results

| Check | State | Observed result |
| --- | --- | --- |
| Full suite, iPhone 17 Pro, iOS 26.5 | pass | 49 of 49 (34 unit, 15 UI), 0 failed, 0 skipped, exit 0, 0 `warning:` lines in the log. |
| Full suite, iPhone SE 3rd gen (SPEND Small Phone), iOS 26.5 | pass | Same 49 of 49, 0 skipped, exit 0, 0 `warning:` lines. |
| Existing behavior | pass | All 37 existing tests (27 unit, 10 UI) pass in both runs, including the `purchaseRow` identifier, label and position checks now that each row is a navigation link. |
| Day grouping and totals (unit) | pass | 7 `DaySectionsTests`: the seed fixture given out of order gives days 2030-06-01, 2026-01-15, 2026-01-14 with totals 6000, 3660, 275 cents and items newest first within a day; 10 + 20 = 30; New York spring-forward day boundaries at 05:00Z and 04:00Z; year boundary splits into two days; empty input gives no sections; overflow throws `totalTooLarge`; 0 and -1 cents throw `invalidRecord`. |
| History sections, totals and order | pass | `testSeededHistoryShowsDaySectionsDetailAndSurvivesRelaunch`: headers "Sat, Jun 1, 2030", "Thu, Jan 15, 2026", "Wed, Jan 14, 2026" top to bottom with totals $60.00, $36.60, $2.75; 4 `historyRow` elements; Weekly grocer above Corner bakery; Dashboard today total $0.00 before and after. |
| Detail shows every field | pass | Same test: $32.10, Weekly grocer, Jan 15, 2026 at 6:40 PM, "Category, Groceries", "Type, Planned", "Weekly shop"; Back returns to History with 4 rows; Back again reaches the Dashboard. |
| Relaunch without the seed argument | pass | Same test: after terminate and relaunch with only the test-store UUID, See all shows the same three sections, totals and 4 rows. |
| Empty state | pass | `testEmptyHistoryShowsEmptyState`: "No purchases yet." and "Purchases you save appear here, newest first." shown, 0 rows; Back returns to the Dashboard at $0.00. |
| Dashboard row opens the detail | pass | `testDashboardRowOpensDetailAndBackReturns`: 12.34 Test cafe saved; the row is scrolled above the Add purchase bar and tapped; detail shows $12.34, Test cafe, "Category, Other", "Type, Planned" and no Notes section; Back; today $12.34. |
| Shortcut from History pops to the Dashboard | pass | `testShortcutFromHistoryReturnsToDashboardAndOpensQuickEntry` (`-run-log-purchase-on-activate`): from History, leaving and returning opens Quick Entry; after Cancel the Add purchase button is hittable, no "History" navigation bar exists, See all is visible and today is $0.00. |
| Accessibility sizes and dark mode | pass | `testDarkAccessibilityHistoryRemainsReadable` (dark, AccessibilityXXXL): headers and totals exist; the last row (Bus fare) becomes hittable after scrolling; its detail shows $2.75 and Bus fare. Screenshots attached. |
| Release simulator build | pass | `BUILD SUCCEEDED`, exit 0, 0 warnings. |
| Seed hook absent from Release | pass | `strings` on the Release `SPEND` binary: 0 matches for `-seed-history-fixture` and for the 6 earlier hook arguments; the seed-only text "Weekly grocer" also 0. The Debug code library `SPEND.debug.dylib` (Xcode puts Debug code there, not in the `SPEND` stub) has 1 of each, so the search can find them. Control: "No purchases yet." and "Recent purchases" are present in Release. |
| Project regeneration byte-stable | pass | XcodeGen 2.46.0 run twice on the final spec: identical `project.pbxproj` and scheme SHA-256; the project diff only adds the 6 new Swift files. |
| Normal journals untouched | pass | SHA-256 of the 6 normal-journal files (store, WAL, SHM on both simulators) equal before and after each full round. |
| Calm, readable screens (visual self-review) | pass after one fix | Light History and detail on Pro and SE: three cards, one per day, totals in the headers, amounts trailing, chevrons, no clipping. Empty state centered. Dashboard dark: See all beside "Recent purchases", the row with the amount trailing. Dark AccessibilityXXXL on Pro and SE first showed the merchant truncated ("Festival ti…"); after the fix below it wraps ("Festival" / "ticket") on both, and the default-size screens are unchanged. The header's day total renders in the header's secondary color, not primary. |
| Security self-review | pass | Diff read: no networking, logging, analytics, packages, entitlements or secrets. History and the detail read through the existing container and context and render stored values as text. The only new write path is the DEBUG seed, gated on `#if DEBUG`, a valid test-store UUID and the argument, writing only an empty test store through `PurchaseWriter`. Screenshots hold synthetic data and live outside the repository. |
| Independent Check | not run here | Needs the fresh chat below. Pending workflow gate, not a product failure. |
| Dashboard row at accessibility sizes, iOS 17 to 25, spoken VoiceOver, thousands of rows | not checked | The existing Dashboard accessibility test does not scroll to the row, so the shared row on the Dashboard card was not seen at that size; only iOS 26.5 and 27 runtimes exist; no VoiceOver speech; grouping runs in the view body. |

### Test-first and sensitivity evidence

- `baseline-test.log`: `SummaryTests/testEmptyJournalHasZeroTotals` passed on
  the Pro before any new test was written.
- `red-daysections-and-history.log`: `DaySections.group` was a stub returning
  one placeholder section (`.distantPast`, total -1, no items). All 7 unit tests
  failed on assertions, for example `("[-1]") is not equal to ("[6000, 3660,
  275]")` and `XCTAssertThrowsError failed: did not throw an error`. The seeded
  UI test failed at "The Dashboard should offer See all".
- `green-daysections-red-pop.log`: the 7 unit tests passed on the first real
  implementation. Of the 5 UI tests, the dark accessibility and empty-state
  tests passed; the seeded and Dashboard-row tests reached the detail and
  failed only at the Category row label, which the List reads as one element
  ("Category, Groceries" versus the expected "Groceries"); the shortcut test
  failed at "Quick Entry should close onto the Dashboard" because the one-line
  pop to root did not exist yet (Cancel landed back on History).
- `green-pop-and-detail.log`: after adding `path = NavigationPath()` and
  changing the two expectations to the combined labels "Category, Groceries"
  and "Type, Planned" (a change to the tests, not the view: the row still shows
  the value and the label reads better for VoiceOver), the 3 tests passed.
- Visual fix round: the SE dark accessibility screenshot showed "Festival ti…".
  Try 1 replaced `AnyLayout` with plain stacks: still truncated
  (`wrapfix-se` bundle). Try 2 kept the plain stacks and gave both sides of the
  row `fixedSize(horizontal: false, vertical: true)`: the merchant wraps
  (`wrapfix2-se` bundle). Both full suites, the Release build and the strings
  check were rerun on this final source (round 2 logs); round 1 logs are kept
  with a `-round1` suffix.

Expected values come from the plan: the seed fixture and the H1 acceptance
check (three headers, $60.00, $36.60, $2.75, four rows, $32.10, Weekly grocer,
Groceries, Planned, Jan 15, 2026 at 6:40 PM, "Weekly shop", $0.00), the Agreed
behavior table (empty-state copy, pop to root, Back) and the slice 1 acceptance
check (12.34 Test cafe). Day keys in the New York test come from the time zone's
offsets (UTC-5 before, UTC-4 after the change).

### Reproduction and artifacts

```sh
xcodebuild test -project ios/SPEND.xcodeproj -scheme SPEND -destination 'platform=iOS Simulator,id=6392B603-3453-49E8-9124-17FBBAC89C3D' -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO
```

```sh
xcodebuild test -project ios/SPEND.xcodeproj -scheme SPEND -destination 'platform=iOS Simulator,id=45D6AC76-2BBA-490E-9A09-E35E2419A1F2' -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO
```

```sh
xcodebuild build -project ios/SPEND.xcodeproj -scheme SPEND -configuration Release -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO
```

Scratch: `~/aym/agents/work/spend-temp/2026-11-07-transaction-history-h1/`
(`run-selfcheck.sh` runs the two suites, the Release build, the strings check
and the journal hashes; `acceptance-pro` and `acceptance-se` logs and result
bundles, `release-build.log`, `strings-check.txt`, `tested-source-sha256.txt`,
`normal-journal-before.txt` and `-after.txt`, `project-run1.txt` and
`project-run2.txt`, the red and green logs named above, `wrapfix-se` and
`wrapfix2-se` bundles, `PurchaseRow.before-wrap-fix.swift`). Deliverables:
`~/aym/agents/outputs/spend/transaction-history/h1/`: named
screenshots from the final (round 2) runs on Pro and SE (History light, both
details, empty state, dark accessibility before and after scrolling, Quick Entry
after the shortcut from History, Dashboard light and dark with the shared row and
See all), the round 1 `history-dark-accessibility-before-fix-pro.png` and
`-se.png` that show the truncation, `strings-check.txt`,
`tested-source-sha256.txt`, `project-run2.txt` and `normal-journal-isolation.txt`.

### Changed files

- New `ios/SPEND/Services/DaySections.swift`: `DatedAmount`, `DaySection`,
  `DaySections.group(_:calendar:)`.
- New `ios/SPEND/Features/History/HistoryView.swift` (`HistoryDestination`,
  `HistoryView`), `PurchaseDetailView.swift`, `PurchaseRow.swift` (`AmountLine`,
  `PurchaseRow`).
- `ios/SPEND/Features/Dashboard/DashboardView.swift`: `NavigationStack(path:)`,
  two value destinations, See all, rows as links with the shared row, pop to
  root in the shortcut handler.
- `ios/SPEND/App/AppConfiguration.swift`: the DEBUG seed hook, called from the
  store loader.
- New `ios/SPENDTests/DaySectionsTests.swift` (7 tests) and
  `ios/SPENDUITests/HistoryUITests.swift` (5 tests). Existing tests unchanged.
- `ios/SPEND.xcodeproj/project.pbxproj`: regenerated, 6 files added.
- `docs/ARCHITECTURE.md`, `docs/DECISIONS.md` (014), `docs/ROADMAP.md`
  ("Transaction history" ticked; "History category filter and search" added),
  `README.md` status, `docs/plans/transaction-history.md` (committed; status
  line now approved).

### Deviations, follow-ups and untested

- The detail's Category and Type rows read as one accessibility element each
  ("Category, Groceries"); the tests assert that combined label.
- `DaySections` has its own private overflow-checked `add` instead of sharing
  `SpendingSummary`'s private one, so `SpendingSummary.swift` (not in the plan's
  surfaces) stays untouched.
- Dashboard cards are links without a chevron (links in a scroll view draw
  none); History rows show the system chevron. Consider a chevron on the cards
  if tapping them proves hard to discover.
- The day total in the section header is secondary gray like the date; the
  plan did not fix its color.
- The Dashboard's own `totalRow` still uses `AnyLayout`; its titles are short
  and it is outside this slice.
- Not checked: the Dashboard card at accessibility sizes, iOS 17 to 25, spoken
  VoiceOver, scrolling with thousands of purchases, and merchant truncation is
  not machine-checked (the row is one combined element, so the UI test cannot
  measure the merchant's lines).

### Independent Check handoff

Check slice H1 in ~/aym/projects/spend-app/.claude/worktrees/transaction-history
(branch transaction-history) against docs/plans/transaction-history.md with
check-this, slice check; treat docs/agents/build.md as claims to verify, not
evidence. Report only, except your own checks.md rows. The latest code commit
is 4c8cdb0; the records commit follows it.
