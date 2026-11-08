import AppIntents

/// Publishes "Log a purchase" as a ready-made shortcut, so it appears in the
/// Shortcuts app, Spotlight, Siri and the Action Button setting without the
/// owner building anything.
struct SpendShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: LogPurchaseIntent(),
                    phrases: ["Log a purchase in \(.applicationName)"],
                    shortTitle: "Log a purchase",
                    systemImageName: "plus.circle")
    }
}
