import Foundation
import Observation

@MainActor
@Observable
public final class SpeedSettings {
    public static let shared = SpeedSettings()

    private static let key = "speedCurve"

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private var storage: SpeedCurve

    public var curve: SpeedCurve {
        get {
            access(keyPath: \.curve)
            return storage
        }
        set {
            let curve = newValue.normalized()

            withMutation(keyPath: \.curve) { storage = curve }
            save(curve)
        }
    }

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        storage = Self.load(from: defaults)
    }

    public func reset() {
        curve = .default
    }

    private static func load(from defaults: UserDefaults) -> SpeedCurve {
        guard
            let data = defaults.data(forKey: key),
            let curve = try? JSONDecoder().decode(SpeedCurve.self, from: data)
        else { return .default }

        return curve.normalized()
    }

    private func save(_ curve: SpeedCurve) {
        guard let data = try? JSONEncoder().encode(curve) else { return }

        defaults.set(data, forKey: Self.key)
    }
}
