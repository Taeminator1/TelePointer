import Foundation
import KeyboardShortcuts
import PointerCore
import ShortcutException

struct SettingsFile: Equatable, Codable {
    enum Failure: Error, Equatable {
        case unreadable
        case unrecognized
    }

    struct Speed: Equatable, Codable {
        var curve: SpeedCurve?
        var steady: Double?
    }

    struct Experiments: Equatable, Codable {
        var smoothTurning: SmoothTurning?
        var slowOnTurn: SlowOnTurn?
        var noHoldLimit: Bool?
    }

    var shortcuts: [String: KeyboardShortcuts.Shortcut?]?
    var exceptions: [String: [ExcludedApp]]?
    var speed: Speed?
    var experiments: Experiments?
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
        knownShortcuts.isEmpty && knownExceptions.isEmpty && speed?.curve == nil && speed?.steady == nil
            && experiments?.smoothTurning == nil && experiments?.slowOnTurn == nil
            && experiments?.noHoldLimit == nil
    }

    private var knownShortcuts: [(name: KeyboardShortcuts.Name, shortcut: KeyboardShortcuts.Shortcut?)] {
        guard let shortcuts else { return [] }

        return pointerShortcutNames.compactMap { name in
            guard let shortcut = shortcuts[name.rawValue] else { return nil }

            return (name, shortcut)
        }
    }

    private var knownExceptions: [String: [ExcludedApp]] {
        guard let exceptions else { return [:] }

        return exceptions.filter { name, _ in
            pointerShortcutNames.contains { $0.rawValue == name }
        }
    }
}

extension SettingsFile {
    @MainActor
    static func current(
        speed speedStore: SpeedStore,
        exceptions exceptionStore: ShortcutExceptionStore,
        experiments experimentStore: ExperimentStore
    ) -> SettingsFile {
        SettingsFile(
            shortcuts: Dictionary(
                uniqueKeysWithValues: pointerShortcutNames.map {
                    ($0.rawValue, KeyboardShortcuts.getShortcut(for: $0))
                }
            ),
            exceptions: exceptionStore.all,
            speed: Speed(curve: speedStore.curve, steady: speedStore.steadySpeed),
            experiments: Experiments(
                smoothTurning: experimentStore.smoothTurning,
                slowOnTurn: experimentStore.slowOnTurn,
                noHoldLimit: experimentStore.noHoldLimit
            )
        )
    }

    @MainActor
    func apply(
        speed speedStore: SpeedStore,
        exceptions exceptionStore: ShortcutExceptionStore,
        experiments experimentStore: ExperimentStore
    ) {
        for (name, shortcut) in knownShortcuts {
            KeyboardShortcuts.setShortcut(shortcut, for: name)
        }

        if !knownExceptions.isEmpty {
            exceptionStore.all = exceptionStore.all.merging(knownExceptions) { _, imported in imported }
        }

        if let curve = speed?.curve {
            speedStore.curve = curve
        }

        if let steady = speed?.steady {
            speedStore.steadySpeed = steady
        }

        if let smoothTurning = experiments?.smoothTurning {
            experimentStore.smoothTurning = smoothTurning
        }

        if let slowOnTurn = experiments?.slowOnTurn {
            experimentStore.slowOnTurn = slowOnTurn
        }

        if let noHoldLimit = experiments?.noHoldLimit {
            experimentStore.noHoldLimit = noHoldLimit
        }
    }
}
