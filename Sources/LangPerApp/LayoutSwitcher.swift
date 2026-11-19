import AppKit
import Carbon
import os

/// Core logic: remembers the layout chosen in each app and restores it on activation.
final class LayoutSwitcher: ObservableObject {
    private let store: AppLayoutStore
    private let log = Logger(subsystem: "LangPerApp", category: "switcher")
    private let ownBundleID = Bundle.main.bundleIdentifier

    /// Source we just selected programmatically; its change notification must not be saved.
    private var pendingProgrammaticSourceID: String?

    @Published private(set) var frontmostBundleID: String?
    @Published private(set) var frontmostName: String?

    init(store: AppLayoutStore) {
        self.store = store

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(appActivated(_:)),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(inputSourceChanged(_:)),
            name: NSNotification.Name(kTISNotifySelectedKeyboardInputSourceChanged as String),
            object: nil,
            suspensionBehavior: .deliverImmediately
        )

        if let app = NSWorkspace.shared.frontmostApplication {
            updateFrontmost(app)
        }
    }

    private func updateFrontmost(_ app: NSRunningApplication) {
        frontmostBundleID = app.bundleIdentifier
        frontmostName = app.localizedName
    }

    @objc private func appActivated(_ note: Notification) {
        guard
            let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
            let bundleID = app.bundleIdentifier,
            bundleID != ownBundleID
        else { return }

        updateFrontmost(app)
        guard store.enabled else { return }

        let target: String
        if let saved = store.source(for: bundleID) {
            target = saved
        } else if let def = store.defaultSourceForNewApps {
            target = def
        } else {
            // Unknown app, keep current layout but remember it for this app.
            if let current = InputSourceManager.currentID() {
                store.set(current, for: bundleID)
            }
            return
        }

        guard target != InputSourceManager.currentID() else { return }
        pendingProgrammaticSourceID = target
        if InputSourceManager.select(id: target) {
            log.info("Restored \(target, privacy: .public) for \(bundleID, privacy: .public)")
        } else {
            pendingProgrammaticSourceID = nil
            log.error("Input source \(target, privacy: .public) unavailable for \(bundleID, privacy: .public)")
        }
    }

    @objc private func inputSourceChanged(_ note: Notification) {
        // Delivered on the main thread; the current source is already updated.
        guard let current = InputSourceManager.currentID() else { return }

        if let pending = pendingProgrammaticSourceID {
            pendingProgrammaticSourceID = nil
            if pending == current { return }
        }

        guard
            store.enabled,
            let app = NSWorkspace.shared.frontmostApplication,
            let bundleID = app.bundleIdentifier,
            bundleID != ownBundleID
        else { return }

        if store.source(for: bundleID) != current {
            store.set(current, for: bundleID)
            log.info("Saved \(current, privacy: .public) for \(bundleID, privacy: .public)")
        }
    }
}
