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

    @discardableResult
    func add() -> Preset.ID {
        let preset = Preset(
            id: UUID(),
            name: String(localized: "Preset \(presets.count + 1)"),
            settings: currentSettings()
        )

        presets.append(preset)

        return preset.id
    }

    func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        switchingActive { $0.move(fromOffsets: source, toOffset: destination) }
    }

    func rename(_ id: Preset.ID, to name: String) {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !name.isEmpty, let index = presets.firstIndex(where: { $0.id == id }) else { return }

        presets[index].name = name
    }

    func remove(_ ids: Set<Preset.ID>) {
        switchingActive { $0.removeAll { ids.contains($0.id) } }
    }

    private func switchingActive(_ change: (inout [Preset]) -> Void) {
        var presets = presets
        let activeID = presets.first?.id

        if !presets.isEmpty {
            presets[0].settings = currentSettings()
        }

        change(&presets)
        self.presets = presets

        guard let active = presets.first, active.id != activeID else { return }

        exceptionStore.all = [:]
        active.settings.apply(speed: speedStore, exceptions: exceptionStore, experiments: experimentStore)
    }

    private func currentSettings() -> SettingsFile {
        .current(speed: speedStore, exceptions: exceptionStore, experiments: experimentStore)
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
