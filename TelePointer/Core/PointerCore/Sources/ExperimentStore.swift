import Foundation
import Observation

@MainActor
@Observable
public final class ExperimentStore {
    public static let shared = ExperimentStore()

    private static let smoothTurningKey = "smoothTurning"
    private static let noHoldLimitKey = "noHoldLimit"

    @ObservationIgnored private let defaults: UserDefaults

    public var smoothTurning: SmoothTurning {
        didSet { defaults.set(smoothTurning.rawValue, forKey: Self.smoothTurningKey) }
    }

    public var noHoldLimit: Bool {
        didSet { defaults.set(noHoldLimit, forKey: Self.noHoldLimitKey) }
    }

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        smoothTurning = defaults.string(forKey: Self.smoothTurningKey).flatMap(SmoothTurning.init) ?? .default
        noHoldLimit = defaults.bool(forKey: Self.noHoldLimitKey)
    }
}
