import CoreGraphics
import Testing
@testable import PointerCore

struct SpeedEasingTests {
    @Test("기본 이징은 progress² 그대로")
    func defaultMatchesSquare() {
        for progress in stride(from: 0.0, through: 1.0, by: 0.1) {
            #expect(abs(SpeedEasing.default.value(at: progress) - progress * progress) < 1e-6)
        }
    }

    @Test("제어점이 대각선에 놓이면 선형")
    func linear() {
        let easing = SpeedEasing(
            first: CGPoint(x: 1.0 / 3, y: 1.0 / 3),
            second: CGPoint(x: 2.0 / 3, y: 2.0 / 3)
        )

        for progress in stride(from: 0.0, through: 1.0, by: 0.1) {
            #expect(abs(easing.value(at: progress) - progress) < 1e-6)
        }
    }

    @Test("어떤 제어점이든 양 끝은 0과 1")
    func endpointsAreFixed() {
        let easing = SpeedEasing(first: CGPoint(x: 0, y: 1), second: CGPoint(x: 1, y: 0))

        #expect(easing.value(at: 0) == 0)
        #expect(abs(easing.value(at: 1) - 1) < 1e-6)
    }

    @Test("앞을 들어올리면 초반에 더 빨리 오른다")
    func frontLoaded() {
        let easing = SpeedEasing(first: CGPoint(x: 0, y: 0.8), second: CGPoint(x: 0.5, y: 1))

        #expect(easing.value(at: 0.25) > 0.25)
        #expect(easing.value(at: 0.5) > 0.5)
    }

    @Test("범위를 벗어난 진행도는 양 끝으로 본다")
    func clampsProgress() {
        #expect(SpeedEasing.default.value(at: -1) == 0)
        #expect(abs(SpeedEasing.default.value(at: 2) - 1) < 1e-6)
    }

    @Test("단위 사각형을 벗어난 제어점은 당겨온다")
    func clampsControlPoints() {
        let easing = SpeedEasing(first: CGPoint(x: -2, y: 3), second: CGPoint(x: 9, y: -9))

        #expect(easing.first == CGPoint(x: 0, y: 1))
        #expect(easing.second == CGPoint(x: 1, y: 0))
    }
}

struct SpeedCurveNormalizationTests {
    @Test("기본값은 이미 정규화된 상태")
    func defaultIsNormalized() {
        #expect(SpeedCurve.default.normalized() == .default)
    }

    @Test("허용 범위를 벗어난 값은 당겨온다")
    func clampsToRanges() {
        let curve = SpeedCurve(base: -100, peak: 99_999, rampDuration: 10).normalized()

        #expect(curve.base == SpeedCurve.baseRange.lowerBound)
        #expect(curve.peak == SpeedCurve.peakRange.upperBound)
        #expect(curve.rampDuration == SpeedCurve.rampDurationRange.upperBound)
    }

    @Test("peak이 base보다 낮으면 base까지 끌어올린다 — 감속하는 곡선은 두지 않는다")
    func peakNeverFallsBelowBase() {
        let curve = SpeedCurve(base: 1200, peak: 400, rampDuration: 0.4).normalized()

        #expect(curve.base == 1200)
        #expect(curve.peak == 1200)
    }
}

struct SpeedCurveAllowedRangeTests {
    private func curve(base: Double, peak: Double) -> SpeedCurve {
        SpeedCurve(base: base, peak: peak, rampDuration: 0.4)
    }

    @Test("base는 peak에서 멈춘다")
    func baseStopsAtPeak() {
        #expect(curve(base: 400, peak: 1000).allowedBaseRange.upperBound == 1000)
    }

    @Test("peak은 base에서 멈춘다")
    func peakStopsAtBase() {
        #expect(curve(base: 1000, peak: 2800).allowedPeakRange.lowerBound == 1000)
    }

    @Test("서로의 벽이 절대 범위를 넘지는 않는다")
    func staysWithinAbsoluteRanges() {
        let wide = curve(base: 100, peak: 6000)
        #expect(wide.allowedBaseRange.upperBound == SpeedCurve.baseRange.upperBound)
        #expect(wide.allowedPeakRange.lowerBound == SpeedCurve.peakRange.lowerBound)

        let narrow = curve(base: 100, peak: 400)
        #expect(narrow.allowedBaseRange.lowerBound == SpeedCurve.baseRange.lowerBound)
        #expect(narrow.allowedPeakRange.upperBound == SpeedCurve.peakRange.upperBound)
    }

    @Test("두 값이 같아도 구간이 뒤집히지 않는다")
    func neverInverts() {
        for speed in [400.0, 1000, 2000] {
            let curve = curve(base: speed, peak: speed)

            #expect(curve.allowedBaseRange.lowerBound <= curve.allowedBaseRange.upperBound)
            #expect(curve.allowedPeakRange.lowerBound <= curve.allowedPeakRange.upperBound)
        }
    }

    @Test("정규화되지 않은 곡선에서도 구간이 뒤집히지 않는다")
    func survivesUnnormalizedInput() {
        for (base, peak) in [(-500.0, -500.0), (9999, 9999), (2000, 400), (100, 99_999)] {
            let curve = curve(base: base, peak: peak)

            #expect(curve.allowedBaseRange.lowerBound <= curve.allowedBaseRange.upperBound)
            #expect(curve.allowedPeakRange.lowerBound <= curve.allowedPeakRange.upperBound)
        }
    }
}
