import CoreGraphics
import Testing
@testable import PointerCore

struct ScreenGeometryTests {

    @Test("주 디스플레이 단독")
    func primaryScreenOnly() {
        let point = warpPoint(
            centerOf: CGRect(x: 0, y: 0, width: 1920, height: 1080),
            primaryScreenHeight: 1080
        )

        #expect(point == CGPoint(x: 960, y: 540))
    }

    @Test("주 디스플레이 위쪽에 붙은 보조 화면")
    func screenAbovePrimary() {
        let point = warpPoint(
            centerOf: CGRect(x: 0, y: 1080, width: 1920, height: 1080),
            primaryScreenHeight: 1080
        )

        #expect(point == CGPoint(x: 960, y: -540))
    }

    @Test("주 디스플레이 아래쪽에 붙은 보조 화면")
    func screenBelowPrimary() {
        let point = warpPoint(
            centerOf: CGRect(x: 0, y: -1080, width: 1920, height: 1080),
            primaryScreenHeight: 1080
        )

        #expect(point == CGPoint(x: 960, y: 1620))
    }

    @Test("주 화면보다 높이가 큰 보조 화면")
    func tallerSecondaryScreen() {
        let point = warpPoint(
            centerOf: CGRect(x: 1920, y: -540, width: 2560, height: 1440),
            primaryScreenHeight: 1080
        )

        #expect(point == CGPoint(x: 3200, y: 900))
    }
}
