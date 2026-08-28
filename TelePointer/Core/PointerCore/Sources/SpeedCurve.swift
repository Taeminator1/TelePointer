public struct SpeedCurve: Equatable, Sendable, Codable {
    public static let `default` = SpeedCurve(base: 400, peak: 2800, rampDuration: 0.4)

    public static let baseRange: ClosedRange<Double> = 100...2000
    public static let peakRange: ClosedRange<Double> = 400...6000
    public static let rampDurationRange: ClosedRange<Double> = 0.05...1

    /// 누른 직후의 속도
    public var base: Double

    /// 도달 가능한 최고 속도
    public var peak: Double

    /// 최고 속도까지 걸리는 시간
    public var rampDuration: Double

    /// base에서 peak까지 어떻게 오를지
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

    /// 현재 `peak` 아래에서 `base`가 가질 수 있는 구간
    public var allowedBaseRange: ClosedRange<Double> {
        let upper = min(Self.baseRange.upperBound, peak)
        return Self.baseRange.lowerBound...max(upper, Self.baseRange.lowerBound)
    }

    /// 현재 `base` 위에서 `peak`이 가질 수 있는 구간
    public var allowedPeakRange: ClosedRange<Double> {
        let lower = max(Self.peakRange.lowerBound, base)
        return min(lower, Self.peakRange.upperBound)...Self.peakRange.upperBound
    }

    /// 허용 범위 안으로 당기고, 감속하는 곡선은 만들지 않는다.
    /// `peak ≥ base`를 조작 중에 지키는 것은 위의 두 구간이고, 여기는 저장된 값의 안전망이다
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
