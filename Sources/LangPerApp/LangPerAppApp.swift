import SwiftUI

@main
struct LangPerAppApp: App {
    @StateObject private var store: AppLayoutStore
    @StateObject private var switcher: LayoutSwitcher
    @StateObject private var settingsMonitor = SystemSettingsMonitor()

    init() {
        let store = AppLayoutStore()
        _store = StateObject(wrappedValue: store)
        _switcher = StateObject(wrappedValue: LayoutSwitcher(store: store))
    }

    var body: some Scene {
        MenuBarExtra(
            "LangPerApp",
            systemImage: settingsMonitor.autoSwitchEnabled ? "exclamationmark.triangle" : "keyboard"
        ) {
            MenuView(store: store, switcher: switcher, settingsMonitor: settingsMonitor)
        }
        .menuBarExtraStyle(.menu)
    }
}
