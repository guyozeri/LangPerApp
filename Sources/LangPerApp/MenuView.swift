import AppKit
import ServiceManagement
import SwiftUI

struct MenuView: View {
    @ObservedObject var store: AppLayoutStore
    @ObservedObject var switcher: LayoutSwitcher
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        Toggle("Enabled", isOn: $store.enabled)

        Divider()

        if let bundleID = switcher.frontmostBundleID {
            let layout = store.source(for: bundleID).map(InputSourceManager.localizedName) ?? "—"
            Text("\(switcher.frontmostName ?? bundleID): \(layout)")
        }

        Menu("Remembered Apps (\(store.mapping.count))") {
            ForEach(store.mapping.keys.sorted(by: { appName($0) < appName($1) }), id: \.self) { bundleID in
                Menu("\(appName(bundleID)) — \(InputSourceManager.localizedName(id: store.mapping[bundleID] ?? ""))") {
                    Button("Forget") { store.forget(bundleID) }
                }
            }
            if !store.mapping.isEmpty {
                Divider()
                Button("Forget All") { store.forgetAll() }
            }
        }

        Picker("Default for New Apps", selection: $store.defaultSourceForNewApps) {
            Text("Keep Current").tag(String?.none)
            ForEach(InputSourceManager.listSelectable()) { src in
                Text(src.name).tag(Optional(src.id))
            }
        }

        Divider()

        Toggle("Launch at Login", isOn: Binding(
            get: { launchAtLogin },
            set: { newValue in
                do {
                    if newValue {
                        try SMAppService.mainApp.register()
                    } else {
                        try SMAppService.mainApp.unregister()
                    }
                } catch {
                    NSLog("LangPerApp: launch-at-login change failed: \(error)")
                }
                launchAtLogin = SMAppService.mainApp.status == .enabled
            }
        ))

        Text("Tip: turn off macOS \"Automatically switch to a document's input source\"")

        Divider()

        Button("Quit") { NSApp.terminate(nil) }
            .keyboardShortcut("q")
    }

    private func appName(_ bundleID: String) -> String {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
            return bundleID
        }
        return FileManager.default.displayName(atPath: url.path)
            .replacingOccurrences(of: ".app", with: "")
    }
}
