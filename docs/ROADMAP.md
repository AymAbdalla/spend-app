# Roadmap

Checked items below are built and self-checked. Independent Check is a separate
gate recorded in `docs/agents/checks.md`. Only "Action Button setup" and "Test on
physical iPhone" were checked on a device (owner-observed, iPhone 18 Pro, iOS
27.2); the other items imply no physical-device acceptance.

## Phase 0 — Foundation

- [x] Create Xcode project
- [x] Configure Git repository
- [x] Establish architecture
- [x] Create initial native design system
- [x] Verify simulator build

## Phase 1 — Core MVP

- [x] Transaction model
- [x] SwiftData persistence
- [x] Quick Entry
- [x] Dashboard
- [x] Transaction history
- [ ] Edit and delete
- [ ] History category filter and search
- [x] Spending calculations
- [x] Automated tests

Edit/delete acceptance: before enabling either action, remove or reconcile the
legacy recovery database (`Application Support/journal.store`) and its
`journal.store-wal` / `journal.store-shm` sidecars, plus any app-controlled
migration recovery copies. Tests must seed legacy data, adopt it, edit/delete,
and relaunch; obsolete values and deleted purchases must not be loaded or
reimported from those copies.

## Phase 2 — iPhone Integration

- [x] App Intent / App Shortcut
- [x] Action Button setup
- [x] Test on physical iPhone
- [ ] CSV export
- [ ] Accessibility review

## Phase 3 — Reflection

- [ ] Weekly summary
- [ ] Category insights
- [ ] Planned versus impulse analysis
- [ ] User testing

## Future Exploration

- Spending goals
- Pre-purchase reflection
- Home Screen widgets
- Optional iCloud sync
- Improved insights

Avoid expanding scope until the core
manual logging experience is validated.
