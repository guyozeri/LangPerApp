import Foundation

/// Persists the bundleID -> input source ID map and user settings in UserDefaults.
final class AppLayoutStore: ObservableObject {
    private let defaults = UserDefaults.standard
    private enum Key {
        static let mapping = "appLayouts"
        static let enabled = "enabled"
        static let defaultSource = "defaultSourceForNewApps"
    }

    @Published private(set) var mapping: [String: String]

    @Published var enabled: Bool {
        didSet { defaults.set(enabled, forKey: Key.enabled) }
    }

    /// nil = keep the current layout when an unknown app is activated.
    @Published var defaultSourceForNewApps: String? {
        didSet { defaults.set(defaultSourceForNewApps, forKey: Key.defaultSource) }
    }

    init() {
        mapping = defaults.dictionary(forKey: Key.mapping) as? [String: String] ?? [:]
        enabled = defaults.object(forKey: Key.enabled) as? Bool ?? true
        defaultSourceForNewApps = defaults.string(forKey: Key.defaultSource)
    }

    func source(for bundleID: String) -> String? { mapping[bundleID] }

    func set(_ sourceID: String, for bundleID: String) {
        guard mapping[bundleID] != sourceID else { return }
        mapping[bundleID] = sourceID
        defaults.set(mapping, forKey: Key.mapping)
    }

    func forget(_ bundleID: String) {
        mapping.removeValue(forKey: bundleID)
        defaults.set(mapping, forKey: Key.mapping)
    }

    func forgetAll() {
        mapping = [:]
        defaults.set(mapping, forKey: Key.mapping)
    }
}
