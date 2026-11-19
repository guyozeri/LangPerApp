import Carbon
import Foundation

struct InputSourceInfo: Identifiable, Hashable {
    let id: String
    let name: String
}

/// Thin wrapper around Carbon's Text Input Source Services.
enum InputSourceManager {
    private static func stringProperty(_ source: TISInputSource, _ key: CFString) -> String? {
        guard let ptr = TISGetInputSourceProperty(source, key) else { return nil }
        return Unmanaged<CFString>.fromOpaque(ptr).takeUnretainedValue() as String
    }

    private static func boolProperty(_ source: TISInputSource, _ key: CFString) -> Bool {
        guard let ptr = TISGetInputSourceProperty(source, key) else { return false }
        return CFBooleanGetValue(Unmanaged<CFBoolean>.fromOpaque(ptr).takeUnretainedValue())
    }

    /// ID of the currently selected keyboard input source, e.g. "com.apple.keylayout.Hebrew".
    static func currentID() -> String? {
        let source = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
        return stringProperty(source, kTISPropertyInputSourceID)
    }

    /// Enabled, user-selectable keyboard layouts / input modes.
    private static func selectableSources() -> [TISInputSource] {
        let filter = [kTISPropertyInputSourceIsSelectCapable as String: true] as CFDictionary
        guard let list = TISCreateInputSourceList(filter, false)?.takeRetainedValue() as? [TISInputSource] else {
            return []
        }
        let allowedCategories: Set<String> = [kTISCategoryKeyboardInputSource as String]
        return list.filter { src in
            guard let category = stringProperty(src, kTISPropertyInputSourceCategory) else { return false }
            return allowedCategories.contains(category)
        }
    }

    static func listSelectable() -> [InputSourceInfo] {
        selectableSources().compactMap { src in
            guard let id = stringProperty(src, kTISPropertyInputSourceID) else { return nil }
            let name = stringProperty(src, kTISPropertyLocalizedName) ?? id
            return InputSourceInfo(id: id, name: name)
        }
    }

    static func localizedName(id: String) -> String {
        listSelectable().first { $0.id == id }?.name ?? id
    }

    /// Selects the input source with the given ID. Returns false if it is not installed/enabled.
    @discardableResult
    static func select(id: String) -> Bool {
        guard let src = selectableSources().first(where: { stringProperty($0, kTISPropertyInputSourceID) == id }) else {
            return false
        }
        return TISSelectInputSource(src) == noErr
    }
}
