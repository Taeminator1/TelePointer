import Testing
@testable import PointerCore

struct RampedSpeedTests {
    private let base = 400.0
    private let peak = 2800.0
    private let rampDuration = 0.4

    private func speed(elapsed: Double, rampDuration: Double? = nil) -> Double {
        rampedSpeed(
            elapsed: elapsed,
            base: base,
            peak: peak,
            rampDuration: rampDuration ?? self.rampDuration
        )
    }

    @Test("누른 직후에는 기본 속도")
    func startsAtBaseSpeed() {
        #expect(speed(elapsed: 0) == base)
    }

    @Test("램프가 끝나면 최고 속도")
    func reachesPeakSpeed() {
        #expect(speed(elapsed: rampDuration) == peak)
    }

    @Test("램프를 넘겨도 최고 속도를 유지한다")
    func staysAtPeakSpeed() {
        #expect(speed(elapsed: 10) == peak)
    }

    @Test("절반 지점에서 25%만 오른다 — 뒤로 갈수록 빨라진다")
    func acceleratesTowardTheEnd() {
        #expect(speed(elapsed: rampDuration / 2) == base + (peak - base) * 0.25)
    }

    @Test("음수 시간은 기본 속도로 본다")
    func negativeElapsed() {
        #expect(speed(elapsed: -1) == base)
    }

    @Test("램프 구간이 없으면 처음부터 최고 속도")
    func zeroRampDuration() {
        #expect(speed(elapsed: 0, rampDuration: 0) == peak)
    }
}
