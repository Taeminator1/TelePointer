public enum SlowOnTurn: String, CaseIterable, Sendable {
    case off
    case dip
    case restartRamp

    public static let `default` = SlowOnTurn.off
}
