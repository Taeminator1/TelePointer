public enum SmoothTurning: String, CaseIterable, Codable, Sendable {
    case off
    case headingBlend
    case overshootReturn

    public static let `default` = SmoothTurning.overshootReturn
}
