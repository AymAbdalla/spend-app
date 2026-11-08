# SPEND. Design System

What the app looks like and why, written from the code that ships. Every
value here appears in the code; when they disagree, fix one of them. The
voice and personality live in `BRAND.md`; the principles behind the screens
live in `UX.md`.

## Purpose and principles

- One accent, no color meaning. Color says "you can tap this", nothing else.
  Planned and Impulse are words, never colors (`UX.md`, `BRAND.md`).
- Neutral surfaces, strong type. Amounts are the loudest thing on a screen.
- System first. Native text styles, system grouped surfaces, Dynamic Type and
  native controls, so the app follows the phone's settings.
- Calm. No animation or haptic is added; nothing moves by itself.

## Color roles

| Role | Light | Dark | Where it is set |
| --- | --- | --- | --- |
| Accent (tinted controls: Add purchase, See all, Done, pickers, Save, Cancel, Try again) | #0B7A75 | #0E948E | `ios/SPEND/Assets.xcassets/AccentColor.colorset`, applied by `ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME` in `ios/project.yml` |
| Page | `systemGroupedBackground` (#F2F2F7) | `systemGroupedBackground` (#000000) | `SpendDesign.pageBackground`; Lists use it by default |
| Card | `secondarySystemGroupedBackground` (#FFFFFF) | `secondarySystemGroupedBackground` (#1C1C1E) | `SpendDesign.cardSurface`; inset grouped List rows use it by default |
| Primary text | `Color.primary` | `Color.primary` | Default text color; the History day total names it explicitly |
| Secondary text | `.secondary` | `.secondary` | Labels, taglines, dates, supporting lines |
| Tertiary | `.tertiary` | `.tertiary` | The chevron on Dashboard rows |

Accent contrast, WCAG 2.x. The light values are from the deep-teal row of
`accent-contrast.md` (2026-11-07, kept with the design outputs outside the
repository); the dark variant was raised from #0D8D87 to #0E948E on 2026-11-08
after the accessibility audit rated See all on a dark card "nearly passed" at
4.19:1, and its values were recomputed then:

| Pair | Ratio |
| --- | --- |
| White label on the light accent (filled button) | 5.18 |
| Light accent on the light page #F2F2F7 (See all) | 4.64 |
| Light accent on a white card | 5.18 |
| White label on the dark accent (filled button) | 3.72 |
| Dark accent on the dark page #000000 (See all) | 5.65 |
| Dark accent on a dark card #1C1C1E (See all) | 4.57 |

Normal text targets 4.5 and every text pair meets it. The white label on the
dark accent button is large text (headline, semibold), where 3.0 is the
minimum; it sits at 3.72, close to the 3.65 that iOS's own blue gives under a
white label in dark mode.

## Typography roles

All roles are Dynamic Type text styles, so they scale with the phone's text
size. Amounts use monospaced digits so columns line up.

| Role | Style | Used by |
| --- | --- | --- |
| Display amount | `.largeTitle`, rounded design, semibold, monospaced digits | Today total; the detail's amount |
| Row amount | body, semibold, monospaced digits | `PurchaseRow` trailing amount; This week, This month, category and intention totals; History day totals |
| Section title | `.headline` | Recent purchases, This month by category, This month by intention; Today (secondary color) |
| Merchant | `.headline` | `PurchaseRow` leading text |
| Label | body, secondary | Period, category and intention names |
| Supporting line | `.subheadline`, secondary | "Category · Type" under a merchant |
| Link | `.subheadline`, medium | See all |
| Caption | `.caption`, secondary | The time or date on a row |
| Footnote | `.footnote`, secondary | The date under Today; "All amounts in USD. Stored on this device." |
| Tagline | `.title3`, secondary | "Feel every dollar." |
| Empty state | `.title3` medium, then body secondary | "Start with one purchase." and its line |
| Detail merchant | `.title3`, medium | The detail's second line |

At accessibility text sizes `AmountLine` and the total rows stack the amount
under its label instead of placing it at the trailing edge, and nothing is
truncated: everything stays reachable by scrolling.

## Spacing and shape

Tokens live in `ios/SPEND/Features/Shared/SpendCard.swift` as `SpendDesign`.

| Token | Value | Meaning |
| --- | --- | --- |
| `pageMargin` | 20 | Screen edge to content, and the Add purchase bar's side padding |
| `sectionGap` | 24 | Between sections (cards) on the Dashboard |
| `cardPadding` | 20 | Card edge to content; also the detail hero's row insets |
| `cardRadius` | 20 | Corner radius of a Dashboard card |
| `rowGap` | 16 | Between rows inside a card, on each side of a divider |

Dividers inside a card run the content width, so they sit `cardPadding` in
from the card's edge. Screens built on a `List` or `Form` (Quick Entry,
History, the detail) keep the system inset grouped shape and row insets; only
the detail's hero row takes `cardPadding`, so the amount sits like a card's.

## Components

- **`SpendCard`** (`.spendCard()`): full width, leading-aligned content,
  `cardPadding`, `cardSurface`, `cardRadius`. Every Dashboard section uses it.
- **`AmountLine`**: leading text with trailing text on one line; stacked at
  accessibility sizes. Rows, total rows and History headers use it or its rule.
- **`PurchaseRow`**: merchant with the amount trailing, "Category · Type",
  then the time (History) or date and time (Dashboard). Reads as one
  accessibility element. On the Dashboard it ends in a `chevron.right` in
  tertiary color because the row opens the detail; the chevron is hidden from
  accessibility so the row's spoken label is unchanged.
- **Total row** (`DashboardView.totalRow`): label in secondary, amount in
  row-amount style, stacked at accessibility sizes.
- **Section header**: headline title, optional trailing link (See all). The
  link's text is small, so the link itself is given a 44-point hit area.
- **Add purchase bar**: a prominent bordered, large button in a `.bar`
  safe-area inset at the bottom; the content scrolls under it.

## States

| State | What shows |
| --- | --- |
| No purchases | Recent purchases card: "Start with one purchase." and "Record what you spent, then see where it goes."; History: "No purchases yet." with "Purchases you save appear here, newest first." |
| Just saved | "Purchase saved." with `checkmark.circle` above the Today card; announced to VoiceOver after the sheet closes (DECISIONS 012) |
| Entry error | A `Label` with `exclamationmark.circle` in primary color at the top of the form; the typed draft stays |
| Store can't open | "Your journal couldn't open" with "Try again" (accent) |
| Opening | `ProgressView("Opening your journal")` |
| Totals can't be calculated | The error message replaces the totals; recent purchases still show |

## Motion

None is added: no animation, transition or haptic. If a later screen adds
motion, it checks `accessibilityReduceMotion` and offers a still version.

## Accessibility rules

- Every control has a label that says what it does ("Amount in US dollars",
  "Merchant or description", "Save purchase").
- Every element a test needs has a stable identifier (`todayTotal`,
  `purchaseRow`, `addPurchase`, `seeAllPurchases`, `daySection.<yyyy-MM-dd>`).
- A row reads as one element; decorative symbols are hidden.
- Tap targets are at least 44 points tall: rows, the See all link, the Quick
  Entry text fields themselves (a 44-point frame that focuses the field on
  tap, because the text line alone is shorter), the large Add purchase button
  and the toolbar buttons.
- Apple's accessibility audit (`performAccessibilityAudit`) runs in
  `AccessibilityAuditUITests` on every screen at the xSmall, large and AX5
  text sizes in light and dark, and attaches a screenshot of each. Each
  excluded finding is named in the test with its reason: Foundation-formatted
  amounts and the name "SPEND." flagged as "not human-readable" (VoiceOver
  speaks both); system secondaryLabel text rated "nearly passed" (Apple's
  palette, 3.4:1 on white, darkened by Increase Contrast); contrast sampled
  under a translucent bar or at the screen edge (where the audit names no
  element), and the Quick Entry Date label, which the dark screenshots
  measure at 13.9:1; the Dynamic Type heuristic on system toolbar buttons and
  on labels the AX5 screenshots show scaling; and the single-line text fields
  it predicts may clip. An outright contrast failure on visible
  text, a small hit area, a missing label or clipped text anywhere else fails
  the test.

## Copy

Short, supportive, direct (`BRAND.md` Voice). No shame, no exaggerated
claims. Sentences end with a full stop, including "SPEND." itself.

## App icon

Concept B, the S. monogram, as an Icon Composer package at
`ios/SPEND/AppIcon.icon`:

- Fill: automatic gradient from the light accent (`extended-srgb:0.04314,
  0.47843, 0.45882` = #0B7A75). iOS derives the dark, clear and tinted looks.
- One group with the default glass, neutral shadow (0.5) and translucency
  (0.5); two white layers, `S.svg` and `Dot.svg`, each with Liquid Glass on.
- The S is an original shape, not a font glyph: two elliptical bowls (upper
  140 × 112, lower 158 × 126 points on the 1024 canvas) joined at an
  inflection, drawn as the filled outline of a 100-point round-capped stroke
  whose terminals end 8° below each bowl's middle; the dot has radius 78 and
  sits 44 points to the right, bottom-aligned with the S.
- Layer sources: `design/assets/icon/S.svg` and `Dot.svg` (the same files as
  the package's `Assets`). The generator script and the concept sketches stay
  with the design outputs outside the repository.
- `ios/project.yml` lists the package as one file resource and excludes it
  from the folder scan; the asset catalog holds no `AppIcon` set.

## Shortcuts tile

`SpendShortcuts.shortcutTileColor` is `.teal`, the system tile color nearest
the accent. The tile's symbol stays `plus.circle` (DECISIONS 013).

## How to change a value

| To change | Edit |
| --- | --- |
| The accent | Both colors in `AccentColor.colorset/Contents.json`, then the icon fill in `AppIcon.icon/icon.json` and `shortcutTileColor` if the hue moves; update the contrast table here |
| Spacing or radius | `SpendDesign` in `SpendCard.swift`; every card follows |
| A type role | The view that owns it, then this table |
| The icon | The SVG layers (same file names), then open the package in Icon Composer to confirm it loads |
| Project files | After adding a Swift file or resource, run `xcodegen generate --spec ios/project.yml` |
