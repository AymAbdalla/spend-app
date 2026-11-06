# Build log

Written only by the builder's main agent, one row per slice. State is `built` or `fixed (round N)`; results start with `self-check:`. Never write `checked` here.

| Slice | Workstream | Branch | Commit | Acceptance checks | Builder results | State | Date |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | spend-core | quick-entry-dashboard | 0393ef57d4e7cd6b233e01307697d13c1ccf4415 | Enter a USD 12.34 purchase, save once, observe it and matching totals on Dashboard, terminate/relaunch, and observe the same persisted purchase exactly once. | self-check: 17 unit + 5 UI tests passed on each of iPhone 17 Pro and iPhone SE 3rd generation, iOS 26.5; no skips or runtime warnings; Release simulator build passed; evidence below | built | 2026-11-06 |
| 1 | spend-core | quick-entry-dashboard | fb04a1dcfd827d8a6dd80e2654b03bf30d77d4e0 | Enter a USD 12.34 purchase, save once, observe it and matching totals on Dashboard, terminate/relaunch, and observe the same persisted purchase exactly once. | self-check: final completion includes the generated shared workspace used by the same passing 22-test runs on both simulators and Release build; compiled source unchanged | built | 2026-11-06 |

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
