# SPEND. — Agent Instructions

Read README.md and docs/ before implementation.

## Mission

Build a minimal, reliable native iOS app
for intentional manual spending.

## Principles

1. Preserve manual logging as a core feature.
2. Favor simple solutions over frameworks.
3. Avoid unnecessary dependencies.
4. Protect user financial information.
5. Keep UI accessible and nonjudgmental.
6. Do not add features outside the roadmap
   without documenting the decision.

## Workflow

1. Inspect existing code before editing.
2. Identify the smallest useful change.
3. Implement and test it.
4. Run available build and test checks.
5. Document architectural decisions.
6. Summarize changes and unresolved issues.

## Code Quality

- Clear Swift naming conventions
- Modular feature organization
- Testable spending calculations
- Precise monetary arithmetic
- No hardcoded secrets
- No fabricated test results

## Git

- main is the stable branch.
- Use feature branches for substantive work.
- Prefer small, reviewable commits.
- Do not force-push or delete user work.
- Report build/test status accurately.

## First Task

Create the Xcode project and implement
the smallest working vertical slice:

Quick Entry -> SwiftData -> Dashboard.

Then integrate the iPhone Action Button.
