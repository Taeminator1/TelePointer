import Foundation
import Observation
import PointerCore
import ShortcutException

struct Preset: Identifiable, Equatable, Codable {
    let id: UUID
    var name: String
    var settings: SettingsFile
}

@MainActor
@Observable
final class PresetStore {
    static let shared = PresetStore()

    private static let presetsKey = "presets"

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let speedStore: SpeedStore
    @ObservationIgnored private let exceptionStore: ShortcutExceptionStore
    @ObservationIgnored private let experimentStore: ExperimentStore

    private(set) var presets: [Preset] {
        didSet { save() }
    }

    init(
        defaults: UserDefaults = .standard,
        speed speedStore: SpeedStore = .shared,
        exceptions exceptionStore: ShortcutExceptionStore = .shared,
        experiments experimentStore: ExperimentStore = .shared
    ) {
        self.defaults = defaults
        self.speedStore = speedStore
        self.exceptionStore = exceptionStore
        self.experimentStore = experimentStore
        presets = Self.load(from: defaults)
    }

    func add() {
        presets.append(
            Preset(
                id: UUID(),
                name: String(localized: "Preset \(presets.count + 1)"),
                settings: .current(speed: speedStore, exceptions: exceptionStore, experiments: experimentStore)
            )
        )
    }

    func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        presets.move(fromOffsets: source, toOffset: destination)
    }

    private static func load(from defaults: UserDefaults) -> [Preset] {
        guard
            let data = defaults.data(forKey: presetsKey),
            let presets = try? JSONDecoder().decode([Preset].self, from: data)
        else { return [] }

        return presets
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(presets) else { return }

        defaults.set(data, forKey: Self.presetsKey)
    }
}
