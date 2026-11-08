import AppIntents

/// Publishes "Log a purchase" as a ready-made shortcut, so it appears in the
/// Shortcuts app, Spotlight, Siri and the Action Button setting without the
/// owner building anything.
struct SpendShortcuts: AppShortcutsProvider {
    /// The system tile color nearest the brand accent (deep teal); the tile's
    /// `plus.circle` symbol stays (DECISIONS 013).
    static var shortcutTileColor: ShortcutTileColor { .teal }

    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: LogPurchaseIntent(),
                    phrases: ["Log a purchase in \(.applicationName)"],
                    shortTitle: "Log a purchase",
                    systemImageName: "plus.circle")
    }
}
