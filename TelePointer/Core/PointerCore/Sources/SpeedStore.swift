import Foundation
import Observation

@MainActor
@Observable
public final class SpeedStore {
    public static let shared = SpeedStore()

    private static let curveKey = "speedCurve"
    private static let steadySpeedKey = "steadySpeed"

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private var storage: SpeedCurve
    @ObservationIgnored private var steadyStorage: Double

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

    public var steadySpeed: Double {
        get {
            access(keyPath: \.steadySpeed)
            return steadyStorage
        }
        set {
            let speed = newValue.clamped(to: SteadySpeed.range)

            withMutation(keyPath: \.steadySpeed) { steadyStorage = speed }
            defaults.set(speed, forKey: Self.steadySpeedKey)
        }
    }

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        storage = Self.load(from: defaults)
        steadyStorage = Self.loadSteadySpeed(from: defaults)
    }

    public func reset() {
        curve = .default
        steadySpeed = SteadySpeed.default
    }

    private static func load(from defaults: UserDefaults) -> SpeedCurve {
        guard
            let data = defaults.data(forKey: curveKey),
            let curve = try? JSONDecoder().decode(SpeedCurve.self, from: data)
        else { return .default }

        return curve.normalized()
    }

    private static func loadSteadySpeed(from defaults: UserDefaults) -> Double {
        guard let speed = defaults.object(forKey: steadySpeedKey) as? Double else {
            return SteadySpeed.default
        }

        return speed.clamped(to: SteadySpeed.range)
    }

    private func save(_ curve: SpeedCurve) {
        guard let data = try? JSONEncoder().encode(curve) else { return }

        defaults.set(data, forKey: Self.curveKey)
    }
}
