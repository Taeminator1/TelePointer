public struct SpeedCurve: Equatable, Sendable, Codable {
    public static let `default` = SpeedCurve(base: 400, peak: 2800, rampDuration: 0.4)

    public static let baseRange: ClosedRange<Double> = 100...2000
    public static let peakRange: ClosedRange<Double> = 400...6000
    public static let rampDurationRange: ClosedRange<Double> = 0.05...1

    public var base: Double
    public var peak: Double
    public var rampDuration: Double
    public var easing: SpeedEasing

    public init(
        base: Double,
        peak: Double,
        rampDuration: Double,
        easing: SpeedEasing = .default
    ) {
        self.base = base
        self.peak = peak
        self.rampDuration = rampDuration
        self.easing = easing
    }

    public func speed(at elapsed: Double) -> Double {
        rampedSpeed(
            elapsed: elapsed,
            base: base,
            peak: peak,
            rampDuration: rampDuration,
            easing: easing
        )
    }

    public var allowedBaseRange: ClosedRange<Double> {
        let upper = min(Self.baseRange.upperBound, peak)
        return Self.baseRange.lowerBound...max(upper, Self.baseRange.lowerBound)
    }

    public var allowedPeakRange: ClosedRange<Double> {
        let lower = max(Self.peakRange.lowerBound, base)
        return min(lower, Self.peakRange.upperBound)...Self.peakRange.upperBound
    }

    public func normalized() -> SpeedCurve {
        let base = base.clamped(to: Self.baseRange)

        return SpeedCurve(
            base: base,
            peak: max(peak.clamped(to: Self.peakRange), base),
            rampDuration: rampDuration.clamped(to: Self.rampDurationRange),
            easing: SpeedEasing(first: easing.first, second: easing.second)
        )
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
