import Foundation
import KeyboardShortcuts
import PointerCore

struct SettingsFile: Equatable, Codable {
    enum Failure: Error, Equatable {
        case unreadable
        case unrecognized
    }

    struct Speed: Equatable, Codable {
        var curve: SpeedCurve?
        var steady: Double?
    }

    var shortcuts: [String: KeyboardShortcuts.Shortcut?]?
    var speed: Speed?
}

extension SettingsFile {
    static func decoded(from data: Data) throws -> SettingsFile {
        guard let file = try? JSONDecoder().decode(SettingsFile.self, from: data) else {
            throw Failure.unreadable
        }

        guard !file.isEmpty else { throw Failure.unrecognized }

        return file
    }

    func encoded() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        return try encoder.encode(self)
    }

    var isEmpty: Bool {
        knownShortcuts.isEmpty && speed?.curve == nil && speed?.steady == nil
    }

    private var knownShortcuts: [(name: KeyboardShortcuts.Name, shortcut: KeyboardShortcuts.Shortcut?)] {
        guard let shortcuts else { return [] }

        return pointerShortcutNames.compactMap { name in
            guard let shortcut = shortcuts[name.rawValue] else { return nil }

            return (name, shortcut)
        }
    }
}

extension SettingsFile {
    @MainActor
    static func current(speed store: SpeedStore) -> SettingsFile {
        SettingsFile(
            shortcuts: Dictionary(
                uniqueKeysWithValues: pointerShortcutNames.map {
                    ($0.rawValue, KeyboardShortcuts.getShortcut(for: $0))
                }
            ),
            speed: Speed(curve: store.curve, steady: store.steadySpeed)
        )
    }

    @MainActor
    func apply(speed store: SpeedStore) {
        for (name, shortcut) in knownShortcuts {
            KeyboardShortcuts.setShortcut(shortcut, for: name)
        }

        if let curve = speed?.curve {
            store.curve = curve
        }

        if let steady = speed?.steady {
            store.steadySpeed = steady
        }
    }
}
