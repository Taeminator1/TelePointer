import Foundation
import Observation

@MainActor
@Observable
public final class ExperimentStore {
    public static let shared = ExperimentStore()

    private static let smoothTurningKey = "smoothTurning"

    @ObservationIgnored private let defaults: UserDefaults

    public var smoothTurning: Bool {
        didSet { defaults.set(smoothTurning, forKey: Self.smoothTurningKey) }
    }

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        smoothTurning = defaults.object(forKey: Self.smoothTurningKey) as? Bool ?? true
    }
}
