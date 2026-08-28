import CoreGraphics
import Foundation
import Testing
@testable import PointerCore

@MainActor
struct SpeedStoreTests {
    private let defaults = UserDefaults(suiteName: "SpeedStoreTests")!

    init() {
        defaults.removePersistentDomain(forName: "SpeedStoreTests")
    }

    @Test("저장된 값이 없으면 기본 곡선")
    func fallsBackToDefault() {
        #expect(SpeedStore(defaults: defaults).curve == .default)
    }

    @Test("바꾼 값은 다음 실행에서도 남는다")
    func persistsAcrossInstances() {
        let curve = SpeedCurve(
            base: 800,
            peak: 4000,
            rampDuration: 0.7,
            easing: SpeedEasing(first: CGPoint(x: 0.1, y: 0.6), second: CGPoint(x: 0.4, y: 0.9))
        )
        SpeedStore(defaults: defaults).curve = curve

        #expect(SpeedStore(defaults: defaults).curve == curve)
    }

    @Test("허용 범위를 벗어난 값은 저장 전에 당겨온다")
    func normalizesOnWrite() {
        let settings = SpeedStore(defaults: defaults)
        settings.curve = SpeedCurve(base: -100, peak: 99_999, rampDuration: 10)

        #expect(settings.curve.base == SpeedCurve.baseRange.lowerBound)
        #expect(settings.curve.peak == SpeedCurve.peakRange.upperBound)
        #expect(SpeedStore(defaults: defaults).curve == settings.curve)
    }

    @Test("깨진 저장값은 기본 곡선으로 본다")
    func recoversFromGarbage() {
        defaults.set(Data("not a curve".utf8), forKey: "speedCurve")

        #expect(SpeedStore(defaults: defaults).curve == .default)
    }

    @Test("초기화하면 기본 곡선으로 돌아간다")
    func reset() {
        let settings = SpeedStore(defaults: defaults)
        settings.curve = SpeedCurve(base: 800, peak: 4000, rampDuration: 0.7)

        settings.reset()

        #expect(settings.curve == .default)
        #expect(SpeedStore(defaults: defaults).curve == .default)
    }
}
