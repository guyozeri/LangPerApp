import AppKit
import Foundation

/// Watches the macOS "Automatically switch to a document's input source" setting,
/// which conflicts with per-app switching, and prompts the user to turn it off.
final class SystemSettingsMonitor: ObservableObject {
    private static let domain = "com.apple.HIToolbox" as CFString
    private static let globalPropsKey = "AppleGlobalTextInputProperties" as CFString
    private static let perContextKey = "TextInputGlobalPropertyPerContextInput"
    private static let keyboardSettingsURL = URL(string: "x-apple.systempreferences:com.apple.Keyboard-Settings.extension?InputSources")!

    @Published private(set) var autoSwitchEnabled = false
    private var timer: Timer?
    private var alertShowing = false

    init() {
        autoSwitchEnabled = Self.readAutoSwitchEnabled()
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.refresh()
        }
        if autoSwitchEnabled {
            // Let the app finish launching before showing the alert.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in self?.showAlert() }
        }
    }

    func refresh() {
        let enabled = Self.readAutoSwitchEnabled()
        guard enabled != autoSwitchEnabled else { return }
        autoSwitchEnabled = enabled
        if enabled { showAlert() }
    }

    static func readAutoSwitchEnabled() -> Bool {
        CFPreferencesAppSynchronize(domain)
        guard let props = CFPreferencesCopyAppValue(globalPropsKey, domain) as? [String: Any] else {
            return false
        }
        return (props[perContextKey] as? NSNumber)?.boolValue ?? false
    }

    func openKeyboardSettings() {
        NSWorkspace.shared.open(Self.keyboardSettingsURL)
    }

    private func showAlert() {
        guard !alertShowing else { return }
        alertShowing = true
        defer { alertShowing = false }

        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Turn off macOS automatic input source switching"
        alert.informativeText = """
        The macOS option "Automatically switch to a document's input source" is on, and it will fight with LangPerApp.

        Click "Open Input Sources", then turn off "Automatically switch to a document's input source" in the window that opens.
        """
        alert.addButton(withTitle: "Open Input Sources")
        alert.addButton(withTitle: "Later")
        if alert.runModal() == .alertFirstButtonReturn {
            openKeyboardSettings()
        }
    }
}
