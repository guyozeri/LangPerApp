import SwiftUI

@main
struct LangPerAppApp: App {
    @StateObject private var store: AppLayoutStore
    @StateObject private var switcher: LayoutSwitcher

    init() {
        let store = AppLayoutStore()
        _store = StateObject(wrappedValue: store)
        _switcher = StateObject(wrappedValue: LayoutSwitcher(store: store))
    }

    var body: some Scene {
        MenuBarExtra("LangPerApp", systemImage: "keyboard") {
            MenuView(store: store, switcher: switcher)
        }
        .menuBarExtraStyle(.menu)
    }
}
