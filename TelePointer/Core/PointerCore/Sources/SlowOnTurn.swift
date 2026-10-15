public enum SlowOnTurn: String, CaseIterable, Codable, Sendable {
    case off
    case dip
    case restartRamp

    public static let `default` = SlowOnTurn.off
}
