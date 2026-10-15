import Foundation
import Observation

@MainActor
@Observable
public final class ExperimentStore {
    public static let shared = ExperimentStore()

    private static let smoothTurningKey = "smoothTurning"
    private static let slowOnTurnKey = "slowOnTurn"
    private static let noHoldLimitKey = "noHoldLimit"

    @ObservationIgnored private let defaults: UserDefaults

    public var smoothTurning: SmoothTurning {
        didSet { defaults.set(smoothTurning.rawValue, forKey: Self.smoothTurningKey) }
    }

    public var slowOnTurn: SlowOnTurn {
        didSet { defaults.set(slowOnTurn.rawValue, forKey: Self.slowOnTurnKey) }
    }

    public var noHoldLimit: Bool {
        didSet { defaults.set(noHoldLimit, forKey: Self.noHoldLimitKey) }
    }

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        smoothTurning = defaults.string(forKey: Self.smoothTurningKey).flatMap(SmoothTurning.init) ?? .default
        slowOnTurn = defaults.string(forKey: Self.slowOnTurnKey).flatMap(SlowOnTurn.init) ?? .default
        noHoldLimit = defaults.bool(forKey: Self.noHoldLimitKey)
    }
}
